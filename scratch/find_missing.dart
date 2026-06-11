import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  // 1. Read _cityCoordinates keys from anagrafica_view.dart
  final viewFile = File('/Users/giorgiomodoni/development/skyaudit/lib/features/anagrafica/anagrafica_view.dart');
  if (!viewFile.existsSync()) {
    print('anagrafica_view.dart non trovato!');
    return;
  }
  final content = viewFile.readAsStringSync();
  final mapRegExp = RegExp(r'static const Map<String, LatLng> _cityCoordinates = \{(.*?)\};', dotAll: true);
  final mapMatch = mapRegExp.firstMatch(content);
  if (mapMatch == null) {
    print('Mappa _cityCoordinates non trovata in anagrafica_view.dart!');
    return;
  }

  final mapContent = mapMatch.group(1)!;
  final keys = <String>{};
  for (var line in mapContent.split('\n')) {
    line = line.trim();
    if (line.isEmpty || line.startsWith('//')) continue;
    final parts = line.split(':');
    if (parts.length >= 2) {
      var keyPart = parts[0].trim();
      if ((keyPart.startsWith("'") && keyPart.endsWith("'")) ||
          (keyPart.startsWith('"') && keyPart.endsWith('"'))) {
        final key = keyPart.substring(1, keyPart.length - 1)
            .replaceAll(r'\', '')
            .toLowerCase()
            .trim();
        keys.add(key);
      }
    }
  }
  print('Caricate ${keys.length} coordinate pulite da anagrafica_view.dart.');

  // 2. Read Excel
  var file = '/Users/giorgiomodoni/development/skyaudit/data_mock/Database Domestic 8 aprile.xlsx';
  if (!File(file).existsSync()) {
    print('File mock non trovato!');
    return;
  }

  var bytes = File(file).readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);
  var sheet = excel.tables['Anagrafica'];
  if (sheet == null) {
    print('Foglio Anagrafica non trovato!');
    return;
  }

  final uniqueComuni = <String>{};
  for (var row in sheet.rows.skip(1)) {
    if (row.length > 41) {
      var val = row[41]?.value?.toString().trim();
      if (val != null && val.isNotEmpty) {
        uniqueComuni.add(val);
      }
    }
  }
  print('Comuni trovati nel file Excel: ${uniqueComuni.length}');

  final missing = <String>[];
  for (var c in uniqueComuni) {
    final cLower = c.toLowerCase().trim();
    if (!keys.contains(cLower)) {
      missing.add(c);
    }
  }

  print('Comuni mancanti reali (${missing.length}):');
  missing.sort();
  for (var m in missing) {
    print(m);
  }
}
