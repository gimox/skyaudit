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
  test('Test Isar query results', () async {
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
    
    final types = ['contabile', 'conto', 'sap', 'amex', 'scarti', 'anagrafica', 'trasferte_sap'];
    final sourceTypes = {
      'contabile': 'Tracciato Contabile',
      'conto': 'Estratto Conto',
      'sap': 'Tracciato SAP',
      'amex': 'Estratto AMEX',
      'anagrafica': 'Anagrafica',
      'scarti': 'Scarti EC SAP',
      'trasferte_sap': 'Trasferte SAP',
    };
    
    for (final type in types) {
      final sourceType = sourceTypes[type]!;
      final existingLogs = await isar.logHistorys.filter()
          .sourceTypeEqualTo(sourceType)
          .or()
          .sourceTypeEqualTo(sourceType == 'Tracciato Contabile' ? 'contabile' : sourceType)
          .findAll();
      
      print('Type: $type, SourceType: $sourceType, Logs found: ${existingLogs.length}');
      for (final log in existingLogs) {
        print('  - ${log.fileName} (${log.date})');
      }
    }
    
    await isar.close();
  });
}
