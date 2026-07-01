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
    final List<Map<String, dynamic>> parsedData = await compute(_parseExcelIsolate, {
      'filePath': file.path,
      'uniqueCode': uniqueCode,
    });

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
        sourceType: 'Estratto Conto',
      );
      await isar.logHistorys.put(logWithStats);
    });

    // --- LOGICA DI CONTROLLO BOLLE DUPLICATE ---
    final List<Map<String, dynamic>> collisions = [];
    
    // Recuperiamo i record appena salvati per avere gli ID
    final savedCurrentRecords = await isar.estrattoContos
        .filter()
        .logHistoryIdEqualTo(uniqueCode)
        .findAll();

    final Map<String, List<EstrattoConto>> internalGroups = {};
    for (var record in savedCurrentRecords) {
      if (record.bolla.isNotEmpty) {
        internalGroups.putIfAbsent(record.bolla, () => []).add(record);
      }
    }

    for (var bolla in internalGroups.keys) {
      final currentRecords = internalGroups[bolla]!;
      
      if (currentRecords.length > 1) {
        for (int i = 1; i < currentRecords.length; i++) {
          collisions.add({
            'type': 'internal',
            'bolla': bolla,
            'current': currentRecords[i].toMap()..['id'] = currentRecords[i].id,
            'found': currentRecords[0].toMap()..['id'] = currentRecords[0].id,
            'foundFileName': file.name,
          });
        }
      }

      final existingRecords = await isar.estrattoContos
          .filter()
          .bollaEqualTo(bolla)
          .and()
          .not()
          .logHistoryIdEqualTo(uniqueCode)
          .findAll();

      if (existingRecords.isNotEmpty) {
        for (var current in currentRecords) {
          for (var existing in existingRecords) {
            String existingFileName = 'Sconosciuto';
            if (existing.logHistoryId != null) {
              final log = await isar.logHistorys
                  .filter()
                  .uniqueCodeEqualTo(existing.logHistoryId!)
                  .findFirst();
              if (log != null) {
                existingFileName = log.fileName;
              }
            }

            collisions.add({
              'type': 'database',
              'bolla': bolla,
              'current': current.toMap()..['id'] = current.id,
              'found': existing.toMap()..['id'] = existing.id,
              'foundFileName': existingFileName,
            });
          }
        }
      }
    }
    // --- FINE LOGICA DI CONTROLLO ---

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
      'uniqueCode': uniqueCode,
      'collisions': collisions,
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
Future<List<Map<String, dynamic>>> _parseExcelIsolate(Map<String, dynamic> params) async {
  final String filePath = params['filePath'];
  final String uniqueCode = params['uniqueCode'];
  
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

  final sheet = excel.tables[documentSheetName];
  if (sheet == null) {
    throw Exception('Foglio "Document" non trovato.');
  }

  for (var i = 1; i < sheet.maxRows; i++) {
    if (i >= sheet.rows.length) continue;
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
      
      String s;
      if (v is TextCellValue) {
        s = v.value.toString().replaceAll(' ', '').trim();
      } else {
        s = v.toString().replaceAll(' ', '').trim();
      }
      
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
      'dataBolla': _normalizeExcelDate(val(2)),
      'dataCompetenza': _normalizeExcelDate(val(3)),
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
      'dataIn': _normalizeExcelDate(val(28)),
      'dataOut': _normalizeExcelDate(val(29)),
      'localitaPartenza': val(30),
      'localitaArrivo': val(31),
      'codiceTrattamento': val(32),
      'codiceSistemazione': val(33),
      'richiedente': val(34),
      'cid': val(35).isNotEmpty ? val(35).padLeft(8, '0') : '',
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
      'logHistoryId': uniqueCode,
    });
  }

  return results;
}

final estrattoContoProvider =
    NotifierProvider<EstrattoContoNotifier, List<EstrattoConto>>(() {
      return EstrattoContoNotifier();
    });

String _normalizeExcelDate(String dateStr) {
  if (dateStr.trim().isEmpty) return '';
  final d = dateStr.trim();
  try {
    // 1. Prova a gestire dd/MM/yy o d/M/yy o dd/MM/yyyy
    final slashMatch = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{2,4})').firstMatch(d);
    if (slashMatch != null) {
      final day = slashMatch.group(1)!.padLeft(2, '0');
      final month = slashMatch.group(2)!.padLeft(2, '0');
      var year = slashMatch.group(3)!;
      if (year.length == 2) {
        year = "20$year";
      }
      return "$day/$month/$year";
    }

    // 2. Prova DateTime.tryParse (ISO yyyy-MM-dd)
    final dt = DateTime.tryParse(d);
    if (dt != null) {
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      return "$day/$month/$year";
    }
    
    // 3. Formato compatto yyyyMMdd
    if (d.length == 8 && RegExp(r'^\d{8}$').hasMatch(d)) {
      return "${d.substring(6, 8)}/${d.substring(4, 6)}/${d.substring(0, 4)}";
    }

    return d;
  } catch (_) {
    return d;
  }
}
