import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final file = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/scarti EC SAP/SCARTI_TC_042026_TIM e Gruppo.XLSX');
  if (file.existsSync()) {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    for (var name in excel.tables.keys) {
      final sheet = excel.tables[name]!;
      print('=== Last rows for sheet: $name (maxRows: ${sheet.maxRows}) ===');
      for (int i = sheet.maxRows - 5; i < sheet.maxRows; i++) {
        if (i < 0) continue;
        final row = sheet.rows[i];
        final trsf = row.length > 1 ? row[1]?.value : null;
        final cid = row.length > 3 ? row[3]?.value : null;
        final desc = row.length > 9 ? row[9]?.value : null;
        final date = row.length > 10 ? row[10]?.value : null;
        print('Row $i: Trsf: $trsf, CID: $cid, Desc: $desc, Date: $date');
      }
    }
  }
}
