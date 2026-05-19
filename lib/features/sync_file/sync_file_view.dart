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

  // State variables for Smart Sync Dashboard
  bool _showAdvancedConsole = false;
  int _totalFilesFound = 0;
  int _processedFilesCount = 0;
  int _totalRecordsImported = 0;
  String _currentFile = '';
  String _currentFileStatus = '';
  int _currentFileRecords = 0;
  List<Map<String, dynamic>> _syncQueue = [];

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

  Future<int> _syncFileItem(
    String syncType,
    SharePointFile file,
    String token,
    AppSettings settings,
    Isar isar,
  ) async {
    String syncName = '';
    String sourceType = '';

    if (syncType == 'contabile') {
      syncName = 'Tracciati Contabili';
      sourceType = 'Tracciato Contabile';
    } else if (syncType == 'conto') {
      syncName = 'Estratti Conto';
      sourceType = 'Estratto Conto';
    } else if (syncType == 'sap') {
      syncName = 'Tracciato SAP';
      sourceType = 'Tracciato SAP';
    } else if (syncType == 'amex') {
      syncName = 'Estratti AMEX';
      sourceType = 'Estratto AMEX';
    } else if (syncType == 'anagrafica') {
      syncName = 'Anagrafica';
      sourceType = 'Anagrafica';
    } else if (syncType == 'scarti') {
      syncName = 'Scarti Tracciato';
      sourceType = 'Scarti EC SAP';
    }

    _log('[$syncName] Inizio elaborazione file: ${file.name}...');
    setState(() {
      _currentFile = file.name;
      _currentFileStatus = 'Scaricamento...';
      _currentFileRecords = 0;
    });

    int importedRecords = 0;

    if (syncType == 'contabile') {
      final fileContent = await _sharePointService.downloadFile(
        accessToken: token,
        itemId: file.id,
        sitePath: file.sitePath,
      );

      setState(() {
        _currentFileStatus = 'Analisi e Inserimento...';
      });

      _log('[$syncName] Download completato. Esecuzione del parsing del tracciato...');
      final lines = fileContent.split('\n');
      
      if (lines.length < 3) {
        _log('[$syncName] Avviso: Il file ${file.name} è vuoto o non conforme.');
        return 0;
      }

      final uniqueCode = '${DateTime.now().millisecondsSinceEpoch}_${syncType}_${file.id.hashCode}';
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
            sourceType: 'Tracciato Contabile',
          );
          await isar.logHistorys.put(logHistoryEntry);
        });

        importedRecords = parsedRecords.length;
        setState(() {
          _currentFileRecords = importedRecords;
        });
        _log('[$syncName] File ${file.name} salvato nel DB: $importedRecords record importati.');
      }
    } else {
      // File Excel (binari)
      final bytes = await _sharePointService.downloadFileBytes(
        accessToken: token,
        itemId: file.id,
        sitePath: file.sitePath,
      );

      setState(() {
        _currentFileStatus = 'Analisi ed Elaborazione Excel...';
      });

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
          _log('[$syncName] Modalità anagrafica: svuotamento dei record precedenti dal database...');
          await ref.read(anagraficaProvider.notifier).clear();
          await isar.writeTxn(() async {
            await isar.logHistorys.filter().sourceTypeEqualTo('Anagrafica').deleteAll();
          });
          result = await ref.read(anagraficaProvider.notifier).loadFromFile(xFile);
        } else if (syncType == 'scarti') {
          result = await ref.read(scartiEcSapProvider.notifier).loadFromFile(xFile);
        }

        importedRecords = result['inserted'] as int? ?? 0;
        setState(() {
          _currentFileRecords = importedRecords;
        });
        _log('[$syncName] File ${file.name} salvato nel DB: $importedRecords record importati.');
      } catch (e) {
        _log('[$syncName] Errore durante l\'importazione del file ${file.name}: $e');
        rethrow;
      } finally {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      }
    }

    return importedRecords;
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
      _syncQueue = [];
      _totalFilesFound = 0;
      _processedFilesCount = 0;
      _totalRecordsImported = 0;
      _currentFile = '';
      _currentFileStatus = '';
      _currentFileRecords = 0;
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

      // Svuota i database per i tipi selezionati se richiesto
      if (_clearBeforeSync) {
        for (final type in typesToSync) {
          _log('Svuotamento della categoria $type in corso...');
          setState(() {
            _syncStep = 'Pulizia database per ${type.toUpperCase()}...';
          });
          
          String sourceType = '';
          if (type == 'contabile') {
            await ref.read(tracciatoContabilesProvider.notifier).clear();
            sourceType = 'Tracciato Contabile';
          } else if (type == 'conto') {
            await ref.read(estrattoContoProvider.notifier).clear();
            sourceType = 'Estratto Conto';
          } else if (type == 'sap') {
            await ref.read(tracciatoSapProvider.notifier).clear();
            sourceType = 'Tracciato SAP';
          } else if (type == 'amex') {
            await ref.read(estrattoAmexProvider.notifier).clear();
            sourceType = 'Estratto AMEX';
          } else if (type == 'anagrafica') {
            await ref.read(anagraficaProvider.notifier).clear();
            sourceType = 'Anagrafica';
          } else if (type == 'scarti') {
            await ref.read(scartiEcSapProvider.notifier).clear();
            sourceType = 'Scarti EC SAP';
          }
          
          await isar.writeTxn(() async {
            await isar.logHistorys.filter()
                .sourceTypeEqualTo(sourceType)
                .or()
                .sourceTypeEqualTo(sourceType == 'Tracciato Contabile' ? 'contabile' : sourceType)
                .deleteAll();
          });
        }
        
        ref.invalidate(tracciatoContabilesProvider);
        ref.invalidate(estrattoContoProvider);
        ref.invalidate(tracciatoSapProvider);
        ref.invalidate(estrattoAmexProvider);
        ref.invalidate(anagraficaProvider);
        ref.invalidate(scartiEcSapProvider);
        ref.invalidate(logHistoryProvider);
        
        _log('Database locale e cronologia per i tipi selezionati puliti con successo.');
      }

      setState(() {
        _syncStep = 'Ricerca dei file su SharePoint...';
      });

      // 1. Listing dei file su SharePoint
      for (final type in typesToSync) {
        String folderPath = '';
        List<String> allowedExtensions = [];
        String syncName = '';
        String sourceType = '';

        if (type == 'contabile') {
          folderPath = settings.sharepointFolderPath.isEmpty ? 'tracciati_uvet' : settings.sharepointFolderPath;
          allowedExtensions = ['.txt'];
          syncName = 'Tracciati Contabili';
          sourceType = 'Tracciato Contabile';
        } else if (type == 'conto') {
          folderPath = settings.sharepointEstrattiContoPath.isEmpty ? 'estratti_conto' : settings.sharepointEstrattiContoPath;
          allowedExtensions = ['.xlsx', '.xls'];
          syncName = 'Estratti Conto';
          sourceType = 'Estratto Conto';
        } else if (type == 'sap') {
          folderPath = settings.sharepointTracciatoSapPath.isEmpty ? 'tracciato_sap' : settings.sharepointTracciatoSapPath;
          allowedExtensions = ['.xlsx'];
          syncName = 'Tracciato SAP';
          sourceType = 'Tracciato SAP';
        } else if (type == 'amex') {
          folderPath = settings.sharepointEstrattiAmexPath.isEmpty ? 'estratti_amex' : settings.sharepointEstrattiAmexPath;
          allowedExtensions = ['.xls'];
          syncName = 'Estratti AMEX';
          sourceType = 'Estratto AMEX';
        } else if (type == 'anagrafica') {
          folderPath = settings.sharepointAnagraficaPath.isEmpty ? 'anagrafica' : settings.sharepointAnagraficaPath;
          allowedExtensions = ['.xlsx'];
          syncName = 'Anagrafica';
          sourceType = 'Anagrafica';
        } else if (type == 'scarti') {
          folderPath = settings.sharepointScartiTracciatoPath.isEmpty ? 'scarti_tracciato' : settings.sharepointScartiTracciatoPath;
          allowedExtensions = ['.xlsx'];
          syncName = 'Scarti Tracciato';
          sourceType = 'Scarti EC SAP';
        }

        _log('[$syncName] Ricerca dei file in corso in "/$folderPath"...');
        
        final sharepointFiles = await _sharePointService.listFiles(
          accessToken: token,
          siteName: settings.sharepointSiteName,
          documentLibrary: settings.sharepointDocumentLibrary,
          folderPath: folderPath,
          allowedExtensions: allowedExtensions,
        );

        _log('[$syncName] Rilevati ${sharepointFiles.length} file su SharePoint.');

        // Filtro delta logic
        final existingLogs = await isar.logHistorys.filter()
            .sourceTypeEqualTo(sourceType)
            .or()
            .sourceTypeEqualTo(sourceType == 'Tracciato Contabile' ? 'contabile' : sourceType)
            .findAll();

        List<SharePointFile> filesToQueue = sharepointFiles;
        if (type == 'anagrafica' && sharepointFiles.isNotEmpty) {
          // Ordina per data di ultima modifica decrescente (il più recente per primo)
          sharepointFiles.sort((a, b) => b.lastModified.compareTo(a.lastModified));
          filesToQueue = [sharepointFiles.first];
          _log('[$syncName] Modalità anagrafica: selezionato il file più recente: ${sharepointFiles.first.name} (${sharepointFiles.first.lastModified.toLocal()})');
        }

        for (final file in filesToQueue) {
          final fileLogs = existingLogs.where((log) => log.fileName == file.name).toList();
          
          bool isAlreadyImported = false;
          int importedRecordsCount = 0;
          
          if (fileLogs.isNotEmpty && !_clearBeforeSync) {
            fileLogs.sort((a, b) => b.date.compareTo(a.date));
            final lastLog = fileLogs.first;
            
            // Il file è considerato già importato solo se non è stato modificato su SharePoint
            // dopo la sua ultima importazione locale (+5 secondi di tolleranza)
            if (!file.lastModified.isAfter(lastLog.date.add(const Duration(seconds: 5)))) {
              isAlreadyImported = true;
              importedRecordsCount = lastLog.insertedRecords;
            }
          }
          
          _syncQueue.add({
            'file': file,
            'syncType': type,
            'syncName': syncName,
            'sourceType': sourceType,
            'status': isAlreadyImported ? 'completed' : 'pending',
            'records': isAlreadyImported ? importedRecordsCount : 0,
            'isDeltaSkipped': isAlreadyImported,
          });
        }
      }

      // Filtriamo solo i file da importare per i totali
      final activeQueue = _syncQueue.where((item) => item['status'] == 'pending').toList();
      setState(() {
        _totalFilesFound = activeQueue.length;
      });

      _log('Totale file da elaborare: $_totalFilesFound.');

      if (_totalFilesFound == 0) {
        setState(() {
          _syncProgress = 1.0;
          _syncStep = 'Sincronizzazione completata: nessun nuovo file trovato.';
          _isSyncing = false;
        });
        _pulseController.stop();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Tutte le tabelle sono aggiornate. Nessun nuovo file da importare.'),
                ],
              ),
              backgroundColor: Colors.blue.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // 2. Loop di importazione dei file attivi
      for (int i = 0; i < _syncQueue.length; i++) {
        final item = _syncQueue[i];
        if (item['status'] == 'completed') continue;

        final file = item['file'] as SharePointFile;
        final syncType = item['syncType'] as String;

        setState(() {
          item['status'] = 'syncing';
          _syncStep = 'Elaborazione file ${_processedFilesCount + 1} di $_totalFilesFound...';
          _syncProgress = _processedFilesCount / _totalFilesFound;
        });

        try {
          final imported = await _syncFileItem(syncType, file, token, settings, isar);
          
          setState(() {
            item['status'] = 'completed';
            item['records'] = imported;
            _totalRecordsImported += imported;
            _processedFilesCount++;
            _syncProgress = _processedFilesCount / _totalFilesFound;
          });
        } catch (e) {
          setState(() {
            item['status'] = 'error';
            item['errorMessage'] = e.toString();
          });
          _log('Errore durante l\'importazione di ${file.name}: $e');
          setState(() {
            _processedFilesCount++;
            _syncProgress = _processedFilesCount / _totalFilesFound;
          });
        }
      }

      ref.invalidate(tracciatoContabilesProvider);
      ref.invalidate(estrattoContoProvider);
      ref.invalidate(tracciatoSapProvider);
      ref.invalidate(estrattoAmexProvider);
      ref.invalidate(anagraficaProvider);
      ref.invalidate(scartiEcSapProvider);
      ref.invalidate(logHistoryProvider);

      setState(() {
        _syncProgress = 1.0;
        _syncStep = 'Sincronizzazione completata!';
        _isSyncing = false;
      });
      _pulseController.stop();
      _log('Sincronizzazione conclusa con successo. Importati $_totalRecordsImported record in totale.');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Sincronizzazione riuscita! Importati $_totalRecordsImported record.'),
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

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartProgressDashboard() {
    final hasFailed = _syncStep.contains('Errore') || _syncStep.contains('fallita');
    final isCompleted = _syncProgress == 1.0 && !_isSyncing;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isCompleted 
                    ? 'Sincronizzazione Completata' 
                    : (hasFailed ? 'Sincronizzazione Interrotta' : 'Avanzamento Globale'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(_syncProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCompleted ? Colors.green.shade700 : (hasFailed ? SkyTheme.timRed : SkyTheme.timBlue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _syncProgress,
            backgroundColor: Colors.grey.shade200,
            color: isCompleted ? Colors.green.shade600 : (hasFailed ? SkyTheme.timRed : SkyTheme.timBlue),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Text(
            _syncStep,
            style: TextStyle(
              fontSize: 12,
              color: hasFailed ? SkyTheme.timRed : Colors.grey.shade700,
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Divider(height: 32),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Record Importati',
                  '$_totalRecordsImported',
                  Icons.save_outlined,
                  Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'File Elaborati',
                  '$_processedFilesCount / $_totalFilesFound',
                  Icons.folder_shared_outlined,
                  SkyTheme.timBlue,
                ),
              ),
            ],
          ),

          if (_isSyncing && _currentFile.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SkyTheme.timBlue.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: SkyTheme.timBlue.withAlpha(30)),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SkyTheme.timBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentFile,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Stato: $_currentFileStatus | Inseriti: $_currentFileRecords record',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_syncQueue.isNotEmpty) ...[
            const SizedBox(height: 20),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                iconColor: SkyTheme.timBlue,
                title: Text(
                  'Elenco dettagliato file (${_syncQueue.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: SkyTheme.timBlue,
                  ),
                ),
                children: [
                  Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _syncQueue.length,
                      itemBuilder: (context, idx) {
                        final item = _syncQueue[idx];
                        final name = (item['file'] as SharePointFile).name;
                        final status = item['status'] as String;
                        final recs = item['records'] as int;
                        final isDeltaSkipped = item['isDeltaSkipped'] as bool? ?? false;

                        IconData statusIcon = Icons.watch_later_outlined;
                        Color iconColor = Colors.grey;

                        if (status == 'completed') {
                          statusIcon = Icons.check_circle_outline;
                          iconColor = isDeltaSkipped ? Colors.grey.shade500 : Colors.green.shade600;
                        } else if (status == 'syncing') {
                          statusIcon = Icons.sync;
                          iconColor = SkyTheme.timBlue;
                        } else if (status == 'error') {
                          statusIcon = Icons.error_outline;
                          iconColor = SkyTheme.timRed;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            children: [
                              Icon(statusIcon, color: iconColor, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: status == 'syncing' ? Colors.black87 : Colors.grey.shade700,
                                    fontWeight: status == 'syncing' ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isDeltaSkipped 
                                    ? 'Già presente' 
                                    : (status == 'error' ? 'Errore' : '+$recs rec'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: status == 'completed' 
                                      ? (isDeltaSkipped ? Colors.grey.shade500 : Colors.green.shade700) 
                                      : (status == 'error' ? SkyTheme.timRed : Colors.grey.shade600),
                                  fontWeight: status == 'completed' && !isDeltaSkipped ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClearDbOption() {
    return Container(
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
        subtitle: const Text(
          'Svuota tutti i record locali della tabella configurata nel DB prima di scaricare l\'intero archivio SharePoint.',
          style: TextStyle(fontSize: 11),
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
    );
  }

  Widget _buildSyncButton() {
    String buttonLabel = '';

    if (_selectedSyncType == 'all') {
      buttonLabel = 'Sincronizza Tutto';
    } else if (_selectedSyncType == 'contabile') {
      buttonLabel = 'Sincronizza Tracciati Contabili';
    } else if (_selectedSyncType == 'conto') {
      buttonLabel = 'Sincronizza Estratti Conto';
    } else if (_selectedSyncType == 'sap') {
      buttonLabel = 'Sincronizza SAP';
    } else if (_selectedSyncType == 'amex') {
      buttonLabel = 'Sincronizza AMEX';
    } else if (_selectedSyncType == 'anagrafica') {
      buttonLabel = 'Sincronizza Anagrafica';
    } else if (_selectedSyncType == 'scarti') {
      buttonLabel = 'Sincronizza Scarti';
    }

    return SizedBox(
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
    );
  }

  Widget _buildDashboardHeader() {
    final settings = ref.read(appSettingsProvider);
    String titleText = '';
    String descText = '';
    String folderInfo = '';

    if (_selectedSyncType == 'all') {
      titleText = 'Sincronizzazione Completa';
      descText = 'Sincronizza in sequenza tutte le categorie configurate (Contabili, Estratti Conto, SAP, AMEX, Scarti, Anagrafica) da SharePoint.';
      folderInfo = 'Tutte le cartelle configurate';
    } else if (_selectedSyncType == 'contabile') {
      titleText = 'Tracciati Contabili';
      descText = 'Sincronizza i file di tracciato contabile (*.txt) da SharePoint.';
      folderInfo = settings.sharepointFolderPath.isEmpty ? 'tracciati_uvet' : settings.sharepointFolderPath;
    } else if (_selectedSyncType == 'conto') {
      titleText = 'Estratti Conto';
      descText = 'Sincronizza i file di estratto conto bancario (*.xlsx, *.xls) da SharePoint.';
      folderInfo = settings.sharepointEstrattiContoPath.isEmpty ? 'estratti_conto' : settings.sharepointEstrattiContoPath;
    } else if (_selectedSyncType == 'sap') {
      titleText = 'Tracciato SAP';
      descText = 'Sincronizza i file del tracciato SAP (*.xlsx) da SharePoint.';
      folderInfo = settings.sharepointTracciatoSapPath.isEmpty ? 'tracciato_sap' : settings.sharepointTracciatoSapPath;
    } else if (_selectedSyncType == 'amex') {
      titleText = 'Estratti AMEX';
      descText = 'Sincronizza i file degli estratti AMEX (*.xls) da SharePoint.';
      folderInfo = settings.sharepointEstrattiAmexPath.isEmpty ? 'estratti_amex' : settings.sharepointEstrattiAmexPath;
    } else if (_selectedSyncType == 'anagrafica') {
      titleText = 'Anagrafica';
      descText = 'Sincronizza i file dell\'anagrafica dipendenti (*.xlsx) da SharePoint.';
      folderInfo = settings.sharepointAnagraficaPath.isEmpty ? 'anagrafica' : settings.sharepointAnagraficaPath;
    } else if (_selectedSyncType == 'scarti') {
      titleText = 'Scarti Tracciato';
      descText = 'Sincronizza i file degli scarti del tracciato (*.xlsx) da SharePoint.';
      folderInfo = settings.sharepointScartiTracciatoPath.isEmpty ? 'scarti_tracciato' : settings.sharepointScartiTracciatoPath;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final alphaVal = (25 + (_pulseController.value * 25)).toInt();
                return Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: SkyTheme.timBlue.withAlpha(alphaVal),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSyncing ? Icons.sync : (_selectedSyncType == 'all' ? Icons.all_inclusive : Icons.cloud_download),
                    size: 26,
                    color: SkyTheme.timBlue,
                  ),
                );
              },
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
                      color: SkyTheme.timBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder_open, size: 12, color: SkyTheme.timBlue),
                        const SizedBox(width: 4),
                        Text(
                          '/$folderInfo',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: SkyTheme.timBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          descText,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMainDashboardCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDashboardHeader(),
            const SizedBox(height: 24),
            
            if (_isSyncing || _totalFilesFound > 0) ...[
              _buildSmartProgressDashboard(),
              const SizedBox(height: 24),
            ],

            if (!_isSyncing && _selectedSyncType != 'anagrafica') ...[
              _buildClearDbOption(),
              const SizedBox(height: 24),
            ],

            _buildSyncButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPromptCard(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withAlpha(20),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Container(
        width: 460,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SkyTheme.timBlue.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_sync_outlined,
                color: SkyTheme.timBlue,
                size: 48,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Sincronizzazione Richiesta',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: SkyTheme.timBlue,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Per poter sincronizzare i dati contabili ed anagrafici dal cloud SharePoint, è necessario autenticarsi con il proprio account aziendale.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SkyTheme.timBlue,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: SkyTheme.timBlue.withAlpha(80),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                await ref.read(authProvider.notifier).login();
              },
              icon: const Icon(Icons.login, size: 20),
              label: const Text(
                'ACCEDI PER SINCRONIZZARE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsoleCard(BuildContext context, Widget content, {double? height}) {
    return Container(
      height: height ?? double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(240),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isConnected = authState.isAuthenticated;

    if (!isConnected) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _buildLoginPromptCard(context),
        ),
      );
    }

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
                  final isError = log.contains('ERRORE') || log.contains('CRITICO');
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
          LayoutBuilder(
            builder: (context, headerConstraints) {
              final isNarrow = headerConstraints.maxWidth < 600;
              return isNarrow
                ? Column(
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
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SkyTheme.timBlue,
                          side: const BorderSide(color: SkyTheme.timBlue, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _showAdvancedConsole = !_showAdvancedConsole;
                          });
                        },
                        icon: Icon(
                          _showAdvancedConsole ? Icons.terminal : Icons.terminal_outlined,
                          size: 16,
                        ),
                        label: Text(_showAdvancedConsole ? 'Nascondi Console' : 'Mostra Console'),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
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
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: SkyTheme.timBlue,
                          side: const BorderSide(color: SkyTheme.timBlue, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _showAdvancedConsole = !_showAdvancedConsole;
                          });
                        },
                        icon: Icon(
                          _showAdvancedConsole ? Icons.terminal : Icons.terminal_outlined,
                          size: 18,
                        ),
                        label: Text(
                          _showAdvancedConsole ? 'Nascondi Console' : 'Mostra Console',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
            },
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
                final showConsole = _showAdvancedConsole;
                final isWide = constraints.maxWidth > 850;

                if (showConsole && isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildMainDashboardCard(context),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: _buildConsoleCard(context, rightPanelContent),
                      ),
                    ],
                  );
                } else if (showConsole && !isWide) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMainDashboardCard(context),
                        const SizedBox(height: 24),
                        _buildConsoleCard(context, rightPanelContent, height: 350),
                      ],
                    ),
                  );
                } else {
                  if (isWide) {
                    return Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: _buildMainDashboardCard(context),
                      ),
                    );
                  } else {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildMainDashboardCard(context),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
