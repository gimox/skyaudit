import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';

class UploadView extends ConsumerStatefulWidget {
  const UploadView({super.key});

  @override
  ConsumerState<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends ConsumerState<UploadView> {
  bool _isDragging = false;
  XFile? _selectedFile;


  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'], 
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = XFile(result.files.single.path!);
      });
    }
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _processData() async {
    if (_selectedFile == null) return;
    
    // Mostra messaggio di caricamento
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('File in elaborazione: ${_selectedFile!.name}...'),
        backgroundColor: SkyTheme.timBlue,
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final result = await ref.read(tracciatoContabilesProvider.notifier).loadFromFile(_selectedFile!);
      
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
              '${duplicates > 0 ? "\n• $duplicates duplicati saltati nel file" : ""}'
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
        // Resetta la selezione dopo il caricamento
        _removeFile();
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'CARICA FLUSSO CONTABILE',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w200,
                      letterSpacing: 2.0,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              

              
              // Drag and Drop Zone
              DropTarget(
                onDragDone: (detail) {
                  final txtFiles = detail.files.where((f) => f.name.toLowerCase().endsWith('.txt')).toList();
                  if (txtFiles.isNotEmpty) {
                    setState(() {
                      _selectedFile = txtFiles.first;
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Per favore inserisci un file in formato .txt'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                },
                onDragEntered: (detail) {
                  setState(() {
                    _isDragging = true;
                  });
                },
                onDragExited: (detail) {
                  setState(() {
                    _isDragging = false;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 250,
                  decoration: BoxDecoration(
                    color: _isDragging 
                        ? Theme.of(context).colorScheme.primary.withAlpha(25) 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isDragging 
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
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(16),
                      child: Center(
                        child: _selectedFile == null 
                            ? _buildEmptyState() 
                            : _buildSelectedFileState(),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Button
              ElevatedButton.icon(
                onPressed: _selectedFile != null ? _processData : null,
                icon: const Icon(Icons.upload_file),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'CARICA ED ELABORA FILE',
                    style: TextStyle(letterSpacing: 1.2),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: 64,
          color: Theme.of(context).colorScheme.primary.withAlpha(150),
        ),
        const SizedBox(height: 16),
        Text(
          'Trascina il file qui',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'oppure clicca per cercare nel computer',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFileState() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                _selectedFile!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'File pronto per l\'elaborazione',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: _removeFile,
            tooltip: 'Rimuovi file',
          ),
        ),
      ],
    );
  }


}
