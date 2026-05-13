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
final ecSelectedSocietaProvider = StateProvider<String?>((ref) => null);
final ecStartDateProvider = StateProvider<DateTime?>((ref) => null);
final ecEndDateProvider = StateProvider<DateTime?>((ref) => null);
final ecSelectedTipiServizioProvider = StateProvider<Set<String>>((ref) => {});
final ecSortAscendingProvider = StateProvider<bool>((ref) => false);
final ecPageProvider = StateProvider<int>((ref) => 0);

class EstrattiContoView extends ConsumerStatefulWidget {
  const EstrattiContoView({super.key});

  @override
  ConsumerState<EstrattiContoView> createState() => _EstrattiContoViewState();
}

class _EstrattiContoViewState extends ConsumerState<EstrattiContoView> {
  final _trasfertaController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _trasfertaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(estrattoContoProvider);
    final selectedTrasferta = ref.watch(ecSelectedTrasfertaProvider);
    final selectedSocieta = ref.watch(ecSelectedSocietaProvider);
    final startDate = ref.watch(ecStartDateProvider);
    final endDate = ref.watch(ecEndDateProvider);
    final selectedTipi = ref.watch(ecSelectedTipiServizioProvider);
    final sortAscending = ref.watch(ecSortAscendingProvider);
    final currentPage = ref.watch(ecPageProvider);
    const pageSize = 50;

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
      selectedSocieta != null,
      startDate != null,
      endDate != null,
      selectedTipi.isNotEmpty,
    ].where((e) => e).length;

    // Estrai società disponibili per il filtro
    final availableSocieta = allRecords
        .map((r) => r.ragioneSociale)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    
    final availableTipi = allRecords
        .map((r) => r.tipoServizio)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      if (selectedTrasferta != null) {
        final query = selectedTrasferta.toLowerCase();
        if (!r.numeroTrasferta.toLowerCase().contains(query) &&
            !r.cid.toLowerCase().contains(query) &&
            !r.bolla.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (selectedSocieta != null && r.ragioneSociale != selectedSocieta) return false;
      
      // Filtro Data Bolla
      if (startDate != null || endDate != null) {
        try {
          final parts = r.dataBolla.split('/');
          if (parts.length == 3) {
            final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            if (startDate != null && date.isBefore(startDate)) return false;
            if (endDate != null && date.isAfter(endDate)) return false;
          }
        } catch (_) {
          // Skip date filter if format is invalid
        }
      }
      
      // Filtro Tipo Servizio
      if (selectedTipi.isNotEmpty && !selectedTipi.contains(r.tipoServizio)) return false;
      
      return true;
    }).toList()
      ..sort((a, b) {
        return sortAscending ? a.cid.compareTo(b.cid) : b.cid.compareTo(a.cid);
      });

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableSocieta, availableTipi),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideHeader = constraints.maxWidth > 800;
                    const headerContent = SizedBox.shrink();
                    final actionsContent = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [


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
                                decoration: const InputDecoration(hintText: 'Cerca per trasferta, CID o bolla...', border: InputBorder.none, isDense: true),
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
                        if (startDate != null) _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(ecStartDateProvider.notifier).state = null),
                        if (endDate != null) _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(ecEndDateProvider.notifier).state = null),
                        if (selectedTipi.isNotEmpty) _buildFilterChip('Tipi: ${selectedTipi.length}', () => ref.read(ecSelectedTipiServizioProvider.notifier).state = {}),
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
                      width: 1300,
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
                        ref.read(ecPageProvider.notifier).state--;
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
                        ref.read(ecPageProvider.notifier).state++;
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
    ref.read(ecSelectedTrasfertaProvider.notifier).state = null;
    ref.read(ecSelectedSocietaProvider.notifier).state = null;
    ref.read(ecStartDateProvider.notifier).state = null;
    ref.read(ecEndDateProvider.notifier).state = null;
    ref.read(ecSelectedTipiServizioProvider.notifier).state = {};
    ref.read(ecPageProvider.notifier).state = 0;
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

  Widget _buildFilterDrawer(BuildContext context, WidgetRef ref, List<String> societa, List<String> availableTipi) {
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
                _buildDrawerSectionTitle('PERIODI BOLLA'),
                const SizedBox(height: 12),
                _buildDatePickerFilter(
                  'Data Inizio',
                  ref.watch(ecStartDateProvider),
                  (val) => ref.read(ecStartDateProvider.notifier).state = val,
                ),
                const SizedBox(height: 12),
                _buildDatePickerFilter(
                  'Data Fine',
                  ref.watch(ecEndDateProvider),
                  (val) => ref.read(ecEndDateProvider.notifier).state = val,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('ANAGRAFICA'),
                const SizedBox(height: 12),
                _buildFilterDropdown<String?>('Società', ref.watch(ecSelectedSocietaProvider), societa, (val) => ref.read(ecSelectedSocietaProvider.notifier).state = val, icon: Icons.business),
                const SizedBox(height: 24),
                _buildChipsMultiSelectFilter(
                  'Tipo Servizio',
                  ref.watch(ecSelectedTipiServizioProvider),
                  availableTipi,
                  (val) {
                    final current = ref.read(ecSelectedTipiServizioProvider);
                    final next = Set<String>.from(current);
                    if (next.contains(val)) {
                      next.remove(val);
                    } else {
                      next.add(val);
                    }
                    ref.read(ecSelectedTipiServizioProvider.notifier).state = next;
                  },
                  icon: Icons.layers_outlined,
                ),
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

  Widget _buildChipsMultiSelectFilter(
    String label,
    Set<String> selectedValues,
    List<String> options,
    Function(String) onToggle, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
            ],
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            
            return FilterChip(
              label: Text(
                option, 
                style: TextStyle(
                  fontSize: 12, 
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )
              ),
              selected: isSelected,
              onSelected: (_) => onToggle(option),
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

  Widget _buildCell(String text, double width, {bool isHeader = false, Color? color, FontWeight? fontWeight, Alignment alignment = Alignment.centerLeft, Widget? child}) {
    return Container(
      width: width, height: 56, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: alignment,
      child: child ?? Text(text, style: TextStyle(fontSize: isHeader ? 11 : 13, fontWeight: isHeader ? FontWeight.bold : (fontWeight ?? FontWeight.normal), color: isHeader ? Colors.grey.shade700 : (color ?? Colors.black87), letterSpacing: isHeader ? 1.0 : null), overflow: TextOverflow.ellipsis),
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
                color: isHighlight ? (highlightColor ?? Colors.purple.shade700) : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, EstrattoConto record) {
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
                      colors: [Colors.purple.shade700, Colors.purple.shade900],
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
                        child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DETTAGLIO ESTRATTO CONTO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bolla: ${record.bolla}',
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
                        _buildDetailSection('Anagrafica', Icons.person_outline, Colors.purple.shade700, [
                          _buildDetailRow('CID', record.cid),
                          _buildDetailRow('Passeggero', record.nomePasseggero),
                          _buildDetailRow('Società', record.ragioneSociale),
                          _buildDetailRow('Trasferta', record.numeroTrasferta),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Dettagli Servizio', Icons.receipt_long_outlined, Colors.purple.shade700, [
                          _buildDetailRow('Tipo Servizio', record.tipoServizio),
                          _buildDetailRow('Descrizione', record.descrizioneServizio),
                          _buildDetailRow('Fornitore', record.fornitore),
                          _buildDetailRow('Itinerario', record.itinerario),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Contabilità', Icons.payments_outlined, Colors.purple.shade700, [
                          _buildDetailRow('Importo Servizio', '${record.importoServizio.toStringAsFixed(2)} €'),
                          _buildDetailRow('Tasse', '${record.tasse.toStringAsFixed(2)} €'),
                          _buildDetailRow('Fee', '${record.fee.toStringAsFixed(2)} €'),
                          _buildDetailRow('Totale Servizio', '${record.totaleServizio.toStringAsFixed(2)} €', isHighlight: true, highlightColor: Colors.purple.shade700),
                          _buildDetailRow('Bolla', record.bolla),
                          _buildDetailRow('Data Bolla', record.dataBolla),
                          _buildDetailRow('Competenza', record.dataCompetenza),
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
                        backgroundColor: Colors.purple.shade700,
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
