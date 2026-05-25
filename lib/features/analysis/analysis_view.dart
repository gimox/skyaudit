import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';

final _defaultDate = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
final selectedMonthProvider = StateProvider<String?>((ref) => null);
final selectedYearProvider = StateProvider<String?>(
  (ref) => _defaultDate.year.toString(),
);
final selectedTrasfertaProvider = StateProvider<String?>((ref) => null);
final selectedSocietaProvider = StateProvider<String?>((ref) => null);
final selectedTipiProvider = StateProvider<List<String>>((ref) => []);
final sortAscendingProvider = StateProvider<bool>((ref) => false);
final analysisPageProvider = StateProvider<int>((ref) => 0);

class AnalysisView extends ConsumerStatefulWidget {
  const AnalysisView({super.key});

  @override
  ConsumerState<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends ConsumerState<AnalysisView> {
  final _trasfertaController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();

  @override
  void dispose() {
    _trasfertaController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(tracciatoContabilesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final selectedTrasferta = ref.watch(selectedTrasfertaProvider);
    final selectedSocieta = ref.watch(selectedSocietaProvider);
    final selectedTipi = ref.watch(selectedTipiProvider);
    final sortAscending = ref.watch(sortAscendingProvider);
    final currentPage = ref.watch(analysisPageProvider);
    final anagrafiche = ref.watch(anagraficaProvider);
    final anagraficheMap = {
      for (var a in anagrafiche)
        if (a.cid != null) a.cid!.trim(): a.nominativo ?? ''
    };
    const pageSize = 50;

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

    final activeFiltersCount = [
      selectedMonth != null,
      selectedYear != null,
      selectedSocieta != null,
      selectedTipi.isNotEmpty,
      selectedTrasferta != null,
    ].where((e) => e).length;

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

    final availableTipi =
        allRecords
            .map((r) => r.tipoDipendente)
            .where((t) => t.isNotEmpty)
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

    final dictionaries = ref.watch(dictionaryProvider);
    final dictionaryMap = {
      for (final entry in dictionaries) entry.code: entry.value,
    };

    // Filtra i record
    final filteredRecords =
        allRecords.where((r) {
          final parts = r.dataSpesa.split('/');
          if (parts.length != 3) return false;
          final month = parts[1];
          final year = parts[2];

          if (selectedMonth != null && month != selectedMonth) return false;
          if (selectedYear != null && year != selectedYear) return false;
          if (selectedTrasferta != null) {
            final query = selectedTrasferta.toLowerCase();
            final name = anagraficheMap[r.cid.trim()] ?? '';
            if (!r.numeroTrasferta.toLowerCase().contains(query) &&
                !r.cid.toLowerCase().contains(query) &&
                !r.numeroBolla.toLowerCase().contains(query) &&
                !name.toLowerCase().contains(query)) {
              return false;
            }
          }
          if (selectedSocieta != null && r.societa != selectedSocieta) {
            return false;
          }
          if (selectedTipi.isNotEmpty && !selectedTipi.contains(r.tipoDipendente)) {
            return false;
          }

          return true;
        }).toList()..sort((a, b) {
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
            return sortAscending
                ? dateA.compareTo(dateB)
                : dateB.compareTo(dateA);
          } catch (e) {
            return 0;
          }
        });

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);


    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, dictionaryMap, availableYears, availableSocieta, availableTipi, selectedTipi),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideHeader = constraints.maxWidth > 800;
                    const headerContent = SizedBox.shrink();
                    final actionsContent = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [


                      ],
                    );
                    return isWideHeader ? Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: headerContent), actionsContent]) : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [headerContent, const SizedBox(height: 16), actionsContent]);
                  },
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
                                decoration: const InputDecoration(hintText: 'Cerca per trasferta, CID o bolla...', border: InputBorder.none, isDense: true),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  ref.read(selectedTrasfertaProvider.notifier).state = value.isEmpty ? null : value;
                                  ref.read(analysisPageProvider.notifier).state = 0;
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
                        if (selectedTrasferta != null)
                          _buildFilterChip('Cerca: "$selectedTrasferta"', () {
                            ref.read(selectedTrasfertaProvider.notifier).state = null;
                            _trasfertaController.clear();
                          }),
                        if (selectedYear != null) _buildFilterChip('Anno: $selectedYear', () => ref.read(selectedYearProvider.notifier).state = null),
                        if (selectedMonth != null) _buildFilterChip('Mese: ${monthNames[selectedMonth]}', () => ref.read(selectedMonthProvider.notifier).state = null),
                        if (selectedSocieta != null) _buildFilterChip('Società: $selectedSocieta', () => ref.read(selectedSocietaProvider.notifier).state = null),
                        if (selectedTipi.isNotEmpty)
                          _buildFilterChip(
                            'Tipi: ${selectedTipi.join(", ")}',
                            () => ref.read(selectedTipiProvider.notifier).state = [],
                          ),
                        TextButton(onPressed: () => _resetAllFilters(ref), child: const Text('Reset tutto', style: TextStyle(fontSize: 12, color: Colors.red))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                    )                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          width: 1870,
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
                                    _buildCell('AZIONI', 100, isHeader: true, alignment: Alignment.center),
                                    _buildCell('CID', 140, isHeader: true),
                                    _buildCell('NOMINATIVO', 220, isHeader: true),
                                    _buildCell('TRASFERTA', 160, isHeader: true),
                                    _buildCell('IMPORTO', 140, isHeader: true),
                                    _buildCell('SEGNO', 80, isHeader: true),
                                    _buildCell('GIUSTIFICATIVO', 250, isHeader: true),
                                    _buildCell('BOLLA', 150, isHeader: true),
                                    _buildCell('SOCIETÀ', 100, isHeader: true),
                                    _buildCell('DATA SPESA', 120, isHeader: true),
                                    _buildCell('DATA INIZIO', 120, isHeader: true),
                                    _buildCell('DATA FINE', 120, isHeader: true),
                                    _buildCell('LOCALITÀ', 170, isHeader: true),
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
                                            _buildCell('', 100, alignment: Alignment.center, child: IconButton(icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20), onPressed: () => _showRecordDetails(context, record, dictionaryMap), padding: EdgeInsets.zero, constraints: const BoxConstraints())),
                                            _buildCopyableCell(record.cid, 140, typeLabel: 'CID', fontWeight: FontWeight.w500),
                                            _buildCell(anagraficheMap[record.cid.trim()] ?? '', 220, fontWeight: FontWeight.w500),
                                            _buildCopyableCell(record.numeroTrasferta, 160, typeLabel: 'Trasferta'),
                                            _buildCell('${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}', 140, fontWeight: FontWeight.bold, color: record.isNegative ? Colors.red.shade700 : Colors.green.shade800),
                                            _buildCell('', 80, child: Icon(record.isNegative ? Icons.remove_circle_outline : Icons.add_circle_outline, color: record.isNegative ? Colors.red.shade300 : Colors.green.shade300, size: 18)),
                                            _buildCell(dictionaryMap[record.giustificativoSpesa] != null ? '${record.giustificativoSpesa} - ${dictionaryMap[record.giustificativoSpesa]}' : record.giustificativoSpesa, 250, color: dictionaryMap[record.giustificativoSpesa] != null ? SkyTheme.timBlue : null),
                                            _buildCopyableCell(record.numeroBolla, 150, typeLabel: 'Bolla'),
                                            _buildCell(dictionaryMap[record.societa] != null ? '${record.societa} - ${dictionaryMap[record.societa]}' : record.societa, 100, color: dictionaryMap[record.societa] != null ? SkyTheme.timBlue : null),
                                            _buildCell(record.dataSpesa, 120),
                                            _buildCell(record.dataInizio, 120),
                                            _buildCell(record.dataFine, 120),
                                            _buildCell(record.localita, 170),
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
                        ref.read(analysisPageProvider.notifier).state--;
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
                        ref.read(analysisPageProvider.notifier).state++;
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
    ref.read(selectedMonthProvider.notifier).state = null;
    ref.read(selectedYearProvider.notifier).state = null;
    ref.read(selectedTrasfertaProvider.notifier).state = null;
    ref.read(selectedSocietaProvider.notifier).state = null;
    ref.read(selectedTipiProvider.notifier).state = [];
    ref.read(analysisPageProvider.notifier).state = 0;
    _trasfertaController.clear();
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

  Widget _buildFilterDrawer(BuildContext context, WidgetRef ref, Map<String, String> dictionaryMap, List<String> years, List<String> societa, List<String> tipi, List<String> selectedTipi) {
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
                      'FILTRI AVANZATI',
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Affina la tua ricerca',
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
                _buildDrawerSectionTitle('PERIODI'),
                const SizedBox(height: 12),
                _buildFilterDropdown<String?>('Seleziona Anno', ref.watch(selectedYearProvider), years, (val) => ref.read(selectedYearProvider.notifier).state = val, icon: Icons.calendar_today),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Seleziona Mese', ref.watch(selectedMonthProvider), monthNames.keys.toList(), (val) => ref.read(selectedMonthProvider.notifier).state = val, icon: Icons.calendar_month, labelMapper: (val) => monthNames[val] ?? val ?? ''),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('ANAGRAFICA'),
                const SizedBox(height: 12),
                _buildFilterDropdown<String?>('Società', ref.watch(selectedSocietaProvider), societa, (val) => ref.read(selectedSocietaProvider.notifier).state = val, icon: Icons.business),
                const SizedBox(height: 16),
                _buildMultiSelectFilter('Tipo Dipendente', selectedTipi, tipi, (val) {
                  final newList = List<String>.from(selectedTipi);
                  if (newList.contains(val)) {
                    newList.remove(val);
                  } else {
                    newList.add(val);
                  }
                  ref.read(selectedTipiProvider.notifier).state = newList;
                }, dictionaryMap: dictionaryMap),
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

  Widget _buildMultiSelectFilter(String label, List<String> selectedValues, List<String> availableValues, Function(String) onToggle, {Map<String, String>? dictionaryMap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_outline, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableValues.map((value) {
            final isSelected = selectedValues.contains(value);
            final description = dictionaryMap?[value];
            final displayLabel = description != null ? '$value - $description' : value;
            
            return FilterChip(
              label: Text(displayLabel, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
              selected: isSelected,
              onSelected: (_) => onToggle(value),
              selectedColor: SkyTheme.timBlue,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? SkyTheme.timBlue : Colors.grey.shade300),
              ),
              showCheckmark: true,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            );
          }).toList(),
        ),
      ],
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
                color: isHighlight ? (highlightColor ?? SkyTheme.timBlue) : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, TracciatoContabile record, Map<String, String> dictionaryMap) {
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
                // HEADER ELEGANTE
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [SkyTheme.timBlue, Color(0xFF0056B3)],
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
                        child: const Icon(Icons.description_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DETTAGLIO TRACCIATO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bolla n. ${record.numeroBolla}',
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
                
                // CONTENUTO
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildDetailSection('Anagrafica Trasferta', Icons.person_outline, SkyTheme.timBlue, [
                          _buildDetailRow('CID Dipendente', record.cid),
                          _buildDetailRow('Numero Trasferta', record.numeroTrasferta),
                          _buildDetailRow('Società', '${record.societa} - ${dictionaryMap[record.societa] ?? ''}'),
                          _buildDetailRow('Tipo Dipendente', record.tipoDipendente),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Dati Spesa', Icons.receipt_long_outlined, SkyTheme.timBlue, [
                          _buildDetailRow('Giustificativo', '${record.giustificativoSpesa} - ${dictionaryMap[record.giustificativoSpesa] ?? ''}'),
                          _buildDetailRow('Località', record.localita),
                          _buildDetailRow('Data Spesa', record.dataSpesa),
                          _buildDetailRow('Periodo', '${record.dataInizio} - ${record.dataFine}'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Contabilità', Icons.payments_outlined, SkyTheme.timBlue, [
                          _buildDetailRow(
                            'Importo Totale', 
                            '${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}',
                            isHighlight: true,
                            highlightColor: record.isNegative ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                          _buildDetailRow('Numero Bolla', record.numeroBolla),
                          _buildDetailRow('Tipo Attività', record.tipoAttivita),
                          _buildDetailRow('Progressivo', record.progressivo),
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
                        backgroundColor: SkyTheme.timBlue,
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



  Future<void> _exportToExcel(List<TracciatoContabile> records) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Tracciato'];
      excel.setDefaultSheet('Tracciato');

      final anagrafiche = ref.read(anagraficaProvider);
      final anagraficheMap = {
        for (var a in anagrafiche)
          if (a.cid != null) a.cid!.trim(): a.nominativo ?? ''
      };

      // Header
      sheet.appendRow([
        TextCellValue('CID'),
        TextCellValue('Nominativo'),
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
          TextCellValue(anagraficheMap[r.cid.trim()] ?? ''),
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
