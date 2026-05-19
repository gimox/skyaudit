import 'package:isar/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 0; // Singleton ID

  bool discardIdenticalBolla = true;

  // Remote Sync SharePoint Configuration
  String sharepointSiteName = 'skyaudit';
  String sharepointFolderPath = 'tracciati_uvet';
  String sharepointDocumentLibrary = 'Documenti condivisi';
}
