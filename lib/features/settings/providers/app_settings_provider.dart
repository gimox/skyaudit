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
    final newSettings = AppSettings()
      ..id = 0
      ..discardIdenticalBolla = value
      ..sharepointSiteName = state.sharepointSiteName
      ..sharepointFolderPath = state.sharepointFolderPath
      ..sharepointDocumentLibrary = state.sharepointDocumentLibrary;

    await isar.writeTxn(() async {
      await isar.appSettings.put(newSettings);
    });

    state = newSettings;
  }

  Future<void> updateSharepointSettings({
    required String siteName,
    required String folderPath,
    required String documentLibrary,
  }) async {
    final isar = ref.read(isarProvider);
    final newSettings = AppSettings()
      ..id = 0
      ..discardIdenticalBolla = state.discardIdenticalBolla
      ..sharepointSiteName = siteName
      ..sharepointFolderPath = folderPath
      ..sharepointDocumentLibrary = documentLibrary;

    await isar.writeTxn(() async {
      await isar.appSettings.put(newSettings);
    });

    state = newSettings;
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  () {
    return AppSettingsNotifier();
  },
);
