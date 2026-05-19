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
      ..sharepointDocumentLibrary = state.sharepointDocumentLibrary
      ..sharepointEstrattiContoPath = state.sharepointEstrattiContoPath
      ..sharepointTracciatoSapPath = state.sharepointTracciatoSapPath
      ..sharepointEstrattiAmexPath = state.sharepointEstrattiAmexPath
      ..sharepointAnagraficaPath = state.sharepointAnagraficaPath
      ..sharepointScartiTracciatoPath = state.sharepointScartiTracciatoPath;

    await isar.writeTxn(() async {
      await isar.appSettings.put(newSettings);
    });

    state = newSettings;
  }

  Future<void> updateSharepointSettings({
    required String siteName,
    required String folderPath,
    required String documentLibrary,
    required String estrattiContoPath,
    required String tracciatoSapPath,
    required String estrattiAmexPath,
    required String anagraficaPath,
    required String scartiTracciatoPath,
  }) async {
    final isar = ref.read(isarProvider);
    final newSettings = AppSettings()
      ..id = 0
      ..discardIdenticalBolla = state.discardIdenticalBolla
      ..sharepointSiteName = siteName
      ..sharepointFolderPath = folderPath
      ..sharepointDocumentLibrary = documentLibrary
      ..sharepointEstrattiContoPath = estrattiContoPath
      ..sharepointTracciatoSapPath = tracciatoSapPath
      ..sharepointEstrattiAmexPath = estrattiAmexPath
      ..sharepointAnagraficaPath = anagraficaPath
      ..sharepointScartiTracciatoPath = scartiTracciatoPath;

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
