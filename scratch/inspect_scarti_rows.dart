import 'dart:io';
import 'package:excel/excel.dart';

String getDateString(dynamic val) {
  if (val == null) return '';

  final s = val.toString().trim();
  if (s.isEmpty) return '';

  try {
    // Remove "T" or space followed by time
    String cleanS = s.split(' ')[0];
    if (cleanS.contains('T')) {
      cleanS = cleanS.split('T')[0];
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

void main() {
  final file = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/scarti EC SAP/SCARTI_TC_042026_TIM e Gruppo.XLSX');
  if (file.existsSync()) {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    for (var name in excel.tables.keys) {
      final sheet = excel.tables[name]!;
      for (int i = 1; i < 5; i++) {
        final row = sheet.rows[i];
        final rawDate = row[10]?.value;
        final formattedDate = getDateString(rawDate);
        print('Row $i: Raw Date: $rawDate, Formatted Date: $formattedDate');
      }
    }
  }
}
