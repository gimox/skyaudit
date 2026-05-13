import 'dart:io';
import 'package:excel2003/excel2003.dart';

void main() {
  final file = '/Users/giorgiomodoni/development/skyaudit/data_mock/estratti conto/amex/E.C. AMEX APRILE 2026.xls';
  final bytes = File(file).readAsBytesSync();
  final excel = XlsReader.fromBytes(bytes);

  for (var i = 0; i < excel.sheetCount; i++) {
    final sheet = excel.sheet(i);
    print('Sheet: ${sheet.name}');
    if (sheet.rows.isNotEmpty) {
      final header = sheet.rows[0];
      for (var j = 0; j < header.length; j++) {
        final val = header[j];
        print('Column $j (${_getColName(j)}): $val');
      }
    }
    print('---');
  }
}

String _getColName(int index) {
  var name = '';
  while (index >= 0) {
    name = String.fromCharCode((index % 26) + 65) + name;
    index = (index ~/ 26) - 1;
  }
  return name;
}
