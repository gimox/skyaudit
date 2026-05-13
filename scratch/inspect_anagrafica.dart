import 'dart:io';
import 'package:excel/excel.dart';

void main(List<String> args) {
  var file = args.isNotEmpty ? args[0] : '/Users/giorgiomodoni/development/skyaudit/data_mock/Database Domestic 8 aprile.xlsx';
  var bytes = File(file).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);

  var table = 'Anagrafica';
  var sheet = excel.tables[table]!;
  
  var header = sheet.rows.first;
  
  for (var i = 0; i < 66; i++) {
    var h = header[i]?.value;
    print('Column $i (Letter ${getColumnLetter(i)}): $h');
  }
}

String getColumnLetter(int index) {
  String letter = '';
  while (index >= 0) {
    letter = String.fromCharCode((index % 26) + 65) + letter;
    index = (index / 26).floor() - 1;
  }
  return letter;
}
