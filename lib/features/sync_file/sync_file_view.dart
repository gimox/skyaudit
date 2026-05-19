import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:cross_file/cross_file.dart';
import '../../core/theme/app_theme.dart';
import '../../core/db/isar_provider.dart';
import '../upload/providers/tracciato_contabile_provider.dart';
import '../upload/providers/estratto_conto_provider.dart';
import '../upload/providers/tracciato_sap_provider.dart';
import '../upload/providers/estratto_amex_provider.dart';
import '../upload/providers/anagrafica_provider.dart';
import '../upload/providers/scarti_ec_sap_provider.dart';
import '../upload/providers/log_history_provider.dart';
import '../upload/models/tracciato_contabile.dart';
import '../upload/models/log_history.dart';
import '../auth/providers/auth_provider.dart';
import '../settings/providers/app_settings_provider.dart';
import '../settings/models/app_settings.dart';
import 'services/sharepoint_service.dart';

class SyncFileView extends ConsumerStatefulWidget {
  const SyncFileView({super.key});

  @override
  ConsumerState<SyncFileView> createState() => _SyncFileViewState();
}

class _SyncFileViewState extends ConsumerState<SyncFileView> with SingleTickerProviderStateMixin {
  String _selectedSyncType = 'contabile';
  bool _clearBeforeSync = false;
  bool _isSyncing = false;
  double _syncProgress = 0.0;
  String _syncStep = '';
  List<String> _syncLogs = [];
  late AnimationController _pulseController;
  final SharePointService _sharePointService = SharePointService();



  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _log(String message) {
    setState(() {
      _syncLogs.insert(0, '[${DateTime.now().toIso8601String().substring(11, 19)}] $message');
    });
  }

  Future<int> _syncSingleType(String syncType, String token, AppSettings settings, Isar isar) async {
    String folderPath = '';
    List<String> allowedExtensions = [];
    String syncName = '';
    String sourceType = '';

    if (syncType == 'contabile') {
      folderPath = settings.sharepointFolderPath.isEmpty ? 'tracciati_uvet' : settings.sharepointFolderPath;
      allowedExtensions = ['.txt'];
      syncName = 'Tracciati Contabili';
      sourceType = 'contabile';
    } else if (syncType == 'conto') {
      folderPath = settings.sharepointEstrattiContoPath.isEmpty ? 'estratti_conto' : settings.sharepointEstrattiContoPath;
      allowedExtensions = ['.xlsx', '.xls'];
      syncName = 'Estratti Conto';
      sourceType = 'Estratto Conto';
    } else if (syncType == 'sap') {
      folderPath = settings.sharepointTracciatoSapPath.isEmpty ? 'tracciato_sap' : settings.sharepointTracciatoSapPath;
      allowedExtensions = ['.xlsx'];
      syncName = 'Tracciato SAP';
      sourceType = 'Tracciato SAP';
    } else if (syncType == 'amex') {
      folderPath = settings.sharepointEstrattiAmexPath.isEmpty ? 'estratti_amex' : settings.sharepointEstrattiAmexPath;
      allowedExtensions = ['.xls'];
      syncName = 'Estratti AMEX';
      sourceType = 'Estratto AMEX';
    } else if (syncType == 'anagrafica') {
      folderPath = settings.sharepointAnagraficaPath.isEmpty ? 'anagrafica' : settings.sharepointAnagraficaPath;
      allowedExtensions = ['.xlsx'];
      syncName = 'Anagrafica';
      sourceType = 'Anagrafica';
    } else if (syncType == 'scarti') {
      folderPath = settings.sharepointScartiTracciatoPath.isEmpty ? 'scarti_tracciato' : settings.sharepointScartiTracciatoPath;
      allowedExtensions = ['.xlsx'];
      syncName = 'Scarti Tracciato';
      sourceType = 'Scarti EC SAP';
    }

    _log('[$syncName] Avvio sincronizzazione...');
    _log('[$syncName] Richiesta listing dei file nella cartella SharePoint "/$folderPath" (filtro: $allowedExtensions)...');

    // Listing dei file reale da SharePoint
    List<SharePointFile> sharepointFiles = await _sharePointService.listFiles(
      accessToken: token,
      siteName: settings.sharepointSiteName,
      documentLibrary: settings.sharepointDocumentLibrary,
      folderPath: folderPath,
      allowedExtensions: allowedExtensions,
    );
    _log('[$syncName] Trovati ${sharepointFiles.length} file su SharePoint.');

    // Controllo opzione PULISCI TUTTO
    if (_clearBeforeSync) {
      _log('[$syncName] Opzione "Pulisci tutti" attiva. Svuotamento dei record e della cronologia in corso...');
      if (syncType == 'contabile') {
        await ref.read(tracciatoContabilesProvider.notifier).clear();
      } else if (syncType == 'conto') {
        await ref.read(estrattoContoProvider.notifier).clear();
      } else if (syncType == 'sap') {
        await ref.read(tracciatoSapProvider.notifier).clear();
      } else if (syncType == 'amex') {
        await ref.read(estrattoAmexProvider.notifier).clear();
      } else if (syncType == 'anagrafica') {
        await ref.read(anagraficaProvider.notifier).clear();
      } else if (syncType == 'scarti') {
        await ref.read(scartiEcSapProvider.notifier).clear();
      }
      
      // Svuota anche la cronologia specifica del sourceType
      await isar.writeTxn(() async {
        await isar.logHistorys.filter().sourceTypeEqualTo(sourceType).deleteAll();
      });
      
      if (syncType == 'contabile') {
        ref.invalidate(tracciatoContabilesProvider);
      } else if (syncType == 'conto') {
        ref.invalidate(estrattoContoProvider);
      } else if (syncType == 'sap') {
        ref.invalidate(tracciatoSapProvider);
      } else if (syncType == 'amex') {
        ref.invalidate(estrattoAmexProvider);
      } else if (syncType == 'anagrafica') {
        ref.invalidate(anagraficaProvider);
      } else if (syncType == 'scarti') {
        ref.invalidate(scartiEcSapProvider);
      }
      ref.invalidate(logHistoryProvider);
      _log('[$syncName] Database locale e cronologia per "$sourceType" puliti con successo.');
    }

    // Identificazione dei file da importare (Delta logic filtrata per sourceType)
    final existingLogs = await isar.logHistorys.filter().sourceTypeEqualTo(sourceType).findAll();
    final existingFileNames = existingLogs.map((log) => log.fileName).toSet();

    final List<SharePointFile> filesToImport = [];
    for (final file in sharepointFiles) {
      if (_clearBeforeSync || !existingFileNames.contains(file.name)) {
        filesToImport.add(file);
        _log('[$syncName] File identificato per l\'importazione: ${file.name}');
      } else {
        _log('[$syncName] File già importato (saltato): ${file.name}');
      }
    }

    if (filesToImport.isEmpty) {
      _log('[$syncName] Nessun nuovo file da importare. Categoria aggiornata.');
      return 0;
    }

    int typeImportedRecords = 0;

    // Download e parsing in loop dei file delta
    for (int i = 0; i < filesToImport.length; i++) {
      final file = filesToImport[i];
      _log('[$syncName] Scaricamento in corso: ${file.name} (${i + 1}/${filesToImport.length})...');

      if (syncType == 'contabile') {
        final fileContent = await _sharePointService.downloadFile(
          accessToken: token,
          itemId: file.id,
          sitePath: file.sitePath,
        );

        _log('[$syncName] Download completato. Esecuzione del parsing del tracciato...');
        final lines = fileContent.split('\n');
        
        if (lines.length < 3) {
          _log('[$syncName] Avviso: Il file ${file.name} è vuoto o non conforme.');
          continue;
        }

        final uniqueCode = '${DateTime.now().millisecondsSinceEpoch}_${syncType}_$i';
        final List<TracciatoContabile> parsedRecords = [];

        for (int lineIndex = 1; lineIndex < lines.length - 1; lineIndex++) {
          final line = lines[lineIndex];
          if (line.trim().isNotEmpty) {
            try {
              final record = TracciatoContabile.fromString(
                line,
                logHistoryId: uniqueCode,
                sourceFileLine: lineIndex + 1,
              );
              parsedRecords.add(record);
            } catch (err) {
              _log('[$syncName] Errore parsing riga ${lineIndex + 1} nel file ${file.name}: $err');
            }
          }
        }

        if (parsedRecords.isNotEmpty) {
          await isar.writeTxn(() async {
            await isar.tracciatoContabiles.putAll(parsedRecords);
            
            final logHistoryEntry = LogHistory(
              fileName: file.name,
              date: DateTime.now(),
              uniqueCode: uniqueCode,
              totalRecords: parsedRecords.length + 2,
              insertedRecords: parsedRecords.length,
              sourceType: 'contabile',
            );
            await isar.logHistorys.put(logHistoryEntry);
          });

          typeImportedRecords += parsedRecords.length;
          _log('[$syncName] File ${file.name} salvato nel DB: ${parsedRecords.length} record importati.');
        }
      } else {
        // File Excel (binari)
        final bytes = await _sharePointService.downloadFileBytes(
          accessToken: token,
          itemId: file.id,
          sitePath: file.sitePath,
        );

        _log('[$syncName] Download completato. Esecuzione del parsing...');
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/${file.name}');
        await tempFile.writeAsBytes(bytes);
        final xFile = XFile(tempFile.path);

        Map<String, dynamic> result = {};
        try {
          if (syncType == 'conto') {
            result = await ref.read(estrattoContoProvider.notifier).loadFromFile(xFile);
          } else if (syncType == 'sap') {
            result = await ref.read(tracciatoSapProvider.notifier).loadFromFile(xFile);
          } else if (syncType == 'amex') {
            result = await ref.read(estrattoAmexProvider.notifier).loadFromFile(xFile);
          } else if (syncType == 'anagrafica') {
            result = await ref.read(anagraficaProvider.notifier).loadFromFile(xFile);
          } else if (syncType == 'scarti') {
            result = await ref.read(scartiEcSapProvider.notifier).loadFromFile(xFile);
          }

          final inserted = result['inserted'] as int? ?? 0;
          typeImportedRecords += inserted;
          _log('[$syncName] File ${file.name} salvato nel DB: $inserted record importati.');
        } catch (e) {
          _log('[$syncName] Errore durante l\'importazione del file ${file.name}: $e');
          rethrow;
        } finally {
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        }
      }
    }

    // Invalidazione dei provider
    if (syncType == 'contabile') {
      ref.invalidate(tracciatoContabilesProvider);
    } else if (syncType == 'conto') {
      ref.invalidate(estrattoContoProvider);
    } else if (syncType == 'sap') {
      ref.invalidate(tracciatoSapProvider);
    } else if (syncType == 'amex') {
      ref.invalidate(estrattoAmexProvider);
    } else if (syncType == 'anagrafica') {
      ref.invalidate(anagraficaProvider);
    } else if (syncType == 'scarti') {
      ref.invalidate(scartiEcSapProvider);
    }
    ref.invalidate(logHistoryProvider);

    return typeImportedRecords;
  }

  Future<void> _startSynchronization() async {
    // 1. Verifica autenticazione
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Autenticazione richiesta. Effettua prima il login Microsoft Entra ID in alto a destra.')),
            ],
          ),
          backgroundColor: SkyTheme.timRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncProgress = 0.0;
      _syncStep = 'Connessione sicura a SharePoint in corso...';
      _syncLogs = [];
    });
    _pulseController.repeat(reverse: true);

    try {
      _log('Richiesta token di sicurezza valido da Entra ID...');
      final token = await ref.read(authProvider.notifier).getValidAccessToken();
      
      if (token == null) {
        throw Exception('Impossibile ottenere un token di sicurezza valido. Effettua nuovamente il login.');
      }

      final settings = ref.read(appSettingsProvider);
      final isar = ref.read(isarProvider);

      List<String> typesToSync = [];
      if (_selectedSyncType == 'all') {
        typesToSync = ['contabile', 'conto', 'sap', 'amex', 'scarti', 'anagrafica'];
      } else {
        typesToSync = [_selectedSyncType];
      }

      int totalImportedRecords = 0;

      for (int i = 0; i < typesToSync.length; i++) {
        final currentType = typesToSync[i];
        final progress = (i / typesToSync.length) * 0.9;
        
        setState(() {
          _syncProgress = progress;
          _syncStep = 'Sincronizzazione in corso per ${currentType.toUpperCase()} (${i + 1}/${typesToSync.length})...';
        });

        final imported = await _syncSingleType(currentType, token, settings, isar);
        totalImportedRecords += imported;
      }

      setState(() {
        _syncProgress = 1.0;
        _syncStep = 'Sincronizzazione completata con successo!';
        _isSyncing = false;
      });
      _pulseController.stop();
      _log('Sincronizzazione conclusa con successo. Importati $totalImportedRecords record in totale.');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Sincronizzazione riuscita! Importati $totalImportedRecords record.'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );

    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSyncing = false;
        _syncStep = 'Errore durante la sincronizzazione: $e';
      });
      _pulseController.stop();
      _log('ERRORE CRITICO: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Errore durante la sincronizzazione: $e')),
            ],
          ),
          backgroundColor: SkyTheme.timRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    String titleText = '';
    String descText = '';
    String buttonLabel = '';
    String folderInfo = '';

    if (_selectedSyncType == 'all') {
      titleText = 'Sincronizzazione Completa';
      descText = 'Sincronizza in sequenza tutte le categorie configurate (Contabili, Estratti Conto, SAP, AMEX, Scarti, Anagrafica) da SharePoint.';
      buttonLabel = 'Sincronizza Tutto';
      folderInfo = 'Tutte le cartelle configurate';
    } else if (_selectedSyncType == 'contabile') {
      titleText = 'Tracciati Contabili';
      descText = 'Sincronizza i file di tracciato contabile (*.txt) da SharePoint.';
      buttonLabel = 'Sincronizza Tracciati Contabili';
      folderInfo = settings.sharepointFolderPath.isEmpty ? 'tracciati_uvet' : settings.sharepointFolderPath;
    } else if (_selectedSyncType == 'conto') {
      titleText = 'Estratti Conto';
      descText = 'Sincronizza i file di estratto conto bancario (*.xlsx, *.xls) da SharePoint.';
      buttonLabel = 'Sincronizza Estratti Conto';
      folderInfo = settings.sharepointEstrattiContoPath.isEmpty ? 'estratti_conto' : settings.sharepointEstrattiContoPath;
    } else if (_selectedSyncType == 'sap') {
      titleText = 'Tracciato SAP';
      descText = 'Sincronizza i file del tracciato SAP (*.xlsx) da SharePoint.';
      buttonLabel = 'Sincronizza SAP';
      folderInfo = settings.sharepointTracciatoSapPath.isEmpty ? 'tracciato_sap' : settings.sharepointTracciatoSapPath;
    } else if (_selectedSyncType == 'amex') {
      titleText = 'Estratti AMEX';
      descText = 'Sincronizza i file degli estratti AMEX (*.xls) da SharePoint.';
      buttonLabel = 'Sincronizza AMEX';
      folderInfo = settings.sharepointEstrattiAmexPath.isEmpty ? 'estratti_amex' : settings.sharepointEstrattiAmexPath;
    } else if (_selectedSyncType == 'anagrafica') {
      titleText = 'Anagrafica';
      descText = 'Sincronizza i file dell\'anagrafica dipendenti (*.xlsx) da SharePoint.';
      buttonLabel = 'Sincronizza Anagrafica';
      folderInfo = settings.sharepointAnagraficaPath.isEmpty ? 'anagrafica' : settings.sharepointAnagraficaPath;
    } else if (_selectedSyncType == 'scarti') {
      titleText = 'Scarti Tracciato';
      descText = 'Sincronizza i file degli scarti del tracciato (*.xlsx) da SharePoint.';
      buttonLabel = 'Sincronizza Scarti';
      folderInfo = settings.sharepointScartiTracciatoPath.isEmpty ? 'scarti_tracciato' : settings.sharepointScartiTracciatoPath;
    }

    // Definizione del contenuto del Pannello di Controllo
    final leftPanelContent = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final alphaVal = (25 + (_pulseController.value * 25)).toInt();
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: SkyTheme.timBlue.withAlpha(alphaVal),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isSyncing ? Icons.sync : (_selectedSyncType == 'all' ? Icons.all_inclusive : Icons.cloud_download),
                size: 40,
                color: SkyTheme.timBlue,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text(
          titleText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: SkyTheme.timBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_open, size: 14, color: SkyTheme.timBlue),
              const SizedBox(width: 6),
              Text(
                'Cartella SharePoint: /$folderInfo',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: SkyTheme.timBlue,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          descText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),

        // Card impostazione "Pulisci tutti prima di sincronizzare"
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SwitchListTile(
            activeTrackColor: SkyTheme.timBlue,
            title: const Text(
              'Pulisci tutti prima di inserire',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              'Svuota tutti i record locali della tabella "$titleText" registrati nel DB prima di scaricare l\'intero archivio SharePoint.',
              style: const TextStyle(fontSize: 11),
            ),
            value: _clearBeforeSync,
            onChanged: _isSyncing
                ? null
                : (val) {
                    setState(() {
                      _clearBeforeSync = val;
                    });
                  },
          ),
        ),
        const SizedBox(height: 20),

        // Progresso
        if (_isSyncing || _syncProgress > 0) ...[
          Column(
            children: [
              LinearProgressIndicator(
                value: _syncProgress,
                backgroundColor: Colors.grey.shade200,
                color: SkyTheme.timBlue,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 12),
              Text(
                _syncStep,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _syncProgress == 1.0 ? Colors.green.shade800 : Colors.grey.shade700,
                  fontWeight: _syncProgress == 1.0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],

        // Pulsante Sincronizza
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSyncing ? null : _startSynchronization,
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.cloud_sync),
            label: Text(
              _isSyncing ? 'Sincronizzazione in Corso...' : buttonLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: SkyTheme.timBlue,
              foregroundColor: Colors.white,
              elevation: _isSyncing ? 0 : 2,
              shadowColor: SkyTheme.timBlue.withAlpha(80),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );

    // Definizione del contenuto della Console Log
    final rightPanelContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isSyncing ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'CONSOLE DI SINCRONIZZAZIONE',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            if (_syncLogs.isNotEmpty)
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.copy, color: Colors.grey, size: 16),
                tooltip: 'Copia tutti i log',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _syncLogs.join('\n')));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Log copiati negli appunti!'),
                        ],
                      ),
                      backgroundColor: SkyTheme.timBlue,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
          ],
        ),
        const Divider(color: Colors.grey, height: 20, thickness: 0.3),
        Expanded(
          child: _syncLogs.isEmpty
            ? const Center(
                child: Text(
                  'In attesa di avviare il processo...',
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _syncLogs.length,
                itemBuilder: (context, index) {
                  final log = _syncLogs[index];
                  final isError = log.contains('ERRORE');
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: SelectableText(
                      log,
                      style: TextStyle(
                        color: isError ? Colors.redAccent : Colors.greenAccent.shade400,
                        fontSize: 12,
                        fontFamily: 'Courier',
                      ),
                    ),
                  );
                },
              ),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SINCRONIZZAZIONE FILE CLOUD',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: SkyTheme.timBlue,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestione e sincronizzazione automatica delta dei file contabili e gestionali aziendali da SharePoint.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: SkyTheme.timBlue,
                  selectedForegroundColor: Colors.white,
                ),
                segments: const [
                  ButtonSegment(value: 'all', label: Text('Tutto'), icon: Icon(Icons.all_inclusive)),
                  ButtonSegment(value: 'contabile', label: Text('Contabili'), icon: Icon(Icons.receipt_long)),
                  ButtonSegment(value: 'conto', label: Text('Estratti Conto'), icon: Icon(Icons.account_balance_wallet)),
                  ButtonSegment(value: 'sap', label: Text('SAP'), icon: Icon(Icons.analytics)),
                  ButtonSegment(value: 'amex', label: Text('AMEX'), icon: Icon(Icons.credit_card)),
                  ButtonSegment(value: 'scarti', label: Text('Scarti'), icon: Icon(Icons.warning_amber)),
                  ButtonSegment(value: 'anagrafica', label: Text('Anagrafica'), icon: Icon(Icons.people)),
                ],
                selected: {_selectedSyncType},
                onSelectionChanged: _isSyncing
                    ? null
                    : (val) {
                        setState(() {
                          _selectedSyncType = val.first;
                        });
                      },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 850) {
                  // Layout Desktop: Affiancato
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pannello di Controllo Sinistro
                      Expanded(
                        flex: 5,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(230),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: leftPanelContent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Terminale di Log Destro
                      Expanded(
                        flex: 4,
                        child: Container(
                          height: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(240),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: rightPanelContent,
                        ),
                      ),
                    ],
                  );
                } else {
                  // Layout Mobile/Tablet: Stackato Verticalmente
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(230),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: leftPanelContent,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 400, // Altezza fissa per la console di log nello stack
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(240),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade800),
                          ),
                          child: rightPanelContent,
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
