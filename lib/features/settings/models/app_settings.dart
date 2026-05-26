import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 0; // Singleton ID

  bool discardIdenticalBolla = true;
  bool alignWithRemote = true;
  bool syncOnStartup = true;
  DateTime? lastSyncTime;

  // Remote Sync SharePoint Configuration
  String sharepointSiteName = 'skyaudit';
  String sharepointFolderPath = 'tracciati_uvet'; // Tracciato Contabile
  String sharepointDocumentLibrary = 'Documenti condivisi';

  // Altre cartelle SharePoint
  String sharepointEstrattiContoPath = 'estratti_conto';
  String sharepointTracciatoSapPath = 'tracciato_sap';
  String sharepointEstrattiAmexPath = 'estratti_amex';
  String sharepointAnagraficaPath = 'anagrafica';
  String sharepointScartiTracciatoPath = 'scarti_tracciato';

  // Network & Proxy Settings
  bool proxyEnabled = false;
  bool proxyAutoConfig = true;
  String customProxyUrl = '';
  bool bypassSslVerification = false;
  String proxyUsername = '';
  String proxyPassword = '';
}
