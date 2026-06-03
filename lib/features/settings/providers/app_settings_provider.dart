import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/app_settings.dart';

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final isar = ref.watch(isarProvider);
    return isar.appSettings.getSync(0) ?? AppSettings();
  }

  AppSettings _cloneWithState(AppSettings s) {
    return AppSettings()
      ..id = 0
      ..discardIdenticalBolla = s.discardIdenticalBolla
      ..alignWithRemote = s.alignWithRemote
      ..syncOnStartup = s.syncOnStartup
      ..lastSyncTime = s.lastSyncTime
      ..clearBeforeSync = s.clearBeforeSync
      ..sharepointSiteName = s.sharepointSiteName
      ..sharepointFolderPath = s.sharepointFolderPath
      ..sharepointDocumentLibrary = s.sharepointDocumentLibrary
      ..sharepointEstrattiContoPath = s.sharepointEstrattiContoPath
      ..sharepointTracciatoSapPath = s.sharepointTracciatoSapPath
      ..sharepointEstrattiAmexPath = s.sharepointEstrattiAmexPath
      ..sharepointAnagraficaPath = s.sharepointAnagraficaPath
      ..sharepointScartiTracciatoPath = s.sharepointScartiTracciatoPath
      ..sharepointTrasferteSapPath = s.sharepointTrasferteSapPath
      ..proxyEnabled = s.proxyEnabled
      ..proxyAutoConfig = s.proxyAutoConfig
      ..customProxyUrl = s.customProxyUrl
      ..bypassSslVerification = s.bypassSslVerification
      ..proxyUsername = s.proxyUsername
      ..proxyPassword = s.proxyPassword
      ..amexFilterHeaderLabel = s.amexFilterHeaderLabel
      ..amexFilterHeaderValue = s.amexFilterHeaderValue;
  }

  Future<void> _saveSettings(AppSettings newSettings) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() async {
      await isar.appSettings.put(newSettings);
    });
    state = newSettings;
  }

  Future<void> updateDiscardIdenticalBolla(bool value) async {
    final newSettings = _cloneWithState(state)..discardIdenticalBolla = value;
    await _saveSettings(newSettings);
  }

  Future<void> updateAlignWithRemote(bool value) async {
    final newSettings = _cloneWithState(state)..alignWithRemote = value;
    await _saveSettings(newSettings);
  }

  Future<void> updateSyncOnStartup(bool value) async {
    final newSettings = _cloneWithState(state)..syncOnStartup = value;
    await _saveSettings(newSettings);
  }

  Future<void> updateLastSyncTime(DateTime value) async {
    final newSettings = _cloneWithState(state)..lastSyncTime = value;
    await _saveSettings(newSettings);
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
    required String trasferteSapPath,
  }) async {
    final newSettings = _cloneWithState(state)
      ..sharepointSiteName = siteName
      ..sharepointFolderPath = folderPath
      ..sharepointDocumentLibrary = documentLibrary
      ..sharepointEstrattiContoPath = estrattiContoPath
      ..sharepointTracciatoSapPath = tracciatoSapPath
      ..sharepointEstrattiAmexPath = estrattiAmexPath
      ..sharepointAnagraficaPath = anagraficaPath
      ..sharepointScartiTracciatoPath = scartiTracciatoPath
      ..sharepointTrasferteSapPath = trasferteSapPath;
    await _saveSettings(newSettings);
  }

  Future<void> updateNetworkSettings({
    required bool proxyEnabled,
    required bool proxyAutoConfig,
    required String customProxyUrl,
    required bool bypassSslVerification,
    required String proxyUsername,
    required String proxyPassword,
  }) async {
    final newSettings = _cloneWithState(state)
      ..proxyEnabled = proxyEnabled
      ..proxyAutoConfig = proxyAutoConfig
      ..customProxyUrl = customProxyUrl
      ..bypassSslVerification = bypassSslVerification
      ..proxyUsername = proxyUsername
      ..proxyPassword = proxyPassword;
    await _saveSettings(newSettings);
  }

  Future<void> updateClearBeforeSync(bool value) async {
    final newSettings = _cloneWithState(state)..clearBeforeSync = value;
    await _saveSettings(newSettings);
  }

  Future<void> updateAmexFilterSettings({
    required String label,
    required String value,
  }) async {
    final newSettings = _cloneWithState(state)
      ..amexFilterHeaderLabel = label
      ..amexFilterHeaderValue = value;
    await _saveSettings(newSettings);
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  () {
    return AppSettingsNotifier();
  },
);
