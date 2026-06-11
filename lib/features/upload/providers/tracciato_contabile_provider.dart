import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/tracciato_contabile.dart';
import '../models/log_history.dart';
import '../models/scarti_ec_sap.dart';
import 'log_history_provider.dart';
import 'scarti_ec_sap_provider.dart';

class TracciatoContabilesNotifier extends Notifier<List<TracciatoContabile>> {
  @override
  List<TracciatoContabile> build() {
    final isar = ref.watch(isarProvider);
    // Caricamento iniziale dal database - Isar è molto veloce, ma findAllSync
    // può bloccare la UI se i record sono centinaia di migliaia.
    return isar.tracciatoContabiles.where().anyId().findAllSync();
  }

  Future<Map<String, dynamic>> loadFromFile(XFile file) async {
    final isar = ref.read(isarProvider);
    final uniqueCode = DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('Caricamento file contabile in background: ${file.path}');

    // Eseguiamo il parsing pesante in un isolate separato
    final List<Map<String, dynamic>> parsedData = await compute(_parseTracciatoIsolate, {
      'filePath': file.path,
      'uniqueCode': uniqueCode,
    });

    final List<TracciatoContabile> newRecords = parsedData.map((map) => TracciatoContabile.fromMap(map)).toList();

    if (newRecords.isEmpty) {
      throw Exception('Nessun record valido trovato nel file.');
    }

    // Identifichiamo i record da salvare (tutti quelli nel file)
    final List<TracciatoContabile> recordsToSave = List.from(newRecords);
    
    int insertedCount = recordsToSave.length;
    int updatedCount = 0;
    const totalDiscarded = 0;

    await isar.writeTxn(() async {
      // Salva tutto come nuovi record
      await isar.tracciatoContabiles.putAll(recordsToSave);

      final logWithStats = LogHistory(
        fileName: file.name,
        date: DateTime.now(),
        uniqueCode: uniqueCode,
        totalRecords: newRecords.length,
        insertedRecords: insertedCount,
        updatedRecords: updatedCount,
        discardedRecords: totalDiscarded,
        sourceType: 'Tracciato Contabile',
      );
      await isar.logHistorys.put(logWithStats);
    });

    // --- LOGICA DI CONTROLLO BOLLE DUPLICATE (SPOSTATA DOPO IL SALVATAGGIO PER AVERE GLI ID) ---
    final List<Map<String, dynamic>> collisions = [];
    
    // Recuperiamo i record appena salvati per avere gli ID
    final savedCurrentRecords = await isar.tracciatoContabiles
        .filter()
        .logHistoryIdEqualTo(uniqueCode)
        .findAll();

    final Map<String, List<TracciatoContabile>> internalGroups = {};
    for (var record in savedCurrentRecords) {
      internalGroups.putIfAbsent(record.numeroBolla, () => []).add(record);
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

      final existingRecords = await isar.tracciatoContabiles
          .filter()
          .numeroBollaEqualTo(bolla)
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

    // --- INCROCIO CON EVENTUALI SCARTI GIÀ CARICATI PER I MEDESIMI PERIODI ---
    final targetPeriods = <String>{};
    for (final r in recordsToSave) {
      final parts = r.dataSpesa.split('/');
      if (parts.length == 3) {
        final month = parts[1];
        final year = parts[2];
        if (month.length == 2 && year.length == 4) {
          targetPeriods.add('$year$month');
        }
      }
    }

    if (targetPeriods.isNotEmpty) {
      final scartiLogs = await isar.logHistorys
          .filter()
          .sourceTypeEqualTo('Scarti EC SAP')
          .findAll();

      final matchingScartiLogIds = <String>{};
      for (final period in targetPeriods) {
        for (final log in scartiLogs) {
          if (log.fileName.contains(period)) {
            matchingScartiLogIds.add(log.uniqueCode);
          }
        }
      }

      if (matchingScartiLogIds.isNotEmpty) {
        final scartiRecords = await isar.scartiEcSaps
            .filter()
            .anyOf(matchingScartiLogIds, (q, String id) => q.logHistoryIdEqualTo(id))
            .findAll();

        if (scartiRecords.isNotEmpty) {
          // Reset status isMatched degli scarti corrispondenti
          for (final scarto in scartiRecords) {
            scarto.isMatched = false;
          }

          final List<TracciatoContabile> candidateRecords = [];
          for (final period in targetPeriods) {
            final targetSuffix = '/${period.substring(4)}/${period.substring(0, 4)}';
            final periodCandidates = await isar.tracciatoContabiles
                .filter()
                .dataSpesaEndsWith(targetSuffix)
                .findAll();
            candidateRecords.addAll(periodCandidates);
          }

          final resetCandidates = <TracciatoContabile>[];
          for (final c in candidateRecords) {
            if (c.isScarto && matchingScartiLogIds.contains(c.scartoLogHistoryId)) {
              final reset = TracciatoContabile(
                recordType: c.recordType,
                cid: c.cid,
                numeroTrasferta: c.numeroTrasferta,
                progressivo: c.progressivo,
                societa: c.societa,
                tipoDipendente: c.tipoDipendente,
                giustificativoSpesa: c.giustificativoSpesa,
                numeroBolla: c.numeroBolla,
                dataSpesa: c.dataSpesa,
                localita: c.localita,
                dataInizio: c.dataInizio,
                oraInizio: c.oraInizio,
                dataFine: c.dataFine,
                oraFine: c.oraFine,
                tipoAttivita: c.tipoAttivita,
                importo: c.importo,
                valuta: c.valuta,
                isNegative: c.isNegative,
                logHistoryId: c.logHistoryId,
                sourceFileLine: c.sourceFileLine,
                isScarto: false,
                scartoLogHistoryId: null,
              )..id = c.id;
              resetCandidates.add(reset);
            }
          }

          for (final rc in resetCandidates) {
            final idx = candidateRecords.indexWhere((cand) => cand.id == rc.id);
            if (idx != -1) {
              candidateRecords[idx] = rc;
            }
          }

          final matchedIds = <int>{};
          final updatedContabileRecords = List<TracciatoContabile>.from(resetCandidates);

          for (final scarto in scartiRecords) {
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

              final updated = TracciatoContabile(
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
                scartoLogHistoryId: scarto.logHistoryId,
              )..id = bestMatch.id;

              final uIdx = updatedContabileRecords.indexWhere((u) => u.id == updated.id);
              if (uIdx != -1) {
                updatedContabileRecords[uIdx] = updated;
              } else {
                updatedContabileRecords.add(updated);
              }

              final cIdx = candidateRecords.indexWhere((c) => c.id == updated.id);
              if (cIdx != -1) {
                candidateRecords[cIdx] = updated;
              }
            }
          }

          await isar.writeTxn(() async {
            if (updatedContabileRecords.isNotEmpty) {
              await isar.tracciatoContabiles.putAll(updatedContabileRecords);
            }
            await isar.scartiEcSaps.putAll(scartiRecords);
          });
          ref.invalidate(scartiEcSapProvider);
        }
      }
    }

    // Aggiorniamo lo stato in modo asincrono
    final allRecords = await isar.tracciatoContabiles.where().anyId().findAll();
    state = allRecords;

    // Invalidate LogHistory provider to update its UI
    ref.invalidate(logHistoryProvider);

    return {
      'inserted': insertedCount,
      'updated': updatedCount,
      'duplicates': totalDiscarded,
      'total': newRecords.length,
      'collisions': collisions,
      'uniqueCode': uniqueCode,
      'updatedRecords': [],
      'discardedRecords': [],
    };
  }

  Future<void> clear() async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.tracciatoContabiles.clear());
    state = [];
  }

  Future<void> deleteRecord(Id id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.tracciatoContabiles.delete(id));
    state = state.where((r) => r.id != id).toList();
  }

  Future<void> recalculateScarti() async {
    final isar = ref.read(isarProvider);

    // 1. Fetch all Scarti EC SAP logs
    final scartiLogs = await isar.logHistorys
        .filter()
        .sourceTypeEqualTo('Scarti EC SAP')
        .findAll();

    // Reset all ScartiEcSap's isMatched to false first
    final allScartiRecords = await isar.scartiEcSaps.where().anyId().findAll();
    for (final scarto in allScartiRecords) {
      scarto.isMatched = false;
    }

    // 2. Fetch all contabile records
    final contabileRecords = await isar.tracciatoContabiles.where().anyId().findAll();

    // 3. Reset isScarto = false and scartoLogHistoryId = null on all records
    final resetRecords = contabileRecords.map((c) {
      return TracciatoContabile(
        recordType: c.recordType,
        cid: c.cid,
        numeroTrasferta: c.numeroTrasferta,
        progressivo: c.progressivo,
        societa: c.societa,
        tipoDipendente: c.tipoDipendente,
        giustificativoSpesa: c.giustificativoSpesa,
        numeroBolla: c.numeroBolla,
        dataSpesa: c.dataSpesa,
        localita: c.localita,
        dataInizio: c.dataInizio,
        oraInizio: c.oraInizio,
        dataFine: c.dataFine,
        oraFine: c.oraFine,
        tipoAttivita: c.tipoAttivita,
        importo: c.importo,
        valuta: c.valuta,
        isNegative: c.isNegative,
        logHistoryId: c.logHistoryId,
        sourceFileLine: c.sourceFileLine,
        isScarto: false,
        scartoLogHistoryId: null,
      )..id = c.id;
    }).toList();

    // Group contabile records by targetPeriod yyyyMM to optimize candidate searching
    final Map<String, List<TracciatoContabile>> contabileByPeriod = {};
    for (final c in resetRecords) {
      final parts = c.dataSpesa.split('/');
      if (parts.length == 3) {
        final month = parts[1];
        final year = parts[2];
        if (month.length == 2 && year.length == 4) {
          contabileByPeriod.putIfAbsent('$year$month', () => []).add(c);
        }
      }
    }

    final updatedRecordsMap = <int, TracciatoContabile>{};

    // 4. For each scarti file, run matching
    for (final log in scartiLogs) {
      // Find period yyyyMM from file name
      final fileName = log.fileName;
      if (fileName.length < 6) continue;
      final yyyyMM = fileName.substring(0, 6);
      if (!RegExp(r'^\d{6}$').hasMatch(yyyyMM)) continue;

      // Filter scarti records belonging to this log from allScartiRecords
      final scartiRecords = allScartiRecords.where((s) => s.logHistoryId == log.uniqueCode).toList();

      if (scartiRecords.isEmpty) continue;

      // Find candidate contabile records for this period (either matched or reset)
      final candidateRecords = contabileByPeriod[yyyyMM] ?? [];
      if (candidateRecords.isEmpty) continue;

      final matchedIds = <int>{};

      for (final scarto in scartiRecords) {
        final scartoCid = scarto.cid.trim().padLeft(8, '0');
        final scartoCleanTrasferta = scarto.numeroTrasferta.trim().split('.')[0].replaceAll(RegExp(r'^0+'), '');
        final scartoImporto = scarto.importo;

        TracciatoContabile? bestMatch;
        for (final candidate in candidateRecords) {
          if (matchedIds.contains(candidate.id)) continue;

          final candCid = candidate.cid.trim().padLeft(8, '0');
          final candCleanTrasferta = candidate.numeroTrasferta.trim().split('.')[0].replaceAll(RegExp(r'^0+'), '');
          // Make sure we use the current updated state if this record was already modified
          final currentCand = updatedRecordsMap[candidate.id] ?? candidate;
          final candImporto = currentCand.isNegative ? -currentCand.importo : currentCand.importo;

          if (scartoCid == candCid &&
              scartoCleanTrasferta == candCleanTrasferta &&
              (scartoImporto - candImporto).abs() < 0.005) {
            bestMatch = currentCand;
            break;
          }
        }

        if (bestMatch != null) {
          matchedIds.add(bestMatch.id);
          scarto.isMatched = true;

          final updated = TracciatoContabile(
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
            scartoLogHistoryId: log.uniqueCode,
          )..id = bestMatch.id;

          updatedRecordsMap[bestMatch.id] = updated;
        }
      }
    }

    // Prepare list of all records to put back
    final List<TracciatoContabile> recordsToPut = [];
    // Include all reset records first
    recordsToPut.addAll(resetRecords);
    // Overwrite the ones that matched
    for (final updated in updatedRecordsMap.values) {
      final idx = recordsToPut.indexWhere((r) => r.id == updated.id);
      if (idx != -1) {
        recordsToPut[idx] = updated;
      }
    }

    await isar.writeTxn(() async {
      await isar.tracciatoContabiles.putAll(recordsToPut);
      await isar.scartiEcSaps.putAll(allScartiRecords);
    });

    ref.invalidate(scartiEcSapProvider);

    state = await isar.tracciatoContabiles.where().anyId().findAll();
  }
}

// Funzione top-level per l'isolate
Future<List<Map<String, dynamic>>> _parseTracciatoIsolate(Map<String, dynamic> params) async {
  final String filePath = params['filePath'];
  final String uniqueCode = params['uniqueCode'];
  
  final List<Map<String, dynamic>> results = [];
  final file = File(filePath);
  
  // Utilizziamo un modo più robusto per leggere il file con caratteri malformati
  final bytes = file.readAsBytesSync();
  final content = const Utf8Decoder(allowMalformed: true).convert(bytes);
  final lines = const LineSplitter().convert(content);

  if (lines.isEmpty) return [];

  bool isFirstLine = true;
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.trim().isEmpty) continue;

    if (isFirstLine) {
      isFirstLine = false;
      continue;
    }

    // Regola: ignora l'ultima riga del file (Footer/Controllo)
    if (i == lines.length - 1 && lines.length > 2) {
      continue;
    }

    try {
      final record = TracciatoContabile.fromString(
        line, 
        logHistoryId: uniqueCode,
        sourceFileLine: i + 1,
      );
      results.add(record.toMap());
    } catch (e) {
      // Salta righe malformate
    }
  }
  
  return results;
}

final tracciatoContabilesProvider =
    NotifierProvider<TracciatoContabilesNotifier, List<TracciatoContabile>>(() {
      return TracciatoContabilesNotifier();
    });
