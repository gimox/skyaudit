import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_check/features/analysis/services/tracciato_generator_service.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';

void main() {
  test('TracciatoGeneratorService correctly generates 163 records from input.xlsx', () {
    final file = File('data_mock/crea_tracciato/input.xlsx');
    expect(file.existsSync(), isTrue);

    final bytes = file.readAsBytesSync();
    final result = TracciatoGeneratorService.generateFromExcelBytes(bytes: bytes);

    expect(result.totalRecords, equals(163));
    expect(result.records.length, equals(163));
    expect(result.header.startsWith('0HR'), isTrue);
    expect(result.header.length, equals(62));
    expect(result.footer.startsWith('ZHR'), isTrue);
    expect(result.footer.length, equals(62));

    // Verify each line is valid and conforms to 167 chars and parses with TracciatoContabile
    for (final rec in result.records) {
      expect(rec.rawLine.length, equals(167));
      expect(rec.rawLine.endsWith('#'), isTrue);
      expect(rec.rawLine.startsWith('1'), isTrue);

      // Bolla must be 12 chars and must not contain 'null' or spaces
      expect(rec.bolla.length, equals(12));
      expect(rec.bolla.toLowerCase().contains('null'), isFalse);
      expect(rec.bolla.contains(' '), isFalse);

      final parsed = TracciatoContabile.fromString(rec.rawLine);
      expect(parsed.cid, equals(rec.cid));
      expect(parsed.numeroTrasferta, equals(rec.numeroTrasferta));
      expect(parsed.progressivo, equals(rec.receiptNo));
      expect(parsed.societa, equals(rec.bukrs));
      expect(parsed.isNegative, equals(rec.isNegative));
      expect(parsed.importo, closeTo(rec.importo, 0.0001));
    }
  });
}
