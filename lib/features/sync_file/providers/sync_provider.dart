import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:cross_file/cross_file.dart';
import '../../../core/db/isar_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/app_settings_provider.dart';
import '../../settings/models/app_settings.dart';
import '../../upload/providers/tracciato_contabile_provider.dart';
import '../../upload/providers/estratto_conto_provider.dart';
import '../../upload/providers/tracciato_sap_provider.dart';
import '../../upload/providers/estratto_amex_provider.dart';
import '../../upload/providers/anagrafica_provider.dart';
import '../../upload/providers/scarti_ec_sap_provider.dart';
import '../../upload/providers/log_history_provider.dart';
import '../../upload/models/tracciato_contabile.dart';
import '../../upload/models/log_history.dart';
import '../services/sharepoint_service.dart';
import '../models/sync_state.dart';

class SyncNotifier extends StateNotifier<SyncState> {
  final Ref _ref;
  final SharePointService _sharePointService = SharePointService();

  SyncNotifier(this._ref) : super(SyncState.initial());

  void setSelectedSyncType(String type) {
    if (!state.isSyncing) {
      state = state.copyWith(selectedSyncType: type);
    }
  }

  void setClearBeforeSync(bool val) {
    if (!state.isSyncing) {
      state = state.copyWith(clearBeforeSync: val);
    }
  }

  void toggleAdvancedConsole() {
    state = state.copyWith(showAdvancedConsole: !state.showAdvancedConsole);
  }

  void _log(String message) {
    final updatedLogs = List<String>.from(state.syncLogs);
    updatedLogs.insert(0, '[${DateTime.now().toIso8601String().substring(11, 19)}] $message');
    state = state.copyWith(syncLogs: updatedLogs);
  }

  Future<int> _syncFileItem(
    String syncType,
    SharePointFile file,
    String token,
    AppSettings settings,
    Isar isar,
  ) async {
    String syncName = '';

    if (syncType == 'contabile') {
      syncName = 'Tracciati Contabili';
    } else if (syncType == 'conto') {
      syncName = 'Estratti Conto';
    } else if (syncType == 'sap') {
      syncName = 'Tracciato SAP';
    } else if (syncType == 'amex') {
      syncName = 'Estratti AMEX';
    } else if (syncType == 'anagrafica') {
      syncName = 'Anagrafica';
    } else if (syncType == 'scarti') {
      syncName = 'Scarti Tracciato';
    }

    _log('[$syncName] Inizio elaborazione file: ${file.name}...');
    state = state.copyWith(
      currentFile: file.name,
      currentFileStatus: 'Scaricamento...',
      currentFileRecords: 0,
    );

    int importedRecords = 0;

    if (syncType == 'contabile') {
      final fileContent = await _sharePointService.downloadFile(
        accessToken: token,
        itemId: file.id,
        sitePath: file.sitePath,
      );

      state = state.copyWith(
        currentFileStatus: 'Analisi e Inserimento...',
      );

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
        state = state.copyWith(
          currentFileRecords: importedRecords,
        );
        _log('[$syncName] File ${file.name} salvato nel DB: $importedRecords record importati.');
      }
    } else {
      // File Excel (binari)
      final bytes = await _sharePointService.downloadFileBytes(
        accessToken: token,
        itemId: file.id,
        sitePath: file.sitePath,
      );

      state = state.copyWith(
        currentFileStatus: 'Analisi ed Elaborazione Excel...',
      );

      _log('[$syncName] Download completato. Esecuzione del parsing...');
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/${file.name}');
      await tempFile.writeAsBytes(bytes);
      final xFile = XFile(tempFile.path);

      Map<String, dynamic> result = {};
      try {
        if (syncType == 'conto') {
          result = await _ref.read(estrattoContoProvider.notifier).loadFromFile(xFile);
        } else if (syncType == 'sap') {
          result = await _ref.read(tracciatoSapProvider.notifier).loadFromFile(xFile);
        } else if (syncType == 'amex') {
          result = await _ref.read(estrattoAmexProvider.notifier).loadFromFile(xFile);
        } else if (syncType == 'anagrafica') {
          _log('[$syncName] Modalità anagrafica: svuotamento dei record precedenti dal database...');
          await _ref.read(anagraficaProvider.notifier).clear();
          await isar.writeTxn(() async {
            await isar.logHistorys.filter().sourceTypeEqualTo('Anagrafica').deleteAll();
          });
          result = await _ref.read(anagraficaProvider.notifier).loadFromFile(xFile);
        } else if (syncType == 'scarti') {
          result = await _ref.read(scartiEcSapProvider.notifier).loadFromFile(xFile);
        }

        importedRecords = result['inserted'] as int? ?? 0;
        state = state.copyWith(
          currentFileRecords: importedRecords,
        );
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

  Future<void> startSynchronization() async {
    // 1. Verifica autenticazione
    final authState = _ref.read(authProvider);
    if (!authState.isAuthenticated) {
      throw Exception('Autenticazione richiesta. Effettua prima il login Microsoft Entra ID.');
    }

    state = state.copyWith(
      isSyncing: true,
      syncProgress: 0.0,
      syncStep: 'Connessione sicura a SharePoint in corso...',
      syncLogs: [],
      syncQueue: [],
      totalFilesFound: 0,
      processedFilesCount: 0,
      totalRecordsImported: 0,
      currentFile: '',
      currentFileStatus: '',
      currentFileRecords: 0,
    );

    try {
      _log('Richiesta token di sicurezza valido da Entra ID...');
      final token = await _ref.read(authProvider.notifier).getValidAccessToken();
      
      if (token == null) {
        throw Exception('Impossibile ottenere un token di sicurezza valido. Effettua nuovamente il login.');
      }

      final settings = _ref.read(appSettingsProvider);
      final isar = _ref.read(isarProvider);

      List<String> typesToSync = [];
      if (state.selectedSyncType == 'all') {
        typesToSync = ['contabile', 'conto', 'sap', 'amex', 'scarti', 'anagrafica'];
      } else {
        typesToSync = [state.selectedSyncType];
      }

      // Svuota i database per i tipi selezionati se richiesto
      if (state.clearBeforeSync) {
        for (final type in typesToSync) {
          _log('Svuotamento della categoria $type in corso...');
          state = state.copyWith(
            syncStep: 'Pulizia database per ${type.toUpperCase()}...',
          );
          
          String sourceType = '';
          if (type == 'contabile') {
            await _ref.read(tracciatoContabilesProvider.notifier).clear();
            sourceType = 'Tracciato Contabile';
          } else if (type == 'conto') {
            await _ref.read(estrattoContoProvider.notifier).clear();
            sourceType = 'Estratto Conto';
          } else if (type == 'sap') {
            await _ref.read(tracciatoSapProvider.notifier).clear();
            sourceType = 'Tracciato SAP';
          } else if (type == 'amex') {
            await _ref.read(estrattoAmexProvider.notifier).clear();
            sourceType = 'Estratto AMEX';
          } else if (type == 'anagrafica') {
            await _ref.read(anagraficaProvider.notifier).clear();
            sourceType = 'Anagrafica';
          } else if (type == 'scarti') {
            await _ref.read(scartiEcSapProvider.notifier).clear();
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
        
        _ref.invalidate(tracciatoContabilesProvider);
        _ref.invalidate(estrattoContoProvider);
        _ref.invalidate(tracciatoSapProvider);
        _ref.invalidate(estrattoAmexProvider);
        _ref.invalidate(anagraficaProvider);
        _ref.invalidate(scartiEcSapProvider);
        _ref.invalidate(logHistoryProvider);
        
        _log('Database locale e cronologia per i tipi selezionati puliti con successo.');
      }

      state = state.copyWith(
        syncStep: 'Ricerca dei file su SharePoint...',
      );

      final List<Map<String, dynamic>> tempQueue = [];

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
          allowedExtensions = ['.xlsx'];
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
          
          if (fileLogs.isNotEmpty && !state.clearBeforeSync) {
            fileLogs.sort((a, b) => b.date.compareTo(a.date));
            final lastLog = fileLogs.first;
            
            // Il file è considerato già importato solo se non è stato modificato su SharePoint
            // dopo la sua ultima importazione locale (+5 secondi di tolleranza)
            if (!file.lastModified.isAfter(lastLog.date.add(const Duration(seconds: 5)))) {
              isAlreadyImported = true;
              importedRecordsCount = lastLog.insertedRecords;
            }
          }
          
          tempQueue.add({
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

      state = state.copyWith(syncQueue: tempQueue);

      // Filtriamo solo i file da importare per i totali
      final activeQueue = state.syncQueue.where((item) => item['status'] == 'pending').toList();
      state = state.copyWith(
        totalFilesFound: activeQueue.length,
      );

      _log('Totale file da elaborare: ${state.totalFilesFound}.');

      if (state.totalFilesFound == 0) {
        state = state.copyWith(
          syncProgress: 1.0,
          syncStep: 'Sincronizzazione completata: nessun nuovo file trovato.',
          isSyncing: false,
        );
        return;
      }

      // 2. Loop di importazione dei file attivi
      for (int i = 0; i < state.syncQueue.length; i++) {
        final item = state.syncQueue[i];
        if (item['status'] == 'completed') continue;

        final file = item['file'] as SharePointFile;
        final syncType = item['syncType'] as String;

        final updatedQueue1 = List<Map<String, dynamic>>.from(state.syncQueue);
        updatedQueue1[i] = Map<String, dynamic>.from(updatedQueue1[i])..['status'] = 'syncing';
        state = state.copyWith(
          syncQueue: updatedQueue1,
          syncStep: 'Elaborazione file ${state.processedFilesCount + 1} di ${state.totalFilesFound}...',
          syncProgress: state.processedFilesCount / state.totalFilesFound,
        );

        try {
          final imported = await _syncFileItem(syncType, file, token, settings, isar);
          
          final updatedQueue2 = List<Map<String, dynamic>>.from(state.syncQueue);
          updatedQueue2[i] = Map<String, dynamic>.from(updatedQueue2[i])
            ..['status'] = 'completed'
            ..['records'] = imported;

          state = state.copyWith(
            syncQueue: updatedQueue2,
            totalRecordsImported: state.totalRecordsImported + imported,
            processedFilesCount: state.processedFilesCount + 1,
            syncProgress: (state.processedFilesCount + 1) / state.totalFilesFound,
          );
        } catch (e) {
          final updatedQueue3 = List<Map<String, dynamic>>.from(state.syncQueue);
          updatedQueue3[i] = Map<String, dynamic>.from(updatedQueue3[i])
            ..['status'] = 'error'
            ..['errorMessage'] = e.toString();

          _log('Errore durante l\'importazione di ${file.name}: $e');
          state = state.copyWith(
            syncQueue: updatedQueue3,
            processedFilesCount: state.processedFilesCount + 1,
            syncProgress: (state.processedFilesCount + 1) / state.totalFilesFound,
          );
        }
      }

      _ref.invalidate(tracciatoContabilesProvider);
      _ref.invalidate(estrattoContoProvider);
      _ref.invalidate(tracciatoSapProvider);
      _ref.invalidate(estrattoAmexProvider);
      _ref.invalidate(anagraficaProvider);
      _ref.invalidate(scartiEcSapProvider);
      _ref.invalidate(logHistoryProvider);

      state = state.copyWith(
        syncProgress: 1.0,
        syncStep: 'Sincronizzazione completata!',
        isSyncing: false,
      );
      _log('Sincronizzazione conclusa con successo. Importati ${state.totalRecordsImported} record in totale.');
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncStep: 'Errore durante la sincronizzazione: $e',
      );
      _log('ERRORE CRITICO: $e');
      rethrow;
    }
  }
}

// Global provider for file synchronization
final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});
