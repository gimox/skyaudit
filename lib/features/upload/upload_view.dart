import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import 'package:isar/isar.dart';
import 'package:travel_check/features/upload/models/log_history.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/upload/providers/estratto_amex_provider.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/features/upload/providers/scarti_ec_sap_provider.dart';
class UploadView extends ConsumerStatefulWidget {
  const UploadView({super.key});

  @override
  ConsumerState<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends ConsumerState<UploadView> {
  XFile? _selectedContabileFile;
  XFile? _selectedEstrattoFile;
  XFile? _selectedSapFile;
  XFile? _selectedAmexFile;
  XFile? _selectedAnagraficaFile;
  XFile? _selectedScartiSapFile;

  bool _isDraggingContabile = false;
  bool _isDraggingEstratto = false;
  bool _isDraggingSap = false;
  bool _isDraggingAmex = false;
  bool _isDraggingAnagrafica = false;
  bool _isDraggingScartiSap = false;

  bool _isProcessingContabile = false;
  bool _isProcessingEstratto = false;
  bool _isProcessingSap = false;
  bool _isProcessingAmex = false;
  bool _isProcessingAnagrafica = false;
  bool _isProcessingScartiSap = false;

  Map<String, dynamic>? _lastContabileResult;
  Map<String, dynamic>? _lastEstrattoResult;
  Map<String, dynamic>? _lastSapResult;
  Map<String, dynamic>? _lastAmexResult;
  Map<String, dynamic>? _lastAnagraficaResult;
  Map<String, dynamic>? _lastScartiSapResult;
  final Set<int> _deletedRecordIds = {};
  int _collisionPage = 0;
  int _collisionPageEstratto = 0;
  static const int _itemsPerPage = 50;

  Future<void> _pickFile(String type) async {
    List<String> extensions;
    if (type == 'contabile') {
      extensions = ['txt'];
    } else if (type == 'sap') {
      extensions = ['xlsx'];
    } else if (type == 'amex') {
      extensions = ['xlsx', 'csv'];
    } else if (type == 'anagrafica') {
      extensions = ['xlsx'];
    } else {
      extensions = ['xlsx'];
    }

    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (type == 'contabile') {
          _selectedContabileFile = XFile(result.files.single.path!);
          _lastContabileResult = null;
        } else if (type == 'estratto') {
          _selectedEstrattoFile = XFile(result.files.single.path!);
          _lastEstrattoResult = null;
        } else if (type == 'sap') {
          _selectedSapFile = XFile(result.files.single.path!);
          _lastSapResult = null;
        } else if (type == 'amex') {
          _selectedAmexFile = XFile(result.files.single.path!);
          _lastAmexResult = null;
        } else if (type == 'anagrafica') {
          _selectedAnagraficaFile = XFile(result.files.single.path!);
          _lastAnagraficaResult = null;
        } else if (type == 'scartiSap') {
          _selectedScartiSapFile = XFile(result.files.single.path!);
          _lastScartiSapResult = null;
        }
      });
    }
  }

  void _removeFile(String type) {
    setState(() {
      if (type == 'contabile') {
        _selectedContabileFile = null;
        _lastContabileResult = null;
      } else if (type == 'estratto') {
        _selectedEstrattoFile = null;
        _lastEstrattoResult = null;
      } else if (type == 'sap') {
        _selectedSapFile = null;
        _lastSapResult = null;
      } else if (type == 'amex') {
        _selectedAmexFile = null;
        _lastAmexResult = null;
      } else if (type == 'anagrafica') {
        _selectedAnagraficaFile = null;
        _lastAnagraficaResult = null;
      } else if (type == 'scartiSap') {
        _selectedScartiSapFile = null;
        _lastScartiSapResult = null;
      }
    });
  }

  Future<bool> _checkDuplicateFile(XFile file) async {
    final isar = ref.read(isarProvider);
    final existingLog = await isar.logHistorys
        .filter()
        .fileNameEqualTo(file.name)
        .sortByDateDesc()
        .findFirst();

    if (existingLog != null) {
      if (!mounted) return false;
      
      final bool? proceed = await showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: '',
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) => Container(),
        transitionBuilder: (context, anim1, anim2, child) {
          return Transform.scale(
            scale: anim1.value,
            child: Opacity(
              opacity: anim1.value,
              child: Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 450),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.warning_rounded, color: Colors.orange.shade800, size: 40),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Attenzione: File già caricato',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Un file con il nome "${file.name}" è già stato importato.',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            _buildLogDetailRow(Icons.calendar_today_outlined, 'Caricato il:', DateFormat('dd/MM/yyyy HH:mm').format(existingLog.date)),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Divider(height: 1),
                            ),
                            _buildLogDetailRow(Icons.description_outlined, 'Record totali:', existingLog.totalRecords.toString()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                'ANNULLA',
                                style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: SkyTheme.timBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'PROCEDI',
                                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
      return proceed ?? false;
    }
    return true;
  }

  Widget _buildLogDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: SkyTheme.timBlue.withAlpha(150)),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
      ],
    );
  }

  Future<void> _processContabileData() async {
    if (_selectedContabileFile == null) return;

    if (!await _checkDuplicateFile(_selectedContabileFile!)) {
      return;
    }

    setState(() {
      _isProcessingContabile = true;
      _lastContabileResult = null;
      _collisionPage = 0;
      _deletedRecordIds.clear();
    });

    try {
      final result = await ref
          .read(tracciatoContabilesProvider.notifier)
          .loadFromFile(_selectedContabileFile!);

      if (mounted) {
        setState(() {
          _lastContabileResult = result;
        });

        final inserted = result['inserted'] ?? 0;
        final updated = result['updated'] ?? 0;
        final duplicates = result['duplicates'] ?? 0;
        final total = inserted + updated + duplicates;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Elaborazione completata: $total record totali.\n'
              '• $inserted nuovi record inseriti\n'
              '• $updated record esistenti aggiornati'
              '${duplicates > 0 ? "\n• $duplicates duplicati saltati nel file" : ""}',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        _selectedContabileFile = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'elaborazione del file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingContabile = false);
    }
  }

  Future<void> _processEstrattoData() async {
    if (_selectedEstrattoFile == null) return;

    if (!await _checkDuplicateFile(_selectedEstrattoFile!)) {
      return;
    }

    setState(() {
      _isProcessingEstratto = true;
      _lastEstrattoResult = null;
      _collisionPageEstratto = 0;
      _deletedRecordIds.clear();
    });

    try {
      final result = await ref
          .read(estrattoContoProvider.notifier)
          .loadFromFile(_selectedEstrattoFile!);

      if (mounted) {
        setState(() {
          _lastEstrattoResult = result;
        });

        final inserted = result['inserted'] ?? 0;
        final updated = result['updated'] ?? 0;
        final duplicates = result['duplicates'] ?? 0;
        final total = result['total'] ?? (inserted + updated + duplicates);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Elaborazione completata: $total record totali.\n'
              '• $inserted nuovi record inseriti\n'
              '• $updated record esistenti aggiornati'
              '${duplicates > 0 ? "\n• $duplicates duplicati saltati" : ""}',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        _selectedEstrattoFile = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Errore durante l\'elaborazione dell\'estratto conto: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingEstratto = false);
    }
  }

  Future<void> _processSapData() async {
    if (_selectedSapFile == null) return;

    if (!await _checkDuplicateFile(_selectedSapFile!)) {
      return;
    }

    setState(() {
      _isProcessingSap = true;
      _lastSapResult = null;
    });

    try {
      final result = await ref
          .read(tracciatoSapProvider.notifier)
          .loadFromFile(_selectedSapFile!);

      if (mounted) {
        setState(() {
          _lastSapResult = result;
        });

        final inserted = result['inserted'] ?? 0;
        final total = result['total'] ?? inserted;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Elaborazione SAP completata: $total record totali.\n'
              '• $inserted nuovi record inseriti',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        _selectedSapFile = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Errore durante l\'elaborazione del tracciato SAP: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingSap = false);
    }
  }

  Future<void> _processAmexData() async {
    if (_selectedAmexFile == null) return;

    if (!await _checkDuplicateFile(_selectedAmexFile!)) {
      return;
    }

    setState(() {
      _isProcessingAmex = true;
      _lastAmexResult = null;
    });

    try {
      final result = await ref
          .read(estrattoAmexProvider.notifier)
          .loadFromFile(_selectedAmexFile!);

      if (mounted) {
        setState(() {
          _lastAmexResult = result;
        });

        final inserted = result['inserted'] ?? 0;
        final total = result['total'] ?? inserted;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Elaborazione AMEX completata: $total record totali.\n'
              '• $inserted nuovi record inseriti',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        _selectedAmexFile = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Errore durante l\'elaborazione dell\'estratto AMEX: $e',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAmex = false);
    }
  }

  Future<void> _processAnagraficaData() async {
    if (_selectedAnagraficaFile == null) return;

    setState(() {
      _isProcessingAnagrafica = true;
      _lastAnagraficaResult = null;
    });

    try {
      final bool alreadyExists = await _checkDuplicateFile(_selectedAnagraficaFile!);
      if (!alreadyExists) {
        if (mounted) setState(() => _isProcessingAnagrafica = false);
        return;
      }

      final result = await ref.read(anagraficaProvider.notifier).loadFromFile(_selectedAnagraficaFile!);

      if (mounted) {
        setState(() {
          _lastAnagraficaResult = result;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Anagrafica elaborata: ${result['inserted']} inseriti, ${result['updated']} aggiornati, ${result['discarded']} scartati.',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        _selectedAnagraficaFile = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'elaborazione dell\'anagrafica: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAnagrafica = false);
    }
  }

  Future<void> _processScartiSapData() async {
    if (_selectedScartiSapFile == null) return;

    setState(() {
      _isProcessingScartiSap = true;
      _lastScartiSapResult = null;
    });

    try {
      final bool alreadyExists = await _checkDuplicateFile(_selectedScartiSapFile!);
      if (!alreadyExists) {
        if (mounted) setState(() => _isProcessingScartiSap = false);
        return;
      }

      final result = await ref.read(scartiEcSapProvider.notifier).loadFromFile(_selectedScartiSapFile!);

      if (mounted) {
        setState(() {
          _lastScartiSapResult = result;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Elaborazione Scarti Tracciato completata: ${result['inserted']} inseriti, ${result['discarded']} scartati.',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        _selectedScartiSapFile = null;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'elaborazione degli scarti del tracciato: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingScartiSap = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildContabileSection()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildEstrattoSection()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildSapSection()),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildAmexSection()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildAnagraficaSection()),
                            const SizedBox(width: 24),
                            Expanded(child: _buildScartiSapSection()),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildContabileSection(),
                        const SizedBox(height: 32),
                        _buildEstrattoSection(),
                        const SizedBox(height: 32),
                        _buildSapSection(),
                        const SizedBox(height: 32),
                        _buildAmexSection(),
                        const SizedBox(height: 32),
                        _buildAnagraficaSection(),
                        const SizedBox(height: 32),
                        _buildScartiSapSection(),
                      ],
                    );
                  }
                },
              ),
              if (_lastContabileResult != null || _lastEstrattoResult != null || _lastSapResult != null || _lastAmexResult != null || _lastAnagraficaResult != null || _lastScartiSapResult != null) ...[
                const SizedBox(height: 48),
                const Divider(),
                const SizedBox(height: 24),
                Text(
                  'DETTAGLI ULTIMA ELABORAZIONE',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_lastContabileResult != null) 
                  _buildDetailedResultCard(
                    title: 'RISULTATI FLUSSO CONTABILE',
                    result: _lastContabileResult!,
                    dataType: 'contabile',
                  ),
                if (_lastEstrattoResult != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailedResultCard(
                    title: 'RISULTATI ESTRATTO CONTO',
                    result: _lastEstrattoResult!,
                    dataType: 'estratto',
                  ),
                ],
                if (_lastSapResult != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailedResultCard(
                    title: 'RISULTATI TRACCIATO SAP',
                    result: _lastSapResult!,
                    dataType: 'sap',
                  ),
                ],
                if (_lastAmexResult != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailedResultCard(
                    title: 'RISULTATI ESTRATTI AMEX',
                    result: _lastAmexResult!,
                    dataType: 'amex',
                  ),
                ],
                if (_lastAnagraficaResult != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailedResultCard(
                    title: 'RISULTATI ANAGRAFICA',
                    result: _lastAnagraficaResult!,
                    dataType: 'anagrafica',
                  ),
                ],
                if (_lastScartiSapResult != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailedResultCard(
                    title: 'RISULTATI SCARTI TRACCIATO',
                    result: _lastScartiSapResult!,
                    dataType: 'scartiSap',
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedResultCard({
    required String title,
    required Map<String, dynamic> result,
    required String dataType,
  }) {
    final bool isContabile = dataType == 'contabile';
    final bool isAnagrafica = dataType == 'anagrafica';
    final inserted = result['inserted'] as int? ?? 0;
    final updated = result['updated'] as int? ?? 0;
    final discarded = result['discarded'] as int? ?? 0;
    final total = result['total'] as int? ?? 0;
    final collisions = result['collisions'] as List<dynamic>? ?? [];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  isAnagrafica 
                      ? Icons.people 
                      : (isContabile 
                          ? Icons.receipt_long 
                          : (dataType == 'scartiSap' 
                              ? Icons.warning_amber_outlined 
                              : Icons.account_balance_wallet)),
                  color: SkyTheme.timBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: SkyTheme.timBlue,
                  ),
                ),
                const Spacer(),
                if (result['uniqueCode'] != null)
                  TextButton.icon(
                    onPressed: () {
                      _confirmDeleteFullImport(
                        result['uniqueCode'], 
                        dataType
                      );
                    },
                    icon: const Icon(Icons.history_toggle_off, color: Colors.redAccent, size: 18),
                    label: const Text(
                      'ELIMINA INTERO IMPORT',
                      style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: Colors.red.shade50,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _buildStatItem('Record Inseriti', inserted, Colors.green),
                if (updated > 0)
                  _buildStatItem('Record Aggiornati', updated, Colors.blue),
                if (discarded > 0)
                  _buildStatItem('Record Scartati', discarded, Colors.red),
                _buildStatItem('Totale File', total, Colors.grey.shade700),
                if (collisions.isNotEmpty)
                  _buildStatItem(isContabile ? 'Conflitti Bolla' : 'Conflitti', collisions.length, Colors.orange),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isAnagrafica 
                  ? 'Nota: I record sono stati elaborati tramite Codice Fiscale. Gli esistenti sono stati aggiornati, i nuovi inseriti.'
                  : (dataType == 'scartiSap'
                      ? 'Nota: I record di scarto del tracciato sono stati importati con successo.'
                      : 'Nota: Tutti i record presenti nel file sono stati importati come nuove voci nel database.'),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ),
            if (collisions.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'REPORT CONFLITTI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.5,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBollaCollisionsReport(collisions, dataType),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBollaCollisionsReport(List<dynamic> collisions, String dataType) {
    final currentPage = dataType == 'contabile' ? _collisionPage : _collisionPageEstratto;
    final totalItems = collisions.length;
    final totalPages = (totalItems / _itemsPerPage).ceil();
    final startIndex = currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < totalItems) ? startIndex + _itemsPerPage : totalItems;
    final visibleCollisions = collisions.sublist(startIndex, endIndex);

    return Column(
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleCollisions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final collision = visibleCollisions[index];
            final type = collision['type'];
            final bolla = collision['bolla'];
            final currentMap = collision['current'] as Map<String, dynamic>;
            final foundMap = collision['found'] as Map<String, dynamic>;
            final foundFileName = collision['foundFileName'];

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withAlpha(50)),
                color: Colors.orange.withAlpha(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withAlpha(20),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'IDENTIFICATIVO: $bolla',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.orange),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: type == 'internal' ? Colors.blue.withAlpha(40) : Colors.purple.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            type == 'internal' ? 'DUPLICATO NEL FILE' : 'PRESENTE NEL DATABASE',
                            style: TextStyle(
                              fontSize: 10, 
                              fontWeight: FontWeight.bold, 
                              color: type == 'internal' ? Colors.blue.shade800 : Colors.purple.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmall = constraints.maxWidth < 600;
                        return isSmall 
                          ? Column(
                              children: [
                                _buildCollisionRecordCard('RECORD ATTUALE (FILE)', currentMap, null, dataType),
                                const SizedBox(height: 12),
                                _buildCollisionRecordCard('RECORD TROVATO', foundMap, foundFileName, dataType),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(child: _buildCollisionRecordCard('RECORD ATTUALE (FILE)', currentMap, null, dataType)),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Icon(Icons.compare_arrows, color: Colors.grey),
                                ),
                                Expanded(child: _buildCollisionRecordCard('RECORD TROVATO', foundMap, foundFileName, dataType)),
                              ],
                            );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (totalPages > 1) ...[
          const SizedBox(height: 24),
          _buildPaginationControls(totalPages, dataType),
        ],
      ],
    );
  }

  Widget _buildPaginationControls(int totalPages, String dataType) {
    final currentPage = dataType == 'contabile' ? _collisionPage : _collisionPageEstratto;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 0 
              ? () {
                  setState(() {
                    if (dataType == 'contabile') {
                      _collisionPage--;
                    } else {
                      _collisionPageEstratto--;
                    }
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_left),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        const SizedBox(width: 24),
        Text(
          'PAGINA ${currentPage + 1} DI $totalPages',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 24),
        IconButton(
          onPressed: currentPage < totalPages - 1 
              ? () {
                  setState(() {
                    if (dataType == 'contabile') {
                      _collisionPage++;
                    } else {
                      _collisionPageEstratto++;
                    }
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteFullImport(String uniqueCode, String type) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione Totale'),
        content: const Text(
          'Sei sicuro di voler eliminare TUTTI i record di questo import e il relativo log storico? '
          'Questa azione non può essere annullata.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('ELIMINA TUTTO'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(logHistoryProvider.notifier).deleteLogHistoryAndRecords(uniqueCode);
      
      setState(() {
        if (type == 'contabile') {
          _lastContabileResult = null;
          _deletedRecordIds.clear();
        } else if (type == 'estratto') {
          _lastEstrattoResult = null;
          _deletedRecordIds.clear();
        } else if (type == 'sap') {
          _lastSapResult = null;
        } else if (type == 'amex') {
          _lastAmexResult = null;
        } else if (type == 'anagrafica') {
          _lastAnagraficaResult = null;
        } else if (type == 'scartiSap') {
          _lastScartiSapResult = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Intero import eliminato con successo')),
        );
      }
    }
  }

  Widget _buildCollisionRecordCard(String title, Map<String, dynamic> rawRecord, String? fileName, String dataType) {
    final recordId = rawRecord['id'] as int?;
    final isDeleted = recordId != null && _deletedRecordIds.contains(recordId);
    
    final String bolla = rawRecord['bolla']?.toString() ?? '';
    final String cid = rawRecord['cid']?.toString() ?? '';
    final String trasferta = rawRecord['numeroTrasferta']?.toString() ?? '';
    
    String importoFormatted = '';
    Color? importoColor;

    if (dataType == 'contabile') {
      final isNegative = rawRecord['isNegative'] ?? false;
      final importo = (rawRecord['importo'] as num?)?.toDouble() ?? 0.0;
      final valuta = rawRecord['valuta'] ?? 'EUR';
      importoFormatted = '${isNegative ? '-' : ''}${importo.toStringAsFixed(2)} $valuta';
      importoColor = isNegative ? Colors.red.shade700 : Colors.green.shade700;
    } else {
      final importo = (rawRecord['totaleServizioGenerale'] as num?)?.toDouble() ?? 0.0;
      importoFormatted = '${importo.toStringAsFixed(2)} EUR';
      importoColor = importo < 0 ? Colors.red.shade700 : Colors.green.shade700;
    }

    final String data = dataType == 'contabile' ? (rawRecord['dataSpesa']?.toString() ?? '') : (rawRecord['dataBolla']?.toString() ?? '');
    final String localita = dataType == 'contabile' ? (rawRecord['localita']?.toString() ?? '') : (rawRecord['descrizioneServizio']?.toString() ?? '');

    return Opacity(
      opacity: isDeleted ? 0.5 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDeleted ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDeleted ? Colors.grey.shade300 : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 0.5),
                ),
                if (recordId != null && !isDeleted)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _confirmDeleteRecord(recordId, bolla, dataType),
                    tooltip: 'Elimina record',
                  ),
                if (isDeleted)
                  const Text(
                    'ELIMINATO',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SkyTheme.timBlue.withAlpha(8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildCollisionDetailRow('BOLLA', bolla, isHighlight: true),
                  const SizedBox(height: 4),
                  _buildCollisionDetailRow(
                    'IMPORTO', 
                    importoFormatted,
                    isHighlight: true,
                    valueColor: importoColor,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildCollisionDetailRow('CID', cid),
            _buildCollisionDetailRow('Trasferta', trasferta),
            _buildCollisionDetailRow('Data', data),
            _buildCollisionDetailRow(dataType == 'contabile' ? 'Località' : 'Servizio', localita),
            if (fileName != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file, size: 12, color: SkyTheme.timBlue),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'File: $fileName',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: SkyTheme.timBlue),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteRecord(int id, String bolla, String dataType) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Sei sicuro di voler eliminare definitivamente il record con bolla $bolla dal database?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('ELIMINA'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (dataType == 'contabile') {
        await ref.read(tracciatoContabilesProvider.notifier).deleteRecord(id);
      } else {
        await ref.read(estrattoContoProvider.notifier).deleteRecord(id);
      }
      
      setState(() {
        _deletedRecordIds.add(id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record eliminato con successo')),
        );
      }
    }
  }

  Widget _buildCollisionDetailRow(String label, String value, {bool isHighlight = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: TextStyle(
              fontSize: isHighlight ? 12 : 11, 
              color: isHighlight ? Colors.grey.shade700 : Colors.grey.shade600,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            )
          ),
          Text(
            value, 
            style: TextStyle(
              fontSize: isHighlight ? 14 : 11, 
              fontWeight: FontWeight.bold,
              color: valueColor ?? (isHighlight ? SkyTheme.timBlue : Colors.black),
            )
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return SizedBox(
      width: 130, // Larghezza fissa per allineamento nel Wrap
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildContabileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          'FLUSSO CONTABILE',
          'File tracciato contabile (.txt)',
        ),
        const SizedBox(height: 24),
        _buildDropZone(
          type: 'contabile',
          selectedFile: _selectedContabileFile,
          isDragging: _isDraggingContabile,
          allowedExtensions: ['txt'],
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          onPressed: (_selectedContabileFile != null && !_isProcessingContabile)
              ? _processContabileData
              : null,
          label: 'ELABORA FLUSSO CONTABILE',
          isLoading: _isProcessingContabile,
        ),
      ],
    );
  }

  Widget _buildEstrattoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          'ESTRATTI CONTO',
          'File estratti conto (.xlsx)',
        ),
        const SizedBox(height: 24),
        _buildDropZone(
          type: 'estratto',
          selectedFile: _selectedEstrattoFile,
          isDragging: _isDraggingEstratto,
          allowedExtensions: ['xlsx'],
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          onPressed: (_selectedEstrattoFile != null && !_isProcessingEstratto)
              ? _processEstrattoData
              : null,
          label: 'ELABORA ESTRATTI CONTO',
          isLoading: _isProcessingEstratto,
        ),
      ],
    );
  }

  Widget _buildSapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          'TRACCIATO SAP',
          'File tracciato SAP (.xlsx)',
        ),
        const SizedBox(height: 24),
        _buildDropZone(
          type: 'sap',
          selectedFile: _selectedSapFile,
          isDragging: _isDraggingSap,
          allowedExtensions: ['xlsx'],
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          onPressed: (_selectedSapFile != null && !_isProcessingSap)
              ? _processSapData
              : null,
          label: 'ELABORA TRACCIATO SAP',
          isLoading: _isProcessingSap,
        ),
      ],
    );
  }
  Widget _buildAmexSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          'ESTRATTI AMEX',
          'File estratti AMEX (.xlsx, .csv)',
        ),
        const SizedBox(height: 24),
        _buildDropZone(
          type: 'amex',
          selectedFile: _selectedAmexFile,
          isDragging: _isDraggingAmex,
          allowedExtensions: ['xlsx', 'csv'],
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          onPressed: (_selectedAmexFile != null && !_isProcessingAmex)
              ? _processAmexData
              : null,
          label: 'ELABORA ESTRATTI AMEX',
          isLoading: _isProcessingAmex,
        ),
      ],
    );
  }

  Widget _buildAnagraficaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          'ANAGRAFICA',
          'File anagrafica dipendenti (.xlsx)',
        ),
        const SizedBox(height: 24),
        _buildDropZone(
          type: 'anagrafica',
          selectedFile: _selectedAnagraficaFile,
          isDragging: _isDraggingAnagrafica,
          allowedExtensions: ['xlsx'],
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          onPressed: (_selectedAnagraficaFile != null && !_isProcessingAnagrafica)
              ? _processAnagraficaData
              : null,
          label: 'ELABORA ANAGRAFICA',
          isLoading: _isProcessingAnagrafica,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return SizedBox(
      height: 70, // Altezza fissa per allineare le zone di drop
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              color: SkyTheme.timBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildDropZone({
    required String type,
    required XFile? selectedFile,
    required bool isDragging,
    required List<String> allowedExtensions,
  }) {
    return DropTarget(
      onDragDone: (detail) {
        final filteredFiles = detail.files.where((f) {
          final ext = f.name.split('.').last.toLowerCase();
          return allowedExtensions.contains(ext);
        }).toList();

        if (filteredFiles.isNotEmpty) {
          setState(() {
            if (type == 'contabile') {
              _selectedContabileFile = filteredFiles.first;
            } else if (type == 'estratto') {
              _selectedEstrattoFile = filteredFiles.first;
            } else if (type == 'sap') {
              _selectedSapFile = filteredFiles.first;
            } else if (type == 'amex') {
              _selectedAmexFile = filteredFiles.first;
            } else if (type == 'anagrafica') {
              _selectedAnagraficaFile = filteredFiles.first;
            } else if (type == 'scartiSap') {
              _selectedScartiSapFile = filteredFiles.first;
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Formato non valido. Estensioni permesse: ${allowedExtensions.join(', ')}',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      onDragEntered: (detail) {
        setState(() {
          if (type == 'contabile') {
            _isDraggingContabile = true;
          } else if (type == 'estratto') {
            _isDraggingEstratto = true;
          } else if (type == 'sap') {
            _isDraggingSap = true;
          } else if (type == 'amex') {
            _isDraggingAmex = true;
          } else if (type == 'anagrafica') {
            _isDraggingAnagrafica = true;
          } else if (type == 'scartiSap') {
            _isDraggingScartiSap = true;
          }
        });
      },
      onDragExited: (detail) {
        setState(() {
          if (type == 'contabile') {
            _isDraggingContabile = false;
          } else if (type == 'estratto') {
            _isDraggingEstratto = false;
          } else if (type == 'sap') {
            _isDraggingSap = false;
          } else if (type == 'amex') {
            _isDraggingAmex = false;
          } else if (type == 'anagrafica') {
            _isDraggingAnagrafica = false;
          } else if (type == 'scartiSap') {
            _isDraggingScartiSap = false;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 200,
        decoration: BoxDecoration(
          color: isDragging
              ? Theme.of(context).colorScheme.primary.withAlpha(15)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDragging
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (type == 'contabile' && !_isProcessingContabile) _pickFile('contabile');
              if (type == 'estratto' && !_isProcessingEstratto) _pickFile('estratto');
              if (type == 'sap' && !_isProcessingSap) _pickFile('sap');
              if (type == 'amex' && !_isProcessingAmex) _pickFile('amex');
              if (type == 'anagrafica' && !_isProcessingAnagrafica) _pickFile('anagrafica');
              if (type == 'scartiSap' && !_isProcessingScartiSap) _pickFile('scartiSap');
            },
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: selectedFile == null
                  ? _buildEmptyState()
                  : _buildSelectedFileState(
                      selectedFile, 
                      type, 
                      type == 'contabile' ? _isProcessingContabile : 
                      (type == 'estratto' ? _isProcessingEstratto : 
                      (type == 'sap' ? _isProcessingSap : 
                      (type == 'amex' ? _isProcessingAmex : 
                      (type == 'anagrafica' ? _isProcessingAnagrafica : _isProcessingScartiSap))))
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String label,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: isLoading 
          ? const SizedBox(
              width: 20, 
              height: 20, 
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            ) 
          : const Icon(Icons.upload_file),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Text(
          isLoading ? 'ELABORAZIONE IN CORSO...' : label, 
          style: const TextStyle(letterSpacing: 1.1)
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: SkyTheme.timBlue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 48,
          color: SkyTheme.timBlue.withAlpha(100),
        ),
        const SizedBox(height: 12),
        const Text(
          'Trascina il file qui',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const Text(
          'o clicca per sfogliare',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSelectedFileState(XFile file, String type, bool isLoading) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isLoading ? Icons.hourglass_empty : Icons.insert_drive_file_outlined,
                size: 48,
                color: isLoading ? Colors.orange : SkyTheme.timBlue,
              ),
              const SizedBox(height: 12),
              Text(
                file.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                isLoading ? 'Elaborazione in corso...' : 'Pronto per l\'elaborazione',
                style: TextStyle(
                  fontSize: 12,
                  color: isLoading ? Colors.orange : Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (!isLoading)
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20, color: Colors.grey),
              onPressed: () => _removeFile(type),
              tooltip: 'Rimuovi file',
            ),
          ),
      ],
    );
  }

  Widget _buildScartiSapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          'SCARTI TRACCIATO',
          'File scarti del tracciato (.xlsx)',
        ),
        const SizedBox(height: 24),
        _buildDropZone(
          type: 'scartiSap',
          selectedFile: _selectedScartiSapFile,
          isDragging: _isDraggingScartiSap,
          allowedExtensions: ['xlsx'],
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          onPressed: (_selectedScartiSapFile != null && !_isProcessingScartiSap)
              ? _processScartiSapData
              : null,
          label: 'ELABORA SCARTI TRACCIATO',
          isLoading: _isProcessingScartiSap,
        ),
      ],
    );
  }
}
