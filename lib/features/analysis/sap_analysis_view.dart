import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';
import 'package:travel_check/core/theme/app_theme.dart';

// SAP Filter Providers
final sapMonthProvider = StateProvider<String?>((ref) => null);
final sapYearProvider = StateProvider<String?>((ref) => null);
final sapTrasfertaProvider = StateProvider<String?>((ref) => null);
final sapCidProvider = StateProvider<String?>((ref) => null);
final sapSocietaProvider = StateProvider<String?>((ref) => null);
final sapRichiestaProvider = StateProvider<String?>((ref) => null);
final sapPageProvider = StateProvider<int>((ref) => 0);
final sapSortAscendingProvider = StateProvider<bool>((ref) => false);

class SapAnalysisView extends ConsumerStatefulWidget {
  const SapAnalysisView({super.key});

  @override
  ConsumerState<SapAnalysisView> createState() => _SapAnalysisViewState();
}

class _SapAnalysisViewState extends ConsumerState<SapAnalysisView> {
  final _trasfertaController = TextEditingController();
  final _cidController = TextEditingController();
  final _richiestaController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _trasfertaController.dispose();
    _cidController.dispose();
    _richiestaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(tracciatoSapProvider);
    final selectedMonth = ref.watch(sapMonthProvider);
    final selectedYear = ref.watch(sapYearProvider);
    final selectedTrasferta = ref.watch(sapTrasfertaProvider);
    final selectedCid = ref.watch(sapCidProvider);
    final selectedRichiesta = ref.watch(sapRichiestaProvider);
    final selectedSocieta = ref.watch(sapSocietaProvider);
    final sortAscending = ref.watch(sapSortAscendingProvider);
    final currentPage = ref.watch(sapPageProvider);
    const pageSize = 100;

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
              'NESSUN DATO SAP CARICATO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w200,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Vai nella sezione "Carica File" per importare il tracciato SAP.'),
          ],
        ),
      );
    }

    final activeFiltersCount = [
      selectedMonth != null,
      selectedYear != null,
      selectedSocieta != null,
      selectedTrasferta != null,
      selectedCid != null,
      selectedRichiesta != null,
    ].where((e) => e).length;

    // Estrai anni disponibili (formato data SAP potrebbe variare, assumiamo DD.MM.YYYY o simile)
    final availableYears = allRecords.map((r) {
      final parts = r.data.split(RegExp(r'[./-]'));
      if (parts.length == 3) return parts[2];
      return '';
    }).where((y) => y.isNotEmpty).toSet().toList()..sort();

    final availableSocieta = allRecords.map((r) => r.societaCodice).where((s) => s.isNotEmpty).toSet().toList()..sort();

    const monthNames = {
      '01': 'Gennaio', '02': 'Febbraio', '03': 'Marzo', '04': 'Aprile',
      '05': 'Maggio', '06': 'Giugno', '07': 'Luglio', '08': 'Agosto',
      '09': 'Settembre', '10': 'Ottobre', '11': 'Novembre', '12': 'Dicembre',
    };

    final filteredRecords = allRecords.where((r) {
      final parts = r.data.split(RegExp(r'[./-]'));
      String? month, year;
      if (parts.length == 3) {
        month = parts[1].padLeft(2, '0');
        year = parts[2];
      }

      if (selectedMonth != null && month != selectedMonth) return false;
      if (selectedYear != null && year != selectedYear) return false;
      if (selectedTrasferta != null && !r.numeroTrasferta.contains(selectedTrasferta)) return false;
      if (selectedCid != null && !r.cid.contains(selectedCid)) return false;
      if (selectedSocieta != null && r.societaCodice != selectedSocieta) return false;
      if (selectedRichiesta != null && r.cdRichiesta != null && !r.cdRichiesta!.contains(selectedRichiesta)) return false;

      return true;
    }).toList()..sort((a, b) {
      try {
        final pA = a.data.split('/');
        final dA = DateTime(int.parse(pA[2]), int.parse(pA[1]), int.parse(pA[0]));
        final pB = b.data.split('/');
        final dB = DateTime(int.parse(pB[2]), int.parse(pB[1]), int.parse(pB[0]));
        return sortAscending ? dA.compareTo(dB) : dB.compareTo(dA);
      } catch (_) {
        return sortAscending ? a.data.compareTo(b.data) : b.data.compareTo(a.data);
      }
    });

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize) > filteredRecords.length ? filteredRecords.length : (startIndex + pageSize);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableYears, availableSocieta),
      floatingActionButton: filteredRecords.isNotEmpty 
          ? FloatingActionButton(
              onPressed: () => _exportToExcel(filteredRecords),
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              tooltip: 'Esporta in Excel',
              child: const Icon(Icons.table_view_rounded),
            )
          : null,
      body: Column(
        children: [
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox.shrink(),
                    Row(
                      children: [


                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                                  ref.read(sapTrasfertaProvider.notifier).state = value.isEmpty ? null : value;
                                  ref.read(sapPageProvider.notifier).state = 0;
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
                if (activeFiltersCount > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (selectedYear != null) _buildFilterChip('Anno: $selectedYear', () => ref.read(sapYearProvider.notifier).state = null),
                        if (selectedMonth != null) _buildFilterChip('Mese: ${monthNames[selectedMonth]}', () => ref.read(sapMonthProvider.notifier).state = null),
                        if (selectedSocieta != null) _buildFilterChip('Società: $selectedSocieta', () => ref.read(sapSocietaProvider.notifier).state = null),
                        if (selectedCid != null) _buildFilterChip('CID: $selectedCid', () { _cidController.clear(); ref.read(sapCidProvider.notifier).state = null; }),
                        if (selectedRichiesta != null) _buildFilterChip('Richiesta: $selectedRichiesta', () { _richiestaController.clear(); ref.read(sapRichiestaProvider.notifier).state = null; }),
                        TextButton(onPressed: () => _resetAllFilters(ref), child: const Text('Reset tutto', style: TextStyle(fontSize: 12, color: Colors.red))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                      width: 1120,
                      child: Column(
                        children: [
                          Container(
                            height: 56,
                            decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                            child: Row(
                              children: [
                                _buildCell('CID', 100, isHeader: true),
                                _buildCell('TRASFERTA', 120, isHeader: true),
                                _buildCell('DATA', 120, isHeader: true),
                                _buildCell('IMPORTO', 140, isHeader: true),
                                _buildCell('CD RICHIESTA', 150, isHeader: true),
                                _buildCell('CODICE STATO', 120, isHeader: true),
                                _buildCell('SOC. CODICE', 120, isHeader: true),
                                _buildCell('TIPO SPESA', 150, isHeader: true),
                                _buildCell('AZIONI', 100, isHeader: true, alignment: Alignment.center),
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
                                    _buildCell(record.cid, 100, fontWeight: FontWeight.w500),
                                    _buildCell(record.numeroTrasferta, 120),
                                    _buildCell(record.data, 120),
                                    _buildCell('${record.importo.toStringAsFixed(2)} ${record.valuta}', 140, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                    _buildCell(record.cdRichiesta ?? '-', 150),
                                    _buildCell(record.codiceStato ?? '-', 120),
                                    _buildCell(record.societaCodice, 120),
                                    _buildCell(record.tipoSpesaCodice, 150),
                                    _buildCell('', 100, alignment: Alignment.center, child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20), onPressed: () => _showRecordDetails(context, record), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                        const SizedBox(width: 8),
                                        IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _deleteRecord(context, ref, record), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                      ],
                                    )),
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
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: currentPage > 0 ? () {
                        ref.read(sapPageProvider.notifier).state--;
                        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pagina ${currentPage + 1} di $totalPages',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: currentPage < totalPages - 1 ? () {
                        ref.read(sapPageProvider.notifier).state++;
                        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      } : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Text(
                      'Totale record: ${filteredRecords.length}',
                      style: const TextStyle(
                        color: SkyTheme.timBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _resetAllFilters(WidgetRef ref) {
    ref.read(sapMonthProvider.notifier).state = null;
    ref.read(sapYearProvider.notifier).state = null;
    ref.read(sapTrasfertaProvider.notifier).state = null;
    ref.read(sapCidProvider.notifier).state = null;
    ref.read(sapSocietaProvider.notifier).state = null;
    ref.read(sapRichiestaProvider.notifier).state = null;
    ref.read(sapPageProvider.notifier).state = 0;
    _trasfertaController.clear();
    _cidController.clear();
    _richiestaController.clear();
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onDeleted: onDeleted,
        backgroundColor: SkyTheme.timBlue.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildFilterDrawer(BuildContext context, WidgetRef ref, List<String> years, List<String> societa) {
    final monthNames = {
      '01': 'Gennaio', '02': 'Febbraio', '03': 'Marzo', '04': 'Aprile',
      '05': 'Maggio', '06': 'Giugno', '07': 'Luglio', '08': 'Agosto',
      '09': 'Settembre', '10': 'Ottobre', '11': 'Novembre', '12': 'Dicembre',
    };
    return Drawer(
      width: 350,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            color: const Color(0xFF001529),
            child: const Row(
              children: [
                Icon(Icons.filter_alt_outlined, color: Colors.white),
                SizedBox(width: 12),
                Text('FILTRI SAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildFilterDropdown<String?>('Seleziona Anno', ref.watch(sapYearProvider), years, (val) => ref.read(sapYearProvider.notifier).state = val, icon: Icons.calendar_today),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Seleziona Mese', ref.watch(sapMonthProvider), monthNames.keys.toList(), (val) => ref.read(sapMonthProvider.notifier).state = val, icon: Icons.calendar_month, labelMapper: (val) => monthNames[val] ?? val ?? ''),
                const SizedBox(height: 24),
                _buildFilterDropdown<String?>('Società', ref.watch(sapSocietaProvider), societa, (val) => ref.read(sapSocietaProvider.notifier).state = val, icon: Icons.business),
                const SizedBox(height: 16),
                _buildDrawerTextField('Cerca per CID', _cidController, Icons.person_search, (val) => ref.read(sapCidProvider.notifier).state = val.isEmpty ? null : val),
                const SizedBox(height: 16),
                _buildDrawerTextField('CD Richiesta', _richiestaController, Icons.receipt_long, (val) => ref.read(sapRichiestaProvider.notifier).state = val.isEmpty ? null : val),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => _resetAllFilters(ref), child: const Text('RESET'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: SkyTheme.timBlue, foregroundColor: Colors.white), child: const Text('APPLICA'))),
              ],
            ),
          ),
        ],
      ),
    );
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

  Widget _buildDetailSection(String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 0, 12),
          child: Row(
            children: [
              Icon(icon, size: 14, color: color.withAlpha(180)),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color.withAlpha(180),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
    Color? highlightColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                color: isHighlight ? (highlightColor ?? Colors.green.shade700) : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, TracciatoSap record) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade700, Colors.green.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DETTAGLIO RECORD SAP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Trasferta n. ${record.numeroTrasferta}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(20),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // CONTENT
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildDetailSection('Dipendente', Icons.person_outline, Colors.green.shade700, [
                          _buildDetailRow('CID', record.cid),
                          _buildDetailRow('Nome', record.nomeDipendente),
                          _buildDetailRow('Tipo', record.tipoDipendente),
                          _buildDetailRow('Classe Retr.', record.classeRetributiva),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Società e Trasferta', Icons.business_outlined, Colors.green.shade700, [
                          _buildDetailRow('Società', '${record.societaDescrizione} (${record.societaCodice})'),
                          _buildDetailRow('Trasferta', record.numeroTrasferta),
                          _buildDetailRow('Data', record.data),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Spesa e Contabilità', Icons.payments_outlined, Colors.green.shade700, [
                          _buildDetailRow('Tipo Spesa', '${record.tipoSpesaDescrizione} (${record.tipoSpesaCodice})'),
                          _buildDetailRow('Importo', '${record.importo.toStringAsFixed(2)} ${record.valuta}', isHighlight: true, highlightColor: Colors.green.shade700),
                          _buildDetailRow('Stato SAP', record.codiceStato ?? '-'),
                          _buildDetailRow('Richiesta CD', record.cdRichiesta ?? '-'),
                          _buildDetailRow('Codice FI', record.fi ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Altri Dati SAP', Icons.data_usage_outlined, Colors.green.shade700, [
                          _buildDetailRow('RI/TR', record.riTr ?? '-'),
                          _buildDetailRow('Calc', record.calc ?? '-'),
                          _buildDetailRow('Trasf. FI', record.codiceTrasferimentoFi ?? '-'),
                          _buildDetailRow('Colonna T', record.colonnaT ?? '-'),
                          _buildDetailRow('Progressivo', record.progressivoGiustificativo ?? '-'),
                        ]),
                      ],
                    ),
                  ),
                ),
                
                // ACTIONS
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('CHIUDI', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _exportToExcel(List<TracciatoSap> records) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['SAP'];
      excel.setDefaultSheet('SAP');

      sheet.appendRow([
        TextCellValue('CID'),
        TextCellValue('Nome'),
        TextCellValue('Soc.'),
        TextCellValue('Società'),
        TextCellValue('Trasferta'),
        TextCellValue('Importo'),
        TextCellValue('Valuta'),
        TextCellValue('Data'),
        TextCellValue('CD Richiesta'),
        TextCellValue('Codice Stato'),
      ]);

      for (final r in records) {
        sheet.appendRow([
          TextCellValue(r.cid),
          TextCellValue(r.nomeDipendente),
          TextCellValue(r.societaCodice),
          TextCellValue(r.societaDescrizione),
          TextCellValue(r.numeroTrasferta),
          DoubleCellValue(r.importo),
          TextCellValue(r.valuta),
          TextCellValue(r.data),
          TextCellValue(r.cdRichiesta ?? ''),
          TextCellValue(r.codiceStato ?? ''),
        ]);
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva Export SAP',
        fileName: 'export_sap_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Esportazione completata!'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _deleteRecord(BuildContext context, WidgetRef ref, TracciatoSap record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Eliminazione'),
        content: Text('Sei sicuro di voler eliminare questo record SAP (Trasferta: ${record.numeroTrasferta})?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              ref.read(tracciatoSapProvider.notifier).deleteRecord(record.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Record eliminato con successo'), backgroundColor: Colors.green),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }
}
