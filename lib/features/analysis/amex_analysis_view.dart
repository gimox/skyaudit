import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/estratto_amex_provider.dart';
import 'package:travel_check/features/upload/models/estratto_amex.dart';
import 'package:travel_check/core/theme/app_theme.dart';

import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';

// Filter providers for Estratti AMEX
final amexSelectedSearchProvider = StateProvider<String?>((ref) => null);
final amexSelectedFornitoreProvider = StateProvider<String?>((ref) => null);
final amexStartDateProvider = StateProvider<DateTime?>((ref) => null);
final amexEndDateProvider = StateProvider<DateTime?>((ref) => null);
final amexSortAscendingProvider = StateProvider<bool>((ref) => false);
final amexPageProvider = StateProvider<int>((ref) => 0);

enum AmexTrasfertaPresenzaFilter { all, present, notPresent }
final amexTrasfertaPresenzaFilterProvider = StateProvider<AmexTrasfertaPresenzaFilter>((ref) => AmexTrasfertaPresenzaFilter.all);

class AmexAnalysisView extends ConsumerStatefulWidget {
  const AmexAnalysisView({super.key});

  @override
  ConsumerState<AmexAnalysisView> createState() => _AmexAnalysisViewState();
}

class _AmexAnalysisViewState extends ConsumerState<AmexAnalysisView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(estrattoAmexProvider);
    final searchFilter = ref.watch(amexSelectedSearchProvider);
    final selectedFornitore = ref.watch(amexSelectedFornitoreProvider);
    final startDate = ref.watch(amexStartDateProvider);
    final endDate = ref.watch(amexEndDateProvider);
    final sortAscending = ref.watch(amexSortAscendingProvider);
    final currentPage = ref.watch(amexPageProvider);
    final trasfertaFilter = ref.watch(amexTrasfertaPresenzaFilterProvider);
    final contabileRecords = ref.watch(tracciatoContabilesProvider);
    final contabileTrasferte = contabileRecords
        .map((tc) => tc.numeroTrasferta.trim())
        .where((t) => t.isNotEmpty)
        .toSet();
    const pageSize = 50;

    if (allRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
            ),
            const SizedBox(height: 16),
            Text(
              'NESSUN ESTRATTO AMEX CARICATO',
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
      searchFilter != null,
      selectedFornitore != null,
      startDate != null,
      endDate != null,
      trasfertaFilter != AmexTrasfertaPresenzaFilter.all,
    ].where((e) => e).length;

    // Estrai fornitori disponibili per il filtro
    final availableFornitori = allRecords
        .map((r) => r.nomeFornitore ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      if (searchFilter != null) {
        final query = searchFilter.toLowerCase();
        if (!(r.numeroTrasferta?.toLowerCase().contains(query) ?? false) &&
            !(r.cid?.toLowerCase().contains(query) ?? false) &&
            !(r.bolla?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }
      if (selectedFornitore != null && r.nomeFornitore != selectedFornitore) return false;
      
      // Filtro Data Transazione (F) - Il formato nel file AMEX è solitamente DD/MM/YYYY o simile
      if (startDate != null || endDate != null) {
        try {
          final dataStr = r.dataTransazione ?? '';
          final parts = dataStr.split('/');
          if (parts.length == 3) {
            final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            if (startDate != null && date.isBefore(startDate)) return false;
            if (endDate != null && date.isAfter(endDate)) return false;
          }
        } catch (_) {
          // Skip date filter if format is invalid
        }
      }
      
      // Filtro Presenza in Tracciato Contabile
      if (trasfertaFilter != AmexTrasfertaPresenzaFilter.all) {
        final isPresent = r.numeroTrasferta != null && contabileTrasferte.contains(r.numeroTrasferta!.trim());
        if (trasfertaFilter == AmexTrasfertaPresenzaFilter.present && !isPresent) return false;
        if (trasfertaFilter == AmexTrasfertaPresenzaFilter.notPresent && isPresent) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        final cidA = a.cid ?? '';
        final cidB = b.cid ?? '';
        return sortAscending ? cidA.compareTo(cidB) : cidB.compareTo(cidA);
      });

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableFornitori),
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
                const SizedBox(height: 8),
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
                                controller: _searchController,
                                decoration: const InputDecoration(hintText: 'Cerca per trasferta, CID o bolla...', border: InputBorder.none, isDense: true),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  ref.read(amexSelectedSearchProvider.notifier).state = value.isEmpty ? null : value;
                                  ref.read(amexPageProvider.notifier).state = 0;
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
                        if (searchFilter != null)
                          _buildFilterChip('Cerca: "$searchFilter"', () {
                            ref.read(amexSelectedSearchProvider.notifier).state = null;
                            _searchController.clear();
                          }),
                        if (selectedFornitore != null) _buildFilterChip('Fornitore: $selectedFornitore', () => ref.read(amexSelectedFornitoreProvider.notifier).state = null),
                        if (startDate != null) _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(amexStartDateProvider.notifier).state = null),
                        if (endDate != null) _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(amexEndDateProvider.notifier).state = null),
                        if (trasfertaFilter != AmexTrasfertaPresenzaFilter.all)
                          _buildFilterChip(
                            trasfertaFilter == AmexTrasfertaPresenzaFilter.present
                                ? 'Riscontro: Presenti'
                                : 'Riscontro: Non Presenti',
                            () => ref.read(amexTrasfertaPresenzaFilterProvider.notifier).state = AmexTrasfertaPresenzaFilter.all,
                          ),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(16), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5), 
                      blurRadius: 15, 
                      offset: const Offset(0, 5)
                    )
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1510,
                      child: Column(
                        children: [
                          // HEADER FISSO
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50, 
                              border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                            ),
                            child: Row(
                              children: [
                                _buildCell('CID', 200, isHeader: true),
                                _buildCell('TRASFERTA', 180, isHeader: true),
                                _buildCell('IMPORTO', 120, isHeader: true),
                                _buildCell('VIAGGIATORE', 200, isHeader: true),
                                _buildCell('BOLLA', 150, isHeader: true),
                                _buildCell('FORNITORE', 250, isHeader: true),
                                _buildCell('DATA TRANS.', 120, isHeader: true),
                                _buildCell('AZIONI', 120, isHeader: true, alignment: Alignment.center),
                              ],
                            ),
                          ),
                          // BODY SCROLLABILE
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: paginatedRecords.length,
                                itemBuilder: (context, index) {
                                  final record = paginatedRecords[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0 ? Colors.white : Colors.grey.shade50.withAlpha(120), 
                                      border: Border(bottom: BorderSide(color: Colors.grey.shade100))
                                    ),
                                    child: Row(
                                      children: [
                                        _buildCopyableCell(record.cid ?? '-', 200, typeLabel: 'CID', fontWeight: FontWeight.w500),
                                        _buildCopyableCell(
                                          record.numeroTrasferta ?? '-',
                                          180,
                                          typeLabel: 'Trasferta',
                                          fontWeight: FontWeight.bold,
                                          color: record.numeroTrasferta != null && contabileTrasferte.contains(record.numeroTrasferta!.trim())
                                              ? Colors.green.shade800
                                              : Colors.red.shade700,
                                        ),
                                        _buildCell('${record.importoLordo?.toStringAsFixed(2) ?? '0.00'} €', 120, fontWeight: FontWeight.bold, color: (record.importoLordo ?? 0) < 0 ? Colors.red.shade700 : Colors.green.shade800),
                                        _buildCopyableCell(record.nomeViaggiatore ?? '-', 200, typeLabel: 'Viaggiatore'),
                                        _buildCell(record.bolla ?? '-', 150),
                                        _buildCell(record.nomeFornitore ?? '-', 250),
                                        _buildCell(record.dataTransazione ?? '-', 120),
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
                            ),
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
                        ref.read(amexPageProvider.notifier).state--;
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
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
                        ref.read(amexPageProvider.notifier).state++;
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
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
    ref.read(amexSelectedSearchProvider.notifier).state = null;
    ref.read(amexSelectedFornitoreProvider.notifier).state = null;
    ref.read(amexStartDateProvider.notifier).state = null;
    ref.read(amexEndDateProvider.notifier).state = null;
    ref.read(amexTrasfertaPresenzaFilterProvider.notifier).state = AmexTrasfertaPresenzaFilter.all;
    ref.read(amexPageProvider.notifier).state = 0;
    _searchController.clear();
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

  Widget _buildFilterDrawer(BuildContext context, WidgetRef ref, List<String> fornitori) {
    return Drawer(
      width: 350,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [SkyTheme.timRed, Color(0xFF9E0007)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'FILTRI AMEX',
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Affina la ricerca AMEX',
                      style: TextStyle(
                        color: Colors.white70, 
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(20),
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildDrawerSectionTitle('PERIODI TRANSAZIONE'),
                const SizedBox(height: 12),
                _buildDatePickerFilter(
                  'Data Inizio',
                  ref.watch(amexStartDateProvider),
                  (val) => ref.read(amexStartDateProvider.notifier).state = val,
                ),
                const SizedBox(height: 12),
                _buildDatePickerFilter(
                  'Data Fine',
                  ref.watch(amexEndDateProvider),
                  (val) => ref.read(amexEndDateProvider.notifier).state = val,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('FORNITORE'),
                const SizedBox(height: 12),
                _buildFilterDropdown<String?>('Fornitore', ref.watch(amexSelectedFornitoreProvider), fornitori, (val) => ref.read(amexSelectedFornitoreProvider.notifier).state = val, icon: Icons.store),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('RISCONTRO CONTABILE'),
                const SizedBox(height: 12),
                _buildChoiceFilter<AmexTrasfertaPresenzaFilter>(
                  ref.watch(amexTrasfertaPresenzaFilterProvider),
                  {
                    AmexTrasfertaPresenzaFilter.all: 'Tutte',
                    AmexTrasfertaPresenzaFilter.present: 'Presenti',
                    AmexTrasfertaPresenzaFilter.notPresent: 'Non Presenti',
                  },
                  (val) => ref.read(amexTrasfertaPresenzaFilterProvider.notifier).state = val,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => _resetAllFilters(ref), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)), child: const Text('RESET'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: SkyTheme.timBlue, foregroundColor: Colors.white), child: const Text('APPLICA'))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceFilter<T>(
    T selected,
    Map<T, String> options,
    Function(T) onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: options.entries.map((entry) {
          final isSelected = selected == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(entry.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? SkyTheme.timRed : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePickerFilter(String label, DateTime? selectedDate, Function(DateTime?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: SkyTheme.timBlue,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) onChanged(date);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: SkyTheme.timBlue),
                const SizedBox(width: 12),
                Text(
                  selectedDate == null 
                      ? 'Seleziona data' 
                      : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: TextStyle(
                    color: selectedDate == null ? Colors.grey : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (selectedDate != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => onChanged(null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SkyTheme.timBlue.withAlpha(150), letterSpacing: 1.2));
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

  Widget _buildCopyableCell(
    String text,
    double width, {
    required String typeLabel,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return _buildCell(
      text,
      width,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: fontWeight ?? FontWeight.normal,
                color: color ?? Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$typeLabel $text copiato negli appunti'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: SkyTheme.timBlue,
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(Icons.copy_rounded, size: 14, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell(String text, double width, {bool isHeader = false, Color? color, FontWeight? fontWeight, Alignment alignment = Alignment.centerLeft, Widget? child}) {
    return Container(
      width: width, height: 56, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: alignment,
      child: child ?? Text(text, style: TextStyle(fontSize: isHeader ? 11 : 13, fontWeight: isHeader ? FontWeight.bold : (fontWeight ?? FontWeight.normal), color: isHeader ? Colors.grey.shade700 : (color ?? Colors.black87), letterSpacing: isHeader ? 1.0 : null), overflow: TextOverflow.ellipsis),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, EstrattoAmex record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Record'),
        content: const Text('Sei sicuro di voler eliminare questo record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              ref.read(estrattoAmexProvider.notifier).deleteRecord(record.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Elimina', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, EstrattoAmex record) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550, maxHeight: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange, Color(0xFFE65100)],
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
                        child: const Icon(Icons.credit_card_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DETTAGLIO TRANSAZIONE AMEX',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${record.idTransazione ?? "-"}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(20),
                          padding: const EdgeInsets.all(6),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDetailSection('INFORMAZIONI PRINCIPALI', Icons.info_outline, Colors.blue, [
                          _buildDetailRow('CID', record.cid ?? '-'),
                          _buildDetailRow('Numero Trasferta', record.numeroTrasferta ?? '-'),
                          _buildDetailRow('Bolla (Trasformata)', record.bolla ?? '-'),
                          _buildDetailRow('Bolla Originale', record.bollaOriginale ?? '-'),
                          _buildDetailRow('Nome Viaggiatore', record.nomeViaggiatore ?? '-'),
                          _buildDetailRow('Conto', record.conto ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('DETTAGLI ECONOMICI', Icons.euro_symbol, Colors.green, [
                          _buildDetailRow('Importo Lordo', '${record.importoLordo?.toStringAsFixed(2) ?? "0.00"} €', isHighlight: true, highlightColor: Colors.green.shade700),
                          _buildDetailRow('Importo Netto', '${record.importoNetto?.toStringAsFixed(2) ?? "0.00"} €'),
                          _buildDetailRow('Totale Tasse', '${record.totaleImportoTasse?.toStringAsFixed(2) ?? "0.00"} €'),
                          _buildDetailRow('Valuta', record.valuta ?? '-'),
                          _buildDetailRow('Tasso Cambio', record.tassoCambio ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('DETTAGLI TRANSAZIONE', Icons.payment_outlined, Colors.purple, [
                          _buildDetailRow('Data Transazione', record.dataTransazione ?? '-'),
                          _buildDetailRow('Fornitore', record.nomeFornitore ?? '-'),
                          _buildDetailRow('Esercizio', record.nomeEsercizio ?? '-'),
                          _buildDetailRow('ID Transazione', record.idTransazione ?? '-'),
                          _buildDetailRow('Stato', record.stato ?? '-'),
                          _buildDetailRow('Agenzia Viaggi', record.agenziaViaggi ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('LOGISTICA VIAGGIO', Icons.flight_takeoff_outlined, Colors.orange, [
                          _buildDetailRow('PNR No', record.pnrNo ?? '-'),
                          _buildDetailRow('Partenza', record.aeroportoPartenza ?? '-'),
                          _buildDetailRow('Destinazione', record.aeroportoDestinazione ?? '-'),
                          _buildDetailRow('Data Partenza', record.dataPartenza ?? '-'),
                          _buildDetailRow('Vettore', record.vettore ?? '-'),
                          _buildDetailRow('Classe', record.classeViaggio ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('ALTRI RIFERIMENTI', Icons.tag_outlined, Colors.grey, [
                          _buildDetailRow('Rif. Viaggio 1', record.rifViaggio1 ?? '-'),
                          _buildDetailRow('Rif. Viaggio 2', record.rifViaggio2 ?? '-'),
                          _buildDetailRow('Rif. Viaggio 3', record.rifViaggio3 ?? '-'),
                          _buildDetailRow('Fattura SE', record.numFatturaSE ?? '-'),
                          _buildDetailRow('ID Log', record.logHistoryId ?? '-'),
                        ]),
                        const SizedBox(height: 16),
                      ],
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
              Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color.withAlpha(180), letterSpacing: 1.2)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))]),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w400))),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600, color: isHighlight ? (highlightColor ?? Colors.purple.shade700) : Colors.black87, fontSize: 14))),
        ],
      ),
    );
  }

  Future<void> _exportToExcel(List<EstrattoAmex> records) async {
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Estratti_AMEX'];
    
    // Headers
    sheet.appendRow([
      TextCellValue('CID'),
      TextCellValue('TRASFERTA'),
      TextCellValue('VIAGGIATORE'),
      TextCellValue('BOLLA'),
      TextCellValue('FORNITORE'),
      TextCellValue('DATA TRANS.'),
      TextCellValue('IMPORTO'),
      TextCellValue('VALUTA'),
    ]);

    for (var r in records) {
      sheet.appendRow([
        TextCellValue(r.cid ?? ''),
        TextCellValue(r.numeroTrasferta ?? ''),
        TextCellValue(r.nomeViaggiatore ?? ''),
        TextCellValue(r.bolla ?? ''),
        TextCellValue(r.nomeFornitore ?? ''),
        TextCellValue(r.dataTransazione ?? ''),
        DoubleCellValue(r.importoLordo ?? 0.0),
        TextCellValue(r.valuta ?? ''),
      ]);
    }

    final String? outputFile = await FilePicker.saveFile(
      dialogTitle: 'Salva export Excel',
      fileName: 'export_amex_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsBytes(excel.encode()!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export completato con successo')));
      }
    }
  }
}
