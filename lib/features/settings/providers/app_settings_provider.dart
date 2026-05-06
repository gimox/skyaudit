import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/app_settings.dart';

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final isar = ref.watch(isarProvider);
    return isar.appSettings.getSync(0) ?? AppSettings();
  }

  Future<void> updateDiscardIdenticalBolla(bool value) async {
    final isar = ref.read(isarProvider);
    final settings = state;
    settings.discardIdenticalBolla = value;

    await isar.writeTxn(() async {
      await isar.appSettings.put(settings);
    });

    state = settings;
    // We manually trigger an update if needed, but state assignment should be enough
    ref.notifyListeners();
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  () {
    return AppSettingsNotifier();
  },
);
