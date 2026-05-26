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
      ..alignWithRemote = state.alignWithRemote
      ..syncOnStartup = state.syncOnStartup
      ..lastSyncTime = state.lastSyncTime
      ..sharepointSiteName = state.sharepointSiteName
      ..sharepointFolderPath = state.sharepointFolderPath
      ..sharepointDocumentLibrary = state.sharepointDocumentLibrary
      ..sharepointEstrattiContoPath = state.sharepointEstrattiContoPath
      ..sharepointTracciatoSapPath = state.sharepointTracciatoSapPath
      ..sharepointEstrattiAmexPath = state.sharepointEstrattiAmexPath
      ..sharepointAnagraficaPath = state.sharepointAnagraficaPath
      ..sharepointScartiTracciatoPath = state.sharepointScartiTracciatoPath
      ..proxyEnabled = state.proxyEnabled
      ..proxyAutoConfig = state.proxyAutoConfig
      ..customProxyUrl = state.customProxyUrl
      ..bypassSslVerification = state.bypassSslVerification
      ..proxyUsername = state.proxyUsername
      ..proxyPassword = state.proxyPassword;

    await isar.writeTxn(() async {
      await isar.appSettings.put(newSettings);
    });

    state = newSettings;
  }

  Future<void> updateAlignWithRemote(bool value) async {
    final isar = ref.read(isarProvider);
    final newSettings = AppSettings()
      ..id = 0
      ..discardIdenticalBolla = state.discardIdenticalBolla
      ..alignWithRemote = value
      ..syncOnStartup = state.syncOnStartup
      ..lastSyncTime = state.lastSyncTime
      ..sharepointSiteName = state.sharepointSiteName
      ..sharepointFolderPath = state.sharepointFolderPath
      ..sharepointDocumentLibrary = state.sharepointDocumentLibrary
      ..sharepointEstrattiContoPath = state.sharepointEstrattiContoPath
      ..sharepointTracciatoSapPath = state.sharepointTracciatoSapPath
      ..sharepointEstrattiAmexPath = state.sharepointEstrattiAmexPath
      ..sharepointAnagraficaPath = state.sharepointAnagraficaPath
      ..sharepointScartiTracciatoPath = state.sharepointScartiTracciatoPath
      ..proxyEnabled = state.proxyEnabled
      ..proxyAutoConfig = state.proxyAutoConfig
      ..customProxyUrl = state.customProxyUrl
      ..bypassSslVerification = state.bypassSslVerification
      ..proxyUsername = state.proxyUsername
      ..proxyPassword = state.proxyPassword;

    await isar.writeTxn(() async {
      await isar.appSettings.put(newSettings);
    });

    state = newSettings;
  }

  Future<void> updateSyncOnStartup(bool value) async {
    final isar = ref.read(isarProvider);
    final newSettings = AppSettings()
      ..id = 0
      ..discardIdenticalBolla = state.discardIdenticalBolla
      ..alignWithRemote = state.alignWithRemote
      ..syncOnStartup = value
      ..lastSyncTime = state.lastSyncTime
      ..sharepointSiteName = state.sharepointSiteName
      ..sharepointFolderPath = state.sharepointFolderPath
      ..sharepointDocumentLibrary = state.sharepointDocumentLibrary
      ..sharepointEstrattiContoPath = state.sharepointEstrattiContoPath
      ..sharepointTracciatoSapPath = state.sharepointTracciatoSapPath
      ..sharepointEstrattiAmexPath = state.sharepointEstrattiAmexPath
      ..sharepointAnagraficaPath = state.sharepointAnagraficaPath
      ..sharepointScartiTracciatoPath = state.sharepointScartiTracciatoPath
      ..proxyEnabled = state.proxyEnabled
      ..proxyAutoConfig = state.proxyAutoConfig
      ..customProxyUrl = state.customProxyUrl
      ..bypassSslVerification = state.bypassSslVerification
      ..proxyUsername = state.proxyUsername
      ..proxyPassword = state.proxyPassword;

    await isar.writeTxn(() async {
      await isar.appSettings.put(newSettings);
    });

    state = newSettings;
  }

  Future<void> updateLastSyncTime(DateTime value) async {
    final isar = ref.read(isarProvider);
    final newSettings = AppSettings()
      ..id = 0
      ..discardIdenticalBolla = state.discardIdenticalBolla
      ..alignWithRemote = state.alignWithRemote
      ..syncOnStartup = state.syncOnStartup
      ..lastSyncTime = value
      ..sharepointSiteName = state.sharepointSiteName
      ..sharepointFolderPath = state.sharepointFolderPath
      ..sharepointDocumentLibrary = state.sharepointDocumentLibrary
      ..sharepointEstrattiContoPath = state.sharepointEstrattiContoPath
      ..sharepointTracciatoSapPath = state.sharepointTracciatoSapPath
      ..sharepointEstrattiAmexPath = state.sharepointEstrattiAmexPath
      ..sharepointAnagraficaPath = state.sharepointAnagraficaPath
      ..sharepointScartiTracciatoPath = state.sharepointScartiTracciatoPath
      ..proxyEnabled = state.proxyEnabled
      ..proxyAutoConfig = state.proxyAutoConfig
      ..customProxyUrl = state.customProxyUrl
      ..bypassSslVerification = state.bypassSslVerification
      ..proxyUsername = state.proxyUsername
      ..proxyPassword = state.proxyPassword;

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
      ..alignWithRemote = state.alignWithRemote
      ..syncOnStartup = state.syncOnStartup
      ..lastSyncTime = state.lastSyncTime
      ..sharepointSiteName = siteName
      ..sharepointFolderPath = folderPath
      ..sharepointDocumentLibrary = documentLibrary
      ..sharepointEstrattiContoPath = estrattiContoPath
      ..sharepointTracciatoSapPath = tracciatoSapPath
      ..sharepointEstrattiAmexPath = estrattiAmexPath
      ..sharepointAnagraficaPath = anagraficaPath
      ..sharepointScartiTracciatoPath = scartiTracciatoPath
      ..proxyEnabled = state.proxyEnabled
      ..proxyAutoConfig = state.proxyAutoConfig
      ..customProxyUrl = state.customProxyUrl
      ..bypassSslVerification = state.bypassSslVerification
      ..proxyUsername = state.proxyUsername
      ..proxyPassword = state.proxyPassword;

    await isar.writeTxn(() async {
      await isar.appSettings.put(newSettings);
    });

    state = newSettings;
  }

  Future<void> updateNetworkSettings({
    required bool proxyEnabled,
    required bool proxyAutoConfig,
    required String customProxyUrl,
    required bool bypassSslVerification,
    required String proxyUsername,
    required String proxyPassword,
  }) async {
    final isar = ref.read(isarProvider);
    final newSettings = AppSettings()
      ..id = 0
      ..discardIdenticalBolla = state.discardIdenticalBolla
      ..alignWithRemote = state.alignWithRemote
      ..syncOnStartup = state.syncOnStartup
      ..lastSyncTime = state.lastSyncTime
      ..sharepointSiteName = state.sharepointSiteName
      ..sharepointFolderPath = state.sharepointFolderPath
      ..sharepointDocumentLibrary = state.sharepointDocumentLibrary
      ..sharepointEstrattiContoPath = state.sharepointEstrattiContoPath
      ..sharepointTracciatoSapPath = state.sharepointTracciatoSapPath
      ..sharepointEstrattiAmexPath = state.sharepointEstrattiAmexPath
      ..sharepointAnagraficaPath = state.sharepointAnagraficaPath
      ..sharepointScartiTracciatoPath = state.sharepointScartiTracciatoPath
      ..proxyEnabled = proxyEnabled
      ..proxyAutoConfig = proxyAutoConfig
      ..customProxyUrl = customProxyUrl
      ..bypassSslVerification = bypassSslVerification
      ..proxyUsername = proxyUsername
      ..proxyPassword = proxyPassword;

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
