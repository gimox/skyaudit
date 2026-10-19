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
