import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  final Map<String, dynamic> cityCoordinates = {
    'roma': null,
    'milano': null,
    'torino': null,
    'napoli': null,
    'firenze': null,
    'bologna': null,
    'venezia': null,
    'palermo': null,
    'genova': null,
    'bari': null,
    'catanzaro': null,
    'cagliari': null,
    'perugia': null,
    'ancona': null,
    'potenza': null,
    'campobasso': null,
    'aosta': null,
    'trento': null,
    'trieste': null,
    'l\'aquila': null,
    'laquila': null,
    'verona': null,
    'padova': null,
    'brescia': null,
    'monza': null,
    'bergamo': null,
    'taranto': null,
    'reggio calabria': null,
    'messina': null,
    'catania': null,
    'sassari': null,
    'salerno': null,
    'foggia': null,
    'pescara': null,
    'latina': null,
    'modena': null,
    'parma': null,
    'reggio emilia': null,
    'livorno': null,
    'pisa': null,
    'siena': null,
    'lucca': null,
    'prato': null,
    'ferrara': null,
    'ravenna': null,
    'rimini': null,
    'forli': null,
    'cesena': null,
    'vicenza': null,
    'treviso': null,
    'udine': null,
    'bolzano': null,
    'pavia': null,
    'cremona': null,
    'mantova': null,
    'piacenza': null,
    'novara': null,
    'alessandria': null,
    'asti': null,
    'cuneo': null,
    'como': null,
    'varese': null,
    'lecco': null,
    'lodi': null,
  };

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
    if (!cityCoordinates.containsKey(c.toLowerCase())) {
      missing.add(c);
    }
  }

  print('Comuni mancanti nelle coordinate:');
  missing.sort();
  for (var m in missing) {
    print(m);
  }
}
