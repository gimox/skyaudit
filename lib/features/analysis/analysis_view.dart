import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';

final _defaultDate = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
final selectedMonthProvider = StateProvider<String?>((ref) => null);
final selectedYearProvider = StateProvider<String?>(
  (ref) => _defaultDate.year.toString(),
);
final selectedTrasfertaProvider = StateProvider<String?>((ref) => null);
final selectedCidProvider = StateProvider<String?>((ref) => null);
final selectedSocietaProvider = StateProvider<String?>((ref) => null);
final selectedTipiProvider = StateProvider<List<String>>((ref) => []);
final sortAscendingProvider = StateProvider<bool>((ref) => false);
final selectedBollaProvider = StateProvider<String?>((ref) => null);
final analysisPageProvider = StateProvider<int>((ref) => 0);

class AnalysisView extends ConsumerStatefulWidget {
  const AnalysisView({super.key});

  @override
  ConsumerState<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends ConsumerState<AnalysisView> {
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
    final allRecords = ref.watch(tracciatoContabilesProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final selectedYear = ref.watch(selectedYearProvider);
    final selectedTrasferta = ref.watch(selectedTrasfertaProvider);
    final selectedCid = ref.watch(selectedCidProvider);
    final selectedBolla = ref.watch(selectedBollaProvider);
    final selectedSocieta = ref.watch(selectedSocietaProvider);
    final selectedTipi = ref.watch(selectedTipiProvider);
    final sortAscending = ref.watch(sortAscendingProvider);
    final currentPage = ref.watch(analysisPageProvider);
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
      selectedCid != null,
      selectedBolla != null,
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
          if (selectedTrasferta != null &&
              !r.numeroTrasferta.contains(selectedTrasferta)) {
            return false;
          }
          if (selectedCid != null && !r.cid.contains(selectedCid)) {
            return false;
          }
          if (selectedSocieta != null && r.societa != selectedSocieta) {
            return false;
          }
          if (selectedTipi.isNotEmpty && !selectedTipi.contains(r.tipoDipendente)) {
            return false;
          }
          if (selectedBolla != null && !r.numeroBolla.contains(selectedBolla)) {
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
    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize) > filteredRecords.length ? filteredRecords.length : (startIndex + pageSize);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);


    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, dictionaryMap, availableYears, availableSocieta, availableTipi, selectedTipi),
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
                    final headerContent = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TRACCIATO CONTABILE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w200, letterSpacing: 2.0)),
                        const SizedBox(height: 4),
                        Text('Visualizzazione tracciato contabile UVET', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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
                                decoration: const InputDecoration(hintText: 'Cerca per trasferta...', border: InputBorder.none, isDense: true),
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
                        if (selectedYear != null) _buildFilterChip('Anno: $selectedYear', () => ref.read(selectedYearProvider.notifier).state = null),
                        if (selectedMonth != null) _buildFilterChip('Mese: ${monthNames[selectedMonth]}', () => ref.read(selectedMonthProvider.notifier).state = null),
                        if (selectedSocieta != null) _buildFilterChip('Società: $selectedSocieta', () => ref.read(selectedSocietaProvider.notifier).state = null),
                        if (selectedTipi.isNotEmpty)
                          _buildFilterChip(
                            'Tipi: ${selectedTipi.join(", ")}',
                            () => ref.read(selectedTipiProvider.notifier).state = [],
                          ),
                        if (selectedCid != null) _buildFilterChip('CID: $selectedCid', () { _cidController.clear(); ref.read(selectedCidProvider.notifier).state = null; }),
                        if (selectedBolla != null) _buildFilterChip('Bolla: $selectedBolla', () { _bollaController.clear(); ref.read(selectedBollaProvider.notifier).state = null; }),
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
                      width: 1570,
                      child: Column(
                        children: [
                          Container(
                            height: 56,
                            decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                            child: Row(
                              children: [
                                _buildCell('CID', 100, isHeader: true),
                                _buildCell('TRASFERTA', 120, isHeader: true),
                                _buildCell('GIUSTIFICATIVO', 250, isHeader: true),
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
                                    _buildCell(dictionaryMap[record.giustificativoSpesa] != null ? '${record.giustificativoSpesa} - ${dictionaryMap[record.giustificativoSpesa]}' : record.giustificativoSpesa, 250, color: dictionaryMap[record.giustificativoSpesa] != null ? SkyTheme.timBlue : null),
                                    _buildCell(record.numeroBolla, 150),
                                    _buildCell(dictionaryMap[record.societa] != null ? '${record.societa} - ${dictionaryMap[record.societa]}' : record.societa, 100, color: dictionaryMap[record.societa] != null ? SkyTheme.timBlue : null),
                                    _buildCell(record.dataSpesa, 120),
                                    _buildCell(record.dataInizio, 120),
                                    _buildCell(record.dataFine, 120),
                                    _buildCell(record.localita, 170),
                                    _buildCell('${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}', 140, color: record.isNegative ? Colors.red.shade700 : Colors.green.shade800),
                                    _buildCell('', 80, child: Icon(record.isNegative ? Icons.remove_circle_outline : Icons.add_circle_outline, color: record.isNegative ? Colors.red.shade300 : Colors.green.shade300, size: 18)),
                                    _buildCell('', 100, alignment: Alignment.center, child: IconButton(icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20), onPressed: () => _showRecordDetails(context, record, dictionaryMap), padding: EdgeInsets.zero, constraints: const BoxConstraints())),
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
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: currentPage > 0 ? () {
                      ref.read(analysisPageProvider.notifier).state--;
                      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('Pagina ${currentPage + 1} di $totalPages (${filteredRecords.length} record)', style: const TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    onPressed: currentPage < totalPages - 1 ? () {
                      ref.read(analysisPageProvider.notifier).state++;
                      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    } : null,
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
    ref.read(selectedMonthProvider.notifier).state = null;
    ref.read(selectedYearProvider.notifier).state = null;
    ref.read(selectedTrasfertaProvider.notifier).state = null;
    ref.read(selectedCidProvider.notifier).state = null;
    ref.read(selectedSocietaProvider.notifier).state = null;
    ref.read(selectedTipiProvider.notifier).state = [];
    ref.read(selectedBollaProvider.notifier).state = null;
    ref.read(analysisPageProvider.notifier).state = 0;
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
                const SizedBox(height: 16),
                _buildDrawerTextField('Cerca per CID', _cidController, Icons.person_search, (val) => ref.read(selectedCidProvider.notifier).state = val.isEmpty ? null : val),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('RIFERIMENTI'),
                const SizedBox(height: 12),
                _buildDrawerTextField('Numero Bolla', _bollaController, Icons.receipt_long, (val) => ref.read(selectedBollaProvider.notifier).state = val.isEmpty ? null : val),
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

  Widget _buildCell(String text, double width, {bool isHeader = false, Color? color, FontWeight? fontWeight, Alignment alignment = Alignment.centerLeft, Widget? child}) {
    return Container(
      width: width, height: 56, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: alignment,
      child: child ?? Text(text, style: TextStyle(fontSize: isHeader ? 11 : 13, fontWeight: isHeader ? FontWeight.bold : (fontWeight ?? FontWeight.normal), color: isHeader ? Colors.grey.shade700 : (color ?? Colors.black87), letterSpacing: isHeader ? 1.0 : null), overflow: TextOverflow.ellipsis),
    );
  }

  void _showRecordDetails(BuildContext context, TracciatoContabile record, Map<String, String> dictionaryMap) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dettaglio Record - ${record.numeroTrasferta}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Società', '${record.societa} - ${dictionaryMap[record.societa] ?? ''}'),
              _buildDetailRow('Dipendente', '${record.cid} (${record.tipoDipendente})'),
              _buildDetailRow('Data Spesa', record.dataSpesa),
              _buildDetailRow('Località', record.localita),
              _buildDetailRow('Giustificativo', '${record.giustificativoSpesa} - ${dictionaryMap[record.giustificativoSpesa] ?? ''}'),
              _buildDetailRow('Numero Bolla', record.numeroBolla),
              _buildDetailRow('Importo', '${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}'),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Chiudi'))],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conferma Svuotamento'),
        content: const Text('Sei sicuro di voler eliminare tutti i dati del tracciato contabile? questa azione non è reversibile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () async {
              ref.read(tracciatoContabilesProvider.notifier).clear();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Svuota tutto'),
          ),
        ],
      ),
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
