import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  var file = '/Users/giorgiomodoni/development/skyaudit/data_mock/Estratto conto ECN26-08866.xlsx';
  var bytes = File(file).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  var table = 'Document';
  var sheet = excel.tables[table]!;
  
  print('Sheet Max Rows: ${sheet.maxRows}');
  print('Sheet Max Columns: ${sheet.maxColumns}');

  var header = sheet.rows.first;
  var row = sheet.rows[1];

  for (var i = 0; i < 55; i++) {
    var h = i < header.length ? header[i]?.value : 'OUT_OF_BOUNDS';
    var v = i < row.length ? row[i]?.value : 'OUT_OF_BOUNDS';
    var type = i < row.length ? row[i]?.value.runtimeType : 'N/A';
    print('Index $i | Header: $h | Value: $v | Type: $type');
  }
}
