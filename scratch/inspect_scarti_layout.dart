import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final file1 = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/scarti EC SAP/SCARTI_TC_03_2026_C120 e Gruppo.xlsx');
  final file2 = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/scarti EC SAP/SCARTI_TC_042026_TIM e Gruppo.XLSX');

  print('=== FILE 1: ${file1.path} ===');
  if (file1.existsSync()) {
    final bytes = file1.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    for (var name in excel.tables.keys) {
      final sheet = excel.tables[name]!;
      print('Sheet: $name, maxColumns: ${sheet.maxColumns}, maxRows: ${sheet.maxRows}');
      if (sheet.maxRows > 0) {
        final firstRow = sheet.rows[0].map((c) => c?.value).toList();
        print('Header row (0): $firstRow');
      }
    }
  } else {
    print('File 1 does not exist');
  }

  print('\n=== FILE 2: ${file2.path} ===');
  if (file2.existsSync()) {
    final bytes = file2.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    for (var name in excel.tables.keys) {
      final sheet = excel.tables[name]!;
      print('Sheet: $name, maxColumns: ${sheet.maxColumns}, maxRows: ${sheet.maxRows}');
      if (sheet.maxRows > 0) {
        final firstRow = sheet.rows[0].map((c) => c?.value).toList();
        print('Header row (0): $firstRow');
      }
    }
  } else {
    print('File 2 does not exist');
  }
}
