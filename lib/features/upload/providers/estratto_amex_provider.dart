import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/estratto_amex.dart';
import '../models/log_history.dart';
import 'log_history_provider.dart';

class EstrattoAmexNotifier extends Notifier<List<EstrattoAmex>> {
  @override
  List<EstrattoAmex> build() {
    final isar = ref.watch(isarProvider);
    return isar.estrattoAmexs.where().anyId().findAllSync();
  }

  Future<Map<String, dynamic>> loadFromFile(XFile file) async {
    final isar = ref.read(isarProvider);
    final uniqueCode = DateTime.now().millisecondsSinceEpoch.toString();

    // Parsing pesante in isolate
    final List<Map<String, dynamic>> parsedData = await compute(
      _parseAmexIsolate,
      {'filePath': file.path, 'uniqueCode': uniqueCode},
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

  final bytes = File(filePath).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  if (excel.tables.isEmpty) return [];

  // Usiamo il primo foglio come da file AMEX
  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName]!;
  final List<Map<String, dynamic>> results = [];

  if (sheet.maxRows <= 1) return [];

  // Saltiamo la prima riga (intestazione)
  int rowIndex = 0;
  for (final row in sheet.rows) {
    rowIndex++;
    if (rowIndex == 1) continue; // Salta intestazione
    if (row.isEmpty) continue;

    String val(int index) {
      if (index < 0 || index >= row.length) return '';
      final cell = row[index];
      if (cell == null || cell.value == null) return '';
      return cell.value.toString().trim();
    }

    double dVal(int index) {
      if (index < 0 || index >= row.length) return 0.0;
      final cell = row[index];
      if (cell == null || cell.value == null) return 0.0;

      final val = cell.value;
      if (val is DoubleCellValue) return val.value;
      if (val is IntCellValue) return val.value.toDouble();

      String s = val.toString().replaceAll(' ', '').trim();
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

    final rif5Raw = val(36); // AK (Rif 5)
    String bollaCalc = rif5Raw;

    // Logica bolla: se in terza posizione c'è '/', trasforma. Altrimenti lascia com'è.
    if (rif5Raw.length >= 3 && rif5Raw[2] == '/') {
      bollaCalc = '${rif5Raw.substring(0, 2)}0${rif5Raw.substring(3)}';
      bollaCalc = bollaCalc.padRight(12, '0');
    }

    results.add({
      'cid': val(28).isNotEmpty ? val(28).padLeft(8, '0') : '', // AC (Rif 1)
      'numeroTrasferta': val(30), // AE (Rif 3)
      'bolla': bollaCalc,
      'bollaOriginale': rif5Raw,
      'numeroConto': val(0), // A
      'conto': val(1), // B
      'identificativoEstrattoConto': val(2), // C
      'dataEstrattoConto': val(3), // D
      'idTransazione': val(4), // E
      'dataTransazione': val(5), // F
      'dataScadenzaPagamento': val(6), // G
      'dataProcessazione': val(7), // H
      'stato': val(8), // I
      'contestata': val(9), // J
      'numeroBollaFattura': val(10), // K
      'fatturaAgenziaViaggio': val(11), // L
      'indicator': val(12), // M
      'nomeViaggiatore': val(13), // N
      'aeroportoDestinazione': val(14), // O
      'aeroportoPartenza': val(15), // P
      'dataPartenza': val(16), // Q
      'importoLordo': dVal(17), // R
      'importoAllocato': dVal(18), // S
      'importoNonAllocato': dVal(19), // T
      'importoNetto': dVal(20), // U
      'totaleImportoTasse': dVal(21), // V
      'valuta': val(22), // W
      'riferimentoEstrattoConto': val(23), // X
      'rifPagamentoEstrattoConto': val(24), // Y
      'debitCreditCode': val(25), // Z
      'agenziaViaggi': val(26), // AA
      'ufficioViaggi': val(27), // AB
      'rif1': val(28), // AC
      'rif2': val(29), // AD
      'rif3': val(30), // AE
      'rif4': val(35), // AJ (Rif 4)
      'rif5': val(36), // AK (Rif 5)
      'rif6': val(37), // AL (Rif 6)
      'rif7': val(38), // AM (Rif 7)
      'pnrNo': val(39), // AN
      'rifViaggio1': val(40), // AO
      'rifViaggio2': val(41), // AP
      'rifViaggio3': val(42), // AQ
      'rifViaggio4': val(43), // AR
      'nomeEsercizio': val(44), // AS
      'tassoCambio': val(45), // AT
      'allocazionePagamento': val(46), // AU
      'valutaTransazione': val(47), // AV
      'codiceMercato': val(48), // AW
      'rifEstrattoContoCarta': val(49), // AX
      'codiceVettore': val(50), // AY
      'codiceSettore': val(51), // AZ
      'inizialiPasseggero': val(52), // BA
      'numeroContoSE': val(53), // BB
      'cittaSE': val(54), // BC
      'codiceSettoreSE': val(55), // BD
      'numFatturaSEOriginale': val(56), // BE
      'numFatturaSE': val(57), // BF
      'codiceTipoTransazione': val(58), // BG
      'nomeFornitore': val(59), // BH
      'idRegione': val(60), // BI
      'statoRichiesta': val(61), // BJ
      'dataAperturaRichiesta': val(62), // BK
      'dataChiusuraRichiesta': val(63), // BL
      'inoltrare': val(64), // BM
      'vettore': val(65), // BN
      'classeViaggio': val(66), // BO
      'ordine': val(67), // BP
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
