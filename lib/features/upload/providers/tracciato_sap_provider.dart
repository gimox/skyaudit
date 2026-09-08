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
    _loadInitialData(isar);
    return [];
  }

  Future<void> _loadInitialData(Isar isar) async {
    final records = await isar.tracciatoSaps.where().anyId().findAll();
    state = records;
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
    final sheet = excel.tables[table];
    if (sheet == null || sheet.maxRows <= 1) continue;

    // Mappatura dinamica delle colonne dall'intestazione
    final Map<String, int> fieldToColIndex = {};
    if (sheet.rows.isNotEmpty) {
      final headerRow = sheet.rows.first;
      String normalize(String s) {
        return s
            .toLowerCase()
            .replaceAll('à', 'a')
            .replaceAll('è', 'e')
            .replaceAll('é', 'e')
            .replaceAll('ì', 'i')
            .replaceAll('ò', 'o')
            .replaceAll('ù', 'u')
            .replaceAll(RegExp(r'[^a-z0-9]'), '')
            .trim();
      }

      final Map<String, List<String>> fieldToHeaders = {
        'cid': ['cid', 'pernr', 'matricola'],
        'nomeDipendente': ['nomedeldipendenteodelcand', 'nomedipendente', 'dipendente', 'nome'],
        'societaCodice': ['soc', 'societacodice', 'codicesocieta'],
        'societaDescrizione': ['societa', 'societadescrizione', 'ragionesociale'],
        'tipoDipendente': ['tpdip', 'tipodipendente'],
        'classeRetributiva': ['clretr', 'classeretributiva'],
        'numeroTrasferta': ['trsf', 'reinr', 'numerotrasferta', 'trasferta', 'idtrasferta'],
        'progressivoGiustificativo': ['pr', 'progressivogiustificativo', 'progr', 'prog'],
        'tipoSpesaCodice': ['tpsp', 'tipospesacodice', 'tipospesa'],
        'tipoSpesaDescrizione': ['tipospesetrasferta', 'tipospesadescrizione', 'descrizionespesa', 'spesadescrizione'],
        'importo': ['importodi', 'importo', 'importototale'],
        'valuta': ['div', 'valuta', 'divisa'],
        'data': ['data', 'dataspesa'],
        'riTr': ['ritr', 'ri/tr'],
        'cdRichiesta': ['cdrichiestatrasfertaotrasf', 'cdrichiesta', 'richiesta'],
        'calc': ['calc'],
        'codiceStato': ['codiceapertodacalcolareca', 'codicestato', 'stato'],
        'fi': ['fi'],
        'codiceTrasferimentoFi': ['codicetrasferimentofi', 'trasferimentofi'],
        'colonnaT': ['colonnat'],
      };

      for (int col = 0; col < headerRow.length; col++) {
        final val = headerRow[col]?.value;
        if (val == null) continue;
        final normHeader = normalize(val.toString());
        if (normHeader.isEmpty) continue;

        fieldToHeaders.forEach((field, patterns) {
          if (!fieldToColIndex.containsKey(field) && patterns.contains(normHeader)) {
            fieldToColIndex[field] = col;
          }
        });
      }
    }

    int getCol(String field, int fallbackIndex) => fieldToColIndex[field] ?? fallbackIndex;

    for (int i = 1; i < sheet.maxRows; i++) {
      if (i >= sheet.rows.length) continue;
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      // Helper to get string safely
      String getString(int index) {
        if (index < 0 || index >= row.length) return '';
        final val = row[index]?.value;
        if (val == null) return '';
        return val.toString().trim();
      }

      // Helper to get double safely
      double getDouble(int index) {
        if (index < 0 || index >= row.length) return 0.0;
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

      // Helper to get date safely and normalized to DD/MM/YYYY
      String getDateString(int index) {
        if (index < 0 || index >= row.length) return '';
        final cell = row[index];
        if (cell == null || cell.value == null) return '';
        final val = cell.value;

        if (val is DateCellValue) {
          final d = val.asDateTimeUtc();
          final day = d.day.toString().padLeft(2, '0');
          final month = d.month.toString().padLeft(2, '0');
          final year = d.year.toString();
          return '$day/$month/$year';
        }

        if (val is DateTimeCellValue) {
          final d = val.asDateTimeUtc();
          final day = d.day.toString().padLeft(2, '0');
          final month = d.month.toString().padLeft(2, '0');
          final year = d.year.toString();
          return '$day/$month/$year';
        }

        if (val is IntCellValue || val is DoubleCellValue) {
          final numVal = val is IntCellValue ? val.value : (val as DoubleCellValue).value.toInt();
          if (numVal > 30000 && numVal < 70000) {
            final dt = DateTime(1899, 12, 30).add(Duration(days: numVal));
            final day = dt.day.toString().padLeft(2, '0');
            final month = dt.month.toString().padLeft(2, '0');
            final year = dt.year.toString();
            return '$day/$month/$year';
          }
        }

        final s = val.toString().trim();
        if (s.isEmpty) return '';

        final serialNum = int.tryParse(s);
        if (serialNum != null && serialNum > 30000 && serialNum < 70000) {
          final dt = DateTime(1899, 12, 30).add(Duration(days: serialNum));
          final day = dt.day.toString().padLeft(2, '0');
          final month = dt.month.toString().padLeft(2, '0');
          final year = dt.year.toString();
          return '$day/$month/$year';
        }

        try {
          final cleanS = s.split(' ')[0];
          final parts = cleanS.split(RegExp(r'[./-]'));
          if (parts.length == 3) {
            if (parts[0].length == 4) {
              final year = parts[0];
              final month = parts[1].padLeft(2, '0');
              final day = parts[2].padLeft(2, '0');
              return '$day/$month/$year';
            } else {
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
        'cid': getString(getCol('cid', 0)).isNotEmpty ? getString(getCol('cid', 0)).padLeft(8, '0') : '',
        'nomeDipendente': getString(getCol('nomeDipendente', 1)),
        'societaCodice': getString(getCol('societaCodice', 2)),
        'societaDescrizione': getString(getCol('societaDescrizione', 3)),
        'tipoDipendente': getString(getCol('tipoDipendente', 4)),
        'classeRetributiva': getString(getCol('classeRetributiva', 5)),
        'numeroTrasferta': getString(getCol('numeroTrasferta', 6)),
        'progressivoGiustificativo': getString(getCol('progressivoGiustificativo', 7)),
        'tipoSpesaCodice': getString(getCol('tipoSpesaCodice', 8)),
        'tipoSpesaDescrizione': getString(getCol('tipoSpesaDescrizione', 9)),
        'importo': getDouble(getCol('importo', 10)),
        'valuta': getString(getCol('valuta', 11)),
        'data': getDateString(getCol('data', 12)),
        'riTr': getString(getCol('riTr', 13)),
        'cdRichiesta': getString(getCol('cdRichiesta', 14)),
        'calc': getString(getCol('calc', 15)),
        'codiceStato': getString(getCol('codiceStato', 16)),
        'fi': getString(getCol('fi', 17)),
        'codiceTrasferimentoFi': getString(getCol('codiceTrasferimentoFi', 18)),
        'colonnaT': getString(getCol('colonnaT', 19)),
        'logHistoryId': uniqueCode,
      });
    }
  }
  return results;
}

final tracciatoSapProvider = NotifierProvider<TracciatoSapNotifier, List<TracciatoSap>>(() {
  return TracciatoSapNotifier();
});
