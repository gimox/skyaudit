import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';

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

  Future<void> _pickFile(bool isContabile) async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: isContabile ? ['txt'] : ['xlsx', 'csv', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isContabile) {
          _selectedContabileFile = XFile(result.files.single.path!);
        } else {
          _selectedEstrattoFile = XFile(result.files.single.path!);
        }
      });
    }
  }

  void _removeFile(bool isContabile) {
    setState(() {
      if (isContabile) {
        _selectedContabileFile = null;
      } else {
        _selectedEstrattoFile = null;
      }
    });
  }

  Future<void> _processContabileData() async {
    if (_selectedContabileFile == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'File in elaborazione: ${_selectedContabileFile!.name}...',
        ),
        backgroundColor: SkyTheme.timBlue,
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final result = await ref
          .read(tracciatoContabilesProvider.notifier)
          .loadFromFile(_selectedContabileFile!);

      if (mounted) {
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
        _removeFile(true);
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
    }
  }

  Future<void> _processEstrattoData() async {
    if (_selectedEstrattoFile == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'File in elaborazione: ${_selectedEstrattoFile!.name}...',
        ),
        backgroundColor: SkyTheme.timBlue,
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final result = await ref
          .read(estrattoContoProvider.notifier)
          .loadFromFile(_selectedEstrattoFile!);

      if (mounted) {
        final inserted = result['inserted'] ?? 0;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Elaborazione completata: $inserted record inseriti nell\'Estratto Conto.',
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        _removeFile(false);
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
            ],
          ),
        ),
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
          onPressed: _selectedContabileFile != null
              ? _processContabileData
              : null,
          label: 'ELABORA FLUSSO CONTABILE',
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
          onPressed: _selectedEstrattoFile != null
              ? _processEstrattoData
              : null,
          label: 'ELABORA ESTRATTI CONTO',
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
            onTap: () => _pickFile(isContabile),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: selectedFile == null
                  ? _buildEmptyState()
                  : _buildSelectedFileState(selectedFile, isContabile),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.upload_file),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Text(label, style: const TextStyle(letterSpacing: 1.1)),
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

  Widget _buildSelectedFileState(XFile file, bool isContabile) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.insert_drive_file_outlined,
                size: 48,
                color: SkyTheme.timBlue,
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
                'Pronto per l\'elaborazione',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
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
