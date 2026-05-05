import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';

final _defaultDate = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
final selectedMonthProvider = StateProvider<String?>(
  (ref) => _defaultDate.month.toString().padLeft(2, '0'),
);
final selectedYearProvider = StateProvider<String?>((ref) => _defaultDate.year.toString());
final selectedTrasfertaProvider = StateProvider<String?>((ref) => null);
final selectedCidProvider = StateProvider<String?>((ref) => null);
final selectedSocietaProvider = StateProvider<String?>((ref) => null);
final sortAscendingProvider = StateProvider<bool>((ref) => false);

class AnalysisView extends ConsumerStatefulWidget {
  const AnalysisView({super.key});

  @override
  ConsumerState<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends ConsumerState<AnalysisView> {
  final _trasfertaController = TextEditingController();
  final _cidController = TextEditingController();

  @override
  void dispose() {
    _trasfertaController.dispose();
    _cidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(tracciatoContabilesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final selectedTrasferta = ref.watch(selectedTrasfertaProvider);
    final selectedSocieta = ref.watch(selectedSocietaProvider);
    final selectedCid = ref.watch(selectedCidProvider);
    final sortAscending = ref.watch(sortAscendingProvider);

    if (allRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
            ),
            const SizedBox(height: 16),
            Text(
              'NESSUN DATO CARICATO',
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

    // Estrai dati disponibili per i filtri
    final availableYears =
        allRecords
            .map((r) {
              final parts = r.dataSpesa.split('/');
              if (parts.length == 3) return parts[2];
              return '';
            })
            .where((y) => y.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final availableSocieta =
        allRecords
            .map((r) => r.societa)
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    const monthNames = {
      '01': 'Gennaio',
      '02': 'Febbraio',
      '03': 'Marzo',
      '04': 'Aprile',
      '05': 'Maggio',
      '06': 'Giugno',
      '07': 'Luglio',
      '08': 'Agosto',
      '09': 'Settembre',
      '10': 'Ottobre',
      '11': 'Novembre',
      '12': 'Dicembre',
    };

    // Filtra i record
    final records = allRecords.where((r) {
      final parts = r.dataSpesa.split('/');
      if (parts.length != 3) return false;
      final month = parts[1];
      final year = parts[2];

      if (selectedMonth != null && month != selectedMonth) return false;
      if (selectedYear != null && year != selectedYear) return false;
      if (selectedTrasferta != null &&
          !r.numeroTrasferta.contains(selectedTrasferta)) {
        return false;
      }
      if (selectedCid != null && !r.cid.contains(selectedCid)) {
        return false;
      }
      if (selectedSocieta != null && r.societa != selectedSocieta) return false;

      return true;
    }).toList()
      ..sort((a, b) {
        try {
          final partsA = a.dataSpesa.split('/');
          final dateA = DateTime(
            int.parse(partsA[2]),
            int.parse(partsA[1]),
            int.parse(partsA[0]),
          );
          final partsB = b.dataSpesa.split('/');
          final dateB = DateTime(
            int.parse(partsB[2]),
            int.parse(partsB[1]),
            int.parse(partsB[0]),
          );
          return sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

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
                  Text(
                    'TRACCIATO CONTABILE',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w200,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Visualizzazione tracciato contabile UVET',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              Row(
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${records.length} Record trovati',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Sezione Filtri
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Filtro Mese
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: selectedMonth,
                    hint: const Text('Tutti i Mesi'),
                    icon: const Icon(Icons.calendar_month, size: 20),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tutti i Mesi'),
                      ),
                      ...monthNames.entries.map(
                        (e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        ref.read(selectedMonthProvider.notifier).state = value,
                  ),
                ),
              ),
              // Filtro Anno
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: selectedYear,
                    hint: const Text('Tutti gli Anni'),
                    icon: const Icon(Icons.date_range, size: 20),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tutti gli Anni'),
                      ),
                      ...availableYears.map(
                        (y) => DropdownMenuItem(value: y, child: Text(y)),
                      ),
                    ],
                    onChanged: (value) =>
                        ref.read(selectedYearProvider.notifier).state = value,
                  ),
                ),
              ),
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
                    onChanged: (value) =>
                        ref.read(selectedSocietaProvider.notifier).state =
                            value,
                  ),
                ),
              ),
              // Filtro Trasferta (Input testo)
              SizedBox(
                width: 220,
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
                  onChanged: (value) =>
                      ref.read(selectedTrasfertaProvider.notifier).state =
                          value.isEmpty ? null : value,
                ),
              ),
              // Filtro CID (Input testo)
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
                  onChanged: (value) =>
                      ref.read(selectedCidProvider.notifier).state = 
                          value.isEmpty ? null : value,
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
                  tooltip: sortAscending ? 'Dal meno recente' : 'Dal più recente',
                  icon: Icon(
                    sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => ref.read(sortAscendingProvider.notifier).state = !sortAscending,
                ),
              ),
              // Pulsante Reset Filtri
              if (selectedMonth != null ||
                  selectedYear != null ||
                  selectedTrasferta != null ||
                  selectedSocieta != null ||
                  selectedCid != null)
                TextButton.icon(
                  onPressed: () {
                    ref.read(selectedMonthProvider.notifier).state = null;
                    ref.read(selectedYearProvider.notifier).state = null;
                    ref.read(selectedTrasfertaProvider.notifier).state = null;
                    ref.read(selectedSocietaProvider.notifier).state = null;
                    ref.read(selectedCidProvider.notifier).state = null;
                    _trasfertaController.clear();
                    _cidController.clear();
                  },
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Reset Filtri'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                ),
              if (records.isNotEmpty) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _exportToExcel(records),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Esporta Excel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
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
                    width: 1320,
                    child: Column(
                      children: [
                        // Intestazione fissa
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
                              _buildCell('CID', 100, isHeader: true),
                              _buildCell('TRASFERTA', 120, isHeader: true),
                              _buildCell('BOLLA', 150, isHeader: true),
                              _buildCell('SOCIETÀ', 100, isHeader: true),
                              _buildCell('DATA SPESA', 120, isHeader: true),
                              _buildCell('DATA INIZIO', 120, isHeader: true),
                              _buildCell('DATA FINE', 120, isHeader: true),
                              _buildCell('LOCALITÀ', 170, isHeader: true),
                              _buildCell('IMPORTO', 140, isHeader: true),
                              _buildCell('SEGNO', 80, isHeader: true),
                              _buildCell('AZIONI', 100, isHeader: true, alignment: Alignment.center),
                            ],
                          ),
                        ),
                        // Corpo scrollabile
                        Expanded(
                          child: ListView.builder(
                            itemCount: records.length,
                            itemBuilder: (context, index) {
                              final record = records[index];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade100,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _buildCell(
                                      record.cid,
                                      100,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    _buildCell(record.numeroTrasferta, 120),
                                    _buildCell(record.numeroBolla, 150),
                                    _buildCell(record.societa, 100),
                                    _buildCell(record.dataSpesa, 120),
                                    _buildCell(record.dataInizio, 120),
                                    _buildCell(record.dataFine, 120),
                                    _buildCell(record.localita, 170),
                                    _buildCell(
                                      '${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}',
                                      140,
                                      color: record.isNegative
                                          ? Colors.red.shade700
                                          : Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    _buildCell(
                                      '',
                                      80,
                                      child: Icon(
                                        record.isNegative
                                            ? Icons.remove_circle_outline
                                            : Icons.add_circle_outline,
                                        color: record.isNegative
                                            ? Colors.red.shade300
                                            : Colors.green.shade300,
                                        size: 18,
                                      ),
                                    ),
                                    _buildCell(
                                      '',
                                      100,
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20),
                                            onPressed: () => _showRecordDetails(context, record),
                                            tooltip: 'Visualizza dettagli',
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Elimina Record'),
                                              content: const Text('Sei sicuro di voler eliminare questo record?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('Annulla'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    ref.read(tracciatoContabilesProvider.notifier).deleteRecord(record.id);
                                                    Navigator.of(context).pop();
                                                  },
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                                                  child: const Text('Elimina', style: TextStyle(color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        tooltip: 'Elimina record',
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
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
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Svuota Tracciato Contabile'),
        content: const Text(
          'Sei sicuro di voler eliminare definitivamente tutti i record caricati? Questa operazione non è reversibile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(tracciatoContabilesProvider.notifier).clear();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dati eliminati con successo')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, TracciatoContabile record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Dettaglio Record - ${record.numeroBolla}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('CID', record.cid),
                  _buildDetailRow('Trasferta', record.numeroTrasferta),
                  _buildDetailRow('Progressivo', record.progressivo),
                  _buildDetailRow('Società', record.societa),
                  _buildDetailRow('Tipo Dipendente', record.tipoDipendente),
                  _buildDetailRow('Giustificativo', record.giustificativoSpesa),
                  _buildDetailRow('Numero Bolla', record.numeroBolla),
                  _buildDetailRow('Data Spesa', record.dataSpesa),
                  _buildDetailRow('Località', record.localita),
                  _buildDetailRow('Inizio', '${record.dataInizio} ${record.oraInizio}'),
                  _buildDetailRow('Fine', '${record.dataFine} ${record.oraFine}'),
                  _buildDetailRow('Tipo Attività', record.tipoAttivita),
                  _buildDetailRow('Importo', '${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}', isHighlight: true),
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

  Future<void> _exportToExcel(List<TracciatoContabile> records) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Tracciato'];
      excel.setDefaultSheet('Tracciato');
      
      // Header
      sheet.appendRow([
        TextCellValue('CID'),
        TextCellValue('Trasferta'),
        TextCellValue('Progressivo'),
        TextCellValue('Società'),
        TextCellValue('Tipo Dipendente'),
        TextCellValue('Giustificativo Spesa'),
        TextCellValue('Numero Bolla'),
        TextCellValue('Data Spesa'),
        TextCellValue('Località'),
        TextCellValue('Data Inizio'),
        TextCellValue('Ora Inizio'),
        TextCellValue('Data Fine'),
        TextCellValue('Ora Fine'),
        TextCellValue('Tipo Attività'),
        TextCellValue('Importo'),
        TextCellValue('Valuta'),
        TextCellValue('Segno'),
      ]);

      // Dati
      for (final r in records) {
        final amountValue = r.isNegative ? -r.importo : r.importo;
        sheet.appendRow([
          TextCellValue(r.cid),
          TextCellValue(r.numeroTrasferta),
          TextCellValue(r.progressivo),
          TextCellValue(r.societa),
          TextCellValue(r.tipoDipendente),
          TextCellValue(r.giustificativoSpesa),
          TextCellValue(r.numeroBolla),
          TextCellValue(r.dataSpesa),
          TextCellValue(r.localita),
          TextCellValue(r.dataInizio),
          TextCellValue(r.oraInizio),
          TextCellValue(r.dataFine),
          TextCellValue(r.oraFine),
          TextCellValue(r.tipoAttivita),
          DoubleCellValue(amountValue),
          TextCellValue(r.valuta),
          TextCellValue(r.isNegative ? 'R' : ''),
        ]);
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva Export Excel',
        fileName: 'export_tracciato_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Esportazione completata con successo!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'esportazione: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? Colors.green.shade700 : Colors.black87,
                fontSize: 14,
              ),
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
      child:
          child ??
          Text(
            text,
            style: TextStyle(
              fontWeight:
                  fontWeight ??
                  (isHeader ? FontWeight.bold : FontWeight.normal),
              fontSize: isHeader ? 13 : 14,
              color:
                  color ??
                  (isHeader
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black87),
              letterSpacing: isHeader ? 0.5 : 0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
    );
  }
}
