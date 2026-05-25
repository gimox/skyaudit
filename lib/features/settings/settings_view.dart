import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/features/settings/models/dictionary.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';
import 'package:travel_check/features/upload/providers/estratto_amex_provider.dart';
import 'package:travel_check/features/upload/models/estratto_amex.dart';
import 'package:travel_check/features/upload/providers/scarti_ec_sap_provider.dart';
import 'package:travel_check/features/upload/models/scarti_ec_sap.dart';
import 'package:travel_check/features/auth/providers/auth_provider.dart';
import 'package:travel_check/features/auth/models/auth_state.dart';
import 'package:travel_check/features/settings/providers/app_settings_provider.dart';
import 'package:travel_check/features/settings/models/app_settings.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:travel_check/core/services/update_service.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _spSiteController = TextEditingController();
  final TextEditingController _spFolderController = TextEditingController(); // Tracciato Contabile
  final TextEditingController _spLibraryController = TextEditingController();
  final TextEditingController _spEstrattiContoController = TextEditingController();
  final TextEditingController _spTracciatoSapController = TextEditingController();
  final TextEditingController _spEstrattiAmexController = TextEditingController();
  final TextEditingController _spAnagraficaController = TextEditingController();
  final TextEditingController _spScartiTracciatoController = TextEditingController();

  String _appVersion = 'Caricamento...';
  String _buildNumber = '';
  bool _isCheckingUpdate = false;
  String _updateCheckStatus = '';
  int _selectedTabIndex = 0;


  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final settings = ref.read(appSettingsProvider);
      _spSiteController.text = settings.sharepointSiteName;
      _spFolderController.text = settings.sharepointFolderPath;
      _spLibraryController.text = settings.sharepointDocumentLibrary;
      _spEstrattiContoController.text = settings.sharepointEstrattiContoPath;
      _spTracciatoSapController.text = settings.sharepointTracciatoSapPath;
      _spEstrattiAmexController.text = settings.sharepointEstrattiAmexPath;
      _spAnagraficaController.text = settings.sharepointAnagraficaPath;
      _spScartiTracciatoController.text = settings.sharepointScartiTracciatoPath;
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    _spSiteController.dispose();
    _spFolderController.dispose();
    _spLibraryController.dispose();
    _spEstrattiContoController.dispose();
    _spTracciatoSapController.dispose();
    _spEstrattiAmexController.dispose();
    _spAnagraficaController.dispose();
    _spScartiTracciatoController.dispose();
    super.dispose();
  }

  Future<void> _clearCollection(String collectionName) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Svuota $collectionName',
      content:
          'Sei sicuro di voler eliminare tutti i dati della collection $collectionName? L\'operazione è irreversibile.',
    );

    if (confirmed == true) {
      if (collectionName == 'Tracciato Contabile') {
        await ref.read(tracciatoContabilesProvider.notifier).clear();
      } else if (collectionName == 'Log History') {
        final isar = ref.read(isarProvider);
        await isar.writeTxn(() => isar.logHistorys.clear());
        ref.invalidate(logHistoryProvider);
      } else if (collectionName == 'Dizionari') {
        final isar = ref.read(isarProvider);
        await isar.writeTxn(() => isar.dictionarys.clear());
        ref.invalidate(dictionaryProvider);
      } else if (collectionName == 'Estratto Conto') {
        await ref.read(estrattoContoProvider.notifier).clear();
      } else if (collectionName == 'Tracciato Sap') {
        await ref.read(tracciatoSapProvider.notifier).clear();
      } else if (collectionName == 'Estratti Amex') {
        await ref.read(estrattoAmexProvider.notifier).clear();
      } else if (collectionName == 'Scarti EC SAP') {
        await ref.read(scartiEcSapProvider.notifier).clear();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collection $collectionName svuotata con successo'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }

  Future<void> _clearEntireDatabase() async {
    final isar = ref.read(isarProvider);
    final confirmed = await _showConfirmationDialog(
      title: 'Svuota Intero Database',
      content:
          'ATTENZIONE! Questa operazione eliminerà TUTTI i dati presenti nel database locale. Sei assolutamente sicuro?',
      isDestructive: true,
    );

    if (confirmed == true) {
      await isar.writeTxn(() async {
        await isar.tracciatoContabiles.clear();
        await isar.logHistorys.clear();
        await isar.estrattoContos.clear();
        await isar.tracciatoSaps.clear();
        await isar.estrattoAmexs.clear();
        await isar.scartiEcSaps.clear();
      });
      // Aggiorniamo anche lo stato in memoria per le collection caricate
      ref.invalidate(tracciatoContabilesProvider);
      ref.invalidate(logHistoryProvider);
      ref.invalidate(estrattoContoProvider);
      ref.invalidate(tracciatoSapProvider);
      ref.invalidate(estrattoAmexProvider);
      ref.invalidate(scartiEcSapProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Tutto il database è stato svuotato con successo',
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }

  Future<void> _showEditDictionaryDialog({
    Dictionary? entry,
    String? category,
  }) async {
    _codeController.text = entry?.code ?? '';
    _valueController.text = entry?.value ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry == null ? 'Nuova Voce' : 'Modifica Voce'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Codice',
                hintText: 'Es: ALP1',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Valore',
                hintText: 'Es: Alloggio prepagato',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salva'),
          ),
        ],
      ),
    );

    if (confirmed == true && _codeController.text.isNotEmpty) {
      if (entry == null) {
        await ref
            .read(dictionaryProvider.notifier)
            .addEntry(
              _codeController.text.toUpperCase(),
              _valueController.text,
              category ?? 'giustificativi_prepagati',
            );
      } else {
        await ref
            .read(dictionaryProvider.notifier)
            .updateEntry(
              entry.id,
              _codeController.text.toUpperCase(),
              _valueController.text,
            );
      }
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: isDestructive ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? Colors.red.shade600
                  : Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final dictionaries = ref.watch(dictionaryProvider);
    final appSettings = ref.watch(appSettingsProvider);
    final prepagatoEntries = dictionaries
        .where((e) => e.category == 'giustificativi_prepagati')
        .toList();
    final tipoDipendenteEntries = dictionaries
        .where((e) => e.category == 'tipo_dipendente')
        .toList();
    final societaEntries = dictionaries
        .where((e) => e.category == 'societa')
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(32.0, 48.0, 32.0, 32.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar di navigazione a sinistra
                SizedBox(
                  width: 280,
                  child: Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Text(
                              'IMPOSTAZIONI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(_tabs.length, (index) {
                            final tab = _tabs[index];
                            final isSelected = _selectedTabIndex == index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: ListTile(
                                selected: isSelected,
                                selectedColor: SkyTheme.timBlue,
                                selectedTileColor: SkyTheme.timBlue.withAlpha(20),
                                iconColor: Colors.grey.shade600,
                                textColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                leading: Icon(tab.icon),
                                title: Text(
                                  tab.title,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Contenuto a destra
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildTabContent(
                        context,
                        authState,
                        appSettings,
                        prepagatoEntries,
                        tipoDipendenteEntries,
                        societaEntries,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Layout per schermi più piccoli
            return Column(
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: List.generate(_tabs.length, (index) {
                          final tab = _tabs[index];
                          final isSelected = _selectedTabIndex == index;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                            child: ChoiceChip(
                              showCheckmark: false,
                              avatar: Icon(
                                tab.icon,
                                color: isSelected ? Colors.white : SkyTheme.timBlue,
                                size: 16,
                              ),
                              label: Text(tab.title),
                              selected: isSelected,
                              selectedColor: SkyTheme.timBlue,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedTabIndex = index;
                                  });
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildTabContent(
                      context,
                      authState,
                      appSettings,
                      prepagatoEntries,
                      tipoDipendenteEntries,
                      societaEntries,
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    AuthState authState,
    AppSettings appSettings,
    List<Dictionary> prepagatoEntries,
    List<Dictionary> tipoDipendenteEntries,
    List<Dictionary> societaEntries,
  ) {
    switch (_selectedTabIndex) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              Icons.cloud_sync_outlined,
              'Cloud & Sincronizzazione',
              'Gestisci l\'accesso aziendale e le impostazioni del drive SharePoint.',
            ),
            const SizedBox(height: 24),
            _buildAuthStatusCard(context, authState),
            const SizedBox(height: 24),
            _buildAutoSyncSettingsCard(context, appSettings),
            const SizedBox(height: 24),
            _buildRemoteSyncCard(context, appSettings),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              Icons.book_outlined,
              'Dizionari di Decodifica',
              'Configura i dizionari per la traduzione automatica dei codici.',
            ),
            const SizedBox(height: 24),
            _buildDictionaryCard(
              context,
              'Giustificativi Prepagati',
              'giustificativi_prepagati',
              prepagatoEntries,
            ),
            const SizedBox(height: 24),
            _buildDictionaryCard(
              context,
              'Tipo Dipendente',
              'tipo_dipendente',
              tipoDipendenteEntries,
            ),
            const SizedBox(height: 24),
            _buildDictionaryCard(
              context,
              'Società',
              'societa',
              societaEntries,
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              Icons.storage,
              'Gestione Database Locale',
              'Amministrazione delle collection e dei dati salvati localmente.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCollectionTile(
                    context,
                    Icons.table_chart_outlined,
                    'Collection: Tracciato Contabile',
                    'Elimina solo i record importati del tracciato contabile',
                    () => _clearCollection('Tracciato Contabile'),
                  ),
                  _buildCollectionTile(
                    context,
                    Icons.history,
                    'Collection: Log History',
                    'Elimina lo storico delle importazioni (file, date, etc.)',
                    () => _clearCollection('Log History'),
                  ),
                  _buildCollectionTile(
                    context,
                    Icons.account_balance_wallet_outlined,
                    'Collection: Estratto Conto',
                    'Elimina tutti i dati caricati dagli estratti conto',
                    () => _clearCollection('Estratto Conto'),
                  ),
                  _buildCollectionTile(
                    context,
                    Icons.analytics_outlined,
                    'Collection: Tracciato Sap',
                    'Elimina tutti i dati caricati dal tracciato SAP',
                    () => _clearCollection('Tracciato Sap'),
                  ),
                  _buildCollectionTile(
                    context,
                    Icons.credit_card_outlined,
                    'Collection: Estratti Amex',
                    'Elimina tutti i dati caricati dagli estratti American Express',
                    () => _clearCollection('Estratti Amex'),
                  ),
                  _buildCollectionTile(
                    context,
                    Icons.warning_amber_outlined,
                    'Collection: Scarti EC SAP',
                    'Elimina tutti i dati caricati dagli scarti Estratto Conto SAP',
                    () => _clearCollection('Scarti EC SAP'),
                  ),
                  const Divider(height: 32),
                  _buildHardResetAction(context),
                ],
              ),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              context,
              Icons.info_outline,
              'Info Applicativo & Aggiornamenti',
              'Verifica la versione installata e controlla la disponibilità di aggiornamenti.',
            ),
            const SizedBox(height: 24),
            _buildAppUpdateCard(context),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }


  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appVersion = 'Non disponibile';
        });
      }
    }
  }

  Future<void> _manualCheckForUpdate() async {
    setState(() {
      _isCheckingUpdate = true;
      _updateCheckStatus = 'Controllo dei server in corso...';
    });

    final result = await UpdateService.checkForUpdate();
    
    if (mounted) {
      setState(() {
        _isCheckingUpdate = false;
        if (!result.isSuccess) {
          _updateCheckStatus = 'Verifica fallita: ${result.errorMessage}.';
        } else if (result.info != null) {
          _updateCheckStatus = 'È disponibile una nuova versione: ${result.info!.version}. Avvio aggiornamento...';
          _showSettingsUpdateDialog(result.info!);
        } else {
          _updateCheckStatus = 'SkyAudit è aggiornato all\'ultima versione.';
        }
      });
    }
  }

  void _showSettingsUpdateDialog(AppUpdateInfo info) {
    UpdateService.performUpdate(info);

    showDialog(
      context: context,
      barrierDismissible: kIsWeb,
      builder: (context) {
        final isDesktop = !kIsWeb && (Platform.isWindows || Platform.isMacOS);
        return PopScope(
          canPop: !isDesktop,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SkyTheme.timBlue.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const CircularProgressIndicator(
                      color: SkyTheme.timBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Aggiornamento in corso',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SkyTheme.timBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isDesktop
                        ? 'Download e installazione della versione ${info.version} in corso...'
                        : 'Reindirizzamento al download della versione ${info.version}...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isDesktop
                        ? 'L\'applicazione verrà riavviata automaticamente al termine.'
                        : 'Puoi chiudere questa finestra una volta completato il download.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (!isDesktop) ...[
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Chiudi'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppUpdateCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SkyTheme.timBlue.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.desktop_windows_outlined,
                  color: SkyTheme.timBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SkyAudit Client',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Versione installata: $_appVersion ${_buildNumber.isNotEmpty ? " (Build $_buildNumber)" : ""}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_updateCheckStatus.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    _updateCheckStatus.contains('nuova')
                        ? Icons.cloud_download
                        : (_updateCheckStatus.contains('errore') ? Icons.error_outline : Icons.check_circle_outline),
                    color: _updateCheckStatus.contains('nuova')
                        ? SkyTheme.timRed
                        : (_updateCheckStatus.contains('errore') ? Colors.amber.shade700 : Colors.green.shade600),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _updateCheckStatus,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: SkyTheme.timBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: _isCheckingUpdate ? null : _manualCheckForUpdate,
            icon: _isCheckingUpdate
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, size: 18),
            label: Text(_isCheckingUpdate ? 'Verifica in corso...' : 'Verifica Aggiornamenti'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: SkyTheme.timBlue),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDictionaryCard(
    BuildContext context,
    String title,
    String category,
    List<Dictionary> entries,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showEditDictionaryDialog(category: category),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Aggiungi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SkyTheme.timBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('Nessuna voce presente')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SkyTheme.timBlue.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.code,
                      style: TextStyle(
                        color: SkyTheme.timBlue,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  title: Text(entry.value),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () => _showEditDictionaryDialog(entry: entry),
                        color: Colors.blue,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () async {
                          final confirmed = await _showConfirmationDialog(
                            title: 'Elimina Voce',
                            content:
                                "Sei sicuro di voler eliminare la voce '${entry.code}'?",
                            isDestructive: true,
                          );
                          if (confirmed == true) {
                            await ref
                                .read(dictionaryProvider.notifier)
                                .deleteEntry(entry.id);
                          }
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCollectionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onPressed,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: SkyTheme.timBlue),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: OutlinedButton.icon(
        icon: const Icon(Icons.delete_outline, size: 18),
        label: const Text('Svuota'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange.shade700,
          side: BorderSide(color: Colors.orange.shade200),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHardResetAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Svuota Intero Database (Hard Reset)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elimina tutte le collection e formatta il database allo stato di fabbrica.',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('Formatta DB'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: _clearEntireDatabase,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthStatusCard(BuildContext context, AuthState authState) {
    final status = authState.status;
    final isConnected = status == AuthStatus.authenticated;
    final isChecking = status == AuthStatus.checking || status == AuthStatus.authenticating;
    final isError = status == AuthStatus.error;

    Color borderColor = Colors.grey.shade300;
    Color iconBgColor = Colors.orange.shade50;
    Color iconColor = Colors.orange.shade700;
    IconData iconData = Icons.cloud_off_outlined;
    String titleText = 'Sincronizzazione Remota Disattivata';
    String subtitleText = 'Puoi operare localmente, ma la sincronizzazione con i server di backend Azure è disattivata. Accedi per abilitarla.';

    if (isConnected) {
      borderColor = Colors.green.shade200;
      iconBgColor = Colors.green.shade50;
      iconColor = Colors.green.shade700;
      iconData = Icons.cloud_done_outlined;
      titleText = 'Sincronizzazione Remota Attiva';
      subtitleText = 'Collegato con successo tramite Microsoft Entra ID. I tracciati e le verifiche saranno allineati con i server aziendali.';
    } else if (isChecking) {
      borderColor = SkyTheme.timBlue.withAlpha(50);
      iconBgColor = SkyTheme.timBlue.withAlpha(15);
      iconColor = SkyTheme.timBlue;
      iconData = Icons.sync;
      titleText = 'Verifica credenziali in corso...';
      subtitleText = 'Connessione ai server Microsoft per il riscontro delle credenziali...';
    } else if (isError) {
      borderColor = Colors.red.shade200;
      iconBgColor = Colors.red.shade50;
      iconColor = Colors.red.shade700;
      iconData = Icons.error_outline;
      titleText = 'Errore di Autenticazione';
      subtitleText = authState.errorMessage ?? 'Si è verificato un errore sconosciuto durante il login.';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titleText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitleText,
                      style: TextStyle(
                        color: isError ? Colors.red.shade700 : Colors.grey.shade600,
                        fontSize: 13,
                        fontWeight: isError ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isConnected) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserDetailRow('Utente TIM:', authState.userName ?? 'Dipendente TIM'),
                      const SizedBox(height: 8),
                      _buildUserDetailRow('Email Aziendale:', authState.userEmail ?? 'utente@tim.it'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text(
                            'Sincronizzazione Remota: ',
                            style: TextStyle(
                              fontSize: 13, 
                              fontWeight: FontWeight.w500, 
                              color: Colors.grey
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Text(
                              'ATTIVA',
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Disconnetti'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    side: BorderSide(color: Colors.red.shade100),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ] else if (!isChecking) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).login();
                },
                icon: const Icon(Icons.login),
                label: const Text('Accedi con TIM (Entra ID)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SkyTheme.timBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAutoSyncSettingsCard(BuildContext context, AppSettings settings) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.autorenew, color: SkyTheme.timBlue),
              SizedBox(width: 12),
              Text(
                'Opzioni di Sincronizzazione Automatica',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: SkyTheme.timBlue,
            title: const Text(
              'Sincronizza all\'avvio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Avvia automaticamente la sincronizzazione di tutti i dati ad ogni apertura dell\'applicazione.',
              style: TextStyle(fontSize: 12),
            ),
            value: settings.syncOnStartup,
            onChanged: (val) {
              ref.read(appSettingsProvider.notifier).updateSyncOnStartup(val);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Ultima sincronizzazione: ${settings.lastSyncTime != null ? DateFormat('dd/MM/yyyy HH:mm:ss').format(settings.lastSyncTime!) : 'Mai sincronizzato'}",
                style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteSyncCard(BuildContext context, AppSettings settings) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PARAMETRI ENDPOINT SHAREPOINT',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: SkyTheme.timBlue,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nome Sito SharePoint',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _spSiteController,
                      decoration: InputDecoration(
                        hintText: 'Es: TIM Audit Site',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: SkyTheme.timBlue, width: 1.5),
                        ),
                        prefixIcon: const Icon(Icons.web, size: 20, color: SkyTheme.timBlue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Document Library (Contenitore)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _spLibraryController,
                      decoration: InputDecoration(
                        hintText: 'Es: Documents',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: SkyTheme.timBlue, width: 1.5),
                        ),
                        prefixIcon: const Icon(Icons.folder_shared, size: 20, color: SkyTheme.timBlue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSharepointFolderField(
                  label: 'Cartella Tracciati Contabili',
                  controller: _spFolderController,
                  hintText: 'Es: General/TracciatiContabili',
                  icon: Icons.folder_open,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildSharepointFolderField(
                  label: 'Cartella Estratti Conto',
                  controller: _spEstrattiContoController,
                  hintText: 'Es: General/EstrattiConto',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSharepointFolderField(
                  label: 'Cartella Tracciato SAP',
                  controller: _spTracciatoSapController,
                  hintText: 'Es: General/TracciatoSap',
                  icon: Icons.analytics_outlined,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildSharepointFolderField(
                  label: 'Cartella Estratti AMEX',
                  controller: _spEstrattiAmexController,
                  hintText: 'Es: General/EstrattiAmex',
                  icon: Icons.credit_card_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSharepointFolderField(
                  label: 'Cartella Anagrafica',
                  controller: _spAnagraficaController,
                  hintText: 'Es: General/Anagrafica',
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildSharepointFolderField(
                  label: 'Cartella Scarti Tracciato',
                  controller: _spScartiTracciatoController,
                  hintText: 'Es: General/ScartiTracciato',
                  icon: Icons.warning_amber_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(appSettingsProvider.notifier).updateSharepointSettings(
                  siteName: _spSiteController.text.trim(),
                  folderPath: _spFolderController.text.trim(),
                  documentLibrary: _spLibraryController.text.trim(),
                  estrattiContoPath: _spEstrattiContoController.text.trim(),
                  tracciatoSapPath: _spTracciatoSapController.text.trim(),
                  estrattiAmexPath: _spEstrattiAmexController.text.trim(),
                  anagraficaPath: _spAnagraficaController.text.trim(),
                  scartiTracciatoPath: _spScartiTracciatoController.text.trim(),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Impostazioni SharePoint salvate con successo!'),
                        ],
                      ),
                      backgroundColor: Colors.green.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text(
                'Salva Impostazioni SharePoint',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: SkyTheme.timBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharepointFolderField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SkyTheme.timBlue, width: 1.5),
            ),
            prefixIcon: Icon(icon, size: 20, color: SkyTheme.timBlue),
          ),
        ),
      ],
    );
  }
}

class _SettingsTab {
  final String title;
  final IconData icon;
  final String description;

  const _SettingsTab({
    required this.title,
    required this.icon,
    required this.description,
  });
}

const List<_SettingsTab> _tabs = [
  _SettingsTab(
    title: 'Cloud & Sync',
    icon: Icons.cloud_sync_outlined,
    description: 'Account, sincronizzazione automatica ed endpoint SharePoint.',
  ),
  _SettingsTab(
    title: 'Dizionari Decodifica',
    icon: Icons.book_outlined,
    description: 'Giustificativi, tipi dipendente e tabelle società.',
  ),
  _SettingsTab(
    title: 'Database Locale',
    icon: Icons.storage_outlined,
    description: 'Manutenzione dati, pulizia e ripristino di fabbrica.',
  ),
  _SettingsTab(
    title: 'Sistema & Info',
    icon: Icons.info_outline,
    description: 'Versione installata e verifica aggiornamenti software.',
  ),
];

