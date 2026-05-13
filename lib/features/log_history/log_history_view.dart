import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';

class LogHistoryView extends ConsumerStatefulWidget {
  const LogHistoryView({super.key});

  @override
  ConsumerState<LogHistoryView> createState() => _LogHistoryViewState();
}

class _LogHistoryViewState extends ConsumerState<LogHistoryView> {
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

  Widget _buildCell(
    String text,
    double width, {
    bool isHeader = false,
    Alignment alignment = Alignment.centerLeft,
    Color? color,
    FontWeight? fontWeight,
    Widget? child,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: alignment,
      child:
          child ??
          Text(
            text,
            style: TextStyle(
              fontSize: isHeader ? 13 : 14,
              fontWeight:
                  fontWeight ??
                  (isHeader ? FontWeight.bold : FontWeight.normal),
              color: color ?? (isHeader ? SkyTheme.timBlue : Colors.black87),
              letterSpacing: isHeader ? 0.5 : 0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logHistoryList = ref.watch(logHistoryProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox.shrink(),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: SkyTheme.timBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${logHistoryList.length} Importazioni',
                  style: const TextStyle(
                    color: SkyTheme.timBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: logHistoryList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history_outlined,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(50),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'NESSUN LOG PRESENTE',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 1.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 1120,
                          child: Column(
                            children: [
                              // Header della tabella
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: SkyTheme.timBlue.withValues(
                                    alpha: 0.05,
                                  ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildCell(
                                      'NOME FILE',
                                      220,
                                      isHeader: true,
                                    ),
                                    _buildCell(
                                      'TIPO DATI',
                                      160,
                                      isHeader: true,
                                    ),
                                    _buildCell(
                                      'DATA IMPORTAZIONE',
                                      160,
                                      isHeader: true,
                                    ),
                                    _buildCell(
                                      'TOTALE',
                                      80,
                                      isHeader: true,
                                      alignment: Alignment.center,
                                    ),
                                    _buildCell(
                                      'INSERITI',
                                      80,
                                      isHeader: true,
                                      alignment: Alignment.center,
                                    ),
                                    _buildCell(
                                      'AGGIORNATI',
                                      90,
                                      isHeader: true,
                                      alignment: Alignment.center,
                                    ),
                                    _buildCell(
                                      'SCARTATI',
                                      80,
                                      isHeader: true,
                                      alignment: Alignment.center,
                                    ),
                                    _buildCell(
                                      'CODICE UNIVOCO',
                                      160,
                                      isHeader: true,
                                    ),
                                    _buildCell(
                                      'AZIONI',
                                      90,
                                      isHeader: true,
                                      alignment: Alignment.center,
                                    ),
                                  ],
                                ),
                              ),
                              // Corpo della tabella
                              Expanded(
                                child: ListView.builder(
                                  itemCount: logHistoryList.length,
                                  itemBuilder: (_, index) {
                                    final log = logHistoryList[index];
                                    return Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey.shade100,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildCell(
                                            log.fileName,
                                            220,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          _buildCell(
                                            log.sourceType ?? 'N.D.',
                                            160,
                                            color: SkyTheme.timBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          _buildCell(
                                            DateFormat(
                                              'dd/MM/yyyy HH:mm',
                                            ).format(log.date),
                                            160,
                                          ),
                                          _buildCell(
                                            log.totalRecords.toString(),
                                            80,
                                            alignment: Alignment.center,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          _buildCell(
                                            log.insertedRecords.toString(),
                                            80,
                                            alignment: Alignment.center,
                                            color: Colors.green.shade700,
                                          ),
                                          _buildCell(
                                            log.updatedRecords.toString(),
                                            90,
                                            alignment: Alignment.center,
                                            color: Colors.blue.shade700,
                                          ),
                                          _buildCell(
                                            log.discardedRecords.toString(),
                                            80,
                                            alignment: Alignment.center,
                                            color: log.discardedRecords > 0
                                                ? Colors.orange.shade700
                                                : Colors.grey,
                                          ),
                                          _buildCell(
                                            log.uniqueCode,
                                            160,
                                            color: Colors.grey.shade500,
                                          ),
                                          _buildCell(
                                            '',
                                            60,
                                            alignment: Alignment.center,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                final messenger =
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    );
                                                final confirmed =
                                                    await _showConfirmationDialog(
                                                      title:
                                                          'Elimina Importazione',
                                                      content:
                                                          "Sei sicuro di voler eliminare l'importazione del file '${log.fileName}' e tutti i suoi record associati?",
                                                      isDestructive: true,
                                                    );
                                                if (confirmed == true) {
                                                  await ref
                                                      .read(
                                                        logHistoryProvider
                                                            .notifier,
                                                      )
                                                      .deleteLogHistoryAndRecords(
                                                        log.uniqueCode,
                                                      );
                                                  if (mounted) {
                                                    messenger.showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Importazione eliminata con successo',
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              tooltip: 'Elimina importazione',
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
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
