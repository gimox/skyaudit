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
    });

    // Invalidate main records provider to refresh the UI
    ref.invalidate(tracciatoContabilesProvider);
    ref.invalidate(tracciatoSapProvider);
    ref.invalidate(estrattoContoProvider);
    ref.invalidate(estrattoAmexProvider);

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
