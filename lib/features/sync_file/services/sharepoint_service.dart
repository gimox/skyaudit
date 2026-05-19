import 'dart:convert';
import 'package:http/http.dart' as http;

class SharePointFile {
  final String id;
  final String name;
  final int size;
  final DateTime lastModified;
  final String? sitePath; // Will now store the concrete siteId

  SharePointFile({
    required this.id,
    required this.name,
    required this.size,
    required this.lastModified,
    this.sitePath,
  });

  factory SharePointFile.fromJson(Map<String, dynamic> json, {String? sitePath}) {
    return SharePointFile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      lastModified: DateTime.tryParse(json['lastModifiedDateTime'] as String? ?? '') ?? DateTime.now(),
      sitePath: sitePath,
    );
  }
}

class SharePointService {
  static const String graphApiUrl = 'https://graph.microsoft.com/v1.0';

  /// Recupera la lista dei file *.txt all'interno della cartella SharePoint configurata
  Future<List<SharePointFile>> listFiles({
    required String accessToken,
    required String siteName,
    required String documentLibrary,
    required String folderPath,
  }) async {
    // 1. Risolve l'hostname del tenant aziendale (es: telecomitalia.sharepoint.com) con fallback sicuro
    String hostname = 'telecomitalia.sharepoint.com';
    try {
      final rootUrl = Uri.parse('$graphApiUrl/sites/root');
      final rootRes = await http.get(
        rootUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      if (rootRes.statusCode == 200) {
        final Map<String, dynamic> rootData = json.decode(rootRes.body) as Map<String, dynamic>;
        if (rootData['hostname'] != null) {
          hostname = rootData['hostname'] as String;
        }
      }
    } catch (_) {
      // Continua con il default
    }

    final cleanPath = folderPath.isEmpty ? 'tracciati_uvet' : folderPath;

    // 2. Se viene specificato un sito del Team SharePoint (es: "skyaudit")
    if (siteName.isNotEmpty && siteName.toLowerCase() != 'tim audit group') {
      // STEP A: Risolviamo l'ID univoco del sito usando la path-based navigation
      final siteUrl = Uri.parse('$graphApiUrl/sites/$hostname:/sites/$siteName');
      final siteRes = await http.get(
        siteUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      
      if (siteRes.statusCode != 200) {
        throw Exception('Impossibile trovare il sito "$siteName": ${siteRes.statusCode} - ${siteRes.body}');
      }
      
      final Map<String, dynamic> siteData = json.decode(siteRes.body) as Map<String, dynamic>;
      final String siteId = siteData['id'] as String;
      
      // STEP B: Usiamo il siteId per interrogare direttamente la cartella nel Drive predefinito.
      // Questo bypassa il bug del segmento "root:" causato dall'unione di due URI path-based.
      final url = Uri.parse('$graphApiUrl/sites/$siteId/drive/root:/$cleanPath:/children');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> value = data['value'] as List<dynamic>? ?? [];
        return value
            .map((item) => SharePointFile.fromJson(item as Map<String, dynamic>, sitePath: siteId))
            .where((file) => file.name.toLowerCase().endsWith('.txt'))
            .toList();
      } else {
        throw Exception('Errore elenco file in "$siteName" (Cartella: $cleanPath): ${response.statusCode} - ${response.body}');
      }
    } else {
      // Scenario Fallback: OneDrive Personale
      final url = Uri.parse('$graphApiUrl/me/drive/root:/$cleanPath:/children');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> value = data['value'] as List<dynamic>? ?? [];
        return value
            .map((item) => SharePointFile.fromJson(item as Map<String, dynamic>))
            .where((file) => file.name.toLowerCase().endsWith('.txt'))
            .toList();
      } else {
        throw Exception('Errore elenco file OneDrive ($cleanPath): ${response.statusCode} - ${response.body}');
      }
    }
  }

  /// Scarica il contenuto testuale di un file
  Future<String> downloadFile({
    required String accessToken,
    required String itemId,
    String? sitePath,
  }) async {
    // sitePath qui contiene il siteId reale (es. telecomitalia.sharepoint.com,fa93...)
    final url = sitePath != null
        ? Uri.parse('$graphApiUrl/sites/$sitePath/drive/items/$itemId/content')
        : Uri.parse('$graphApiUrl/me/drive/items/$itemId/content');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Errore di download file da SharePoint: ${response.statusCode} - ${response.body}');
    }
  }
}
