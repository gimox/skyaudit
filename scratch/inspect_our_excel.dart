import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  var file = '/Users/giorgiomodoni/development/skyaudit/data_mock/202606_OSPITI_GIUGNO_ECN26.xlsx';
  if (!File(file).existsSync()) {
    print('File does not exist!');
    return;
  }
  var bytes = File(file).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  print('Sheet names in Excel file: ${excel.tables.keys.toList()}');

  var sheetName = excel.tables.keys.first;
  var sheet = excel.tables[sheetName]!;
  print('Sheet name: $sheetName');
  print('Max Rows: ${sheet.maxRows}');
  print('Max Columns: ${sheet.maxColumns}');

  if (sheet.maxRows > 0) {
    var header = sheet.rows.first;
    print('--- Headers (first row) ---');
    for (var i = 0; i < header.length; i++) {
      print('Col $i: ${header[i]?.value}');
    }
  }

  if (sheet.maxRows > 1) {
    print('--- First Data Row (row 1) ---');
    var row = sheet.rows[1];
    for (var i = 0; i < row.length; i++) {
      var v = row[i]?.value;
      print('Col $i: $v (type: ${v?.runtimeType})');
    }
  }
}
