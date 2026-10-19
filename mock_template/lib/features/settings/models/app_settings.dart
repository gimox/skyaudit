import 'package:isar_community/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 0; // Singleton

  // Parametri Generali
  String appName = 'Enterprise Dashboard';
  DateTime? lastSyncTime;

  // Cloud & SharePoint (Opzionale, non bloccante)
  String sharepointSiteName = '';
  String sharepointDocumentLibrary = 'Documenti';
  bool syncOnStartup = false;

  // Modulo Rete & Proxy Aziendale
  bool proxyEnabled = false;
  bool proxyAutoConfig = true; // true = PAC / Sistema, false = Manuale
  String customProxyUrl = ''; // host:porta
  bool bypassSslVerification = false;
  String proxyUsername = '';
  String proxyPassword = '';
}
