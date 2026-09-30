import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/models/anagrafica.dart';
import 'package:travel_check/features/upload/models/trasferte_sap.dart';

class GeneratedTracciatoRecord {
  final int index;
  final String cid;
  final String numeroTrasferta;
  final String receiptNo;
  final String bukrs;
  final String persk;
  final String spkzl;
  final String bolla;
  final String dataSpesaFormatted;
  final String dateYMD;
  final String localita;
  final String dataInizio;
  final String oraInizio;
  final String dataFine;
  final String oraFine;
  final String tipoAttivita;
  final double importo;
  final String valuta;
  final bool isNegative;
  final String rawLine;

  const GeneratedTracciatoRecord({
    required this.index,
    required this.cid,
    required this.numeroTrasferta,
    required this.receiptNo,
    required this.bukrs,
    required this.persk,
    required this.spkzl,
    required this.bolla,
    required this.dataSpesaFormatted,
    required this.dateYMD,
    required this.localita,
    required this.dataInizio,
    required this.oraInizio,
    required this.dataFine,
    required this.oraFine,
    required this.tipoAttivita,
    required this.importo,
    required this.valuta,
    required this.isNegative,
    required this.rawLine,
  });

  TracciatoContabile toTracciatoContabile({
    String? logHistoryId,
    int? sourceFileLine,
  }) {
    return TracciatoContabile.fromString(
      rawLine,
      logHistoryId: logHistoryId,
      sourceFileLine: sourceFileLine ?? index,
    );
  }
}

class TracciatoGeneratorResult {
  final List<GeneratedTracciatoRecord> records;
  final String header;
  final String footer;
  final String fullText;
  final int totalRecords;
  final double totalPositiveAmount;
  final double totalNegativeAmount;
  final double netAmount;
  final int uniqueTrasferteCount;
  final int uniqueCidCount;
  final Map<String, int> countBySocieta;
  final Map<String, int> countByGiustificativo;
  final Map<String, int> countByTipoDipendente;

  const TracciatoGeneratorResult({
    required this.records,
    required this.header,
    required this.footer,
    required this.fullText,
    required this.totalRecords,
    required this.totalPositiveAmount,
    required this.totalNegativeAmount,
    required this.netAmount,
    required this.uniqueTrasferteCount,
    required this.uniqueCidCount,
    required this.countBySocieta,
    required this.countByGiustificativo,
    required this.countByTipoDipendente,
  });
}

class TracciatoGeneratorService {
  /// Bypasses `package:excel` bug with custom numFmtId < 164
  static Uint8List sanitizeExcelBytes(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      bool modified = false;
      final newArchive = Archive();

      for (final file in archive) {
        if (file.name == 'xl/styles.xml' && file.isFile) {
          String content = String.fromCharCodes(file.content as List<int>);
          final regex = RegExp(r'<numFmt\s+numFmtId="([0-9]{1,2})"');
          final match = regex.firstMatch(content);
          if (match != null) {
            final customId = match.group(1)!;
            content = content.replaceAll('numFmtId="$customId"', 'numFmtId="164"');
            final newBytes = Uint8List.fromList(content.codeUnits);
            newArchive.addFile(
              ArchiveFile(file.name, newBytes.length, newBytes),
            );
            modified = true;
            continue;
          }
        }
        newArchive.addFile(file);
      }

      if (modified) {
        final encoded = ZipEncoder().encode(newArchive);
        if (encoded != null) {
          return Uint8List.fromList(encoded);
        }
      }
    } catch (_) {}
    return bytes;
  }

  static String _cleanString(dynamic value) {
    if (value == null) return '';
    var s = value.toString().trim();
    if (s.toLowerCase() == 'null') return '';
    while (s.isNotEmpty && (s.startsWith('"') || s.startsWith("'"))) {
      s = s.substring(1);
    }
    while (s.isNotEmpty && (s.endsWith('"') || s.endsWith("'"))) {
      s = s.substring(0, s.length - 1);
    }
    if (s.toLowerCase() == 'null') return '';
    return s.trim();
  }

  static String _normalizeHeader(String h) {
    return _cleanString(h)
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

  static TracciatoGeneratorResult generateFromExcelBytes({
    required Uint8List bytes,
    Map<String, Anagrafica>? anagraficaMap,
    Map<String, TrasferteSap>? trasferteSapMap,
    Map<String, TracciatoContabile>? existingContabileMap,
  }) {
    final sanitizedBytes = sanitizeExcelBytes(bytes);
    final excel = Excel.decodeBytes(sanitizedBytes);

    if (excel.tables.isEmpty) {
      throw Exception('Il file Excel non contiene fogli di lavoro.');
    }

    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName];
    if (sheet == null || sheet.rows.length <= 1) {
      throw Exception('Il foglio di lavoro non contiene dati.');
    }

    final headerRow = sheet.rows.first;
    final List<String> rawHeaders = headerRow
        .map((c) => _cleanString(c?.value))
        .toList();

    // Map column aliases
    final Map<String, List<String>> fieldAliases = {
      'cid': ['cid', 'pernr', 'matricola', 'dipendente'],
      'trasferta': [
        'ntrasferta',
        'numerotrasferta',
        'trasferta',
        'reinr',
        'idtrasferta',
      ],
      'bukrs': ['bukrs', 'societa', 'company', 'azienda'],
      'bolla': [
        'bolla',
        'numerobolla',
        'nbolla',
      ],
      'zzidtkt': [
        'zzidtkt',
        'biglietto',
        'tkt',
      ],
      'data': [
        'begda',
        'data',
        'datagiustificativo',
        'dataspesa',
        'dataspese',
        'giorno',
      ],
      'localita': [
        'zort1',
        'destinazione',
        'localita',
        'tratta',
        'citta',
        'luogo',
      ],
      'importo': ['recamount', 'importo', 'amount', 'totale', 'costo', 'prezzo'],
      'valuta': ['reccurr', 'waers', 'valuta', 'curr', 'divisa'],
      'rimborso': [
        'zzrimbann',
        'rimborso',
        'segno',
        'ra',
        'rimborsoannullamento',
      ],
      'tipoDip': ['persk', 'tipodipendente', 'tipodip', 'qualifica'],
      'spkzl': ['spkzl', 'giustificativo', 'tipospesa', 'spesa'],
    };

    final Map<String, int> colIndices = {};
    fieldAliases.forEach((field, aliases) {
      for (int i = 0; i < rawHeaders.length; i++) {
        final norm = _normalizeHeader(rawHeaders[i]);
        if (aliases.contains(norm)) {
          colIndices[field] = i;
          break;
        }
      }
    });

    final int colCid = colIndices['cid'] ?? 0;
    final int colTr = colIndices['trasferta'] ?? 1;
    final int? colBukrs = colIndices['bukrs'];
    final int? colBolla = colIndices['bolla'] ?? colIndices['zzidtkt'];
    final int? colZzidtkt = colIndices['zzidtkt'];
    final int? colData = colIndices['data'];
    final int? colLoc = colIndices['localita'];
    final int? colAmount = colIndices['importo'];
    final int? colCurr = colIndices['valuta'];
    final int? colRimb = colIndices['rimborso'];
    final int? colTipoDip = colIndices['tipoDip'];
    final int? colSpkzl = colIndices['spkzl'];

    final now = DateTime.now();
    final yyyymmdd =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final yymmdd = yyyymmdd.substring(2);
    final hhmmss =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';

    final header =
        '0HR        AI01.TO.UTATC.Z9.P$yymmdd$yyyymmdd${hhmmss}000000000000#';

    final List<GeneratedTracciatoRecord> records = [];
    final Map<String, int> trasfertaCounters = {};
    final Map<String, int> bollaCounters = {};

    double totalPos = 0.0;
    double totalNeg = 0.0;
    final Set<String> uniqueTrasferte = {};
    final Set<String> uniqueCids = {};
    final Map<String, int> countBySocieta = {};
    final Map<String, int> countByGiustificativo = {};
    final Map<String, int> countByTipoDipendente = {};

    for (int r = 1; r < sheet.rows.length; r++) {
      final row = sheet.rows[r];
      if (row.isEmpty) continue;

      String getVal(int? col) {
        if (col == null || col < 0 || col >= row.length) return '';
        final v = row[col]?.value;
        if (v == null) return '';
        return _cleanString(v);
      }

      final rawCid = getVal(colCid);
      if (rawCid.isEmpty) continue;
      final cid = rawCid.padLeft(8, '0');
      uniqueCids.add(cid);

      final rawTr = getVal(colTr);
      final numeroTrasferta = rawTr.padLeft(10, '0');
      uniqueTrasferte.add(numeroTrasferta);

      // Receipt number progressive per trasferta
      trasfertaCounters[numeroTrasferta] =
          (trasfertaCounters[numeroTrasferta] ?? 0) + 1;
      final receiptNo = trasfertaCounters[numeroTrasferta]!
          .toString()
          .padLeft(3, '0');

      // Società (BUKRS, 4 chars)
      String bukrs = getVal(colBukrs);
      if (bukrs.isEmpty && anagraficaMap != null && anagraficaMap.containsKey(cid)) {
        bukrs = anagraficaMap[cid]?.societa ?? '';
      }
      if (bukrs.isEmpty) bukrs = 'C120';
      bukrs = bukrs.padRight(4, ' ').substring(0, 4);
      countBySocieta[bukrs.trim()] = (countBySocieta[bukrs.trim()] ?? 0) + 1;

      // Tipo Dipendente (PERSK, 2 chars)
      String persk = getVal(colTipoDip);
      if (persk.isEmpty && anagraficaMap != null && anagraficaMap.containsKey(cid)) {
        final rawTipo = anagraficaMap[cid]?.tipoDip ?? '';
        if (rawTipo.contains('DR') || rawTipo.toLowerCase().contains('dirig')) {
          persk = 'DR';
        } else if (rawTipo.contains('QD') || rawTipo.toLowerCase().contains('quadr')) {
          persk = 'QD';
        } else if (rawTipo.contains('RS') || rawTipo.toLowerCase().contains('strateg')) {
          persk = 'RS';
        } else if (rawTipo.contains('IM') || rawTipo.toLowerCase().contains('impieg')) {
          persk = 'IM';
        }
      }
      if (persk.isEmpty) persk = 'IM';
      persk = persk.padRight(2, ' ').substring(0, 2);
      countByTipoDipendente[persk] = (countByTipoDipendente[persk] ?? 0) + 1;

      // Località / Destinazione (ZORT1, 59 chars)
      final rawDest = getVal(colLoc).toUpperCase();
      final zort1 = rawDest.padRight(59, ' ').substring(0, 59);

      // Giustificativo (SPKZL, 4 chars) and Tipo Attività (KZTKT, 1 char)
      String spkzl = getVal(colSpkzl);
      String kztkt = 'H';

      if (spkzl.isEmpty && existingContabileMap != null) {
        final rawB = getVal(colBolla);
        if (existingContabileMap.containsKey(rawB)) {
          final matched = existingContabileMap[rawB]!;
          spkzl = matched.giustificativoSpesa;
          kztkt = matched.tipoAttivita;
        }
      }

      if (spkzl.isEmpty) {
        if (rawDest.contains('CAR')) {
          spkzl = 'TNP1';
          kztkt = 'C';
        } else if (rawDest.contains('AEROPORTO') ||
            rawDest.contains('AIRPORT') ||
            rawDest.contains('FCO') ||
            rawDest.contains('LINATE') ||
            rawDest.contains('MALPENSA') ||
            rawDest.contains('MXP') ||
            rawDest.contains('GOA') ||
            rawDest.contains('PMO') ||
            rawDest.contains('GVA') ||
            rawDest.contains('CAI') ||
            rawDest.contains('DXB') ||
            rawDest.contains('TUN') ||
            rawDest.contains('DUSSELDORF') ||
            rawDest.contains('DULLES') ||
            rawDest.contains('VOLO')) {
          spkzl = 'TAP1';
          kztkt = 'A';
        } else if (rawDest.contains('/') || rawDest.contains('-')) {
          spkzl = 'TTP1';
          kztkt = 'T';
        } else {
          spkzl = 'ALP1';
          kztkt = 'H';
        }
      } else {
        if (spkzl.startsWith('TT')) {
          kztkt = 'T';
        } else if (spkzl.startsWith('TA')) {
          kztkt = 'A';
        } else if (spkzl.startsWith('TN')) {
          kztkt = 'C';
        } else if (spkzl.startsWith('TG')) {
          kztkt = 'F';
        } else {
          kztkt = 'H';
        }
      }
      spkzl = spkzl.padRight(4, ' ').substring(0, 4);
      countByGiustificativo[spkzl.trim()] =
          (countByGiustificativo[spkzl.trim()] ?? 0) + 1;

      // Bolla (ZZIDTKT, 12 chars)
      var rawBolla = getVal(colBolla);
      if (rawBolla.isEmpty && colZzidtkt != null) {
        rawBolla = getVal(colZzidtkt);
      }

      bollaCounters[rawBolla] = (bollaCounters[rawBolla] ?? 0) + 1;
      final bollaItemIndex =
          (bollaCounters[rawBolla]! - 1).toString().padLeft(2, '0');

      String formattedBolla;
      if (rawBolla.isEmpty) {
        formattedBolla = '000000000000';
      } else if (rawBolla.length == 12) {
        formattedBolla = rawBolla;
      } else if (rawBolla.length <= 8 && RegExp(r'^\d+$').hasMatch(rawBolla)) {
        formattedBolla = '260${rawBolla.padLeft(7, '0')}$bollaItemIndex';
      } else {
        formattedBolla = rawBolla.padLeft(12, '0').substring(0, 12);
      }

      // Data Spesa (BEGDA, 8 chars YYYYMMDD)
      final rawDate = getVal(colData);
      String dateYMD = yyyymmdd;
      String displayDate = '';

      if (rawDate.contains('/')) {
        final parts = rawDate.split('/');
        if (parts.length == 3) {
          final d = parts[0].padLeft(2, '0');
          final m = parts[1].padLeft(2, '0');
          var y = parts[2];
          if (y.length == 2) y = '20$y';
          dateYMD = '$y$m$d';
          displayDate = '$d/$m/$y';
        }
      } else if (RegExp(r'^\d{5}$').hasMatch(rawDate)) {
        final days = int.tryParse(rawDate) ?? 0;
        final dt = DateTime(1899, 12, 30).add(Duration(days: days));
        final d = dt.day.toString().padLeft(2, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final y = dt.year.toString();
        dateYMD = '$y$m$d';
        displayDate = '$d/$m/$y';
      } else if (rawDate.length == 8 && RegExp(r'^\d{8}$').hasMatch(rawDate)) {
        dateYMD = rawDate;
        displayDate =
            '${rawDate.substring(6, 8)}/${rawDate.substring(4, 6)}/${rawDate.substring(0, 4)}';
      } else {
        displayDate =
            '${yyyymmdd.substring(6, 8)}/${yyyymmdd.substring(4, 6)}/${yyyymmdd.substring(0, 4)}';
      }

      // Data/Ora Inizio & Fine
      String datv1 = dateYMD;
      String uhrv1 = '080000';
      String datb1 = dateYMD;
      String uhrb1 = '200000';

      if (trasferteSapMap != null &&
          trasferteSapMap.containsKey(numeroTrasferta)) {
        final sap = trasferteSapMap[numeroTrasferta]!;
        if (sap.dataInizioTrasferta.isNotEmpty) {
          final clean = sap.dataInizioTrasferta.replaceAll('/', '');
          if (clean.length == 8) {
            datv1 = '${clean.substring(4, 8)}${clean.substring(2, 4)}${clean.substring(0, 2)}';
          }
        }
        if (sap.oraInizioTrasferta.isNotEmpty) {
          final cleanOra = sap.oraInizioTrasferta.replaceAll(':', '');
          if (cleanOra.length == 6) uhrv1 = cleanOra;
        }
        if (sap.dataFineTrasferta.isNotEmpty) {
          final clean = sap.dataFineTrasferta.replaceAll('/', '');
          if (clean.length == 8) {
            datb1 = '${clean.substring(4, 8)}${clean.substring(2, 4)}${clean.substring(0, 2)}';
          }
        }
        if (sap.oraFineTrasferta.isNotEmpty) {
          final cleanOra = sap.oraFineTrasferta.replaceAll(':', '');
          if (cleanOra.length == 6) uhrb1 = cleanOra;
        }
      }

      // Importo (REC_AMOUNT, 20 chars)
      final rawAmount = getVal(colAmount);
      final parsedAmount =
          double.tryParse(rawAmount.replaceAll(',', '.')) ?? 0.0;
      final amountVal = parsedAmount.abs();

      final intPart = amountVal.truncate();
      final decPart = ((amountVal - intPart) * 10000000).round();
      final recAmount =
          '${intPart.toString().padLeft(12, '0')}.${decPart.toString().padLeft(7, '0')}';

      // Valuta (WAERS, 5 chars)
      final rawCurr = getVal(colCurr);
      final waers = (rawCurr.isNotEmpty ? rawCurr : 'EUR')
          .padRight(5, ' ')
          .substring(0, 5);

      // Rimborso / Segno (ZZRIMB_ANN, 1 char)
      final rawRimb = getVal(colRimb).toUpperCase();
      final isNeg = rawRimb == 'R' || rawRimb == 'A' || parsedAmount < 0;
      final rimbChar = isNeg ? 'R' : ' ';

      if (isNeg) {
        totalNeg += amountVal;
      } else {
        totalPos += amountVal;
      }

      // Line format: exactly 167 chars + newline
      final line =
          '1$cid$numeroTrasferta$receiptNo$bukrs$persk$spkzl$formattedBolla$dateYMD$zort1$datv1$uhrv1$datb1$uhrb1$kztkt$recAmount$waers$rimbChar#';

      records.add(
        GeneratedTracciatoRecord(
          index: records.length + 1,
          cid: cid,
          numeroTrasferta: numeroTrasferta,
          receiptNo: receiptNo,
          bukrs: bukrs.trim(),
          persk: persk.trim(),
          spkzl: spkzl.trim(),
          bolla: formattedBolla,
          dataSpesaFormatted: displayDate,
          dateYMD: dateYMD,
          localita: rawDest,
          dataInizio: datv1,
          oraInizio: uhrv1,
          dataFine: datb1,
          oraFine: uhrb1,
          tipoAttivita: kztkt,
          importo: amountVal,
          valuta: waers.trim(),
          isNegative: isNeg,
          rawLine: line,
        ),
      );
    }

    final totalDetails = records.length;
    final footer =
        'ZHR        AI01.TO.UTATC.Z9.P$yymmdd$yyyymmdd$hhmmss${totalDetails.toString().padLeft(12, '0')}#';

    final buffer = StringBuffer();
    buffer.writeln(header);
    for (final rec in records) {
      buffer.writeln(rec.rawLine);
    }
    buffer.write(footer);

    return TracciatoGeneratorResult(
      records: records,
      header: header,
      footer: footer,
      fullText: buffer.toString(),
      totalRecords: totalDetails,
      totalPositiveAmount: totalPos,
      totalNegativeAmount: totalNeg,
      netAmount: totalPos - totalNeg,
      uniqueTrasferteCount: uniqueTrasferte.length,
      uniqueCidCount: uniqueCids.length,
      countBySocieta: countBySocieta,
      countByGiustificativo: countByGiustificativo,
      countByTipoDipendente: countByTipoDipendente,
    );
  }
}
