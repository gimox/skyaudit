import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateInfo {
  final String version;
  final int buildNumber;
  final bool mandatory;
  final String downloadUrl;
  final List<String> changelog;

  AppUpdateInfo({
    required this.version,
    required this.buildNumber,
    required this.mandatory,
    required this.downloadUrl,
    required this.changelog,
  });

  factory AppUpdateInfo.fromJson(Map<String, dynamic> json) {
    // Rileva la piattaforma e seleziona il downloadUrl corrispondente
    String downloadUrl = '';
    if (kIsWeb) {
      downloadUrl = json['downloadUrls']?['web'] ?? '';
    } else if (Platform.isMacOS) {
      downloadUrl = json['downloadUrls']?['macos'] ?? '';
    } else if (Platform.isWindows) {
      downloadUrl = json['downloadUrls']?['windows'] ?? '';
    } else {
      downloadUrl = json['downloadUrl'] ?? '';
    }

    return AppUpdateInfo(
      version: json['version'] as String? ?? '1.0.0',
      buildNumber: json['buildNumber'] as int? ?? 1,
      mandatory: json['mandatory'] as bool? ?? false,
      downloadUrl: downloadUrl,
      changelog: List<String>.from(json['changelog'] ?? []),
    );
  }
}

class UpdateService {
  static const String manifestUrl = 'https://raw.githubusercontent.com/gimox/skyaudit/main/version.json';

  /// Controlla se è disponibile un aggiornamento.
  /// Ritorna [AppUpdateInfo] se è presente un aggiornamento, altrimenti [null].
  static Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final response = await http.get(Uri.parse(manifestUrl)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode != 200) {
        debugPrint('UpdateService: Richiesta manifest fallita con codice ${response.statusCode}');
        return null;
      }

      final Map<String, dynamic> data = json.decode(response.body);
      final remoteInfo = AppUpdateInfo.fromJson(data);

      final packageInfo = await PackageInfo.fromPlatform();
      final localVersion = packageInfo.version;
      final localBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      final hasNewerVersion = _isNewer(localVersion, remoteInfo.version);
      final hasNewerBuild = !hasNewerVersion && 
                            (localVersion == remoteInfo.version) && 
                            (remoteInfo.buildNumber > localBuild);

      if (hasNewerVersion || hasNewerBuild) {
        return remoteInfo;
      }
    } catch (e) {
      debugPrint('UpdateService: Errore durante il controllo aggiornamenti: $e');
    }
    return null;
  }

  /// Confronta due stringhe di versione semantica (es. 1.0.0 e 1.1.0)
  static bool _isNewer(String local, String remote) {
    try {
      final localParts = local.split('.').map(int.parse).toList();
      final remoteParts = remote.split('.').map(int.parse).toList();
      
      final maxLen = localParts.length > remoteParts.length ? localParts.length : remoteParts.length;
      for (int i = 0; i < maxLen; i++) {
        final localVal = i < localParts.length ? localParts[i] : 0;
        final remoteVal = i < remoteParts.length ? remoteParts[i] : 0;
        
        if (remoteVal > localVal) return true;
        if (localVal > remoteVal) return false;
      }
    } catch (_) {}
    return false;
  }

  /// Esegue il reindirizzamento al download o aggiorna la pagina Web
  static Future<void> performUpdate(AppUpdateInfo info) async {
    if (info.downloadUrl.isEmpty) return;
    
    final uri = Uri.parse(info.downloadUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Impossibile aprire il link di download: ${info.downloadUrl}');
    }
  }
}
