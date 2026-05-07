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

    final activeFiltersCount = [
      selectedTrasferta != null,
      selectedCid != null,
      selectedSocieta != null,
      selectedBolla != null,
    ].where((e) => e).length;

    // Estrai società disponibili per il filtro
    final availableSocieta = allRecords
        .map((r) => r.ragioneSociale)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      if (selectedTrasferta != null && !r.numeroTrasferta.toLowerCase().contains(selectedTrasferta.toLowerCase())) return false;
      if (selectedCid != null && !r.cid.toLowerCase().contains(selectedCid.toLowerCase())) return false;
      if (selectedSocieta != null && r.ragioneSociale != selectedSocieta) return false;
      if (selectedBolla != null && !r.bolla.toLowerCase().contains(selectedBolla.toLowerCase())) return false;
      return true;
    }).toList()
      ..sort((a, b) {
        return sortAscending ? a.cid.compareTo(b.cid) : b.cid.compareTo(a.cid);
      });

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize) > filteredRecords.length ? filteredRecords.length : (startIndex + pageSize);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableSocieta),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideHeader = constraints.maxWidth > 800;
                    final headerContent = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ESTRATTI CONTO', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w200, letterSpacing: 2.0)),
                        const SizedBox(height: 4),
                        Text('Visualizzazione estratti conto bancari', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                    );
                    final actionsContent = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () => _showClearDialog(context, ref),
                          icon: const Icon(Icons.delete_sweep_outlined, size: 20),
                          label: const Text('Svuota Dati'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                        ),
                        const SizedBox(width: 12),
                        if (filteredRecords.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () => _exportToExcel(filteredRecords),
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Esporta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                      ],
                    );
                    return isWideHeader ? Row(children: [Expanded(child: headerContent), actionsContent]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [headerContent, const SizedBox(height: 16), actionsContent]);
                  },
                ),
                const SizedBox(height: 24),
                // SEARCHBAR & FILTER BUTTON
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _trasfertaController,
                                decoration: const InputDecoration(hintText: 'Cerca per trasferta...', border: InputBorder.none, isDense: true),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  ref.read(ecSelectedTrasfertaProvider.notifier).state = value.isEmpty ? null : value;
                                  ref.read(ecPageProvider.notifier).state = 0;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Builder(
                      builder: (context) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => Scaffold.of(context).openEndDrawer(),
                            icon: const Icon(Icons.filter_list_rounded),
                            label: const Text('Filtri'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: activeFiltersCount > 0 ? SkyTheme.timBlue : Colors.grey.shade300),
                              foregroundColor: activeFiltersCount > 0 ? SkyTheme.timBlue : Colors.grey.shade700,
                            ),
                          ),
                          if (activeFiltersCount > 0)
                            Positioned(
                              top: -8, right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: SkyTheme.timBlue, shape: BoxShape.circle),
                                child: Text('$activeFiltersCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                // ACTIVE FILTER CHIPS
                if (activeFiltersCount > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (selectedSocieta != null) _buildFilterChip('Società: $selectedSocieta', () => ref.read(ecSelectedSocietaProvider.notifier).state = null),
                        if (selectedCid != null) _buildFilterChip('CID: $selectedCid', () { _cidController.clear(); ref.read(ecSelectedCidProvider.notifier).state = null; }),
                        if (selectedBolla != null) _buildFilterChip('Bolla: $selectedBolla', () { _bollaController.clear(); ref.read(ecSelectedBollaProvider.notifier).state = null; }),
                        TextButton(onPressed: () => _resetAllFilters(ref), child: const Text('Reset tutto', style: TextStyle(fontSize: 12, color: Colors.red))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // MAIN TABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 15, offset: const Offset(0, 5))]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1300,
                      child: Column(
                        children: [
                          Container(
                            height: 56,
                            decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
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
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: paginatedRecords.length,
                            itemBuilder: (context, index) {
                              final record = paginatedRecords[index];
                              return Container(
                                decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade100))),
                                child: Row(
                                  children: [
                                    _buildCell(record.cid, 120, fontWeight: FontWeight.w500),
                                    _buildCell(record.numeroTrasferta, 150),
                                    _buildCell(record.tipoServizio, 150),
                                    _buildCell(record.bolla, 150),
                                    _buildCell(record.ragioneSociale, 250),
                                    _buildCell(record.dataBolla, 120),
                                    _buildCell(record.dataCompetenza, 140),
                                    _buildCell('${record.totaleServizio.toStringAsFixed(2)} €', 100, fontWeight: FontWeight.bold, color: record.totaleServizio < 0 ? Colors.red.shade700 : Colors.green.shade800),
                                    _buildCell('', 120, alignment: Alignment.center, child: Row(mainAxisSize: MainAxisSize.min, children: [
                                      IconButton(icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20), onPressed: () => _showRecordDetails(context, record), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                      const SizedBox(width: 12),
                                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _showDeleteDialog(context, ref, record), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                    ])),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // PAGINATION
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage > 0 ? () => ref.read(ecPageProvider.notifier).state-- : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('Pagina ${currentPage + 1} di $totalPages (${filteredRecords.length} record)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: currentPage < totalPages - 1 ? () => ref.read(ecPageProvider.notifier).state++ : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _resetAllFilters(WidgetRef ref) {
    ref.read(ecSelectedTrasfertaProvider.notifier).state = null;
    ref.read(ecSelectedCidProvider.notifier).state = null;
    ref.read(ecSelectedSocietaProvider.notifier).state = null;
    ref.read(ecSelectedBollaProvider.notifier).state = null;
    ref.read(ecPageProvider.notifier).state = 0;
    _trasfertaController.clear();
    _cidController.clear();
    _bollaController.clear();
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onDeleted: onDeleted,
        deleteIconColor: Colors.red.shade400,
        backgroundColor: SkyTheme.timBlue.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: SkyTheme.timBlue.withAlpha(50)),
      ),
    );
  }

  Widget _buildFilterDrawer(BuildContext context, WidgetRef ref, List<String> societa) {
    return Drawer(
      width: 350,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            color: const Color(0xFF001529),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_outlined, color: Colors.white),
                const SizedBox(width: 12),
                const Text('FILTRI AVANZATI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildDrawerSectionTitle('ANAGRAFICA'),
                const SizedBox(height: 12),
                _buildFilterDropdown<String?>('Società', ref.watch(ecSelectedSocietaProvider), societa, (val) => ref.read(ecSelectedSocietaProvider.notifier).state = val, icon: Icons.business),
                const SizedBox(height: 16),
                _buildDrawerTextField('Cerca per CID', _cidController, Icons.person_search, (val) => ref.read(ecSelectedCidProvider.notifier).state = val.isEmpty ? null : val),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('RIFERIMENTI'),
                const SizedBox(height: 12),
                _buildDrawerTextField('Numero Bolla', _bollaController, Icons.receipt_long, (val) => ref.read(ecSelectedBollaProvider.notifier).state = val.isEmpty ? null : val),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => _resetAllFilters(ref), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)), child: const Text('RESET FILTRI'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: SkyTheme.timBlue, foregroundColor: Colors.white), child: const Text('APPLICA'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SkyTheme.timBlue.withAlpha(150), letterSpacing: 1.2));
  }

  Widget _buildDrawerTextField(String hint, TextEditingController controller, IconData? icon, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(hintText: hint, icon: icon != null ? Icon(icon, size: 18, color: Colors.grey) : null, border: InputBorder.none, isDense: true),
        style: const TextStyle(fontSize: 14),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFilterDropdown<T>(String label, T value, List<T> items, Function(T) onChanged, {IconData? icon, String Function(T)? labelMapper}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(label, style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          icon: Icon(icon ?? Icons.arrow_drop_down, size: 20),
          items: [
            DropdownMenuItem<T>(value: null as T, child: Text('Tutti ($label)', style: const TextStyle(fontSize: 14))),
            ...items.map((item) => DropdownMenuItem<T>(value: item, child: Text(labelMapper != null ? labelMapper(item) : item.toString(), style: const TextStyle(fontSize: 14)))),
          ],
          onChanged: (val) { if (val != null || (null is T)) onChanged(val as T); },
        ),
      ),
    );
  }

  Widget _buildCell(String text, double width, {bool isHeader = false, Color? color, FontWeight? fontWeight, Alignment alignment = Alignment.centerLeft, Widget? child}) {
    return Container(
      width: width, height: 56, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: alignment,
      child: child ?? Text(text, style: TextStyle(fontSize: isHeader ? 11 : 13, fontWeight: isHeader ? FontWeight.bold : (fontWeight ?? FontWeight.normal), color: isHeader ? Colors.grey.shade700 : (color ?? Colors.black87), letterSpacing: isHeader ? 1.0 : null), overflow: TextOverflow.ellipsis),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Svuotamento'),
        content: const Text('Sei sicuro di voler eliminare tutti i dati degli estratti conto? questa azione non è reversibile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () async {
              ref.read(estrattoContoProvider.notifier).clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Svuota tutto'),
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
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
          title: Text('Dettaglio Estratto Conto - ${record.bolla}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  _buildDetailRow('Data Bolla', record.dataBolla),
                  _buildDetailRow('Società', record.ragioneSociale),
                  _buildDetailRow('Tipo Servizio', record.tipoServizio),
                  _buildDetailRow('Importo Servizio', '${record.importoServizio.toStringAsFixed(2)} €'),
                  _buildDetailRow('Fee', '${record.fee.toStringAsFixed(2)} €'),
                  _buildDetailRow('Totale Servizio', '${record.totaleServizio.toStringAsFixed(2)} €', isHighlight: true),
                ],
              ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Chiudi'))],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: TextStyle(color: isHighlight ? SkyTheme.timBlue : null, fontWeight: isHighlight ? FontWeight.bold : null))),
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
        TextCellValue('ID'),
        TextCellValue('Nr Estratto Conto'),
        TextCellValue('Nr Bolla'),
        TextCellValue('Bolla Calcolata'),
        TextCellValue('Data Bolla'),
        TextCellValue('Data Competenza'),
        TextCellValue('Codice Cliente'),
        TextCellValue('Ragione Sociale'),
        TextCellValue('Tipo Transazione'),
        TextCellValue('Tipo Servizio'),
        TextCellValue('Descrizione Servizio'),
        TextCellValue('Itinerario'),
        TextCellValue('Fornitore'),
        TextCellValue('Codice Viaggio'),
        TextCellValue('Nr Pax'),
        TextCellValue('Nr Tkt Bolla'),
        TextCellValue('Nome Passeggero'),
        TextCellValue('Met Pagamento Serv'),
        TextCellValue('Met Pagamento Fee'),
        TextCellValue('Importo Servizio'),
        TextCellValue('Tasse'),
        TextCellValue('Fee'),
        TextCellValue('Codice Iva'),
        TextCellValue('Iva Servizio'),
        TextCellValue('Iva Tasse'),
        TextCellValue('Iva Fee'),
        TextCellValue('Totale Servizio'),
        TextCellValue('Totale Tasse'),
        TextCellValue('Totale Servizio Generale'),
        TextCellValue('Totale Fee'),
        TextCellValue('Data In'),
        TextCellValue('Data Out'),
        TextCellValue('Località Partenza'),
        TextCellValue('Località Arrivo'),
        TextCellValue('Codice Trattamento'),
        TextCellValue('Codice Sistemazione'),
        TextCellValue('Richiedente'),
        TextCellValue('CID'),
        TextCellValue('Centro Costo'),
        TextCellValue('Numero Trasferta'),
        TextCellValue('Campo Statistico 4'),
        TextCellValue('Riga CRM'),
        TextCellValue('SAP NO SAP'),
        TextCellValue('Campo Statistico 7'),
        TextCellValue('Campo Statistico 8'),
        TextCellValue('Campo Statistico 9'),
        TextCellValue('Campo Statistico 10'),
        TextCellValue('Numero CC Servizio'),
        TextCellValue('Numero CC Fee'),
        TextCellValue('Numero Docum Servizio'),
        TextCellValue('Numero Docum Fee'),
        TextCellValue('Nr Notti'),
        TextCellValue('Segue Fattura Servizi'),
        TextCellValue('Servizio Da Pagare'),
        TextCellValue('Merchant Fee'),
        TextCellValue('Descrizione Spedire A'),
        TextCellValue('Descrizione Righe Pratiche'),
        TextCellValue('Riga File Originale'),
      ]);

      for (final r in records) {
        sheet.appendRow([
          IntCellValue(r.id),
          TextCellValue(r.nrEstrattoConto),
          TextCellValue(r.nrBolla),
          TextCellValue(r.bolla),
          TextCellValue(r.dataBolla),
          TextCellValue(r.dataCompetenza),
          TextCellValue(r.codiceCliente),
          TextCellValue(r.ragioneSociale),
          TextCellValue(r.tipoTransazione),
          TextCellValue(r.tipoServizio),
          TextCellValue(r.descrizioneServizio),
          TextCellValue(r.itinerario),
          TextCellValue(r.fornitore),
          TextCellValue(r.codiceViaggio),
          TextCellValue(r.nrPax),
          TextCellValue(r.nrTktBolla),
          TextCellValue(r.nomePasseggero),
          TextCellValue(r.metPagamentoServ),
          TextCellValue(r.metPagamentoFee),
          DoubleCellValue(r.importoServizio),
          DoubleCellValue(r.tasse),
          DoubleCellValue(r.fee),
          TextCellValue(r.codiceIva),
          DoubleCellValue(r.importoIvaServizio),
          DoubleCellValue(r.importoIvaTasse),
          DoubleCellValue(r.importoIvaFee),
          DoubleCellValue(r.totaleServizio),
          DoubleCellValue(r.totaleTasse),
          DoubleCellValue(r.totaleServizioGenerale),
          DoubleCellValue(r.totaleFee),
          TextCellValue(r.dataIn),
          TextCellValue(r.dataOut),
          TextCellValue(r.localitaPartenza),
          TextCellValue(r.localitaArrivo),
          TextCellValue(r.codiceTrattamento),
          TextCellValue(r.codiceSistemazione),
          TextCellValue(r.richiedente),
          TextCellValue(r.cid),
          TextCellValue(r.centroCosto),
          TextCellValue(r.numeroTrasferta),
          TextCellValue(r.campoStatistico4),
          TextCellValue(r.rigaCrm),
          TextCellValue(r.sapNoSap),
          TextCellValue(r.campoStatistico7),
          TextCellValue(r.campoStatistico8),
          TextCellValue(r.campoStatistico9),
          TextCellValue(r.campoStatistico10),
          TextCellValue(r.numeroCCServizio),
          TextCellValue(r.numeroCCFee),
          TextCellValue(r.numeroDocumServizio),
          TextCellValue(r.numeroDocumFee),
          TextCellValue(r.nrNotti),
          TextCellValue(r.segueFatturaServizi),
          TextCellValue(r.servizioDaPagare),
          DoubleCellValue(r.merchantFee),
          TextCellValue(r.descrizioneSpedireA),
          TextCellValue(r.descrizioneRighePratiche),
          IntCellValue(r.sourceFileLine ?? 0),
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
