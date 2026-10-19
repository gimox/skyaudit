# GUIDA OPERATIVA: GENERAZIONE SCHELETRO FLUTTER ENTERPRISE (DESKTOP)

> **ISTRUZIONE PER L'AGENTE IA**:
> Quando l'utente ti chiede *"Genera lo scheletro dell'app"*:
> 1. **VERIFICA PRESENZA CARTELLA SORGENTI**: Se nella cartella del progetto è presente la cartella `mock_template/` (o `mick_template/`), puoi copiare direttamente i file già pronti nella radice del progetto:
>    - `pubspec.yaml`
>    - `lib/` (tutti i file Dart)
>    - `macos/Runner/*.entitlements`
>    - `.github/workflows/desktop_release.yml`
> 2. **GENERAZIONE DIRETTA DA QUESTO DOCUMENTO**: Se la cartella `mock_template/` non è presente, devi creare **tutti** i file descritti in questo documento esattamente come specificato nel testo.
>
> Il risultato finale deve essere un'applicazione Flutter Desktop (macOS, Windows, Linux) immediatamente compilabile ed eseguibile con `flutter run`, dotata di:
> 1. Finestra desktop dimensionata e centrata (`window_manager`).
> 2. Database locale Isar (`isar_community`) con modello `AppSettings` singleton.
> 3. Modulo completo e funzionante **"Impostazioni -> Rete & Proxy"** (con auto-rilevamento PAC/sistema, bypass SSL e proxy manuale).
> 4. **Home Page pulita (vuota)** con shell di navigazione enterprise (Sidebar laterale collassabile e Topbar).
> 5. Permessi di rete macOS configurati per consentire il traffico sandbox.
> 6. Workflow GitHub Actions pronto per le build desktop di release.


---

## 1. FILE DI CONFIGURAZIONE: `pubspec.yaml`

Crea o sostituisci interamente `pubspec.yaml` con il seguente contenuto:

```yaml
name: enterprise_app
description: "Enterprise Desktop Application Template"
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.2.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  window_manager: ^0.5.1
  intl: ^0.20.2
  go_router: ^17.2.3
  flutter_riverpod: ^2.6.1
  isar_community: ^3.3.2
  isar_community_flutter_libs: ^3.3.2
  path_provider: ^2.1.5
  universal_io: ^2.2.2
  package_info_plus: ^8.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.9
  isar_community_generator: ^3.3.2

flutter:
  uses-material-design: true
```

---

## 2. CONFIGURAZIONE PERMESSI RETE MACOS (SANDBOX)

Per evitare che macOS blocchi le connessioni di rete e i test proxy a causa della sandbox, assicurati che i seguenti file contengano la chiave `com.apple.security.network.client`:

### `macos/Runner/DebugProfile.entitlements`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.cs.allow-jit</key>
	<true/>
	<key>com.apple.security.network.server</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
</dict>
</plist>
```

### `macos/Runner/Release.entitlements`
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.network.client</key>
	<true/>
</dict>
</plist>
```

---

## 3. CORE ARCHITECTURE

### 3.1. Tema Aziendale: `lib/core/theme/app_theme.dart`
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF003399);
  static const Color accentRed = Color(0xFFE4010B);
  static const Color background = Color(0xFFF6F8FA);
  static const Color cardSurface = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentRed,
        surface: cardSurface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
```

### 3.2. Isar Provider: `lib/core/db/isar_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar non è stato inizializzato nel ProviderScope');
});
```

### 3.3. Proxy Service: `lib/core/services/proxy_service.dart`
```dart
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
```

### 3.4. Router di Navigazione: `lib/core/navigation/app_router.dart`
```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
```

---

## 4. MODELLO E PROVIDER SETTINGS

### 4.1. Modello Isar: `lib/features/settings/models/app_settings.dart`
```dart
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
```

### 4.2. Riverpod State Notifier: `lib/features/settings/providers/app_settings_provider.dart`
```dart
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
```

---

## 5. UI: SCHERMATA IMPOSTAZIONI (RETE & PROXY)

### `lib/features/settings/settings_view.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/proxy_service.dart';
import 'providers/app_settings_provider.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final _proxyUrlController = TextEditingController();
  final _proxyUsernameController = TextEditingController();
  final _proxyPasswordController = TextEditingController();

  bool _proxyEnabled = false;
  bool _proxyAutoConfig = true;
  bool _bypassSslVerification = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final settings = ref.read(appSettingsProvider);
      _proxyEnabled = settings.proxyEnabled;
      _proxyAutoConfig = settings.proxyAutoConfig;
      _bypassSslVerification = settings.bypassSslVerification;
      _proxyUrlController.text = settings.customProxyUrl;
      _proxyUsernameController.text = settings.proxyUsername;
      _proxyPasswordController.text = settings.proxyPassword;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _proxyUrlController.dispose();
    _proxyUsernameController.dispose();
    _proxyPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Impostazioni Rete & Proxy',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 6),
                Text(
                  'Configura l\'istradamento di rete e i certificati per ambienti aziendali protetti.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONFIGURAZIONE PROXY',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Abilita Proxy di Rete', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Instrada tutte le richieste HTTP/HTTPS tramite un server proxy aziendale.'),
                          value: _proxyEnabled,
                          onChanged: (val) => setState(() => _proxyEnabled = val),
                        ),
                        if (_proxyEnabled) ...[
                          const Divider(height: 32),
                          const Text('Modalità di Rilevamento', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: RadioListTile<bool>(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Automatica (PAC / Sistema)'),
                                  subtitle: const Text('Rileva il proxy dal sistema operativo o script PAC'),
                                  value: true,
                                  groupValue: _proxyAutoConfig,
                                  onChanged: (val) => setState(() => _proxyAutoConfig = val!),
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Manuale'),
                                  subtitle: const Text('Specifica host, porta e credenziali dedicate'),
                                  value: false,
                                  groupValue: _proxyAutoConfig,
                                  onChanged: (val) => setState(() => _proxyAutoConfig = val!),
                                ),
                              ),
                            ],
                          ),
                          if (!_proxyAutoConfig) ...[
                            const SizedBox(height: 16),
                            TextField(
                              controller: _proxyUrlController,
                              decoration: InputDecoration(
                                labelText: 'Server Proxy (host:porta)',
                                hintText: 'es: proxy.azienda.local:8080',
                                prefixIcon: const Icon(Icons.dns_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _proxyUsernameController,
                                    decoration: InputDecoration(
                                      labelText: 'Username (opzionale)',
                                      prefixIcon: const Icon(Icons.person_outline),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _proxyPasswordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password (opzionale)',
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                        const Divider(height: 40),
                        const Text(
                          'SICUREZZA & CERTIFICATI',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue, letterSpacing: 1.0),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Bypass Controllo SSL (SSL Inspection)', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Consente la comunicazione anche in presenza di certificati aziendali interni o proxy man-in-the-middle.'),
                          value: _bypassSslVerification,
                          onChanged: (val) => setState(() => _bypassSslVerification = val),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _saveSettings,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Salva ed Applica Impostazioni', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    await ref.read(appSettingsProvider.notifier).updateNetworkSettings(
      proxyEnabled: _proxyEnabled,
      proxyAutoConfig: _proxyAutoConfig,
      customProxyUrl: _proxyUrlController.text.trim(),
      bypassSslVerification: _bypassSslVerification,
      proxyUsername: _proxyUsernameController.text.trim(),
      proxyPassword: _proxyPasswordController.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ProxyService.resolvedProxy != null
                ? 'Proxy applicato: ${ProxyService.resolvedProxy}'
                : 'Impostazioni di rete salvate con successo!',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
```

---

## 6. UI: HOME SCREEN CON HOME VUOTA E SHELL ENTERPRISE

### `lib/features/home/home_screen.dart`
```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/proxy_service.dart';
import '../settings/settings_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Row(
        children: [
          // SIDEBAR LATERALE
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isSidebarCollapsed ? 76 : 240,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Column(
              children: [
                // Header Sidebar con Logo e Toggle
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isSidebarCollapsed)
                        const Row(
                          children: [
                            Icon(Icons.dashboard_customize_rounded, color: AppTheme.primaryBlue, size: 28),
                            SizedBox(width: 12),
                            Text(
                              'App Template',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                            ),
                          ],
                        ),
                      IconButton(
                        icon: Icon(_isSidebarCollapsed ? Icons.menu : Icons.menu_open, color: Colors.grey.shade700),
                        onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                        tooltip: _isSidebarCollapsed ? 'Espandi menu' : 'Comprimi menu',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Voci di Menu
                _buildNavItem(index: 0, icon: Icons.home_outlined, selectedIcon: Icons.home, title: 'Home'),
                _buildNavItem(index: 1, icon: Icons.settings_outlined, selectedIcon: Icons.settings, title: 'Impostazioni'),

                const Spacer(),

                // Stato Proxy in basso
                if (!_isSidebarCollapsed)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          ProxyService.resolvedProxy != null ? Icons.wifi_protected_setup : Icons.wifi,
                          size: 18,
                          color: ProxyService.resolvedProxy != null ? Colors.green.shade700 : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ProxyService.resolvedProxy != null ? 'Proxy attivo' : 'Rete standard',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // CONTENUTO PRINCIPALE
          Expanded(
            child: Column(
              children: [
                // TopBar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedIndex == 0 ? 'Home' : 'Impostazioni',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        avatar: const Icon(Icons.circle, color: Colors.green, size: 10),
                        label: const Text('Modalità Standalone Locale', style: TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey.shade100,
                        side: BorderSide.none,
                      ),
                    ],
                  ),
                ),

                // Body delle Viste
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: [
                      _buildEmptyHomeView(),
                      const SettingsView(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
  }) {
    final isSelected = _selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue.withAlpha(20) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(isSelected ? selectedIcon : icon, color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade700, size: 22),
              if (!_isSidebarCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Home pulita con segnaposto neutro
  Widget _buildEmptyHomeView() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.dashboard_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Benvenuto nello Scheletro Applicativo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Questa è una schermata Home iniziale pulita. Il core dell\'applicazione, il database Isar e il modulo Proxy sono già operativi e pronti per accogliere nuove funzionalità.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 7. ENTRYPOINT: `lib/main.dart`

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/db/isar_provider.dart';
import 'core/navigation/app_router.dart';
import 'core/services/proxy_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/models/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inizializzazione Finestra Desktop
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1360, 800),
      minimumSize: Size(1000, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // 2. Inizializzazione Database Isar Locale
  final dir = await getApplicationSupportDirectory();
  if (!dir.existsSync()) {
    try {
      dir.createSync(recursive: true);
    } catch (_) {}
  }

  final isar = await Isar.open(
    [AppSettingsSchema],
    directory: dir.path,
    inspector: true, // Attiva l'inspector locale in debug
  );

  // 3. Inizializzazione Proxy Service con le impostazioni persistite
  final settings = await isar.appSettings.get(0) ?? AppSettings();
  if (settings.id == 0 && (await isar.appSettings.count()) == 0) {
    await isar.writeTxn(() async => await isar.appSettings.put(settings));
  }
  await ProxyService.initialize(settings);

  // 4. Avvio dell'Applicazione con Riverpod
  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const EnterpriseApp(),
    ),
  );
}

class EnterpriseApp extends ConsumerWidget {
  const EnterpriseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Enterprise App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
```

---

## 8. WORKFLOW DI BUILD & RELEASE GITHUB ACTIONS

Salva il seguente file in `.github/workflows/desktop_release.yml`:

```yaml
name: Build & Release Desktop Apps

on:
  push:
    tags:
      - 'v*'
  workflow_dispatch:

jobs:
  build-macos:
    name: Build macOS App
    runs-on: macos-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Build macOS
        run: flutter build macos --release

      - name: Create DMG package
        run: |
          cd build/macos/Build/Products/Release
          APP_NAME=$(ls -d *.app | head -n 1)
          hdiutil create -format UDZO -srcfolder "$APP_NAME" App_macOS.dmg
          mv App_macOS.dmg ../../../../../App_macOS.dmg

      - name: Upload macOS Artifact
        uses: actions/upload-artifact@v4
        with:
          name: macos-dmg
          path: App_macOS.dmg

  build-windows:
    name: Build Windows App
    runs-on: windows-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
          cache: true

      - name: Install dependencies
        run: flutter pub get

      - name: Build Windows
        run: flutter build windows --release

      - name: Package Windows (ZIP)
        shell: pwsh
        run: |
          Compress-Archive -Path build\windows\x64\runner\Release\* -DestinationPath App_Windows.zip

      - name: Upload Windows Artifact
        uses: actions/upload-artifact@v4
        with:
          name: windows-zip
          path: App_Windows.zip

  create-release:
    name: Create GitHub Release
    needs: [build-macos, build-windows]
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Download macOS Artifact
        uses: actions/download-artifact@v4
        with:
          name: macos-dmg

      - name: Download Windows Artifact
        uses: actions/download-artifact@v4
        with:
          name: windows-zip

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          files: |
            App_macOS.dmg
            App_Windows.zip
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 9. SEQUENZA DEI COMANDI DI ESECUZIONE PER L'AGENTE

Quando viene richiesto *"Genera lo scheletro dell'app"*, l'Agente deve seguire ed eseguire la sequenza:

1. Se la cartella è vuota o priva di configurazione Flutter:
   ```bash
   flutter create . --platforms=macos,windows,linux --org=com.enterprise
   ```
2. **Distribuzione dei file**:
   * **Se è presente `mock_template/` o `mick_template/`**: Copia ricorsivamente i file nella radice del progetto:
     ```bash
     cp -R mock_template/* .
     ```
   * **Se non è presente la cartella**: Crea i file Dart, gli entitlements e il workflow CI/CD dai blocchi di codice specificati nelle Sezioni da 1 a 8 di questo documento.
3. Eseguire l'installazione dei pacchetti:
   ```bash
   flutter pub get
   ```
4. Generare il codice Isar:
   ```bash
   dart run build_runner build -d
   ```
5. Verificare la compilazione senza errori con:
   ```bash
   flutter analyze
   ```

