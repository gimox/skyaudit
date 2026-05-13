import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:excel2003/excel2003.dart';
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
    final List<Map<String, dynamic>> parsedData = await compute(_parseAmexIsolate, {
      'filePath': file.path,
      'uniqueCode': uniqueCode,
    });

    final List<EstrattoAmex> newRecords = parsedData.map((map) => EstrattoAmex.fromMap(map)).toList();

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

Future<List<Map<String, dynamic>>> _parseAmexIsolate(Map<String, dynamic> params) async {
  final String filePath = params['filePath'];
  final String uniqueCode = params['uniqueCode'];
  
  final bytes = File(filePath).readAsBytesSync();
  final excel = XlsReader.fromBytes(bytes);

  if (excel.sheetCount == 0) return [];

  // Usiamo il primo foglio come da file AMEX
  final sheet = excel.sheet(0);
  final List<Map<String, dynamic>> results = [];

  // Saltiamo la prima riga (intestazione)
  for (var i = 1; i < sheet.lastRow; i++) {
    final row = sheet.row(i);
    if (row.isEmpty) continue;

    String val(int index) {
      if (index >= row.length) return '';
      final cell = row[index];
      if (cell == null) return '';
      return cell.toString().trim();
    }

    double dVal(int index) {
      if (index >= row.length) return 0.0;
      final cell = row[index];
      if (cell == null) return 0.0;
      if (cell is num) return cell.toDouble();
      return double.tryParse(cell.toString().replaceAll(',', '.')) ?? 0.0;
    }

    final rif5Raw = val(32); // AG
    String bollaCalc = rif5Raw;
    
    // Logica bolla: se in terza posizione c'è '/', trasforma. Altrimenti lascia com'è.
    if (rif5Raw.length >= 3 && rif5Raw[2] == '/') {
      bollaCalc = '${rif5Raw.substring(0, 2)}0${rif5Raw.substring(3)}';
      bollaCalc = bollaCalc.padRight(12, '0');
    }

    results.add({
      'cid': val(28), // AC (Rif 1)
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
      'rif4': val(31), // AF
      'rif5': val(32), // AG
      'rif6': val(33), // AH
      'rif7': val(34), // AI
      'pnrNo': val(35), // AJ
      'rifViaggio1': val(36), // AK
      'rifViaggio2': val(37), // AL
      'rifViaggio3': val(38), // AM
      'rifViaggio4': val(39), // AN
      'nomeEsercizio': val(40), // AO
      'tassoCambio': val(41), // AP
      'allocazionePagamento': val(42), // AQ
      'valutaTransazione': val(43), // AR
      'codiceMercato': val(44), // AS
      'rifEstrattoContoCarta': val(45), // AT
      'codiceVettore': val(46), // AU
      'codiceSettore': val(47), // AV
      'inizialiPasseggero': val(48), // AW
      'numeroContoSE': val(49), // AX
      'cittaSE': val(50), // AY
      'codiceSettoreSE': val(51), // AZ
      'numFatturaSEOriginale': val(52), // BA
      'numFatturaSE': val(53), // BB
      'codiceTipoTransazione': val(54), // BC
      'nomeFornitore': val(55), // BD
      'idRegione': val(56), // BE
      'statoRichiesta': val(57), // BF
      'dataAperturaRichiesta': val(58), // BG
      'dataChiusuraRichiesta': val(59), // BH
      'inoltrare': val(60), // BI
      'vettore': val(61), // BJ
      'classeViaggio': val(62), // BK
      'ordine': val(63), // BL
      'logHistoryId': uniqueCode,
      'sourceFileLine': i + 1,
    });
  }

  return results;
}

final estrattoAmexProvider = NotifierProvider<EstrattoAmexNotifier, List<EstrattoAmex>>(() {
  return EstrattoAmexNotifier();
});
