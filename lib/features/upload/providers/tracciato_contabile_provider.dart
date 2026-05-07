import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/tracciato_contabile.dart';
import '../models/log_history.dart';
import 'log_history_provider.dart';

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
      );
      await isar.logHistorys.put(logWithStats);
    });

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
