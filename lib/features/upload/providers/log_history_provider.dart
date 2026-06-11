import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/models/estratto_amex.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/providers/estratto_amex_provider.dart';
import 'package:travel_check/features/upload/models/trasferte_sap.dart';
import 'package:travel_check/features/upload/providers/trasferte_sap_provider.dart';

import 'package:travel_check/features/upload/models/anagrafica.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/features/upload/models/scarti_ec_sap.dart';
import 'package:travel_check/features/upload/providers/scarti_ec_sap_provider.dart';

class LogHistoryNotifier extends Notifier<List<LogHistory>> {
  @override
  List<LogHistory> build() {
    final isar = ref.watch(isarProvider);
    final logs = isar.logHistorys.where().anyId().findAllSync();
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  Future<void> deleteLogHistoryAndRecords(String uniqueCode) async {
    final isar = ref.read(isarProvider);

    await isar.writeTxn(() async {
      // Delete from LogHistory
      await isar.logHistorys.filter().uniqueCodeEqualTo(uniqueCode).deleteAll();

      // Delete from TracciatoContabile
      await isar.tracciatoContabiles
          .filter()
          .logHistoryIdEqualTo(uniqueCode)
          .deleteAll();

      // Delete from TracciatoSap
      await isar.tracciatoSaps
          .filter()
          .logHistoryIdEqualTo(uniqueCode)
          .deleteAll();

      // Delete from EstrattoConto
      await isar.estrattoContos
          .filter()
          .logHistoryIdEqualTo(uniqueCode)
          .deleteAll();

      // Delete from EstrattoAmex
      await isar.estrattoAmexs
          .filter()
          .logHistoryIdEqualTo(uniqueCode)
          .deleteAll();

      // Delete from Anagrafica (Nota: qui usiamo importBatch che è il corrispondente di logHistoryId)
      await isar.anagraficas
          .filter()
          .importBatchEqualTo(uniqueCode)
          .deleteAll();

      // Delete from ScartiEcSap
      await isar.scartiEcSaps
          .filter()
          .logHistoryIdEqualTo(uniqueCode)
          .deleteAll();

      // Reset matching contabile records scarto status
      final matchedContabile = await isar.tracciatoContabiles
          .filter()
          .scartoLogHistoryIdEqualTo(uniqueCode)
          .findAll();

      if (matchedContabile.isNotEmpty) {
        final resetContabile = matchedContabile.map((bestMatch) {
          return TracciatoContabile(
            recordType: bestMatch.recordType,
            cid: bestMatch.cid,
            numeroTrasferta: bestMatch.numeroTrasferta,
            progressivo: bestMatch.progressivo,
            societa: bestMatch.societa,
            tipoDipendente: bestMatch.tipoDipendente,
            giustificativoSpesa: bestMatch.giustificativoSpesa,
            numeroBolla: bestMatch.numeroBolla,
            dataSpesa: bestMatch.dataSpesa,
            localita: bestMatch.localita,
            dataInizio: bestMatch.dataInizio,
            oraInizio: bestMatch.oraInizio,
            dataFine: bestMatch.dataFine,
            oraFine: bestMatch.oraFine,
            tipoAttivita: bestMatch.tipoAttivita,
            importo: bestMatch.importo,
            valuta: bestMatch.valuta,
            isNegative: bestMatch.isNegative,
            logHistoryId: bestMatch.logHistoryId,
            sourceFileLine: bestMatch.sourceFileLine,
            isScarto: false,
            scartoLogHistoryId: null,
          )..id = bestMatch.id;
        }).toList();
        await isar.tracciatoContabiles.putAll(resetContabile);
      }

      // Delete from TrasferteSap
      await isar.trasferteSaps
          .filter()
          .logHistoryIdEqualTo(uniqueCode)
          .deleteAll();
    });

    // Invalidate main records provider to refresh the UI
    ref.invalidate(tracciatoContabilesProvider);
    ref.invalidate(tracciatoSapProvider);
    ref.invalidate(estrattoContoProvider);
    ref.invalidate(estrattoAmexProvider);
    ref.invalidate(anagraficaProvider);
    ref.invalidate(scartiEcSapProvider);
    ref.invalidate(trasferteSapProvider);

    // Refresh state
    final logs = isar.logHistorys.where().anyId().findAllSync();
    logs.sort((a, b) => b.date.compareTo(a.date));
    state = logs;
  }
}

final logHistoryProvider =
    NotifierProvider<LogHistoryNotifier, List<LogHistory>>(() {
      return LogHistoryNotifier();
    });
