import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/core/theme/app_theme.dart';

// Filter providers for Estratti Conto
final ecSelectedTrasfertaProvider = StateProvider<String?>((ref) => null);
final ecSelectedCidProvider = StateProvider<String?>((ref) => null);
final ecSelectedSocietaProvider = StateProvider<String?>((ref) => null);
final ecSelectedBollaProvider = StateProvider<String?>((ref) => null);
final ecSortAscendingProvider = StateProvider<bool>((ref) => false);
final ecPageProvider = StateProvider<int>((ref) => 0);

class EstrattiContoView extends ConsumerStatefulWidget {
  const EstrattiContoView({super.key});

  @override
  ConsumerState<EstrattiContoView> createState() => _EstrattiContoViewState();
}

class _EstrattiContoViewState extends ConsumerState<EstrattiContoView> {
  final _trasfertaController = TextEditingController();
  final _cidController = TextEditingController();
  final _bollaController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _trasfertaController.dispose();
    _cidController.dispose();
    _bollaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(estrattoContoProvider);
    final selectedTrasferta = ref.watch(ecSelectedTrasfertaProvider);
    final selectedCid = ref.watch(ecSelectedCidProvider);
    final selectedSocieta = ref.watch(ecSelectedSocietaProvider);
    final selectedBolla = ref.watch(ecSelectedBollaProvider);
    final sortAscending = ref.watch(ecSortAscendingProvider);
    final currentPage = ref.watch(ecPageProvider);
    const pageSize = 100;

    if (allRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
            ),
            const SizedBox(height: 16),
            Text(
              'NESSUN ESTRATTO CONTO CARICATO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w200,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Vai nella sezione "Carica File" per iniziare.'),
          ],
        ),
      );
    }

    // Estrai società disponibili per il filtro
    final availableSocieta = allRecords
        .map((r) => r.ragioneSociale)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      if (selectedTrasferta != null &&
          !r.numeroTrasferta.toLowerCase().contains(selectedTrasferta.toLowerCase())) {
        return false;
      }
      if (selectedCid != null && !r.cid.toLowerCase().contains(selectedCid.toLowerCase())) {
        return false;
      }
      if (selectedSocieta != null && r.ragioneSociale != selectedSocieta) {
        return false;
      }
      if (selectedBolla != null && !r.bolla.toLowerCase().contains(selectedBolla.toLowerCase())) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) {
        // Ordinamento per CID di default se non diversamente specificato
        return sortAscending ? a.cid.compareTo(b.cid) : b.cid.compareTo(a.cid);
      });

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize) > filteredRecords.length
        ? filteredRecords.length
        : (startIndex + pageSize);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final headerContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTRATTI CONTO',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w200,
                          letterSpacing: 2.0,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Visualizzazione estratti conto bancari',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              );

              final actionsContent = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showClearDialog(context, ref),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Svuota Dati'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (filteredRecords.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _exportToExcel(filteredRecords),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Esporta Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                ],
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: headerContent),
                    actionsContent,
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerContent,
                    const SizedBox(height: 16),
                    actionsContent,
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          // Sezione Filtri
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Filtro Società
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: selectedSocieta,
                    hint: const Text('Tutte le Società'),
                    icon: const Icon(Icons.business, size: 20),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tutte le Società'),
                      ),
                      ...availableSocieta.map(
                        (s) => DropdownMenuItem(value: s, child: Text(s)),
                      ),
                    ],
                    onChanged: (value) {
                      ref.read(ecSelectedSocietaProvider.notifier).state = value;
                      ref.read(ecPageProvider.notifier).state = 0;
                    },
                  ),
                ),
              ),
              // Filtro Trasferta
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _trasfertaController,
                  decoration: InputDecoration(
                    hintText: 'Cerca Trasferta...',
                    prefixIcon: const Icon(Icons.flight_takeoff, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(ecSelectedTrasfertaProvider.notifier).state =
                        value.isEmpty ? null : value;
                    ref.read(ecPageProvider.notifier).state = 0;
                  },
                ),
              ),
              // Filtro CID
              SizedBox(
                width: 150,
                child: TextField(
                  controller: _cidController,
                  decoration: InputDecoration(
                    hintText: 'Cerca CID...',
                    prefixIcon: const Icon(Icons.badge, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(ecSelectedCidProvider.notifier).state =
                        value.isEmpty ? null : value;
                    ref.read(ecPageProvider.notifier).state = 0;
                  },
                ),
              ),
              // Filtro Bolla
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _bollaController,
                  decoration: InputDecoration(
                    hintText: 'Cerca Bolla...',
                    prefixIcon: const Icon(Icons.receipt_long_outlined, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(ecSelectedBollaProvider.notifier).state =
                        value.isEmpty ? null : value;
                    ref.read(ecPageProvider.notifier).state = 0;
                  },
                ),
              ),
              // Ordinamento
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  tooltip: sortAscending ? 'Crescente' : 'Decrescente',
                  icon: Icon(
                    sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () =>
                      ref.read(ecSortAscendingProvider.notifier).state = !sortAscending,
                ),
              ),
              // Pulsante Reset
              if (selectedTrasferta != null ||
                  selectedCid != null ||
                  selectedSocieta != null ||
                  selectedBolla != null)
                TextButton.icon(
                  onPressed: () {
                    ref.read(ecSelectedTrasfertaProvider.notifier).state = null;
                    ref.read(ecSelectedCidProvider.notifier).state = null;
                    ref.read(ecSelectedSocietaProvider.notifier).state = null;
                    ref.read(ecSelectedBollaProvider.notifier).state = null;
                    ref.read(ecPageProvider.notifier).state = 0;
                    _trasfertaController.clear();
                    _cidController.clear();
                    _bollaController.clear();
                  },
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Reset Filtri'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1300, // Larghezza calcolata per le nuove colonne
                    child: Column(
                      children: [
                        // Intestazione
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildCell('CID', 120, isHeader: true),
                              _buildCell('TRASFERTA', 150, isHeader: true),
                              _buildCell('TIPO SERVIZIO', 150, isHeader: true),
                              _buildCell('BOLLA', 150, isHeader: true),
                              _buildCell('SOCIETÀ', 250, isHeader: true),
                              _buildCell('DATA BOLLA', 120, isHeader: true),
                              _buildCell('DATA COMP.', 140, isHeader: true),
                              _buildCell('TOTALE', 100, isHeader: true),
                              _buildCell('AZIONI', 120, isHeader: true, alignment: Alignment.center),
                            ],
                          ),
                        ),
                        // Lista Record
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            itemCount: paginatedRecords.length,
                            itemBuilder: (context, index) {
                              final record = paginatedRecords[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey.shade100),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildCell(record.cid, 120, fontWeight: FontWeight.w500),
                                    _buildCell(record.numeroTrasferta, 150),
                                    _buildCell(record.tipoServizio, 150),
                                    _buildCell(record.bolla, 150),
                                    _buildCell(record.ragioneSociale, 250),
                                    _buildCell(record.dataBolla, 120),
                                    _buildCell(record.dataCompetenza, 140),
                                    _buildCell(
                                      '${record.totaleServizio.toStringAsFixed(2)} €',
                                      100,
                                      fontWeight: FontWeight.bold,
                                      color: record.totaleServizio < 0
                                          ? Colors.red.shade700
                                          : Colors.green.shade800,
                                    ),
                                    _buildCell(
                                      '',
                                      120,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20),
                                            onPressed: () => _showRecordDetails(context, record),
                                            tooltip: 'Visualizza dettagli',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            onPressed: () => _showDeleteDialog(context, ref, record),
                                            tooltip: 'Elimina record',
                                          ),
                                        ],
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
          // Paginazione
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage > 0
                        ? () => ref.read(ecPageProvider.notifier).state--
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    'Pagina ${currentPage + 1} di $totalPages',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: currentPage < totalPages - 1
                        ? () => ref.read(ecPageProvider.notifier).state++
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
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
    Widget? child,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: alignment,
      child: child ??
          Text(
            text,
            style: TextStyle(
              fontWeight: fontWeight ?? (isHeader ? FontWeight.bold : FontWeight.normal),
              fontSize: isHeader ? 13 : 14,
              color: color ?? (isHeader ? Theme.of(context).colorScheme.primary : Colors.black87),
              letterSpacing: isHeader ? 0.5 : 0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Svuota Database'),
        content: const Text('Sei sicuro di voler eliminare TUTTI i record degli estratti conto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(estrattoContoProvider.notifier).clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Svuota', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, EstrattoConto record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Record'),
        content: const Text('Sei sicuro di voler eliminare questo record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(estrattoContoProvider.notifier).deleteRecord(record.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, EstrattoConto record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Dettaglio Estratto Conto - ${record.bolla}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('CID', record.cid),
                  _buildDetailRow('Trasferta', record.numeroTrasferta),
                  _buildDetailRow('Bolla', record.bolla),
                  _buildDetailRow('NR Bolla', record.nrBolla),
                  _buildDetailRow('Data Bolla', record.dataBolla),
                  _buildDetailRow('Data Competenza', record.dataCompetenza),
                  _buildDetailRow('Società', record.ragioneSociale),
                  _buildDetailRow('Tipo Servizio', record.tipoServizio),
                  _buildDetailRow('Descrizione', record.descrizioneServizio),
                  _buildDetailRow('Itinerario', record.itinerario),
                  _buildDetailRow('Fornitore', record.fornitore),
                  _buildDetailRow('Passeggero', record.nomePasseggero),
                  _buildDetailRow('Importo Servizio', '${record.importoServizio.toStringAsFixed(2)} €'),
                  _buildDetailRow('Tasse', '${record.tasse.toStringAsFixed(2)} €'),
                  _buildDetailRow('Fee', '${record.fee.toStringAsFixed(2)} €'),
                  _buildDetailRow('Totale Servizio', '${record.totaleServizio.toStringAsFixed(2)} €', isHighlight: true),
                  _buildDetailRow('Località Partenza', record.localitaPartenza),
                  _buildDetailRow('Località Arrivo', record.localitaArrivo),
                  _buildDetailRow('Data In', record.dataIn),
                  _buildDetailRow('Data Out', record.dataOut),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? SkyTheme.timBlue : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel(List<EstrattoConto> records) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['EstrattiConto'];
      excel.delete('Sheet1');

      sheet.appendRow([
        TextCellValue('CID'),
        TextCellValue('Trasferta'),
        TextCellValue('Tipo Servizio'),
        TextCellValue('Bolla'),
        TextCellValue('Società'),
        TextCellValue('Totale'),
      ]);

      for (final r in records) {
        sheet.appendRow([
          TextCellValue(r.cid),
          TextCellValue(r.numeroTrasferta),
          TextCellValue(r.tipoServizio),
          TextCellValue(r.bolla),
          TextCellValue(r.ragioneSociale),
          DoubleCellValue(r.totaleServizio),
        ]);
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva Export Excel',
        fileName: 'export_estratti_conto_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esportazione completata con successo!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore durante l\'esportazione: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
