import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../auth/providers/auth_provider.dart';
import '../settings/providers/app_settings_provider.dart';
import 'services/sharepoint_service.dart';
import 'providers/sync_provider.dart';
import 'models/sync_state.dart';

class SyncFileView extends ConsumerStatefulWidget {
  const SyncFileView({super.key});

  @override
  ConsumerState<SyncFileView> createState() => _SyncFileViewState();
}

class _SyncFileViewState extends ConsumerState<SyncFileView> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(syncProvider).isSyncing) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startSynchronization() async {
    try {
      await ref.read(syncProvider.notifier).startSynchronization();
      if (mounted) {
        final syncState = ref.read(syncProvider);
        if (syncState.totalFilesFound == 0) {
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Sincronizzazione riuscita! Importati ${syncState.totalRecordsImported} record.'),
                ],
              ),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
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

  Widget _buildSmartProgressDashboard(SyncState syncState) {
    final hasFailed = syncState.syncStep.contains('Errore') || syncState.syncStep.contains('fallita');
    final isCompleted = syncState.syncProgress == 1.0 && !syncState.isSyncing;

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
                '${(syncState.syncProgress * 100).toInt()}%',
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
            value: syncState.syncProgress,
            backgroundColor: Colors.grey.shade200,
            color: isCompleted ? Colors.green.shade600 : (hasFailed ? SkyTheme.timRed : SkyTheme.timBlue),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 12),
          Text(
            syncState.syncStep,
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
                  '${syncState.totalRecordsImported}',
                  Icons.save_outlined,
                  Colors.green.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'File Elaborati',
                  '${syncState.processedFilesCount} / ${syncState.totalFilesFound}',
                  Icons.folder_shared_outlined,
                  SkyTheme.timBlue,
                ),
              ),
            ],
          ),

          if (syncState.isSyncing && syncState.currentFile.isNotEmpty) ...[
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
                          syncState.currentFile,
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
                          'Stato: ${syncState.currentFileStatus} | Inseriti: ${syncState.currentFileRecords} record',
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

          if (syncState.syncQueue.isNotEmpty) ...[
            const SizedBox(height: 20),
            Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                iconColor: SkyTheme.timBlue,
                title: Text(
                  'Elenco dettagliato file (${syncState.syncQueue.length})',
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
                      itemCount: syncState.syncQueue.length,
                      itemBuilder: (context, idx) {
                        final item = syncState.syncQueue[idx];
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

  Widget _buildClearDbOption(SyncState syncState) {
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
        value: syncState.clearBeforeSync,
        onChanged: syncState.isSyncing
            ? null
            : (val) {
                ref.read(syncProvider.notifier).setClearBeforeSync(val);
              },
      ),
    );
  }

  Widget _buildSyncButton(SyncState syncState) {
    String buttonLabel = '';

    if (syncState.selectedSyncType == 'all') {
      buttonLabel = 'Sincronizza Tutto';
    } else if (syncState.selectedSyncType == 'contabile') {
      buttonLabel = 'Sincronizza Tracciati Contabili';
    } else if (syncState.selectedSyncType == 'conto') {
      buttonLabel = 'Sincronizza Estratti Conto';
    } else if (syncState.selectedSyncType == 'sap') {
      buttonLabel = 'Sincronizza SAP';
    } else if (syncState.selectedSyncType == 'amex') {
      buttonLabel = 'Sincronizza AMEX';
    } else if (syncState.selectedSyncType == 'anagrafica') {
      buttonLabel = 'Sincronizza Anagrafica';
    } else if (syncState.selectedSyncType == 'scarti') {
      buttonLabel = 'Sincronizza Scarti';
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: syncState.isSyncing ? null : _startSynchronization,
        icon: syncState.isSyncing
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
          syncState.isSyncing ? 'Sincronizzazione in Corso...' : buttonLabel,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: SkyTheme.timBlue,
          foregroundColor: Colors.white,
          elevation: syncState.isSyncing ? 0 : 2,
          shadowColor: SkyTheme.timBlue.withAlpha(80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(SyncState syncState) {
    final settings = ref.read(appSettingsProvider);
    String titleText = '';
    String descText = '';
    String folderInfo = '';

    if (syncState.selectedSyncType == 'all') {
      titleText = 'Sincronizzazione Completa';
      descText = 'Sincronizza in sequenza tutte le categorie configurate (Contabili, Estratti Conto, SAP, AMEX, Scarti, Anagrafica) da SharePoint.';
      folderInfo = 'Tutte le cartelle configurate';
    } else if (syncState.selectedSyncType == 'contabile') {
      titleText = 'Tracciati Contabili';
      descText = 'Sincronizza i file di tracciato contabile (*.txt) da SharePoint.';
      folderInfo = settings.sharepointFolderPath.isEmpty ? 'tracciati_uvet' : settings.sharepointFolderPath;
    } else if (syncState.selectedSyncType == 'conto') {
      titleText = 'Estratti Conto';
      descText = 'Sincronizza i file di estratto conto bancario (*.xlsx, *.xls) da SharePoint.';
      folderInfo = settings.sharepointEstrattiContoPath.isEmpty ? 'estratti_conto' : settings.sharepointEstrattiContoPath;
    } else if (syncState.selectedSyncType == 'sap') {
      titleText = 'Tracciato SAP';
      descText = 'Sincronizza i file del tracciato SAP (*.xlsx) da SharePoint.';
      folderInfo = settings.sharepointTracciatoSapPath.isEmpty ? 'tracciato_sap' : settings.sharepointTracciatoSapPath;
    } else if (syncState.selectedSyncType == 'amex') {
      titleText = 'Estratti AMEX';
      descText = 'Sincronizza i file degli estratti AMEX (*.xlsx) da SharePoint.';
      folderInfo = settings.sharepointEstrattiAmexPath.isEmpty ? 'estratti_amex' : settings.sharepointEstrattiAmexPath;
    } else if (syncState.selectedSyncType == 'anagrafica') {
      titleText = 'Anagrafica';
      descText = 'Sincronizza i file dell\'anagrafica dipendenti (*.xlsx) da SharePoint.';
      folderInfo = settings.sharepointAnagraficaPath.isEmpty ? 'anagrafica' : settings.sharepointAnagraficaPath;
    } else if (syncState.selectedSyncType == 'scarti') {
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
                    syncState.isSyncing ? Icons.sync : (syncState.selectedSyncType == 'all' ? Icons.all_inclusive : Icons.cloud_download),
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

  Widget _buildMainDashboardCard(BuildContext context, SyncState syncState) {
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
            _buildDashboardHeader(syncState),
            const SizedBox(height: 24),
            
            if (syncState.isSyncing || syncState.totalFilesFound > 0) ...[
              _buildSmartProgressDashboard(syncState),
              const SizedBox(height: 24),
            ],

            if (!syncState.isSyncing && syncState.selectedSyncType != 'anagrafica') ...[
              _buildClearDbOption(syncState),
              const SizedBox(height: 24),
            ],

            _buildSyncButton(syncState),
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

    final syncState = ref.watch(syncProvider);

    // Listen to isSyncing change to trigger/stop pulse controller
    ref.listen<bool>(
      syncProvider.select((s) => s.isSyncing),
      (previous, next) {
        if (next) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
        }
      },
    );

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
                    color: syncState.isSyncing ? Colors.green : Colors.grey,
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
            if (syncState.syncLogs.isNotEmpty)
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.copy, color: Colors.grey, size: 16),
                tooltip: 'Copia tutti i log',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: syncState.syncLogs.join('\n')));
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
          child: syncState.syncLogs.isEmpty
            ? const Center(
                child: Text(
                  'In attesa di avviare il processo...',
                  style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                ),
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: syncState.syncLogs.length,
                itemBuilder: (context, index) {
                  final log = syncState.syncLogs[index];
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
                          ref.read(syncProvider.notifier).toggleAdvancedConsole();
                        },
                        icon: Icon(
                          syncState.showAdvancedConsole ? Icons.terminal : Icons.terminal_outlined,
                          size: 16,
                        ),
                        label: Text(syncState.showAdvancedConsole ? 'Nascondi Console' : 'Mostra Console'),
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
                          ref.read(syncProvider.notifier).toggleAdvancedConsole();
                        },
                        icon: Icon(
                          syncState.showAdvancedConsole ? Icons.terminal : Icons.terminal_outlined,
                          size: 18,
                        ),
                        label: Text(
                          syncState.showAdvancedConsole ? 'Nascondi Console' : 'Mostra Console',
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
                selected: {syncState.selectedSyncType},
                onSelectionChanged: syncState.isSyncing
                    ? null
                    : (val) {
                        ref.read(syncProvider.notifier).setSelectedSyncType(val.first);
                      },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showConsole = syncState.showAdvancedConsole;
                final isWide = constraints.maxWidth > 850;

                if (showConsole && isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildMainDashboardCard(context, syncState),
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
                        _buildMainDashboardCard(context, syncState),
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
                        child: _buildMainDashboardCard(context, syncState),
                      ),
                    );
                  } else {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: _buildMainDashboardCard(context, syncState),
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
