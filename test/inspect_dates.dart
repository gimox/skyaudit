import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';
import 'package:travel_check/features/upload/models/estratto_amex.dart';
import 'package:travel_check/features/upload/models/anagrafica.dart';
import 'package:travel_check/features/upload/models/scarti_ec_sap.dart';
import 'package:travel_check/features/upload/models/trasferte_sap.dart';
import 'package:travel_check/features/settings/models/dictionary.dart';
import 'package:travel_check/features/settings/models/app_settings.dart';

void main() {
  test('Inspect lastLog dates and calculate comparison', () async {
    final dbDir = Directory('/Users/modonigiorgio/Library/Containers/com.example.travelCheck/Data/Library/Application Support/com.example.travelCheck');
    await Isar.initializeIsarCore(download: true);
    final isar = await Isar.open(
      [
        TracciatoContabileSchema,
        LogHistorySchema,
        DictionarySchema,
        AppSettingsSchema,
        EstrattoContoSchema,
        TracciatoSapSchema,
        EstrattoAmexSchema,
        AnagraficaSchema,
        ScartiEcSapSchema,
        TrasferteSapSchema,
      ],
      directory: dbDir.path,
      name: 'default',
    );
    
    final logs = await isar.logHistorys.where().anyId().findAll();
    for (final log in logs) {
      if (log.fileName.contains('SCARTI')) {
        print('File: ${log.fileName}');
        print('  - Log Date: ${log.date} (isUtc: ${log.date.isUtc})');
        print('  - Log Date plus 5 seconds: ${log.date.add(Duration(seconds: 5))}');
      }
    }
    await isar.close();
  });
}
