import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/db/isar_provider.dart';
import '../../../core/services/proxy_service.dart';
import '../models/app_settings.dart';

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final isar = ref.watch(isarProvider);
  return AppSettingsNotifier(isar);
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final Isar _isar;

  AppSettingsNotifier(this._isar) : super(AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _isar.appSettings.get(0);
    if (settings != null) {
      state = settings;
    } else {
      final initial = AppSettings();
      await _isar.writeTxn(() async {
        await _isar.appSettings.put(initial);
      });
      state = initial;
    }
  }

  Future<void> updateNetworkSettings({
    required bool proxyEnabled,
    required bool proxyAutoConfig,
    required String customProxyUrl,
    required bool bypassSslVerification,
    required String proxyUsername,
    required String proxyPassword,
  }) async {
    final updated = AppSettings()
      ..id = 0
      ..appName = state.appName
      ..sharepointSiteName = state.sharepointSiteName
      ..sharepointDocumentLibrary = state.sharepointDocumentLibrary
      ..syncOnStartup = state.syncOnStartup
      ..proxyEnabled = proxyEnabled
      ..proxyAutoConfig = proxyAutoConfig
      ..customProxyUrl = customProxyUrl
      ..bypassSslVerification = bypassSslVerification
      ..proxyUsername = proxyUsername
      ..proxyPassword = proxyPassword;

    await _isar.writeTxn(() async {
      await _isar.appSettings.put(updated);
    });

    state = updated;
    await ProxyService.initialize(updated);
  }
}
