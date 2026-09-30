import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:universal_io/io.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/analysis/services/tracciato_generator_service.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/features/upload/providers/trasferte_sap_provider.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/anagrafica.dart';
import 'package:travel_check/features/upload/models/trasferte_sap.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';

enum SegnoFilter { tutti, soloAddebiti, soloRimborsi }

class CreaTracciatoView extends ConsumerStatefulWidget {
  const CreaTracciatoView({super.key});

  @override
  ConsumerState<CreaTracciatoView> createState() => _CreaTracciatoViewState();
}

class _CreaTracciatoViewState extends ConsumerState<CreaTracciatoView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();

  bool _isLoading = false;
  bool _isDragging = false;
  String? _loadedFileName;
  TracciatoGeneratorResult? _generatorResult;

  // Pagination & Filters State
  static const int _pageSize = 50;
  int _currentPage = 0;
  String _searchQuery = '';
  SegnoFilter _segnoFilter = SegnoFilter.tutti;
  final Set<String> _selectedSociete = {};
  final Set<String> _selectedGiustificativi = {};

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickAndProcessExcel() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.single;
      Uint8List? fileBytes = pickedFile.bytes;

      if (fileBytes == null && pickedFile.path != null) {
        fileBytes = await File(pickedFile.path!).readAsBytes();
      }

      if (fileBytes == null || fileBytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossibile leggere il file selezionato.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      await _processExcelBytes(fileBytes, pickedFile.name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore selezione file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processExcelBytes(Uint8List fileBytes, String fileName) async {
    setState(() {
      _isLoading = true;
      _isDragging = false;
    });

    try {
      // Prepare fast O(1) indexed maps from Isar
      final anagraficaList = ref.read(anagraficaProvider);
      final Map<String, Anagrafica> anagraficaMap = {};
      for (final a in anagraficaList) {
        if (a.cid != null && a.cid!.isNotEmpty) {
          anagraficaMap[a.cid!.padLeft(8, '0')] = a;
        }
      }

      final trasferteSapList = ref.read(trasferteSapProvider);
      final Map<String, TrasferteSap> trasferteSapMap = {};
      for (final t in trasferteSapList) {
        trasferteSapMap[t.numeroTrasferta.padLeft(10, '0')] = t;
      }

      final tracciatoContabileList = ref.read(tracciatoContabilesProvider);
      final Map<String, TracciatoContabile> contabileMap = {};
      for (final c in tracciatoContabileList) {
        if (c.numeroBolla.isNotEmpty) {
          contabileMap[c.numeroBolla] = c;
        }
      }

      final generatorResult = TracciatoGeneratorService.generateFromExcelBytes(
        bytes: fileBytes,
        anagraficaMap: anagraficaMap,
        trasferteSapMap: trasferteSapMap,
        existingContabileMap: contabileMap,
      );

      setState(() {
        _generatorResult = generatorResult;
        _loadedFileName = fileName;
        _currentPage = 0;
        _isLoading = false;
        _selectedSociete.clear();
        _selectedGiustificativi.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tracciato generato con successo! ${generatorResult.totalRecords} record creati.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore elaborazione file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportTxtFile() async {
    if (_generatorResult == null) return;

    try {
      final now = DateTime.now();
      final dateStr =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final defaultFileName = '${dateStr}_TIM_TRACCIATO_CONTABILE.txt';

      final outputPath = await FilePicker.saveFile(
        dialogTitle: 'Salva File Tracciato Contabile (.txt)',
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (outputPath == null) return;

      final file = File(outputPath);
      await file.writeAsBytes(utf8.encode(_generatorResult!.fullText));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File tracciato salvato con successo: $outputPath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante il salvataggio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _importDirectlyToDatabase() async {
    if (_generatorResult == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Importa in Tracciato Contabile'),
        content: Text(
          'Vuoi importare direttamente i ${_generatorResult!.totalRecords} record nel database locale di Tracciato Contabile?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SkyTheme.timBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Conferma Import'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/tracciato_generato_${DateTime.now().millisecondsSinceEpoch}.txt';
      final tempFile = File(tempPath);
      await tempFile.writeAsString(_generatorResult!.fullText);

      final xFile = XFile(tempPath, name: _loadedFileName ?? 'tracciato_generato.txt');
      await ref.read(tracciatoContabilesProvider.notifier).loadFromFile(xFile);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_generatorResult!.totalRecords} record importati con successo nel Tracciato Contabile!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'importazione: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTxtPreviewDialog() {
    if (_generatorResult == null) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 750),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: SkyTheme.timBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.description_outlined,
                            color: SkyTheme.timBlue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Anteprima File TXT Formattato (Fixed-Width 167 Chars)',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Testata (0HR), ${_generatorResult!.totalRecords} record dettaglio, Coda (ZHR)',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: _generatorResult!.fullText),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Testo tracciato copiato negli appunti!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 16),
                          label: const Text('Copia'),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade800),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _generatorResult!.fullText,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Color(0xFF4EC9B0),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Chiudi'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _exportTxtFile();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SkyTheme.timBlue,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Scarica File TXT'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$integerPart,${parts[1]} €';
  }

  List<GeneratedTracciatoRecord> _getFilteredRecords() {
    if (_generatorResult == null) return [];

    return _generatorResult!.records.where((r) {
      if (_segnoFilter == SegnoFilter.soloAddebiti && r.isNegative) return false;
      if (_segnoFilter == SegnoFilter.soloRimborsi && !r.isNegative) return false;

      if (_selectedSociete.isNotEmpty && !_selectedSociete.contains(r.bukrs)) {
        return false;
      }

      if (_selectedGiustificativi.isNotEmpty &&
          !_selectedGiustificativi.contains(r.spkzl)) {
        return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchCid = r.cid.toLowerCase().contains(query);
        final matchTr = r.numeroTrasferta.toLowerCase().contains(query);
        final matchBolla = r.bolla.toLowerCase().contains(query);
        final matchLoc = r.localita.toLowerCase().contains(query);
        final matchSoc = r.bukrs.toLowerCase().contains(query);
        if (!matchCid && !matchTr && !matchBolla && !matchLoc && !matchSoc) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredRecords = _getFilteredRecords();
    final totalFiltered = filteredRecords.length;
    final totalPages = (totalFiltered / _pageSize).ceil();
    final safePage = totalPages > 0 ? _currentPage.clamp(0, totalPages - 1) : 0;
    final startIndex = safePage * _pageSize;
    final endIndex = (startIndex + _pageSize).clamp(0, totalFiltered);
    final pageRecords = totalFiltered > 0
        ? filteredRecords.sublist(startIndex, endIndex)
        : <GeneratedTracciatoRecord>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DropTarget(
        onDragEntered: (_) => setState(() => _isDragging = true),
        onDragExited: (_) => setState(() => _isDragging = false),
        onDragDone: (detail) async {
          setState(() => _isDragging = false);
          final validFiles = detail.files.where((f) {
            final ext = f.name.split('.').last.toLowerCase();
            return ext == 'xlsx' || ext == 'xls';
          }).toList();

          if (validFiles.isNotEmpty) {
            final file = validFiles.first;
            final bytes = await file.readAsBytes();
            await _processExcelBytes(bytes, file.name);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Formato non valido. Trascina un file Excel (.xlsx o .xls).',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopHeader(theme),
                if (_isLoading)
                  const LinearProgressIndicator(
                    color: SkyTheme.timBlue,
                    minHeight: 3,
                  )
                else
                  const Divider(height: 1),
                Expanded(
                  child: _generatorResult == null
                      ? _buildEmptyDropzone(theme)
                      : _buildDashboardContent(
                          theme: theme,
                          totalFiltered: totalFiltered,
                          totalPages: totalPages,
                          safePage: safePage,
                          startIndex: startIndex,
                          endIndex: endIndex,
                          pageRecords: pageRecords,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SkyTheme.timBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.post_add_rounded,
              color: SkyTheme.timBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'CREA TRACCIATO CONTABILE',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    if (_loadedFileName != null) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          _loadedFileName!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Generazione file TXT Uvet / SAP Fixed-Width (167 char) a partire da upload file Excel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_generatorResult != null) ...[
                OutlinedButton.icon(
                  onPressed: _showTxtPreviewDialog,
                  icon: const Icon(Icons.remove_red_eye_outlined, size: 16),
                  label: const Text('Anteprima TXT'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SkyTheme.timBlue,
                    side: const BorderSide(color: SkyTheme.timBlue),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _importDirectlyToDatabase,
                  icon: const Icon(Icons.save_alt, size: 16),
                  label: const Text('Importa in DB'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade700),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _exportTxtFile,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Scarica Tracciato (.txt)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SkyTheme.timBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickAndProcessExcel,
                icon: const Icon(Icons.upload_file, size: 16),
                label: Text(
                  _generatorResult == null ? 'Carica File Excel' : 'Altro File',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _generatorResult == null
                      ? SkyTheme.timBlue
                      : Colors.grey.shade800,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDropzone(ThemeData theme) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(maxWidth: 620),
        padding: const EdgeInsets.all(40),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _isDragging
              ? SkyTheme.timBlue.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isDragging ? SkyTheme.timBlue : Colors.grey.shade300,
            width: _isDragging ? 2.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isDragging
                  ? SkyTheme.timBlue.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: _isDragging ? 24 : 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _isDragging
                    ? SkyTheme.timBlue.withValues(alpha: 0.15)
                    : SkyTheme.timBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isDragging
                    ? Icons.file_download_rounded
                    : Icons.upload_file_rounded,
                size: 48,
                color: SkyTheme.timBlue,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isDragging
                  ? 'Rilascia il file Excel qui'
                  : 'Carica o trascina il file Excel di Input',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _isDragging ? SkyTheme.timBlue : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trascina e rilascia qui il file .xlsx o .xls, oppure utilizza il pulsante sottostante per selezionarlo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickAndProcessExcel,
              style: ElevatedButton.styleFrom(
                backgroundColor: SkyTheme.timBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text(
                'SELEZIONA FILE EXCEL',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Supporta drag & drop per file .xlsx e .xls • Specifiche SAP R/3 SBT',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent({
    required ThemeData theme,
    required int totalFiltered,
    required int totalPages,
    required int safePage,
    required int startIndex,
    required int endIndex,
    required List<GeneratedTracciatoRecord> pageRecords,
  }) {
    final res = _generatorResult!;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat Cards
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'TOTALE RECORD',
                  value: '${res.totalRecords}',
                  subtitle: '${res.uniqueTrasferteCount} trasferte • ${res.uniqueCidCount} dipendenti',
                  icon: Icons.format_list_numbered,
                  iconColor: SkyTheme.timBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'ADDEBITI',
                  value: _formatAmount(res.totalPositiveAmount),
                  subtitle: '${res.records.where((r) => !r.isNegative).length} righe addebito',
                  icon: Icons.trending_up,
                  iconColor: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'RIMBORSI / ANNULLAMENTI',
                  value: _formatAmount(res.totalNegativeAmount),
                  subtitle: '${res.records.where((r) => r.isNegative).length} righe "R"',
                  icon: Icons.trending_down,
                  iconColor: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'SALDO NETTO TRACCIATO',
                  value: _formatAmount(res.netAmount),
                  subtitle: 'Valuta EUR',
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters & Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                            _currentPage = 0;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Cerca per CID, Trasferta, Bolla o Località...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _currentPage = 0;
                                    });
                                  },
                                )
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Segno filter dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<SegnoFilter>(
                          value: _segnoFilter,
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() {
                              _segnoFilter = val;
                              _currentPage = 0;
                            });
                          },
                          items: const [
                            DropdownMenuItem(
                              value: SegnoFilter.tutti,
                              child: Text('Tutti i movimenti'),
                            ),
                            DropdownMenuItem(
                              value: SegnoFilter.soloAddebiti,
                              child: Text('Solo Addebiti'),
                            ),
                            DropdownMenuItem(
                              value: SegnoFilter.soloRimborsi,
                              child: Text('Solo Rimborsi (R)'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Società & Giustificativo Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Società:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    ...res.countBySocieta.keys.map((soc) {
                      final isSelected = _selectedSociete.contains(soc);
                      return FilterChip(
                        label: Text('$soc (${res.countBySocieta[soc]})'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSociete.add(soc);
                            } else {
                              _selectedSociete.remove(soc);
                            }
                            _currentPage = 0;
                          });
                        },
                        selectedColor: SkyTheme.timBlue.withValues(alpha: 0.15),
                        checkmarkColor: SkyTheme.timBlue,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? SkyTheme.timBlue : Colors.grey.shade800,
                        ),
                      );
                    }),
                    const SizedBox(width: 12),
                    const Text(
                      'Giustificativo:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    ...res.countByGiustificativo.keys.map((spk) {
                      final isSelected = _selectedGiustificativi.contains(spk);
                      return FilterChip(
                        label: Text('$spk (${res.countByGiustificativo[spk]})'),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedGiustificativi.add(spk);
                            } else {
                              _selectedGiustificativi.remove(spk);
                            }
                            _currentPage = 0;
                          });
                        },
                        selectedColor: Colors.purple.withValues(alpha: 0.15),
                        checkmarkColor: Colors.purple,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.purple.shade800 : Colors.grey.shade800,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Records Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Righe Tracciato ($totalFiltered di ${res.totalRecords})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Pagina ${safePage + 1} di ${totalPages == 0 ? 1 : totalPages} (50 elementi per pagina)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 1000),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Colors.grey.shade50,
                        ),
                        headingTextStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                        dataRowMinHeight: 44,
                        dataRowMaxHeight: 48,
                        columns: const [
                          DataColumn(label: Text('#')),
                          DataColumn(label: Text('CID')),
                          DataColumn(label: Text('N° TRASFERTA')),
                          DataColumn(label: Text('PROG')),
                          DataColumn(label: Text('SOCIETÀ')),
                          DataColumn(label: Text('TIPO DIP')),
                          DataColumn(label: Text('GIUST.')),
                          DataColumn(label: Text('N° BOLLA')),
                          DataColumn(label: Text('DATA SPESA')),
                          DataColumn(label: Text('LOCALITÀ / TRATTA')),
                          DataColumn(label: Text('IMPORTO')),
                          DataColumn(label: Text('TIPO')),
                        ],
                        rows: pageRecords.map((r) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  '${r.index}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  r.cid,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(Text(r.numeroTrasferta, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(r.receiptNo, style: const TextStyle(fontSize: 12))),
                              DataCell(Text(r.bukrs, style: const TextStyle(fontSize: 12))),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    r.persk,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: SkyTheme.timBlue.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    r.spkzl,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: SkyTheme.timBlue,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(r.bolla, style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
                              DataCell(Text(r.dataSpesaFormatted, style: const TextStyle(fontSize: 12))),
                              DataCell(
                                SizedBox(
                                  width: 220,
                                  child: Text(
                                    r.localita,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  _formatAmount(r.importo),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: r.isNegative ? Colors.orange.shade800 : Colors.black87,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: r.isNegative
                                        ? Colors.orange.shade50
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: r.isNegative
                                          ? Colors.orange.shade200
                                          : Colors.green.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    r.isNegative ? 'Rimborso (R)' : 'Addebito',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: r.isNegative
                                          ? Colors.orange.shade800
                                          : Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1),
                // Pagination Footer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        totalFiltered == 0
                            ? 'Nessun record'
                            : 'Mostrati ${startIndex + 1} - $endIndex di $totalFiltered record',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: safePage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                          ),
                          Text(
                            '${safePage + 1} / ${totalPages == 0 ? 1 : totalPages}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: safePage < totalPages - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.grey,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
