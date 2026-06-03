import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/trasferte_sap.dart';
import '../models/log_history.dart';
import 'log_history_provider.dart';

class TrasferteSapNotifier extends Notifier<List<TrasferteSap>> {
  @override
  List<TrasferteSap> build() {
    final isar = ref.watch(isarProvider);
    return isar.trasferteSaps.where().anyId().findAllSync();
  }

  Future<Map<String, dynamic>> loadFromFile(XFile file) async {
    final isar = ref.read(isarProvider);
    final uniqueCode = DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('Caricamento file Trasferte SAP: ${file.path}');

    final List<Map<String, dynamic>> parsedData = await compute(
      _parseTrasferteSapIsolate,
      {'filePath': file.path, 'uniqueCode': uniqueCode},
    );

    if (parsedData.isEmpty) {
      throw Exception('Nessun dato trovato nel file Trasferte SAP.');
    }

    final List<TrasferteSap> recordsToSave = [];
    int insertedCount = 0;
    int updatedCount = 0;

    await isar.writeTxn(() async {
      for (final map in parsedData) {
        final newRecord = TrasferteSap(
          numeroTrasferta: map['numeroTrasferta'],
          cid: map['cid'],
          dataInizioTrasferta: map['dataInizioTrasferta'],
          oraInizioTrasferta: map['oraInizioTrasferta'],
          dataFineTrasferta: map['dataFineTrasferta'],
          oraFineTrasferta: map['oraFineTrasferta'],
          logHistoryId: uniqueCode,
        );

        final existing = await isar.trasferteSaps
            .filter()
            .numeroTrasfertaEqualTo(newRecord.numeroTrasferta)
            .findFirst();

        if (existing != null) {
          newRecord.id = existing.id;
          updatedCount++;
        } else {
          insertedCount++;
        }
        recordsToSave.add(newRecord);
      }

      await isar.trasferteSaps.putAll(recordsToSave);

      final log = LogHistory(
        fileName: file.name,
        date: DateTime.now(),
        uniqueCode: uniqueCode,
        totalRecords: parsedData.length,
        insertedRecords: insertedCount,
        updatedRecords: updatedCount,
        discardedRecords: 0,
        sourceType: 'Trasferte SAP',
      );
      await isar.logHistorys.put(log);
    });

    state = await isar.trasferteSaps.where().anyId().findAll();
    ref.invalidate(logHistoryProvider);

    return {
      'inserted': insertedCount,
      'updated': updatedCount,
      'total': parsedData.length,
      'uniqueCode': uniqueCode,
    };
  }

  Future<void> clear() async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.trasferteSaps.clear());
    state = [];
  }

  Future<void> deleteRecord(Id id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.trasferteSaps.delete(id));
    state = await isar.trasferteSaps.where().anyId().findAll();
  }
}

Future<List<Map<String, dynamic>>> _parseTrasferteSapIsolate(
  Map<String, dynamic> params,
) async {
  final String filePath = params['filePath'];
  final bytes = File(filePath).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);

  if (excel.tables.isEmpty) return [];
  final sheetName = excel.tables.keys.first;
  final sheet = excel.tables[sheetName]!;
  if (sheet.maxRows <= 1) return [];

  String cleanQuotes(String s) {
    s = s.trim();
    while (s.isNotEmpty && (s.startsWith('"') || s.startsWith("'"))) {
      s = s.substring(1);
    }
    while (s.isNotEmpty && (s.endsWith('"') || s.endsWith("'"))) {
      s = s.substring(0, s.length - 1);
    }
    return s.trim();
  }

  String normalize(String val) {
    return cleanQuotes(val)
        .toLowerCase()
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'[.\-\s/_°]+'), '')
        .replaceAll('à', 'a')
        .replaceAll('è', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ì', 'i')
        .replaceAll('ò', 'o')
        .replaceAll('ù', 'u')
        .trim();
  }

  final List<String> headers = sheet.rows.first
      .map((cell) => cleanQuotes(cell?.value?.toString() ?? ''))
      .toList();

  final Map<String, List<String>> fieldToHeaders = {
    'cid': ['pernr', 'cid', 'matricola'],
    'numeroTrasferta': ['reinr', 'numerotrasferta', 'trasferta', 'idtrasferta'],
    'dataInizioTrasferta': ['pdatv', 'datainiziotrasferta', 'datainizio', 'datada'],
    'oraInizioTrasferta': ['puhrv', 'orainiziotrasferta', 'orainizio', 'orada', 'puhr'],
    'dataFineTrasferta': ['pdatb', 'datafinetrasferta', 'datafine', 'dataa'],
    'oraFineTrasferta': ['puhrb', 'orafinetrasferta', 'orafine', 'oraa'],
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

  // Se mancano colonne critiche proviamo a usare indici di fallback basati sull'ordine tipico
  int? getIndex(String field, int fallbackIndex) {
    return fieldToColIndex[field] ?? (fallbackIndex < headers.length ? fallbackIndex : null);
  }

  String _normalizeExcelDate(String dateStr) {
    if (dateStr.trim().isEmpty) return '';
    final d = dateStr.trim();
    try {
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

      final dt = DateTime.tryParse(d);
      if (dt != null) {
        final day = dt.day.toString().padLeft(2, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final year = dt.year.toString();
        return "$day/$month/$year";
      }
      
      if (d.length == 8 && RegExp(r'^\d{8}$').hasMatch(d)) {
        return "${d.substring(6, 8)}/${d.substring(4, 6)}/${d.substring(0, 4)}";
      }

      return d;
    } catch (_) {
      return d;
    }
  }

  String _normalizeExcelTime(String timeStr) {
    if (timeStr.trim().isEmpty) return '';
    var t = timeStr.trim();
    try {
      if (t.contains(' ')) {
        final parts = t.split(' ');
        if (parts.length > 1) {
          t = parts[1];
        }
      }
      final timeMatch = RegExp(r'^(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?').firstMatch(t);
      if (timeMatch != null) {
        final hour = timeMatch.group(1)!.padLeft(2, '0');
        final min = timeMatch.group(2)!.padLeft(2, '0');
        final sec = (timeMatch.group(3) ?? '00').padLeft(2, '0');
        return "$hour:$min:$sec";
      }
      if (t.length == 6 && RegExp(r'^\d{6}$').hasMatch(t)) {
        return "${t.substring(0, 2)}:${t.substring(2, 4)}:${t.substring(4, 6)}";
      }
      if (t.length == 4 && RegExp(r'^\d{4}$').hasMatch(t)) {
        return "${t.substring(0, 2)}:${t.substring(2, 4)}:00";
      }
      return t;
    } catch (_) {
      return t;
    }
  }

  final Map<String, Map<String, dynamic>> resultsMap = {};

  for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
    final row = sheet.rows[rowIndex];
    if (row.isEmpty) continue;

    String val(int? index) {
      if (index == null || index < 0 || index >= row.length) return '';
      final cell = row[index];
      if (cell == null || cell.value == null) return '';
      return cleanQuotes(cell.value.toString());
    }

    final cidIndex = getIndex('cid', 0);
    final reinrIndex = getIndex('numeroTrasferta', 1);

    final rawCid = cidIndex != null ? val(cidIndex) : '';
    final rawTrasferta = reinrIndex != null ? val(reinrIndex) : '';

    // Rimuoviamo eventuali decimali interpretati da excel per i codici
    String cleanCode(String s) {
      if (s.contains('.')) {
        s = s.split('.')[0];
      }
      return s;
    }

    final cid = cleanCode(rawCid).isNotEmpty ? cleanCode(rawCid).padLeft(8, '0') : '';
    final numeroTrasferta = cleanCode(rawTrasferta);

    // Se non c'è il numero della trasferta, saltiamo la riga
    if (numeroTrasferta.isEmpty) continue;

    resultsMap[numeroTrasferta] = {
      'cid': cid,
      'numeroTrasferta': numeroTrasferta,
      'dataInizioTrasferta': _normalizeExcelDate(val(getIndex('dataInizioTrasferta', 2))),
      'oraInizioTrasferta': _normalizeExcelTime(val(getIndex('oraInizioTrasferta', 3))),
      'dataFineTrasferta': _normalizeExcelDate(val(getIndex('dataFineTrasferta', 4))),
      'oraFineTrasferta': _normalizeExcelTime(val(getIndex('oraFineTrasferta', 5))),
    };
  }

  return resultsMap.values.toList();
}

final trasferteSapProvider =
    NotifierProvider<TrasferteSapNotifier, List<TrasferteSap>>(() {
  return TrasferteSapNotifier();
});
