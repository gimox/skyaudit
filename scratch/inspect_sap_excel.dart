import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final bytes = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/Query_prepagati_2026_dopo caricamento 28042026.XLS.xlsx').readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  
  for (var table in excel.tables.keys) {
    print('Sheet: $table');
    final sheet = excel.tables[table]!;
    if (sheet.maxRows > 0) {
      final header = sheet.rows[0];
      for (var i = 0; i < header.length; i++) {
        print('Col ${i} (${String.fromCharCode(65 + i)}): ${header[i]?.value}');
      }
    }
  }
}
