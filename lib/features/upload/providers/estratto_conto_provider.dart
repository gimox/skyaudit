import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/estratto_conto.dart';
import '../models/log_history.dart';
import 'log_history_provider.dart';

class EstrattoContoNotifier extends Notifier<List<EstrattoConto>> {
  @override
  List<EstrattoConto> build() {
    final isar = ref.watch(isarProvider);
    return isar.estrattoContos.where().anyId().findAllSync();
  }

  Future<Map<String, dynamic>> loadFromFile(XFile file) async {
    final isar = ref.read(isarProvider);
    
    final uniqueCode = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Eseguiamo il parsing pesante in un isolate separato per non bloccare la UI
    final List<Map<String, dynamic>> parsedData = await compute(_parseExcelIsolate, file.path);

    final List<EstrattoConto> newRecords = parsedData.map((map) => EstrattoConto.fromMap(map)).toList();

    if (newRecords.isEmpty) {
      throw Exception('Nessun dato trovato.');
    }

    // Identifichiamo i record da salvare (tutti quelli nel file)
    final List<EstrattoConto> recordsToSave = List.from(newRecords);
    
    int insertedCount = recordsToSave.length;
    int updatedCount = 0;
    const totalDiscarded = 0;

    await isar.writeTxn(() async {
      // Salva tutto come nuovi record
      await isar.estrattoContos.putAll(recordsToSave);

      final logWithStats = LogHistory(
        fileName: file.name,
        date: DateTime.now(),
        uniqueCode: uniqueCode,
        totalRecords: newRecords.length,
        insertedRecords: insertedCount,
        updatedRecords: updatedCount,
        discardedRecords: totalDiscarded,
      );
      await isar.logHistorys.put(logWithStats);
    });

    // Aggiorniamo lo stato in modo asincrono
    final allRecords = await isar.estrattoContos.where().anyId().findAll();
    state = allRecords;

    // Invalidate LogHistory provider to update its UI
    ref.invalidate(logHistoryProvider);

    return {
      'inserted': insertedCount, 
      'updated': updatedCount,
      'duplicates': totalDiscarded,
      'total': newRecords.length,
      'updatedRecords': [],
      'discardedRecords': [],
    };
  }

  Future<void> clear() async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.estrattoContos.clear());
    state = [];
  }

  Future<void> deleteRecord(Id id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.estrattoContos.delete(id));
    final allRecords = await isar.estrattoContos.where().anyId().findAll();
    state = allRecords;
  }
}

// Funzione top-level per l'isolate
Future<List<Map<String, dynamic>>> _parseExcelIsolate(String filePath) async {
  final bytes = File(filePath).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  final List<Map<String, dynamic>> results = [];

  String? documentSheetName;
  for (var name in excel.tables.keys) {
    if (name.toLowerCase() == 'document') {
      documentSheetName = name;
      break;
    }
  }

  if (documentSheetName == null) {
    throw Exception('Foglio "Document" non trovato.');
  }

  final sheet = excel.tables[documentSheetName]!;

  for (var i = 1; i < sheet.maxRows; i++) {
    final row = sheet.rows[i];
    if (row.isEmpty) continue;

    String val(int index) {
      if (index >= row.length) return '';
      final cell = row[index];
      if (cell == null || cell.value == null) return '';
      final v = cell.value;
      if (v is TextCellValue) return v.value.toString().trim();
      return v.toString().trim();
    }

    double dVal(int index) {
      if (index >= row.length) return 0.0;
      final cell = row[index];
      if (cell == null || cell.value == null) return 0.0;
      final v = cell.value;
      if (v is DoubleCellValue) return v.value;
      if (v is IntCellValue) return v.value.toDouble();
      if (v is TextCellValue) {
        return double.tryParse(v.value.toString().replaceAll(',', '.')) ?? 0.0;
      }
      return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0.0;
    }

    final nrBollaRaw = val(1);
    String bollaCalc = '';
    if (nrBollaRaw.isNotEmpty) {
      bollaCalc = nrBollaRaw;
      if (bollaCalc.length >= 3 && bollaCalc[2] == '/') {
        bollaCalc = '${bollaCalc.substring(0, 2)}0${bollaCalc.substring(3)}';
      }
      bollaCalc = bollaCalc.padRight(12, '0');
    }

    results.add({
      'nrEstrattoConto': val(0),
      'nrBolla': nrBollaRaw,
      'bolla': bollaCalc,
      'dataBolla': val(2),
      'dataCompetenza': val(3),
      'codiceCliente': val(4),
      'ragioneSociale': val(5),
      'tipoTransazione': val(6),
      'tipoServizio': val(7),
      'descrizioneServizio': val(8),
      'itinerario': val(9),
      'fornitore': val(10),
      'codiceViaggio': val(11),
      'nrPax': val(12),
      'nrTktBolla': val(13),
      'nomePasseggero': val(14),
      'metPagamentoServ': val(15),
      'metPagamentoFee': val(16),
      'importoServizio': dVal(17),
      'tasse': dVal(18),
      'fee': dVal(19),
      'codiceIva': val(20),
      'importoIvaServizio': dVal(21),
      'importoIvaTasse': dVal(22),
      'importoIvaFee': dVal(23),
      'totaleServizio': dVal(26),
      'totaleTasse': dVal(25),
      'totaleServizioGenerale': dVal(24),
      'totaleFee': dVal(27),
      'dataIn': val(28),
      'dataOut': val(29),
      'localitaPartenza': val(30),
      'localitaArrivo': val(31),
      'codiceTrattamento': val(32),
      'codiceSistemazione': val(33),
      'richiedente': val(34),
      'cid': val(35),
      'centroCosto': val(36),
      'numeroTrasferta': val(37),
      'campoStatistico4': val(38),
      'rigaCrm': val(39),
      'sapNoSap': val(40),
      'campoStatistico7': val(41),
      'campoStatistico8': val(42),
      'campoStatistico9': val(43),
      'campoStatistico10': val(44),
      'numeroCCServizio': val(45),
      'numeroCCFee': val(46),
      'numeroDocumServizio': val(47),
      'numeroDocumFee': val(48),
      'nrNotti': val(49),
      'segueFatturaServizi': val(50),
      'servizioDaPagare': val(51),
      'merchantFee': dVal(52),
      'descrizioneSpedireA': val(53),
      'descrizioneRighePratiche': val(54),
      'sourceFileLine': i + 1, // Excel row number
    });
  }

  return results;
}

final estrattoContoProvider =
    NotifierProvider<EstrattoContoNotifier, List<EstrattoConto>>(() {
      return EstrattoContoNotifier();
    });
