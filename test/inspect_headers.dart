import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final dir = Directory('data_mock');
  if (!dir.existsSync()) {
    print('data_mock not found!');
    return;
  }
  
  final List<File> excelFiles = [];
  _findExcel(dir, excelFiles);
  
  print('Found ${excelFiles.length} excel files.');
  
  for (var file in excelFiles) {
    final lowerPath = file.path.toLowerCase();
    if (!lowerPath.contains('amex') && !lowerPath.contains('ec gruppo') && !lowerPath.contains('ec tim')) {
      continue;
    }
    print('File: ${file.path}');
    try {
      final bytes = file.readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        print('  No sheets.');
        continue;
      }
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;
      print('  Sheet: $sheetName');
      if (sheet.maxRows > 0) {
        final row = sheet.rows.first;
        final headers = row.map((cell) => cell?.value?.toString() ?? '').toList();
        print('  Headers count: ${headers.length}');
        print('  Headers: $headers');
        
        for (var i = 0; i < headers.length; i++) {
          final h = headers[i].toLowerCase();
          if (h.contains('rif') || h.contains('conto') || h.contains('importo') || h.contains('trasferta') || h.contains('cid')) {
            print('    Index $i: ${headers[i]}');
          }
        }
      }
    } catch (e) {
      print('  Error: $e');
    }
    print('---');
  }
}

void _findExcel(Directory dir, List<File> files) {
  for (var entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.xlsx')) {
      files.add(entity);
    }
  }
}
