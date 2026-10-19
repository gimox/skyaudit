import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:universal_io/universal_io.dart';
import '../../features/settings/models/app_settings.dart';

class ProxyService {
  static String? _resolvedProxy;
  static bool _bypassSsl = false;
  static String _username = '';
  static String _password = '';

  static String? get resolvedProxy => _resolvedProxy;

  static Future<void> initialize(AppSettings settings) async {
    if (kIsWeb) return;

    _bypassSsl = settings.bypassSslVerification;
    _username = settings.proxyUsername;
    _password = settings.proxyPassword;

    if (!settings.proxyEnabled) {
      _resolvedProxy = null;
      HttpOverrides.global = AppHttpOverrides(null, _bypassSsl, _username, _password);
      debugPrint('[ProxyService] Proxy disabilitato.');
      return;
    }

    if (!settings.proxyAutoConfig) {
      _resolvedProxy = settings.customProxyUrl.trim();
      debugPrint('[ProxyService] Proxy manuale applicato: $_resolvedProxy');
    } else {
      try {
        if (Platform.isMacOS) {
          final result = await Process.run('scutil', ['--proxy']);
          if (result.exitCode == 0) {
            _resolvedProxy = await _parseMacProxy(result.stdout as String);
          }
        } else if (Platform.isWindows) {
          final result = await Process.run('reg', [
            'query',
            'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings'
          ]);
          if (result.exitCode == 0) {
            _resolvedProxy = await _parseWindowsProxy(result.stdout as String);
          }
        }
      } catch (e) {
        debugPrint('[ProxyService] Errore rilevamento proxy di sistema: $e');
      }
      debugPrint('[ProxyService] Proxy automatico risolto: $_resolvedProxy');
    }

    HttpOverrides.global = AppHttpOverrides(_resolvedProxy, _bypassSsl, _username, _password);
  }

  static Future<String?> _parseMacProxy(String output) async {
    final pacEnable = RegExp(r'ProxyAutoConfigEnable\s*:\s*1').hasMatch(output);
    final pacUrl = RegExp(r'ProxyAutoConfigURLString\s*:\s*([^\s]+)').firstMatch(output)?.group(1);
    if (pacEnable && pacUrl != null) return await _fetchProxyFromPac(pacUrl);

    final httpsEnable = RegExp(r'HTTPSEnable\s*:\s*1').hasMatch(output);
    final httpsProxy = RegExp(r'HTTPSProxy\s*:\s*([^\s]+)').firstMatch(output)?.group(1);
    final httpsPort = RegExp(r'HTTPSPort\s*:\s*([^\s]+)').firstMatch(output)?.group(1);
    if (httpsEnable && httpsProxy != null && httpsPort != null) return '$httpsProxy:$httpsPort';

    final httpEnable = RegExp(r'HTTPEnable\s*:\s*1').hasMatch(output);
    final httpProxy = RegExp(r'HTTPProxy\s*:\s*([^\s]+)').firstMatch(output)?.group(1);
    final httpPort = RegExp(r'HTTPPort\s*:\s*([^\s]+)').firstMatch(output)?.group(1);
    if (httpEnable && httpProxy != null && httpPort != null) return '$httpProxy:$httpPort';

    return null;
  }

  static Future<String?> _parseWindowsProxy(String output) async {
    final autoConfigUrl = RegExp(r'AutoConfigURL\s+REG_SZ\s+([^\r\n]+)').firstMatch(output)?.group(1);
    if (autoConfigUrl != null) return await _fetchProxyFromPac(autoConfigUrl);

    final proxyEnable = RegExp(r'ProxyEnable\s+REG_DWORD\s+0x1').hasMatch(output);
    final proxyServer = RegExp(r'ProxyServer\s+REG_SZ\s+([^\r\n]+)').firstMatch(output)?.group(1);
    if (proxyEnable && proxyServer != null) {
      if (proxyServer.contains(';')) {
        for (final part in proxyServer.split(';')) {
          if (part.startsWith('https=')) return part.substring(6);
          if (part.startsWith('http=')) return part.substring(5);
        }
      }
      return proxyServer;
    }
    return null;
  }

  static Future<String?> _fetchProxyFromPac(String pacUrl) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      client.badCertificateCallback = (cert, host, port) => true;
      final request = await client.getUrl(Uri.parse(pacUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        final content = await response.transform(latin1.decoder).join();
        final matches = RegExp(r'PROXY\s+([a-zA-Z0-9\.-]+:\d+)').allMatches(content);
        if (matches.isNotEmpty) return matches.first.group(1);
      }
    } catch (_) {}
    return null;
  }

  static bool shouldBypassProxy(Uri uri) {
    final host = uri.host.toLowerCase();
    if (host == 'localhost' || host == '127.0.0.1') return true;
    if (host.endsWith('.local') || host.endsWith('.lan') || host.endsWith('.corp')) return true;
    return false;
  }
}

class AppHttpOverrides extends HttpOverrides {
  final String? proxy;
  final bool bypassSsl;
  final String username;
  final String password;

  AppHttpOverrides(this.proxy, this.bypassSsl, this.username, this.password);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);

    if (proxy != null && proxy!.isNotEmpty) {
      client.findProxy = (uri) {
        if (ProxyService.shouldBypassProxy(uri)) return 'DIRECT';
        return 'PROXY $proxy;';
      };

      if (username.isNotEmpty || password.isNotEmpty) {
        client.authenticateProxy = (host, port, scheme, realm) async {
          client.addProxyCredentials(host, port, realm ?? '', HttpClientBasicCredentials(username, password));
          return true;
        };
      }
    }

    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      if (bypassSsl) return true;
      return false;
    };

    return client;
  }
}
