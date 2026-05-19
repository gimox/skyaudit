import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  // 1. Read Scarti EC SAP
  final scartiFile = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/scarti EC SAP/SCARTI_TC_03_2026_C120 e Gruppo.xlsx');
  if (!scartiFile.existsSync()) {
    print('Scarti file not found.');
    return;
  }
  
  final bytes = scartiFile.readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  final scartiMap = <String, Map<String, dynamic>>{};
  
  for (var name in excel.tables.keys) {
    final sheet = excel.tables[name]!;
    print('Processing sheet: $name with ${sheet.maxRows} rows.');
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;
      
      final bool isNewFormat = sheet.maxColumns >= 15;
      
      String getVal(int index) {
        if (index >= row.length) return '';
        return row[index]?.value?.toString().trim() ?? '';
      }
      
      final String trasf = isNewFormat ? getVal(1) : getVal(0);
      final String cid = isNewFormat ? getVal(3) : getVal(1);
      final String spesa = isNewFormat ? getVal(12) : getVal(3);
      final String importoStr = isNewFormat ? getVal(14) : getVal(4);
      
      if (trasf.isEmpty && cid.isEmpty) continue;
      
      scartiMap[trasf] = {
        'trasferta': trasf,
        'cid': cid,
        'spesa': spesa,
        'importo': importoStr,
      };
    }
  }
  
  print('Total scarti parsed: ${scartiMap.length}');
  print('First 5 scarti entries:');
  final scartiKeys = scartiMap.keys.take(5).toList();
  for (final k in scartiKeys) {
    print('  Trasferta: "$k" -> ${scartiMap[k]}');
  }

  // 2. Read UVET txt files to search for any match
  final uvetFile = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/flusso UVET/TIM_20260327_Marzo_ConAltreSocieta_GenFeb.txt');
  if (!uvetFile.existsSync()) {
    print('UVET file not found.');
    return;
  }
  
  final lines = uvetFile.readAsLinesSync(encoding: utf8);
  print('Total UVET lines: ${lines.length}');
  
  print('Searching matches for first 5 scarti trasferte in UVET file...');
  for (int i = 1; i < lines.length - 1; i++) {
    final line = lines[i];
    if (line.length < 52) continue;
    
    final tcCid = line.substring(1, 9).trim();
    final tcTrasf = line.substring(9, 19).trim();
    
    // Check if tcTrasf matches any of the scarti keys (with or without leading zeros)
    for (final sk in scartiMap.keys) {
      final cleanSk = sk.split('.')[0];
      final cleanTcTrasf = tcTrasf.replaceAll(RegExp(r'^0+'), '');
      final cleanSkNoZeros = cleanSk.replaceAll(RegExp(r'^0+'), '');
      
      if (cleanTcTrasf == cleanSkNoZeros) {
        print('FOUND MATCH in line ${i + 1}:');
        print('  UVET Line CID: "$tcCid", Trasferta: "$tcTrasf", Full line segment: "${line.substring(0, 52)}"');
        print('  Scarto Trasferta: "$sk", CID: "${scartiMap[sk]!['cid']}"');
      }
    }
  }
}
