import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/tracciato_sap.dart';
import '../models/log_history.dart';
import 'log_history_provider.dart';

class TracciatoSapNotifier extends Notifier<List<TracciatoSap>> {
  @override
  List<TracciatoSap> build() {
    final isar = ref.watch(isarProvider);
    return isar.tracciatoSaps.where().anyId().findAllSync();
  }

  Future<Map<String, dynamic>> loadFromFile(XFile file) async {
    final isar = ref.read(isarProvider);
    final uniqueCode = DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('Caricamento file SAP: ${file.path}');

    // Per Excel usiamo un approccio sincrono o compute se pesante
    // Dato che excel decode può essere lento, meglio compute
    final List<Map<String, dynamic>> results = await compute(_parseSapIsolate, {
      'filePath': file.path,
      'uniqueCode': uniqueCode,
    });

    if (results.isEmpty) {
      throw Exception('Nessun record valido trovato nel file SAP.');
    }

    final recordsToSave = results.map((m) {
      // Manual mapping from map if needed, or use a factory
      // Since we already have the map from isolate, let's just use it
      return TracciatoSap(
        cid: m['cid'],
        nomeDipendente: m['nomeDipendente'],
        societaCodice: m['societaCodice'],
        societaDescrizione: m['societaDescrizione'],
        tipoDipendente: m['tipoDipendente'],
        classeRetributiva: m['classeRetributiva'],
        numeroTrasferta: m['numeroTrasferta'],
        progressivoGiustificativo: m['progressivoGiustificativo'],
        tipoSpesaCodice: m['tipoSpesaCodice'],
        tipoSpesaDescrizione: m['tipoSpesaDescrizione'],
        importo: m['importo'],
        valuta: m['valuta'],
        data: m['data'],
        riTr: m['riTr'],
        cdRichiesta: m['cdRichiesta'],
        calc: m['calc'],
        codiceStato: m['codiceStato'],
        fi: m['fi'],
        codiceTrasferimentoFi: m['codiceTrasferimentoFi'],
        colonnaT: m['colonnaT'],
        logHistoryId: m['logHistoryId'],
      );
    }).toList();

    await isar.writeTxn(() async {
      await isar.tracciatoSaps.putAll(recordsToSave);

      final log = LogHistory(
        fileName: file.name,
        date: DateTime.now(),
        uniqueCode: uniqueCode,
        totalRecords: recordsToSave.length,
        insertedRecords: recordsToSave.length,
        updatedRecords: 0,
        discardedRecords: 0,
        sourceType: 'Tracciato SAP',
      );
      await isar.logHistorys.put(log);
    });

    state = await isar.tracciatoSaps.where().anyId().findAll();
    ref.invalidate(logHistoryProvider);

    return {
      'inserted': recordsToSave.length,
      'total': recordsToSave.length,
      'uniqueCode': uniqueCode,
    };
  }

  Future<void> clear() async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.tracciatoSaps.clear());
    state = [];
  }

  Future<void> deleteRecord(Id id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.tracciatoSaps.delete(id));
    state = state.where((r) => r.id != id).toList();
  }
}

Future<List<Map<String, dynamic>>> _parseSapIsolate(Map<String, dynamic> params) async {
  final String filePath = params['filePath'];
  final String uniqueCode = params['uniqueCode'];
  
  final bytes = File(filePath).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  
  final List<Map<String, dynamic>> results = [];
  
  for (var table in excel.tables.keys) {
    final sheet = excel.tables[table]!;
    if (sheet.maxRows <= 1) continue;

    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      // Helper to get string safely
      String getString(int index) {
        if (index >= row.length) return '';
        final val = row[index]?.value;
        if (val == null) return '';
        return val.toString().trim();
      }

      // Helper to get double safely
      double getDouble(int index) {
        if (index >= row.length) return 0.0;
        final val = row[index]?.value;
        if (val == null) return 0.0;
        
        final stringVal = val.toString().replaceAll(',', '.').trim();
        return double.tryParse(stringVal) ?? 0.0;
      }

      // Helper to get date safely and normalized to DD/MM/YYYY
      String getDateString(int index) {
        if (index >= row.length) return '';
        final val = row[index]?.value;
        if (val == null) return '';

        // Otteniamo la stringa (es. "2026-03-26 00:00:00.000" o "26/03/2026")
        final s = val.toString().trim();
        if (s.isEmpty) return '';

        try {
          // Rimuoviamo eventuale parte oraria
          final cleanS = s.split(' ')[0];
          
          // Gestione formati comuni: YYYY-MM-DD, DD.MM.YYYY, DD/MM/YYYY
          final parts = cleanS.split(RegExp(r'[./-]'));
          if (parts.length == 3) {
            if (parts[0].length == 4) {
              // Assumiamo YYYY-MM-DD
              final year = parts[0];
              final month = parts[1].padLeft(2, '0');
              final day = parts[2].padLeft(2, '0');
              return '$day/$month/$year';
            } else {
              // Assumiamo DD-MM-YYYY o simile
              final day = parts[0].padLeft(2, '0');
              final month = parts[1].padLeft(2, '0');
              final year = parts[2].length > 4 ? parts[2].substring(0, 4) : parts[2];
              return '$day/$month/$year';
            }
          }
        } catch (_) {}

        return s;
      }

      results.add({
        'cid': getString(0),
        'nomeDipendente': getString(1),
        'societaCodice': getString(2),
        'societaDescrizione': getString(3),
        'tipoDipendente': getString(4),
        'classeRetributiva': getString(5),
        'numeroTrasferta': getString(6),
        'progressivoGiustificativo': getString(7),
        'tipoSpesaCodice': getString(8),
        'tipoSpesaDescrizione': getString(9),
        'importo': getDouble(10),
        'valuta': getString(11),
        'data': getDateString(12),
        'riTr': getString(13),
        'cdRichiesta': getString(14),
        'calc': getString(15),
        'codiceStato': getString(16),
        'fi': getString(17),
        'codiceTrasferimentoFi': getString(18),
        'colonnaT': getString(19),
        'logHistoryId': uniqueCode,
      });
    }
  }
  return results;
}

final tracciatoSapProvider = NotifierProvider<TracciatoSapNotifier, List<TracciatoSap>>(() {
  return TracciatoSapNotifier();
});
