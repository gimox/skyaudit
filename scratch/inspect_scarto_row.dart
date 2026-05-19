import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final file = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/scarti EC SAP/SCARTI_TC_03_2026_C120 e Gruppo.xlsx');
  if (!file.existsSync()) {
    print('File not found.');
    return;
  }
  
  final bytes = file.readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  
  for (var name in excel.tables.keys) {
    final sheet = excel.tables[name]!;
    print('Sheet: $name');
    
    // Print headers
    final header = sheet.rows[0];
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;
      
      final trasf = row[0]?.value?.toString().trim() ?? '';
      if (trasf.contains('6000002736') || trasf.contains('6000003104')) {
        print('Row $i:');
        for (int c = 0; c < row.length; c++) {
          final hName = c < header.length ? header[c]?.value : 'Col $c';
          print('  $hName ($c): "${row[c]?.value}" (${row[c]?.value.runtimeType})');
        }
      }
    }
  }
}
