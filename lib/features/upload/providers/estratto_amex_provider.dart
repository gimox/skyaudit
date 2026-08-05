import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import 'package:travel_check/features/settings/providers/app_settings_provider.dart';
import '../models/estratto_amex.dart';
import '../models/log_history.dart';
import 'log_history_provider.dart';

class EstrattoAmexNotifier extends Notifier<List<EstrattoAmex>> {
  @override
  List<EstrattoAmex> build() {
    final isar = ref.watch(isarProvider);
    _loadInitialData(isar);
    return [];
  }

  Future<void> _loadInitialData(Isar isar) async {
    final records = await isar.estrattoAmexs.where().anyId().findAll();
    state = records;
  }

  Future<Map<String, dynamic>> loadFromFile(XFile file) async {
    final isar = ref.read(isarProvider);
    final uniqueCode = DateTime.now().millisecondsSinceEpoch.toString();
    final settings = ref.read(appSettingsProvider);

    // Parsing pesante in isolate
    final List<Map<String, dynamic>> parsedData = await compute(
      _parseAmexIsolate,
      {
        'filePath': file.path,
        'uniqueCode': uniqueCode,
        'filterLabel': settings.amexFilterHeaderLabel,
        'filterValue': settings.amexFilterHeaderValue,
      },
    );

    final List<EstrattoAmex> newRecords = parsedData
        .map((map) => EstrattoAmex.fromMap(map))
        .toList();

    if (newRecords.isEmpty) {
      throw Exception('Nessun dato trovato nel file AMEX.');
    }

    await isar.writeTxn(() async {
      await isar.estrattoAmexs.putAll(newRecords);

      final log = LogHistory(
        fileName: file.name,
        date: DateTime.now(),
        uniqueCode: uniqueCode,
        totalRecords: newRecords.length,
        insertedRecords: newRecords.length,
        updatedRecords: 0,
        discardedRecords: 0,
        sourceType: 'Estratto AMEX',
      );
      await isar.logHistorys.put(log);
    });

    final allRecords = await isar.estrattoAmexs.where().anyId().findAll();
    state = allRecords;
    ref.invalidate(logHistoryProvider);

    return {
      'inserted': newRecords.length,
      'updated': 0,
      'duplicates': 0,
      'total': newRecords.length,
      'uniqueCode': uniqueCode,
      'collisions': [], // Per ora vuoto, implementabile se necessario
    };
  }

  Future<void> clear() async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.estrattoAmexs.clear());
    state = [];
  }

  Future<void> deleteRecord(Id id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.estrattoAmexs.delete(id));
    final allRecords = await isar.estrattoAmexs.where().anyId().findAll();
    state = allRecords;
  }
}

Future<List<Map<String, dynamic>>> _parseAmexIsolate(
  Map<String, dynamic> params,
) async {
  final String filePath = params['filePath'];
  final String uniqueCode = params['uniqueCode'];
  final String? filterLabel = params['filterLabel'];
  final String? filterValue = params['filterValue'];

  final bytes = File(filePath).readAsBytesSync();
  final isCsv = filePath.toLowerCase().endsWith('.csv');

  String cleanQuotes(String s) {
    s = s.trim();
    while (s.isNotEmpty && (s.startsWith('"') || s.startsWith("'"))) {
      s = s.substring(1);
    }
    while (s.isNotEmpty && (s.endsWith('"') || s.endsWith("'"))) {
      s = s.substring(0, s.length - 1);
    }
    return s.trim();
  }

  Excel? excel;
  Sheet? sheet;
  List<List<String>> csvRows = [];

  if (isCsv) {
    final csvString = utf8.decode(bytes, allowMalformed: true);
    final lines = csvString.split(RegExp(r'\r?\n'));
    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      final List<String> row = [];
      final StringBuffer sb = StringBuffer();
      bool inQuotes = false;
      for (int i = 0; i < line.length; i++) {
        final char = line[i];
        if (char == '"') {
          inQuotes = !inQuotes;
        } else if (char == ';' && !inQuotes) {
          row.add(cleanQuotes(sb.toString()));
          sb.clear();
        } else {
          sb.write(char);
        }
      }
      row.add(cleanQuotes(sb.toString()));
      csvRows.add(row);
    }
    if (csvRows.isEmpty) return [];
  } else {
    excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) return [];
    final sheetName = excel.tables.keys.first;
    sheet = excel.tables[sheetName];
    if (sheet == null || sheet.maxRows <= 1) return [];
  }

  final List<Map<String, dynamic>> results = [];

  // Analisi delle intestazioni (riga 1) per mappare dinamicamente le colonne
  final List<String> headers = isCsv
      ? csvRows.first
      : sheet!.rows.first.map((cell) => cleanQuotes(cell?.value?.toString() ?? '')).toList();

  String normalize(String val) {
    return cleanQuotes(val)
        .toLowerCase()
        .replaceAll(RegExp(r'<[^>]*>'), '') // Rimuove tag HTML come <br/>
        .replaceAll(RegExp(r'[.\-\s/_°]+'), '') // Rimuove spazi, punteggiatura e gradi/simboli speciali
        .replaceAll('à', 'a')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('ò', 'o')
        .replaceAll('ù', 'u')
        .trim();
  }

  final Map<String, List<String>> fieldToHeaders = {
    'numeroConto': ['numeroconto', 'conto', 'numerodiconto'],
    'conto': ['conto'],
    'identificativoEstrattoConto': ['numerodirifestrattoconto', 'numerorifestrattoconto', 'numerodiriferimentoestrattoconto', 'rifestrattoconto', 'identificativoestrattoconto', 'nidentificativoestrattoconto', 'noidentificativoestrattoconto'],
    'dataEstrattoConto': ['dataestrattoconto'],
    'idTransazione': ['idtransazione', 'identificativotransazione'],
    'dataTransazione': ['datatransazione', 'dataprocessazione', 'datadiprocessazione'],
    'dataScadenzaPagamento': ['datascadenzapagamento', 'datascadenza', 'datadiscadenzadelpagamento'],
    'dataProcessazione': ['dataprocessazione', 'datadiprocessazione'],
    'stato': ['stato'],
    'contestata': ['contestata', 'codicecontestazione'],
    'numeroBollaFattura': ['numerobollafattura', 'numerobolla', 'numerofattura', 'nrbollafattura'],
    'fatturaAgenziaViaggio': ['fatturaagenziaviaggio', 'fatturaagenzia', 'fattura', 'fatturadellaagenziadiviaggio', 'fatturaagenziadiviaggio'],
    'indicator': ['indicator', 'indicatore'],
    'nomeViaggiatore': ['nomeviaggiatore', 'viaggiatore'],
    'aeroportoDestinazione': ['aeroportodestinazione', 'aeroportodidestinazione', 'destinazione'],
    'aeroportoPartenza': ['aeroportopartenza', 'aeroportodipartenza', 'partenza'],
    'dataPartenza': ['datapartenza', 'datadipartenza'],
    'importoLordo': ['importolordo', 'lordo', 'importo'],
    'importoAllocato': ['importoallocato'],
    'importoNonAllocato': ['importononallocato'],
    'importoNetto': ['importonetto', 'netto'],
    'totaleImportoTasse': ['totaleimportotasse', 'tasse', 'tassaaeroportuale'],
    'valuta': ['valuta', 'valutatransazione'],
    'riferimentoEstrattoConto': ['riferimentoestrattoconto', 'rifestrattoconto'],
    'rifPagamentoEstrattoConto': ['rifpagamentoestrattoconto', 'nriferimentopagamentoestrattoconto', 'noriferimentopagamentoestrattoconto'],
    'debitCreditCode': ['debitcreditcode', 'indicatoredebitocreditodrcr', 'indicatoredebitocredito', 'drcr'],
    'agenziaViaggi': ['agenziaviaggi', 'agenziadiviaggi'],
    'ufficioViaggi': ['ufficioviaggi', 'ufficiodiviaggi'],
    'rif1': ['rif1', 'cid', 'matricola'],
    'rif2': ['rif2', 'centrodicosto'],
    'rif3': ['rif3', 'nrtrasferta', 'numerotrasferta', 'idtrasferta'],
    'rif4': ['rif4'],
    'rif5': ['rif5', 'bollaoriginale', 'bolla'],
    'rif6': ['rif6'],
    'rif7': ['rif7'],
    'pnrNo': ['pnrno', 'pnr', 'pnrnumber'],
    'rifViaggio1': ['rifviaggio1'],
    'rifViaggio2': ['rifviaggio2'],
    'rifViaggio3': ['rifviaggio3'],
    'rifViaggio4': ['rifviaggio4'],
    'nomeEsercizio': ['nomeesercizio', 'nomeesercizioconvenzionato', 'esercizio'],
    'tassoCambio': ['tassocambio', 'tassodicambio', 'cambio'],
    'allocazionePagamento': ['allocazionepagamento'],
    'valutaTransazione': ['valutatransazione'],
    'codiceMercato': ['codicemercato'],
    'rifEstrattoContoCarta': ['rifestrattocontocarta'],
    'codiceVettore': ['codicevettore'],
    'codiceSettore': ['codicesettore'],
    'inizialiPasseggero': ['inizialipasseggero', 'inizialiviaggiatore', 'inizialiviaggiatorei', 'inizialipasseggeroi'],
    'numeroContoSE': ['numerocontose', 'numerodicontose'],
    'cittaSE': ['cittase'],
    'codiceSettoreSE': ['codicesettorese'],
    'numFatturaSEOriginale': ['numerodellafatturaseoriginale', 'numerofatturaseoriginale', 'numfatturaseoriginale'],
    'numFatturaSE': ['numerofatturase', 'numfatturase'],
    'codiceTipoTransazione': ['codicetipotransazione', 'codicetipoditransazione'],
    'nomeFornitore': ['nomefornitore', 'fornitore'],
    'idRegione': ['idregione', 'regione'],
    'statoRichiesta': ['statorichiesta'],
    'dataAperturaRichiesta': ['dataaperturarichiesta', 'datadiaperturadellarichiesta', 'datadiaperturedellarichiesta'],
    'dataChiusuraRichiesta': ['datachiusurarichiesta', 'datadichiusuradellarichiesta', 'datadichiususradellarichiesta'],
    'inoltrare': ['inoltrare'],
    'vettore': ['vettore'],
    'classeViaggio': ['classeviaggio', 'classediviaggio'],
    'ordine': ['ordine'],
  };

  final Map<String, int> fieldToColIndex = {};
  fieldToHeaders.forEach((field, normalizedLabels) {
    for (int col = 0; col < headers.length; col++) {
      final normHeader = normalize(headers[col]);
      if (normalizedLabels.contains(normHeader)) {
        fieldToColIndex[field] = col;
        break;
      }
    }
  });

  // Trova indice colonna per filtro Amex
  int? amexFilterColIndex;
  final String activeLabel = (filterLabel == null || filterLabel.trim().isEmpty) ? 'Categ. transazione' : filterLabel;
  final String activeValue = (filterValue == null || filterValue.trim().isEmpty) ? 'Nuovi addebiti' : filterValue;

  for (int col = 0; col < headers.length; col++) {
    if (headers[col].trim().toLowerCase() == activeLabel.trim().toLowerCase()) {
      amexFilterColIndex = col;
      break;
    }
  }

  final bool hasHeaders = fieldToColIndex.isNotEmpty;

  int? getIndex(String field, int defaultIndex) {
    if (hasHeaders) {
      return fieldToColIndex[field];
    } else {
      return defaultIndex;
    }
  }

  final int totalRows = isCsv ? csvRows.length : sheet!.rows.length;

  for (int rowIndex = 1; rowIndex < totalRows; rowIndex++) {
    if (!isCsv && rowIndex >= sheet!.rows.length) continue;
    final excelRow = isCsv ? null : sheet!.rows[rowIndex];
    final csvRow = isCsv ? csvRows[rowIndex] : null;

    if (!isCsv && excelRow == null) continue;
    if (isCsv && csvRow == null) continue;
    if (!isCsv && excelRow!.isEmpty) continue;
    if (isCsv && csvRow!.isEmpty) continue;

    String val(int? index) {
      if (isCsv) {
        if (index == null || index < 0 || index >= csvRow!.length) return '';
        return csvRow[index];
      } else {
        if (index == null || index < 0 || index >= excelRow!.length) return '';
        final cell = excelRow[index];
        if (cell == null || cell.value == null) return '';
        return cleanQuotes(cell.value.toString());
      }
    }

    double dVal(int? index) {
      if (isCsv) {
        if (index == null || index < 0 || index >= csvRow!.length) return 0.0;
        String s = csvRow[index].replaceAll(' ', '');
        if (s.isEmpty) return 0.0;

        if (s.contains('.') && s.contains(',')) {
          final dotIndex = s.indexOf('.');
          final commaIndex = s.indexOf(',');
          if (dotIndex < commaIndex) {
            s = s.replaceAll('.', '').replaceAll(',', '.');
          } else {
            s = s.replaceAll(',', '');
          }
        } else if (s.contains(',')) {
          s = s.replaceAll(',', '.');
        }

        return double.tryParse(s) ?? 0.0;
      } else {
        if (index == null || index < 0 || index >= excelRow!.length) return 0.0;
        final cell = excelRow[index];
        if (cell == null || cell.value == null) return 0.0;

        final val = cell.value;
        if (val is DoubleCellValue) return val.value;
        if (val is IntCellValue) return val.value.toDouble();

        String s = cleanQuotes(val.toString()).replaceAll(' ', '');
        if (s.isEmpty) return 0.0;

        if (s.contains('.') && s.contains(',')) {
          final dotIndex = s.indexOf('.');
          final commaIndex = s.indexOf(',');
          if (dotIndex < commaIndex) {
            s = s.replaceAll('.', '').replaceAll(',', '.');
          } else {
            s = s.replaceAll(',', '');
          }
        } else if (s.contains(',')) {
          s = s.replaceAll(',', '.');
        }

        return double.tryParse(s) ?? 0.0;
      }
    }

    if (amexFilterColIndex != null) {
      final actualVal = val(amexFilterColIndex).trim();
      if (actualVal.toLowerCase() != activeValue.trim().toLowerCase()) {
        continue; // Scarta la riga se non corrisponde
      }
    }

    final rif5Raw = val(getIndex('rif5', 36)); // AK (Rif 5)
    String bollaCalc = rif5Raw;

    // Logica bolla: se in terza posizione c'è '/', trasforma. Altrimenti lascia com'è.
    if (rif5Raw.length >= 3 && rif5Raw[2] == '/') {
      bollaCalc = '${rif5Raw.substring(0, 2)}0${rif5Raw.substring(3)}';
      bollaCalc = bollaCalc.padRight(12, '0');
    }

    results.add({
      'cid': val(getIndex('rif1', 28)).isNotEmpty ? val(getIndex('rif1', 28)).padLeft(8, '0') : '', // AC (Rif 1)
      'numeroTrasferta': val(getIndex('rif3', 30)), // AE (Rif 3)
      'bolla': bollaCalc,
      'bollaOriginale': rif5Raw,
      'numeroConto': val(getIndex('numeroConto', 0)), // A
      'conto': val(getIndex('conto', 1)), // B
      'identificativoEstrattoConto': val(getIndex('identificativoEstrattoConto', 2)), // C
      'dataEstrattoConto': val(getIndex('dataEstrattoConto', 3)), // D
      'idTransazione': val(getIndex('idTransazione', 4)), // E
      'dataTransazione': val(getIndex('dataTransazione', 5)), // F
      'dataScadenzaPagamento': val(getIndex('dataScadenzaPagamento', 6)), // G
      'dataProcessazione': val(getIndex('dataProcessazione', 7)), // H
      'stato': val(getIndex('stato', 8)), // I
      'contestata': val(getIndex('contestata', 9)), // J
      'numeroBollaFattura': val(getIndex('numeroBollaFattura', 10)), // K
      'fatturaAgenziaViaggio': val(getIndex('fatturaAgenziaViaggio', 11)), // L
      'indicator': val(getIndex('indicator', 12)), // M
      'nomeViaggiatore': val(getIndex('nomeViaggiatore', 13)), // N
      'aeroportoDestinazione': val(getIndex('aeroportoDestinazione', 14)), // O
      'aeroportoPartenza': val(getIndex('aeroportoPartenza', 15)), // P
      'dataPartenza': val(getIndex('dataPartenza', 16)), // Q
      'importoLordo': dVal(getIndex('importoLordo', 17)), // R
      'importoAllocato': dVal(getIndex('importoAllocato', 18)), // S
      'importoNonAllocato': dVal(getIndex('importoNonAllocato', 19)), // T
      'importoNetto': dVal(getIndex('importoNetto', 20)), // U
      'totaleImportoTasse': dVal(getIndex('totaleImportoTasse', 21)), // V
      'valuta': val(getIndex('valuta', 22)), // W
      'riferimentoEstrattoConto': val(getIndex('riferimentoEstrattoConto', 23)), // X
      'rifPagamentoEstrattoConto': val(getIndex('rifPagamentoEstrattoConto', 24)), // Y
      'debitCreditCode': val(getIndex('debitCreditCode', 25)), // Z
      'agenziaViaggi': val(getIndex('agenziaViaggi', 26)), // AA
      'ufficioViaggi': val(getIndex('ufficioViaggi', 27)), // AB
      'rif1': val(getIndex('rif1', 28)), // AC
      'rif2': val(getIndex('rif2', 29)), // AD
      'rif3': val(getIndex('rif3', 30)), // AE
      'rif4': val(getIndex('rif4', 35)), // AJ (Rif 4)
      'rif5': val(getIndex('rif5', 36)), // AK (Rif 5)
      'rif6': val(getIndex('rif6', 37)), // AL (Rif 6)
      'rif7': val(getIndex('rif7', 38)), // AM (Rif 7)
      'pnrNo': val(getIndex('pnrNo', 39)), // AN
      'rifViaggio1': val(getIndex('rifViaggio1', 40)), // AO
      'rifViaggio2': val(getIndex('rifViaggio2', 41)), // AP
      'rifViaggio3': val(getIndex('rifViaggio3', 42)), // AQ
      'rifViaggio4': val(getIndex('rifViaggio4', 43)), // AR
      'nomeEsercizio': val(getIndex('nomeEsercizio', 44)), // AS
      'tassoCambio': val(getIndex('tassoCambio', 45)), // AT
      'allocazionePagamento': val(getIndex('allocazionePagamento', 46)), // AU
      'valutaTransazione': val(getIndex('valutaTransazione', 47)), // AV
      'codiceMercato': val(getIndex('codiceMercato', 48)), // AW
      'rifEstrattoContoCarta': val(getIndex('rifEstrattoContoCarta', 49)), // AX
      'codiceVettore': val(getIndex('codiceVettore', 50)), // AY
      'codiceSettore': val(getIndex('codiceSettore', 51)), // AZ
      'inizialiPasseggero': val(getIndex('inizialiPasseggero', 52)), // BA
      'numeroContoSE': val(getIndex('numeroContoSE', 53)), // BB
      'cittaSE': val(getIndex('cittaSE', 54)), // BC
      'codiceSettoreSE': val(getIndex('codiceSettoreSE', 55)), // BD
      'numFatturaSEOriginale': val(getIndex('numFatturaSEOriginale', 56)), // BE
      'numFatturaSE': val(getIndex('numFatturaSE', 57)), // BF
      'codiceTipoTransazione': val(getIndex('codiceTipoTransazione', 58)), // BG
      'nomeFornitore': val(getIndex('nomeFornitore', 59)), // BH
      'idRegione': val(getIndex('idRegione', 60)), // BI
      'statoRichiesta': val(getIndex('statoRichiesta', 61)), // BJ
      'dataAperturaRichiesta': val(getIndex('dataAperturaRichiesta', 62)), // BK
      'dataChiusuraRichiesta': val(getIndex('dataChiusuraRichiesta', 63)), // BL
      'inoltrare': val(getIndex('inoltrare', 64)), // BM
      'vettore': val(getIndex('vettore', 65)), // BN
      'classeViaggio': val(getIndex('classeViaggio', 66)), // BO
      'ordine': val(getIndex('ordine', 67)), // BP
      'logHistoryId': uniqueCode,
      'sourceFileLine': rowIndex,
    });
  }

  return results;
}

final estrattoAmexProvider =
    NotifierProvider<EstrattoAmexNotifier, List<EstrattoAmex>>(() {
      return EstrattoAmexNotifier();
    });
