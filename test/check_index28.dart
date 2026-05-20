import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final dir = Directory('data_mock');
  if (!dir.existsSync()) return;
  
  final List<File> excelFiles = [];
  _findExcel(dir, excelFiles);
  
  for (var file in excelFiles) {
    try {
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) continue;
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;
      if (sheet.maxRows > 0) {
        final row = sheet.rows.first;
        final headers = row.map((cell) => cell?.value?.toString().trim() ?? '').toList();
        
        // Let's check if Rif 1 is at index 28 or Rif.1 is at index 28
        String rif1Val = '';
        if (headers.length > 28) rif1Val = headers[28];
        
        String rif3Val = '';
        if (headers.length > 30) rif3Val = headers[30];
        
        if (rif1Val.toLowerCase().contains('rif') || rif3Val.toLowerCase().contains('rif')) {
          print('Matching File: ${file.path}');
          print('  Index 28: $rif1Val, Index 30: $rif3Val');
        }
      }
    } catch (_) {}
  }
}

void _findExcel(Directory dir, List<File> files) {
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.xlsx')) {
      files.add(entity);
    }
  }
}
