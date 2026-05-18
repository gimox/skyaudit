import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final bytes = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/scarti EC SAP/SCARTI_TC_03_2026_C120 e Gruppo.xlsx').readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  
  for (var table in excel.tables.keys) {
    print('Sheet: $table');
    final sheet = excel.tables[table]!;
    if (sheet.maxRows > 0) {
      final header = sheet.rows[0];
      for (var i = 0; i < header.length; i++) {
        print('Col $i (${String.fromCharCode(65 + i)}): ${header[i]?.value}');
      }
      print('First row of data:');
      if (sheet.maxRows > 1) {
        final row = sheet.rows[1];
        for (var i = 0; i < row.length; i++) {
          print('Col $i: ${row[i]?.value}');
        }
      }
    }
  }
}
