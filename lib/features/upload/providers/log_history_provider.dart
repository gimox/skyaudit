import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';

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
    });

    // Invalidate main records provider to refresh the UI
    ref.invalidate(tracciatoContabilesProvider);

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
