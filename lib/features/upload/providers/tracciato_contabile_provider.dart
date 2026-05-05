import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/tracciato_contabile.dart';

class TracciatoContabilesNotifier extends Notifier<List<TracciatoContabile>> {
  @override
  List<TracciatoContabile> build() {
    final isar = ref.watch(isarProvider);
    // Caricamento iniziale dal database - Isar è molto veloce, ma findAllSync
    // può bloccare la UI se i record sono centinaia di migliaia.
    return isar.tracciatoContabiles.where().findAllSync();
  }

  Future<Map<String, int>> loadFromFile(XFile file) async {
    final List<TracciatoContabile> newRecords = [];
    final isar = ref.read(isarProvider);
    
    debugPrint('Caricamento file: ${file.path}');
    final stream = File(file.path)
        .openRead()
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter());

    String? bufferedLine;
    bool isFirstLine = true;
    int linesCount = 0;

    await for (final line in stream) {
      if (line.trim().isEmpty) continue;

      linesCount++;
      if (isFirstLine) {
        debugPrint('Saltata riga di intestazione: $line');
        isFirstLine = false;
        continue;
      }

      if (bufferedLine != null) {
        try {
          final record = TracciatoContabile.fromString(bufferedLine);
          newRecords.add(record);
        } catch (e) {
          debugPrint('Error parsing line: $e');
        }
      }
      
      bufferedLine = line;
    }
    
    debugPrint('Totale righe lette: $linesCount');
    debugPrint('Record parsati correttamente: ${newRecords.length}');
    
    // 1. Rimuovi duplicati interni al file (tieni l'ultimo)
    final Map<String, TracciatoContabile> distinctMap = {};
    for (final r in newRecords) {
      distinctMap[r.numeroBolla] = r;
    }
    
    final bollaNumbers = distinctMap.keys.toList();
    
    int insertedCount = 0;
    int updatedCount = 0;

    await isar.writeTxn(() async {
      // 2. Recupera i record esistenti per questi numeri bolla
      final existingRecords = await isar.tracciatoContabiles
          .filter()
          .anyOf(bollaNumbers, (q, String b) => q.numeroBollaEqualTo(b))
          .findAll();
      
      // Crea una mappa per un accesso veloce
      final existingMap = {for (var r in existingRecords) r.numeroBolla: r.id};
      
      // 3. Assegna gli ID esistenti ai nuovi record per forzare l'UPDATE invece dell'INSERT
      final recordsToSave = distinctMap.values.map((newRecord) {
        if (existingMap.containsKey(newRecord.numeroBolla)) {
          newRecord.id = existingMap[newRecord.numeroBolla]!;
          updatedCount++;
        } else {
          insertedCount++;
        }
        return newRecord;
      }).toList();

      // 4. Salva tutto
      await isar.tracciatoContabiles.putAll(recordsToSave);
    });
    
    final duplicatesInFile = newRecords.length - distinctMap.length;
    state = isar.tracciatoContabiles.where().findAllSync();

    return {
      'inserted': insertedCount,
      'updated': updatedCount,
      'duplicates': duplicatesInFile,
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

final tracciatoContabilesProvider = NotifierProvider<TracciatoContabilesNotifier, List<TracciatoContabile>>(() {
  return TracciatoContabilesNotifier();
});
