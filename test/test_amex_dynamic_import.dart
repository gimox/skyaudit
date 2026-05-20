import 'dart:io';
import 'package:excel/excel.dart';

void main() async {
  print('=== STARTING AMEX DYNAMIC IMPORT VERIFICATION ===');
  
  final file1 = File('data_mock/EC - AMEX Gruppo/amex Gruppo/2026_03_26_OS-5001-001_STATEMENT_860896414 - SPARKLE.xlsx');
  final file2 = File('data_mock/EC - AMEX TIM/amex TIM/DICEMBRE AMEX.xlsx');

  if (!file1.existsSync()) {
    print('Error: file1 does not exist at ${file1.path}');
    return;
  }
  if (!file2.existsSync()) {
    print('Error: file2 does not exist at ${file2.path}');
    return;
  }

  print('\n--- Testing File 1: ${file1.path} ---');
  final results1 = parseAmex(file1.path);
  print('Parsed ${results1.length} records.');
  
  int nonEcid1 = 0;
  for (var r in results1) {
    if (r['cid'].isNotEmpty) {
      nonEcid1++;
    }
  }
  print('Records with non-empty CID: $nonEcid1');
  
  print('\nFirst 5 Records:');
  for (int i = 0; i < 5 && i < results1.length; i++) {
    final r = results1[i];
    print('Record $i:');
    print('  CID: "${r['cid']}"');
    print('  Numero Trasferta: "${r['numeroTrasferta']}"');
    print('  Bolla: "${r['bolla']}"');
    print('  Importo Lordo: ${r['importoLordo']}');
    print('  Nome Viaggiatore: "${r['nomeViaggiatore']}"');
  }

  print('\n--- Testing File 2: ${file2.path} ---');
  final results2 = parseAmex(file2.path);
  print('Parsed ${results2.length} records.');
  
  int nonEcid2 = 0;
  for (var r in results2) {
    if (r['cid'].isNotEmpty) {
      nonEcid2++;
    }
  }
  print('Records with non-empty CID: $nonEcid2');

  print('\nFirst 5 Records:');
  for (int i = 0; i < 5 && i < results2.length; i++) {
    final r = results2[i];
    print('Record $i:');
    print('  CID: "${r['cid']}"');
    print('  Numero Trasferta: "${r['numeroTrasferta']}"');
    print('  Bolla: "${r['bolla']}"');
    print('  Importo Lordo: ${r['importoLordo']}');
    print('  Nome Viaggiatore: "${r['nomeViaggiatore']}"');
  }

  print('\n=== VERIFICATION COMPLETED ===');
}

List<Map<String, dynamic>> parseAmex(String filePath) {
  final bytes = File(filePath).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  if (excel.tables.isEmpty) return [];

  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName]!;
  final List<Map<String, dynamic>> results = [];

  if (sheet.maxRows <= 1) return [];

  // Analisi delle intestazioni (riga 1) per mappare dinamicamente le colonne
  final headerRow = sheet.rows.first;
  final List<String> headers = headerRow.map((cell) => cell?.value?.toString().trim() ?? '').toList();

  String normalize(String val) {
    return val.toLowerCase()
        .replaceAll(RegExp(r'[.\-\s/_]+'), '')
        .replaceAll('à', 'a')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('ò', 'o')
        .replaceAll('ù', 'u')
        .trim();
  }

  final Map<String, List<String>> fieldToHeaders = {
    'numeroConto': ['numeroconto', 'conto'],
    'conto': ['conto'],
    'identificativoEstrattoConto': ['numerodirifestrattoconto', 'rifestrattoconto', 'identificativoestrattoconto'],
    'dataEstrattoConto': ['dataestrattoconto'],
    'idTransazione': ['idtransazione', 'identificativotransazione'],
    'dataTransazione': ['datatransazione', 'dataprocessazione', 'datadiprocessazione'],
    'dataScadenzaPagamento': ['datascadenzapagamento', 'datascadenza'],
    'dataProcessazione': ['dataprocessazione', 'datadiprocessazione'],
    'stato': ['stato'],
    'contestata': ['contestata', 'codicecontestazione'],
    'numeroBollaFattura': ['numerobollafattura', 'numerobolla', 'numerofattura', 'nrbollafattura'],
    'fatturaAgenziaViaggio': ['fatturaagenziaviaggio', 'fatturaagenzia', 'fattura'],
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
    'rifPagamentoEstrattoConto': ['rifpagamentoestrattoconto'],
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
    'inizialiPasseggero': ['inizialipasseggero', 'inizialiviaggiatore', 'inizialiviaggiatorei'],
    'numeroContoSE': ['numerocontose', 'numerodicontose'],
    'cittaSE': ['cittase'],
    'codiceSettoreSE': ['codicesettorese'],
    'numFatturaSEOriginale': ['numerodellafatturaseoriginale', 'numerofatturaseoriginale', 'numfatturaseoriginale'],
    'numFatturaSE': ['numerofatturase', 'numfatturase'],
    'codiceTipoTransazione': ['codicetipotransazione', 'codicetipoditransazione'],
    'nomeFornitore': ['nomefornitore', 'fornitore'],
    'idRegione': ['idregione', 'regione'],
    'statoRichiesta': ['statorichiesta'],
    'dataAperturaRichiesta': ['dataaperturarichiesta', 'datadiaperturadellarichiesta'],
    'dataChiusuraRichiesta': ['datachiusurarichiesta', 'datadichiusuradellarichiesta'],
    'inoltrare': ['inoltrare'],
    'vettore': ['vettore'],
    'classeViaggio': ['classeviaggio'],
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

  final bool hasHeaders = fieldToColIndex.isNotEmpty;

  int? getIndex(String field, int defaultIndex) {
    if (hasHeaders) {
      return fieldToColIndex[field];
    } else {
      return defaultIndex;
    }
  }

  int rowIndex = 0;
  for (final row in sheet.rows) {
    rowIndex++;
    if (rowIndex == 1) continue; // Salta intestazione
    if (row.isEmpty) continue;

    String val(int? index) {
      if (index == null || index < 0 || index >= row.length) return '';
      final cell = row[index];
      if (cell == null || cell.value == null) return '';
      String s = cell.value.toString().trim();
      if (s.startsWith("'")) {
        s = s.substring(1);
      }
      if (s.endsWith("'")) {
        s = s.substring(0, s.length - 1);
      }
      return s.trim();
    }

    double dVal(int? index) {
      if (index == null || index < 0 || index >= row.length) return 0.0;
      final cell = row[index];
      if (cell == null || cell.value == null) return 0.0;

      final val = cell.value;
      if (val is DoubleCellValue) return val.value;
      if (val is IntCellValue) return val.value.toDouble();

      String s = val.toString().replaceAll(' ', '').trim();
      if (s.startsWith("'")) {
        s = s.substring(1);
      }
      if (s.endsWith("'")) {
        s = s.substring(0, s.length - 1);
      }
      s = s.trim();
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

    final rif5Raw = val(getIndex('rif5', 36)); // AK (Rif 5)
    String bollaCalc = rif5Raw;

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
      'logHistoryId': 'test',
      'sourceFileLine': rowIndex,
    });
  }
  return results;
}
