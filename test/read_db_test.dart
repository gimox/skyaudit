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
  test('Read real database log history', () async {
    final dbDir = Directory('/Users/modonigiorgio/Library/Containers/com.example.travelCheck/Data/Library/Application Support/com.example.travelCheck');
    
    if (!dbDir.existsSync()) {
      print('Database directory does not exist');
      return;
    }
    
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
    
    print('--- LOG HISTORYS ---');
    final logs = await isar.logHistorys.where().anyId().findAll();
    final logMap = {for (var l in logs) l.uniqueCode: l.fileName};
    for (final log in logs) {
      print('  Log: uniqueCode=${log.uniqueCode}, fileName="${log.fileName}", sourceType="${log.sourceType}"');
    }
    
    print('--- DEBBUGGING TRASFERTA 6000000577 ---');
    
    final tracciato = await isar.tracciatoContabiles.filter().numeroTrasfertaEqualTo('6000000577').findAll();
    print('Tracciato count: ${tracciato.length}');
    for (final r in tracciato) {
      print('  Tracciato: id=${r.id}, isScarto=${r.isScarto}, importo=${r.importo}, isNegative=${r.isNegative}, bolla=${r.numeroBolla}, logFile=${logMap[r.logHistoryId]}');
    }

    final ec = await isar.estrattoContos.filter().numeroTrasfertaEqualTo('6000000577').findAll();
    print('EstrattoConto count: ${ec.length}');
    for (final r in ec) {
      print('  EstrattoConto: id=${r.id}, totaleServizio=${r.totaleServizio}, bolla=${r.bolla}, logFile=${logMap[r.logHistoryId]}');
    }

    final sap = await isar.tracciatoSaps.filter().numeroTrasfertaEqualTo('6000000577').findAll();
    print('TracciatoSap count: ${sap.length}');
    for (final r in sap) {
      print('  TracciatoSap: id=${r.id}, importo=${r.importo}, logFile=${logMap[r.logHistoryId]}');
    }

    final amex = await isar.estrattoAmexs.filter().numeroTrasfertaEqualTo('6000000577').findAll();
    print('EstrattoAmex count: ${amex.length}');
    for (final r in amex) {
      print('  EstrattoAmex: id=${r.id}, importoLordo=${r.importoLordo}, logFile=${logMap[r.logHistoryId]}');
    }

    final scarti = await isar.scartiEcSaps.filter().numeroTrasfertaEqualTo('6000000577').findAll();
    print('ScartiEcSap count: ${scarti.length}');
    for (final r in scarti) {
      print('  ScartiEcSap: id=${r.id}, importo=${r.importo}, isMatched=${r.isMatched}, logFile=${logMap[r.logHistoryId]}');
    }
    
    await isar.close();
  });
}
