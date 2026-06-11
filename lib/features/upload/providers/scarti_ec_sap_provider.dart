import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/scarti_ec_sap.dart';
import '../models/log_history.dart';
import 'log_history_provider.dart';
import '../models/tracciato_contabile.dart';
import 'tracciato_contabile_provider.dart';

class ScartiEcSapNotifier extends Notifier<List<ScartiEcSap>> {
  @override
  List<ScartiEcSap> build() {
    final isar = ref.watch(isarProvider);
    return isar.scartiEcSaps.where().anyId().findAllSync();
  }

  Future<Map<String, dynamic>> loadFromFile(XFile file) async {
    final isar = ref.read(isarProvider);
    final uniqueCode = DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('Caricamento file Scarti EC SAP: ${file.path}');

    // Estrazione anno e mese dalle prime 6 cifre del nome del file (formato yyyyMM)
    final fileName = file.name;
    if (fileName.length < 6) {
      throw Exception('Il nome del file degli scarti deve iniziare con 6 cifre per anno e mese (yyyyMM).');
    }
    final yyyyMM = fileName.substring(0, 6);
    if (!RegExp(r'^\d{6}$').hasMatch(yyyyMM)) {
      throw Exception('Le prime 6 cifre del nome del file degli scarti devono rappresentare anno e mese (yyyyMM).');
    }

    // Eseguiamo il parsing in un isolate separato per evitare blocchi dell'interfaccia utente (jank)
    final List<Map<String, dynamic>> results = await compute(_parseScartiIsolate, {
      'filePath': file.path,
      'uniqueCode': uniqueCode,
    });

    if (results.isEmpty) {
      throw Exception('Nessun record valido trovato nel file Scarti EC SAP.');
    }

    final recordsToSave = results.map((m) {
      return ScartiEcSap(
        numeroTrasferta: m['numeroTrasferta'],
        cid: m['cid'],
        descrizioneScarto: m['descrizioneScarto'],
        spesa: m['spesa'],
        importo: m['importo'],
        divisa: m['divisa'],
        storno: m['storno'],
        dataInvio: m['dataInvio'],
        note: m['note'],
        logHistoryId: m['logHistoryId'],
      );
    }).toList();

    // 1. Carica i record del tracciato contabile corrispondente allo stesso yyyyMM
    final logs = await isar.logHistorys
        .filter()
        .sourceTypeEqualTo('Tracciato Contabile')
        .findAll();
    
    LogHistory? matchingLog;
    for (final log in logs) {
      if (log.fileName.contains(yyyyMM)) {
        matchingLog = log;
        break;
      }
    }

    final List<TracciatoContabile> candidateRecords;
    if (matchingLog != null) {
      candidateRecords = await isar.tracciatoContabiles
          .filter()
          .logHistoryIdEqualTo(matchingLog.uniqueCode)
          .findAll();
    } else {
      // Fallback: cerca i record tramite dataSpesa che termina con /MM/yyyy
      final targetSuffix = '/${yyyyMM.substring(4)}/${yyyyMM.substring(0, 4)}';
      candidateRecords = await isar.tracciatoContabiles
          .filter()
          .dataSpesaEndsWith(targetSuffix)
          .findAll();
    }

    // 2. Eseguiamo l'abbinamento univoco (1-a-1)
    final matchedIds = <int>{};
    final updatedContabileRecords = <TracciatoContabile>[];
    int matchCount = 0;

    for (final scarto in recordsToSave) {
      final scartoCid = scarto.cid.trim().padLeft(8, '0');
      final scartoCleanTrasferta = scarto.numeroTrasferta.trim().split('.')[0].replaceAll(RegExp(r'^0+'), '');
      final scartoImporto = scarto.importo;

      TracciatoContabile? bestMatch;
      for (final candidate in candidateRecords) {
        if (matchedIds.contains(candidate.id)) continue;

        final candCid = candidate.cid.trim().padLeft(8, '0');
        final candCleanTrasferta = candidate.numeroTrasferta.trim().split('.')[0].replaceAll(RegExp(r'^0+'), '');
        final candImporto = candidate.isNegative ? -candidate.importo : candidate.importo;

        if (scartoCid == candCid &&
            scartoCleanTrasferta == candCleanTrasferta &&
            (scartoImporto - candImporto).abs() < 0.005) {
          bestMatch = candidate;
          break;
        }
      }

      if (bestMatch != null) {
        matchedIds.add(bestMatch.id);
        scarto.isMatched = true;
        
        final updatedRecord = TracciatoContabile(
          recordType: bestMatch.recordType,
          cid: bestMatch.cid,
          numeroTrasferta: bestMatch.numeroTrasferta,
          progressivo: bestMatch.progressivo,
          societa: bestMatch.societa,
          tipoDipendente: bestMatch.tipoDipendente,
          giustificativoSpesa: bestMatch.giustificativoSpesa,
          numeroBolla: bestMatch.numeroBolla,
          dataSpesa: bestMatch.dataSpesa,
          localita: bestMatch.localita,
          dataInizio: bestMatch.dataInizio,
          oraInizio: bestMatch.oraInizio,
          dataFine: bestMatch.dataFine,
          oraFine: bestMatch.oraFine,
          tipoAttivita: bestMatch.tipoAttivita,
          importo: bestMatch.importo,
          valuta: bestMatch.valuta,
          isNegative: bestMatch.isNegative,
          logHistoryId: bestMatch.logHistoryId,
          sourceFileLine: bestMatch.sourceFileLine,
          isScarto: true,
          scartoLogHistoryId: uniqueCode,
        )..id = bestMatch.id;

        updatedContabileRecords.add(updatedRecord);
        matchCount++;
      }
    }

    // 3. Salvataggio e aggiornamenti
    await isar.writeTxn(() async {
      await isar.scartiEcSaps.putAll(recordsToSave);
      
      if (updatedContabileRecords.isNotEmpty) {
        await isar.tracciatoContabiles.putAll(updatedContabileRecords);
      }

      final log = LogHistory(
        fileName: file.name,
        date: DateTime.now(),
        uniqueCode: uniqueCode,
        totalRecords: recordsToSave.length,
        insertedRecords: recordsToSave.length,
        updatedRecords: matchCount,
        discardedRecords: 0,
        sourceType: 'Scarti EC SAP',
      );
      await isar.logHistorys.put(log);
    });

    state = await isar.scartiEcSaps.where().anyId().findAll();
    ref.invalidate(logHistoryProvider);
    ref.invalidate(tracciatoContabilesProvider);

    return {
      'inserted': recordsToSave.length,
      'total': recordsToSave.length,
      'uniqueCode': uniqueCode,
    };
  }

  Future<void> clear() async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.scartiEcSaps.clear());
    state = [];
  }

  Future<void> deleteRecord(Id id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.scartiEcSaps.delete(id));
    state = state.where((r) => r.id != id).toList();
  }
}

Future<List<Map<String, dynamic>>> _parseScartiIsolate(Map<String, dynamic> params) async {
  final String filePath = params['filePath'];
  final String uniqueCode = params['uniqueCode'];
  
  final bytes = File(filePath).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  
  final List<Map<String, dynamic>> results = [];
  
  for (var table in excel.tables.keys) {
    final sheet = excel.tables[table]!;
    if (sheet.maxRows <= 1) continue;

    // Rileva se è il nuovo formato (almeno 15 colonne)
    final bool isNewFormat = sheet.maxColumns >= 15;

    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      // Helper per stringhe
      String getString(int index) {
        if (index >= row.length) return '';
        final val = row[index]?.value;
        if (val == null) return '';
        return val.toString().trim();
      }

      // Helper specifico per la trasferta per rimuovere eventuali decimali dovuti ad Excel
      String getTrasferta(int index) {
        if (index >= row.length) return '';
        final val = row[index]?.value;
        if (val == null) return '';
        String s = val.toString().trim();
        if (s.contains('.')) {
          s = s.split('.')[0];
        }
        return s;
      }

      // Helper per il CID con padding a 8 cifre e gestione di cifre decimali interpretate da Excel
      String getCid(int index) {
        if (index >= row.length) return '';
        final val = row[index]?.value;
        if (val == null) return '';
        String s = val.toString().trim();
        if (s.isEmpty) return '';
        
        if (s.contains('.')) {
          s = s.split('.')[0];
        }
        return s.padLeft(8, '0');
      }

      // Helper per importi decimali (es. "  2.412,00" -> 2412.0)
      double getDouble(int index) {
        if (index >= row.length) return 0.0;
        final val = row[index]?.value;
        if (val == null) return 0.0;
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


      // Helper per normalizzare data da dd.MM.yyyy / ISO8601 a dd/MM/yyyy
      String getDateString(int index) {
        if (index >= row.length) return '';
        final val = row[index]?.value;
        if (val == null) return '';

        final s = val.toString().trim();
        if (s.isEmpty) return '';

        try {
          String cleanS = s.split(' ')[0]; // Rimuove ore se presenti
          if (cleanS.contains('T')) {
            cleanS = cleanS.split('T')[0]; // Rimuove ore per date ISO8601 con 'T'
          }
          
          if (cleanS.contains('.')) {
            final parts = cleanS.split('.');
            if (parts.length == 3) {
              final day = parts[0].padLeft(2, '0');
              final month = parts[1].padLeft(2, '0');
              final year = parts[2];
              return '$day/$month/$year';
            }
          }
          
          final parts = cleanS.split(RegExp(r'[/-]'));
          if (parts.length == 3) {
            if (parts[0].length == 4) {
              final year = parts[0];
              final month = parts[1].padLeft(2, '0');
              final day = parts[2].padLeft(2, '0');
              return '$day/$month/$year';
            } else {
              final day = parts[0].padLeft(2, '0');
              final month = parts[1].padLeft(2, '0');
              final year = parts[2];
              return '$day/$month/$year';
            }
          }
        } catch (_) {}

        return s;
      }

      final trasferta = isNewFormat ? getTrasferta(1) : getTrasferta(0);
      final cid = isNewFormat ? getCid(3) : getCid(1);
      
      // Saltiamo righe vuote
      if (trasferta.isEmpty && cid.isEmpty) continue;

      if (isNewFormat) {
        double importo = getDouble(14);
        final qVal = getString(16);
        if (qVal == 'R') {
          importo = -importo;
        }

        results.add({
          'numeroTrasferta': trasferta,
          'cid': cid,
          'descrizioneScarto': getString(9),
          'spesa': getString(12),
          'importo': importo,
          'divisa': getString(15),
          'storno': qVal.isNotEmpty ? qVal : null,
          'dataInvio': getDateString(10),
          'note': null,
          'logHistoryId': uniqueCode,
        });
      } else {
        final stornoVal = getString(6);
        double importo = getDouble(4);
        String? finalStorno;
        if (stornoVal == '-') {
          finalStorno = 'R';
          importo = -importo;
        } else if (stornoVal.isNotEmpty) {
          finalStorno = stornoVal;
        }

        results.add({
          'numeroTrasferta': trasferta,
          'cid': cid,
          'descrizioneScarto': getString(2),
          'spesa': getString(3),
          'importo': importo,
          'divisa': getString(5),
          'storno': finalStorno,
          'dataInvio': getDateString(7),
          'note': getString(8).isNotEmpty ? getString(8) : null,
          'logHistoryId': uniqueCode,
        });
      }
    }
  }
  return results;
}

final scartiEcSapProvider = NotifierProvider<ScartiEcSapNotifier, List<ScartiEcSap>>(() {
  return ScartiEcSapNotifier();
});
