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

  /// Recupera la lista dei file all'interno della cartella SharePoint configurata,
  /// filtrati eventualmente per le estensioni specificate.
  Future<List<SharePointFile>> listFiles({
    required String accessToken,
    required String siteName,
    required String documentLibrary,
    required String folderPath,
    List<String>? allowedExtensions,
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

    bool matchesExtensions(String fileName) {
      if (allowedExtensions == null || allowedExtensions.isEmpty) return true;
      final lower = fileName.toLowerCase();
      return allowedExtensions.any((ext) => lower.endsWith(ext.toLowerCase()));
    }

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
            .where((file) => matchesExtensions(file.name))
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
            .where((file) => matchesExtensions(file.name))
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

  /// Scarica il contenuto in bytes di un file (es: fogli Excel)
  Future<List<int>> downloadFileBytes({
    required String accessToken,
    required String itemId,
    String? sitePath,
  }) async {
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
      return response.bodyBytes;
    } else {
      throw Exception('Errore di download file da SharePoint: ${response.statusCode} - ${response.body}');
    }
  }

  /// Risolve l'ID univoco del sito SharePoint
  Future<String> resolveSiteId({
    required String accessToken,
    required String siteName,
  }) async {
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
    } catch (_) {}

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
    return siteData['id'] as String;
  }

  /// Recupera la mappa dei nomi interni delle colonne della lista SharePoint
  Future<Map<String, String>> _getListColumnInternalNames({
    required String accessToken,
    required String siteId,
    required String listTitle,
  }) async {
    final Map<String, String> mapping = {};
    try {
      final url = Uri.parse('$graphApiUrl/sites/$siteId/lists/$listTitle/columns');
      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final items = data['value'] as List<dynamic>? ?? [];
        for (final col in items) {
          final displayName = (col['displayName'] as String? ?? '').trim().toLowerCase().replaceAll(' ', '');
          final name = col['name'] as String? ?? '';
          if (displayName.isNotEmpty && name.isNotEmpty) {
            mapping[displayName] = name;
          }
        }
      }
    } catch (_) {}
    return mapping;
  }

  /// Scarica tutte le bonifiche registrate nella lista SharePoint
  Future<List<SharePointBonificaItem>> fetchBonificheList({
    required String accessToken,
    required String siteName,
    String listTitle = 'BonificheContabiliTracciato',
  }) async {
    final siteId = await resolveSiteId(accessToken: accessToken, siteName: siteName);
    final List<SharePointBonificaItem> results = [];
    String? nextUrl = '$graphApiUrl/sites/$siteId/lists/$listTitle/items?expand=fields&\$top=999';

    while (nextUrl != null) {
      final res = await http.get(
        Uri.parse(nextUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode != 200) {
        throw Exception('Errore lettura lista "$listTitle": ${res.statusCode} - ${res.body}');
      }

      final data = json.decode(res.body) as Map<String, dynamic>;
      final items = data['value'] as List<dynamic>? ?? [];
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          results.add(SharePointBonificaItem.fromGraphJson(item));
        }
      }

      nextUrl = data['@odata.nextLink'] as String?;
    }

    return results;
  }

  /// Crea o aggiorna un record di bonifica nella lista SharePoint
  Future<void> saveOrUpdateBonifica({
    required String accessToken,
    required String siteName,
    String listTitle = 'BonificheContabiliTracciato',
    required String key,
    required String cid,
    required String numeroTrasferta,
    required String progressivo,
    required String numeroBolla,
    required String dataSpesa,
    required double importo,
    required bool isBonificato,
    String? nota,
    String? operatore,
    DateTime? dataBonifica,
  }) async {
    final siteId = await resolveSiteId(accessToken: accessToken, siteName: siteName);
    final colMap = await _getListColumnInternalNames(
      accessToken: accessToken,
      siteId: siteId,
      listTitle: listTitle,
    );

    // Risolve i nomi corretti dei campi interni
    final noteColName = colMap['notebonifica'] ?? colMap['note'] ?? colMap['nota'] ?? 'Note_x0020_Bonifica';
    final isBonificatoColName = colMap['isbonificato'] ?? colMap['bonificato'] ?? 'IsBonificato';
    final cidColName = colMap['cid'] ?? 'CID';
    final trasfertaColName = colMap['numerotrasferta'] ?? 'NumeroTrasferta';
    final progressivoColName = colMap['progressivo'] ?? 'Progressivo';
    final bollaColName = colMap['numerobolla'] ?? 'NumeroBolla';
    final dataSpesaColName = colMap['dataspesa'] ?? 'DataSpesa';
    final importoColName = colMap['importo'] ?? 'Importo';
    final operatoreColName = colMap['operatore'] ?? 'Operatore';
    final dataBonificaColName = colMap['databonifica'] ?? 'DataBonifica';

    // 1. Cerca se l'elemento esiste già per Chiave Univoca (Title)
    final searchUrl = Uri.parse(
      '$graphApiUrl/sites/$siteId/lists/$listTitle/items?expand=fields&\$filter=fields/Title eq \'$key\'',
    );
    final searchRes = await http.get(
      searchUrl,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );

    String? existingItemId;
    if (searchRes.statusCode == 200) {
      final searchData = json.decode(searchRes.body) as Map<String, dynamic>;
      final list = searchData['value'] as List<dynamic>? ?? [];
      if (list.isNotEmpty) {
        existingItemId = list.first['id'] as String?;
      }
    }

    final fields = <String, dynamic>{
      'Title': key,
      cidColName: cid,
      trasfertaColName: numeroTrasferta,
      progressivoColName: progressivo,
      bollaColName: numeroBolla,
      dataSpesaColName: dataSpesa,
      importoColName: importo,
      isBonificatoColName: isBonificato,
      noteColName: nota ?? '',
      operatoreColName: operatore ?? '',
      dataBonificaColName: dataBonifica?.toIso8601String() ?? '',
    };

    if (existingItemId != null) {
      // Aggiornamento (PATCH)
      final patchUrl = Uri.parse('$graphApiUrl/sites/$siteId/lists/$listTitle/items/$existingItemId/fields');
      final patchRes = await http.patch(
        patchUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          isBonificatoColName: isBonificato,
          noteColName: nota ?? '',
          operatoreColName: operatore ?? '',
          dataBonificaColName: dataBonifica?.toIso8601String() ?? '',
        }),
      );
      if (patchRes.statusCode != 200 && patchRes.statusCode != 204) {
        throw Exception('Errore aggiornamento bonifica su SharePoint: ${patchRes.statusCode} - ${patchRes.body}');
      }
    } else {
      // Creazione (POST)
      final postUrl = Uri.parse('$graphApiUrl/sites/$siteId/lists/$listTitle/items');
      final postRes = await http.post(
        postUrl,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fields': fields}),
      );
      if (postRes.statusCode != 201 && postRes.statusCode != 200) {
        throw Exception('Errore inserimento bonifica su SharePoint: ${postRes.statusCode} - ${postRes.body}');
      }
    }
  }
}

/// Modello di rappresentazione di una riga di bonifica su SharePoint List
class SharePointBonificaItem {
  final String? itemId;
  final String title;
  final String cid;
  final String numeroTrasferta;
  final String progressivo;
  final String numeroBolla;
  final String dataSpesa;
  final double importo;
  final bool isBonificato;
  final String? nota;
  final String? operatore;
  final DateTime? dataBonifica;

  SharePointBonificaItem({
    this.itemId,
    required this.title,
    required this.cid,
    required this.numeroTrasferta,
    required this.progressivo,
    required this.numeroBolla,
    required this.dataSpesa,
    required this.importo,
    required this.isBonificato,
    this.nota,
    this.operatore,
    this.dataBonifica,
  });

  static String generateKey({
    required String cid,
    required String numeroTrasferta,
    required String progressivo,
    required String numeroBolla,
  }) {
    return '${cid.trim()}_${numeroTrasferta.trim()}_${progressivo.trim()}_${numeroBolla.trim()}';
  }

  factory SharePointBonificaItem.fromGraphJson(Map<String, dynamic> json) {
    final fields = json['fields'] as Map<String, dynamic>? ?? {};
    final rawImporto = fields['Importo'];
    double parsedImporto = 0.0;
    if (rawImporto is num) {
      parsedImporto = rawImporto.toDouble();
    } else if (rawImporto is String) {
      parsedImporto = double.tryParse(rawImporto.replaceAll(',', '.')) ?? 0.0;
    }

    final rawIsBonificato = fields['IsBonificato'] ?? fields['Bonificato'];
    bool parsedIsBonificato = false;
    if (rawIsBonificato is bool) {
      parsedIsBonificato = rawIsBonificato;
    } else if (rawIsBonificato != null) {
      parsedIsBonificato = rawIsBonificato.toString().toLowerCase() == 'true' ||
          rawIsBonificato.toString() == '1';
    }

    final note = fields['Note_x0020_Bonifica'] as String? ??
        fields['NoteBonifica'] as String? ??
        fields['NotaBonifica'] as String? ??
        fields['Nota'] as String? ??
        fields['Note'] as String?;

    final rawDate = fields['DataBonifica'] as String?;
    final date = rawDate != null ? DateTime.tryParse(rawDate) : null;

    return SharePointBonificaItem(
      itemId: json['id'] as String?,
      title: fields['Title'] as String? ?? '',
      cid: fields['CID'] as String? ?? '',
      numeroTrasferta: fields['NumeroTrasferta'] as String? ?? '',
      progressivo: fields['Progressivo'] as String? ?? '',
      numeroBolla: fields['NumeroBolla'] as String? ?? '',
      dataSpesa: fields['DataSpesa'] as String? ?? '',
      importo: parsedImporto,
      isBonificato: parsedIsBonificato,
      nota: note,
      operatore: fields['Operatore'] as String?,
      dataBonifica: date,
    );
  }
}
