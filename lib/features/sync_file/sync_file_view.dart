import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../core/theme/app_theme.dart';
import '../../core/db/isar_provider.dart';
import '../upload/providers/tracciato_contabile_provider.dart';
import '../upload/providers/log_history_provider.dart';
import '../upload/models/tracciato_contabile.dart';
import '../upload/models/log_history.dart';
import '../auth/providers/auth_provider.dart';
import '../settings/providers/app_settings_provider.dart';
import 'services/sharepoint_service.dart';

class SyncFileView extends ConsumerStatefulWidget {
  const SyncFileView({super.key});

  @override
  ConsumerState<SyncFileView> createState() => _SyncFileViewState();
}

class _SyncFileViewState extends ConsumerState<SyncFileView> with SingleTickerProviderStateMixin {
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
      final spFolder = settings.sharepointFolderPath.isEmpty ? 'TracciatiContabili' : settings.sharepointFolderPath;

      await Future.delayed(const Duration(milliseconds: 700));
      _log('Token recuperato con successo.');
      _log('Richiesta listing dei file nella cartella SharePoint "/$spFolder"...');

      setState(() {
        _syncProgress = 0.25;
        _syncStep = 'Recupero della lista dei file da SharePoint...';
      });

      // 2. Listing dei file reale da SharePoint
      List<SharePointFile> sharepointFiles = [];
      sharepointFiles = await _sharePointService.listFiles(
        accessToken: token,
        siteName: settings.sharepointSiteName,
        documentLibrary: settings.sharepointDocumentLibrary,
        folderPath: settings.sharepointFolderPath,
      );
      _log('Trovati ${sharepointFiles.length} file contabili su SharePoint.');

      final isar = ref.read(isarProvider);
      
      // 3. Controllo opzione PULISCI TUTTO
      if (_clearBeforeSync) {
        _log('Opzione "Pulisci tutti" attiva. Svuotamento dei tracciati e della cronologia in corso...');
        setState(() {
          _syncProgress = 0.45;
          _syncStep = 'Pulizia database locale in corso...';
        });
        await ref.read(tracciatoContabilesProvider.notifier).clear();
        
        // Svuota anche la cronologia dei tracciati contabili
        await isar.writeTxn(() async {
          await isar.logHistorys.filter().sourceTypeEqualTo('contabile').deleteAll();
        });
        ref.invalidate(logHistoryProvider);
        _log('Database locale pulito con successo.');
      }

      // 4. Identificazione dei file da importare (Delta logic)
      final existingLogs = await isar.logHistorys.where().anyId().findAll();
      final existingFileNames = existingLogs.map((log) => log.fileName).toSet();

      final List<SharePointFile> filesToImport = [];
      for (final file in sharepointFiles) {
        if (_clearBeforeSync || !existingFileNames.contains(file.name)) {
          filesToImport.add(file);
          _log('File identificato per l\'importazione: ${file.name}');
        } else {
          _log('File già importato (saltato): ${file.name}');
        }
      }

      if (filesToImport.isEmpty) {
        setState(() {
          _syncProgress = 1.0;
          _syncStep = 'Sincronizzazione completata. Tutti i file sono già aggiornati!';
          _isSyncing = false;
        });
        _pulseController.stop();
        _log('Nessun nuovo file da importare. Il sistema è aggiornato.');
        return;
      }

      setState(() {
        _syncProgress = 0.6;
        _syncStep = 'Download e parsing dei tracciati contabili...';
      });

      int totalImportedRecords = 0;

      // 5. Download e parsing in loop dei file delta
      for (int i = 0; i < filesToImport.length; i++) {
        final file = filesToImport[i];
        final progressStep = 0.6 + ((i / filesToImport.length) * 0.3);
        
        setState(() {
          _syncProgress = progressStep;
          _syncStep = 'Importazione di ${file.name} (${i + 1}/${filesToImport.length})...';
        });

        _log('Scaricamento in corso: ${file.name}...');
        final fileContent = await _sharePointService.downloadFile(
          accessToken: token,
          itemId: file.id,
          sitePath: file.sitePath,
        );

        _log('Download completato. Esecuzione del parsing del tracciato...');
        final lines = fileContent.split('\n');
        
        if (lines.length < 3) {
          _log('Avviso: Il file ${file.name} è vuoto o non conforme.');
          continue;
        }

        final uniqueCode = '${DateTime.now().millisecondsSinceEpoch}_$i';
        final List<TracciatoContabile> parsedRecords = [];

        // Parsing riga per riga escludendo prima e ultima riga (Header & Footer)
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
              _log('Errore parsing riga ${lineIndex + 1} nel file ${file.name}: $err');
            }
          }
        }

        // Salvataggio nel DB locale Isar
        if (parsedRecords.isNotEmpty) {
          await isar.writeTxn(() async {
            await isar.tracciatoContabiles.putAll(parsedRecords);
            
            // Crea record storico per mantenere la logica delta
            final logHistoryEntry = LogHistory(
              fileName: file.name,
              date: DateTime.now(),
              uniqueCode: uniqueCode,
              totalRecords: parsedRecords.length + 2, // Include Header & Footer
              insertedRecords: parsedRecords.length,
              sourceType: 'contabile',
            );
            await isar.logHistorys.put(logHistoryEntry);
          });

          totalImportedRecords += parsedRecords.length;
          _log('File ${file.name} salvato nel DB: ${parsedRecords.length} record importati.');
        }
      }

      // 6. Completamento e invalidazione dei provider Riverpod
      ref.invalidate(tracciatoContabilesProvider);
      ref.invalidate(logHistoryProvider);

      setState(() {
        _syncProgress = 1.0;
        _syncStep = 'Sincronizzazione completata con successo!';
        _isSyncing = false;
      });
      _pulseController.stop();
      _log('Sincronizzazione conclusa. Importati $totalImportedRecords record contabili totali.');

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
            'Gestione e sincronizzazione automatica delta dei file contabili aziendali da SharePoint.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
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
                      child: Column(
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
                                  _isSyncing ? Icons.sync : Icons.cloud_download,
                                  size: 40,
                                  color: SkyTheme.timBlue,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Sincronizzazione SharePoint',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: SkyTheme.timBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Verifica la presenza di nuovi file di tracciato contabile in SharePoint ed esegui l\'importazione dei soli record mancanti.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 24),

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
                              subtitle: const Text(
                                'Svuota tutti i tracciati contabili locali registrati nel DB prima di scaricare l\'intero archivio SharePoint.',
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
                          ),
                          const SizedBox(height: 24),

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
                                const SizedBox(height: 24),
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
                                _isSyncing ? 'Sincronizzazione in Corso...' : 'Sincronizza Tracciati Contabili',
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
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Terminale di Log Destro per monitoraggio in tempo reale
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
                    child: Column(
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
