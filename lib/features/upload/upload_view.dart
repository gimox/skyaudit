import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';

class UploadView extends ConsumerStatefulWidget {
  const UploadView({super.key});

  @override
  ConsumerState<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends ConsumerState<UploadView> {
  XFile? _selectedContabileFile;
  XFile? _selectedEstrattoFile;
  bool _isDraggingContabile = false;
  bool _isDraggingEstratto = false;
  bool _isProcessingContabile = false;
  bool _isProcessingEstratto = false;

  Map<String, dynamic>? _lastContabileResult;
  Map<String, dynamic>? _lastEstrattoResult;

  Future<void> _pickFile(bool isContabile) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: isContabile ? ['txt'] : ['xlsx', 'csv', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isContabile) {
          _selectedContabileFile = XFile(result.files.single.path!);
          _lastContabileResult = null;
        } else {
          _selectedEstrattoFile = XFile(result.files.single.path!);
          _lastEstrattoResult = null;
        }
      });
    }
  }

  void _removeFile(bool isContabile) {
    setState(() {
      if (isContabile) {
        _selectedContabileFile = null;
        _lastContabileResult = null;
      } else {
        _selectedEstrattoFile = null;
        _lastEstrattoResult = null;
      }
    });
  }

  Future<void> _processContabileData() async {
    if (_selectedContabileFile == null) return;

    setState(() {
      _isProcessingContabile = true;
      _lastContabileResult = null;
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

    setState(() {
      _isProcessingEstratto = true;
      _lastEstrattoResult = null;
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
              Text(
                'GESTIONE CARICAMENTO DATI',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w200,
                  letterSpacing: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildContabileSection()),
                        const SizedBox(width: 32),
                        Expanded(child: _buildEstrattoSection()),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _buildContabileSection(),
                        const SizedBox(height: 48),
                        _buildEstrattoSection(),
                      ],
                    );
                  }
                },
              ),
              if (_lastContabileResult != null || _lastEstrattoResult != null) ...[
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
                    isContabile: true,
                  ),
                if (_lastEstrattoResult != null) ...[
                  const SizedBox(height: 24),
                  _buildDetailedResultCard(
                    title: 'RISULTATI ESTRATTO CONTO',
                    result: _lastEstrattoResult!,
                    isContabile: false,
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
    required bool isContabile,
  }) {
    final inserted = result['inserted'] as int? ?? 0;
    final total = result['total'] as int? ?? 0;

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
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: SkyTheme.timBlue,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatItem('Record Inseriti', inserted, Colors.green),
                _buildStatItem('Totale File', total, Colors.grey.shade700),
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
                'Nota: Tutti i record presenti nel file sono stati importati come nuove voci nel database.',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Expanded(
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
          isContabile: true,
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
          'File estratti conto (XLSX, CSV, PDF)',
        ),
        const SizedBox(height: 24),
        _buildDropZone(
          isContabile: false,
          selectedFile: _selectedEstrattoFile,
          isDragging: _isDraggingEstratto,
          allowedExtensions: ['xlsx', 'csv', 'pdf'],
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: SkyTheme.timBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildDropZone({
    required bool isContabile,
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
            if (isContabile) {
              _selectedContabileFile = filteredFiles.first;
            } else {
              _selectedEstrattoFile = filteredFiles.first;
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
          if (isContabile) {
            _isDraggingContabile = true;
          } else {
            _isDraggingEstratto = true;
          }
        });
      },
      onDragExited: (detail) {
        setState(() {
          if (isContabile) {
            _isDraggingContabile = false;
          } else {
            _isDraggingEstratto = false;
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
            onTap: (isContabile ? _isProcessingContabile : _isProcessingEstratto) 
                ? null 
                : () => _pickFile(isContabile),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: selectedFile == null
                  ? _buildEmptyState()
                  : _buildSelectedFileState(selectedFile, isContabile, (isContabile ? _isProcessingContabile : _isProcessingEstratto)),
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

  Widget _buildSelectedFileState(XFile file, bool isContabile, bool isLoading) {
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
              onPressed: () => _removeFile(isContabile),
              tooltip: 'Rimuovi file',
            ),
          ),
      ],
    );
  }
}
