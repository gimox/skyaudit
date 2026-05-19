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
  final scartiList = <Map<String, dynamic>>[];
  
  for (var name in excel.tables.keys) {
    final sheet = excel.tables[name]!;
    for (int i = 1; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;
      
      final bool isNewFormat = sheet.maxColumns >= 15;
      
      String getVal(int index) {
        if (index >= row.length) return '';
        return row[index]?.value?.toString().trim() ?? '';
      }
      
      double getDouble(int index) {
        if (index >= row.length) return 0.0;
        final val = row[index]?.value;
        if (val == null) return 0.0;
        final s = val.toString().replaceAll(' ', '').replaceAll(',', '.').trim();
        return double.tryParse(s) ?? 0.0;
      }
      
      final String trasf = isNewFormat ? getVal(1) : getVal(0);
      final String cid = isNewFormat ? getVal(3) : getVal(1);
      final String spesa = isNewFormat ? getVal(12) : getVal(3);
      final double importo = isNewFormat ? getDouble(14) : getDouble(4);
      final String storno = isNewFormat ? getVal(16) : getVal(6);
      
      double finalImporto = importo;
      if (storno == '-' || storno == 'R') {
        finalImporto = -importo;
      }
      
      if (trasf.isEmpty && cid.isEmpty) continue;
      
      // Pad CID
      String paddedCid = cid.replaceAll(RegExp(r'^0+'), '').padLeft(8, '0');
      if (cid.isEmpty) paddedCid = '';
      
      scartiList.add({
        'trasferta': trasf.split('.')[0],
        'cid': paddedCid,
        'spesa': spesa,
        'importo': finalImporto,
      });
    }
  }

  // 2. Read UVET txt files
  final uvetFile = File('/Users/modonigiorgio/Developer/travelcheck/data_mock/flusso UVET/TIM_20260327_Marzo_ConAltreSocieta_GenFeb.txt');
  if (!uvetFile.existsSync()) {
    print('UVET file not found.');
    return;
  }
  
  final lines = uvetFile.readAsLinesSync(encoding: utf8);
  final uvetList = <Map<String, dynamic>>[];
  for (int i = 1; i < lines.length - 1; i++) {
    final line = lines[i];
    if (line.length < 166) continue;
    
    final tcCid = line.substring(1, 9).trim().padLeft(8, '0');
    final tcTrasf = line.substring(9, 19).trim();
    final rawImporto = line.substring(140, 160).trim();
    final double importo = double.tryParse(rawImporto) ?? 0.0;
    final isNegative = line.substring(165, 166) == 'R';
    final double finalImporto = isNegative ? -importo : importo;
    
    uvetList.add({
      'cid': tcCid,
      'trasferta': tcTrasf,
      'importo': finalImporto,
    });
  }
  
  print('Parsed ${scartiList.length} scarti records and ${uvetList.length} UVET records.');
  
  int unmatchedWithTrasfertaPresent = 0;
  
  for (final sc in scartiList) {
    // Check if trasferta is present in UVET
    final matchingTrasferte = uvetList.where((uv) => uv['trasferta'] == sc['trasferta']).toList();
    final hasTrasferta = matchingTrasferte.isNotEmpty;
    
    // Check if there is a full match (CID + Trasferta + Importo)
    final fullMatches = matchingTrasferte.where((uv) {
      final cidMatch = uv['cid'] == sc['cid'];
      final importoMatch = (uv['importo'] - sc['importo']).abs() < 0.01;
      return cidMatch && importoMatch;
    }).toList();
    
    final isMatched = fullMatches.isNotEmpty;
    
    if (!isMatched) {
      if (hasTrasferta) {
        unmatchedWithTrasfertaPresent++;
        print('UNMATCHED SCARTO (but Trasferta is present):');
        print('  Scarto: Trasferta="${sc['trasferta']}", CID="${sc['cid']}", Importo=${sc['importo']}');
        print('  Matching UVET records for this Trasferta (${matchingTrasferte.length} found):');
        for (var uv in matchingTrasferte) {
          final cidMatch = uv['cid'] == sc['cid'];
          final importoMatch = (uv['importo'] - sc['importo']).abs() < 0.01;
          print('    - UVET: CID="${uv['cid']}" (match? $cidMatch), Importo=${uv['importo']} (match? $importoMatch)');
        }
      } else {
        print('UNMATCHED SCARTO (Trasferta completely absent):');
        print('  Scarto: Trasferta="${sc['trasferta']}", CID="${sc['cid']}", Importo=${sc['importo']}');
      }
    }
  }
  
  print('Summary: unmatched with trasferta present = $unmatchedWithTrasfertaPresent');
}
