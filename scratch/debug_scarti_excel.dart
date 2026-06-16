import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  try {
    final filePath = '/Users/modonigiorgio/Downloads/202605_SCARTI_TC_052026_TIM e Gruppo.XLSX';
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    
    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) {
        print('Sheet $table is null');
        continue;
      }
      print('Sheet: $table, maxRows: ${sheet.maxRows}, maxColumns: ${sheet.maxColumns}');
      
      final bool isNewFormat = sheet.maxColumns >= 15;
      print('isNewFormat: $isNewFormat');

      for (int i = 1; i < sheet.maxRows; i++) {
        if (i >= sheet.rows.length) {
          print('Row $i is out of bounds (rows length: ${sheet.rows.length})');
          continue;
        }
        final row = sheet.rows[i];
        if (row == null) {
          print('Row $i is null');
          continue;
        }
        if (row.isEmpty) {
          print('Row $i is empty');
          continue;
        }

        String getString(int index) {
          if (index >= row.length) return '';
          final val = row[index]?.value;
          if (val == null) return '';
          return val.toString().trim();
        }

        String getTrasferta(int index) {
          if (index >= row.length) return '';
          final val = row[index]?.value;
          if (val == null) return '';
          String s = val.toString().trim();
          if (s.contains('.')) {
            s = s.split('.')[0];
          }
          return s;
        }

        String getCid(int index) {
          if (index >= row.length) return '';
          final val = row[index]?.value;
          if (val == null) return '';
          String s = val.toString().trim();
          if (s.isEmpty) return '';
          if (s.contains('.')) {
            s = s.split('.')[0];
          }
          return s.padLeft(8, '0');
        }

        double getDouble(int index) {
          if (index >= row.length) return 0.0;
          final val = row[index]?.value;
          if (val == null) return 0.0;
          if (val is DoubleCellValue) return val.value;
          if (val is IntCellValue) return val.value.toDouble();
          String s = val.toString().replaceAll(' ', '').trim();
          if (s.isEmpty) return 0.0;
          return double.tryParse(s) ?? 0.0;
        }

        String getDateString(int index) {
          if (index >= row.length) return '';
          final val = row[index]?.value;
          if (val == null) return '';
          return val.toString().trim();
        }

        final trasferta = isNewFormat ? getTrasferta(1) : getTrasferta(0);
        final cid = isNewFormat ? getCid(3) : getCid(1);

        if (trasferta.isEmpty && cid.isEmpty) {
          continue;
        }

        if (isNewFormat) {
          double importo = getDouble(14);
          final qVal = getString(16);
          final dataInvio = getDateString(10);
          
          if (i < 5) {
            print('Row $i: trasferta=$trasferta, cid=$cid, importo=$importo, qVal=$qVal, dataInvio=$dataInvio');
          }
        } else {
          double importo = getDouble(4);
          final stornoVal = getString(6);
          final dataInvio = getDateString(7);
          
          if (i < 5) {
            print('Row $i: trasferta=$trasferta, cid=$cid, importo=$importo, stornoVal=$stornoVal, dataInvio=$dataInvio');
          }
        }
      }
    }
    print('SUCCESS parsing!');
  } catch (e, s) {
    print('ERROR: $e');
    print('STACK: $s');
  }
}
