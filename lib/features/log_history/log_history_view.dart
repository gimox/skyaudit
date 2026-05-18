import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';

// Filter providers for Log History
final logSearchQueryProvider = StateProvider<String?>((ref) => null);
final logStartDateProvider = StateProvider<DateTime?>((ref) => null);
final logEndDateProvider = StateProvider<DateTime?>((ref) => null);
final logSelectedSourceTypesProvider = StateProvider<Set<String>>((ref) => {});
final logSortAscendingProvider = StateProvider<bool>((ref) => false); // default false (newest first)
final logPageProvider = StateProvider<int>((ref) => 0);

const Map<String, String> sourceTypeLabels = {
  'contabile': 'Tracciato Contabile',
  'estratto': 'Estratto Conto',
  'sap': 'SAP EC',
  'amex': 'Amex',
  'anagrafica': 'Anagrafica',
  'scartiSap': 'Scarti Tracciato',
};

class LogHistoryView extends ConsumerStatefulWidget {
  const LogHistoryView({super.key});

  @override
  ConsumerState<LogHistoryView> createState() => _LogHistoryViewState();
}

class _LogHistoryViewState extends ConsumerState<LogHistoryView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: isDestructive ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? Colors.red.shade600
                  : Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  void _resetAllFilters(WidgetRef ref) {
    ref.read(logSearchQueryProvider.notifier).state = null;
    ref.read(logStartDateProvider.notifier).state = null;
    ref.read(logEndDateProvider.notifier).state = null;
    ref.read(logSelectedSourceTypesProvider.notifier).state = {};
    ref.read(logPageProvider.notifier).state = 0;
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

  Widget _buildCell(
    String text,
    double width, {
    bool isHeader = false,
    Alignment alignment = Alignment.centerLeft,
    Color? color,
    FontWeight? fontWeight,
    Widget? child,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: alignment,
      child: child ??
          Text(
            text,
            style: TextStyle(
              fontSize: isHeader ? 11 : 13,
              fontWeight: fontWeight ?? (isHeader ? FontWeight.bold : FontWeight.normal),
              color: color ?? (isHeader ? Colors.grey.shade700 : Colors.black87),
              letterSpacing: isHeader ? 1.0 : 0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(logHistoryProvider);
    final searchQuery = ref.watch(logSearchQueryProvider);
    final startDate = ref.watch(logStartDateProvider);
    final endDate = ref.watch(logEndDateProvider);
    final selectedSourceTypes = ref.watch(logSelectedSourceTypesProvider);
    final sortAscending = ref.watch(logSortAscendingProvider);
    final currentPage = ref.watch(logPageProvider);
    const pageSize = 50;

    // Watch active filter counts
    final activeFiltersCount = [
      searchQuery != null,
      startDate != null,
      endDate != null,
      selectedSourceTypes.isNotEmpty,
    ].where((e) => e).length;

    // Get available source types dynamically from existing log list
    final availableSourceTypes = allRecords
        .map((r) => r.sourceType ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Filter logs
    final filteredRecords = allRecords.where((log) {
      // Search text filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchFile = log.fileName.toLowerCase().contains(query);
        final matchCode = log.uniqueCode.toLowerCase().contains(query);
        if (!matchFile && !matchCode) return false;
      }

      // Date range filter
      if (startDate != null) {
        final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
        if (log.date.isBefore(startOfDay)) return false;
      }
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        if (log.date.isAfter(endOfDay)) return false;
      }

      // Source type filter
      if (selectedSourceTypes.isNotEmpty && !selectedSourceTypes.contains(log.sourceType)) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        return sortAscending ? a.date.compareTo(b.date) : b.date.compareTo(a.date);
      });

    // Pagination
    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableSourceTypes),
      body: Column(
        children: [
          // HEADER CON RICERCA E FILTRI
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
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Cerca per Nome File, Codice Univoco...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  ref.read(logSearchQueryProvider.notifier).state = value.isEmpty ? null : value;
                                  ref.read(logPageProvider.notifier).state = 0;
                                },
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(logSearchQueryProvider.notifier).state = null;
                                  ref.read(logPageProvider.notifier).state = 0;
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        ref.read(logSortAscendingProvider.notifier).state = !sortAscending;
                      },
                      icon: Icon(sortAscending ? Icons.swap_vert : Icons.swap_vert_rounded),
                      tooltip: sortAscending ? 'Ordina per Meno Recente' : 'Ordina per Più Recente',
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
                        if (searchQuery != null)
                          _buildFilterChip('Ricerca: "$searchQuery"', () {
                            _searchController.clear();
                            ref.read(logSearchQueryProvider.notifier).state = null;
                          }),
                        if (startDate != null)
                          _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(logStartDateProvider.notifier).state = null),
                        if (endDate != null)
                          _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(logEndDateProvider.notifier).state = null),
                        if (selectedSourceTypes.isNotEmpty)
                          _buildFilterChip('Tipo Dati: ${selectedSourceTypes.length}', () => ref.read(logSelectedSourceTypesProvider.notifier).state = {}),
                        TextButton(
                          onPressed: () => _resetAllFilters(ref),
                          child: const Text('Reset tutto', style: TextStyle(fontSize: 12, color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // TABELLA E CONTENUTO
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                  child: filteredRecords.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary.withAlpha(50),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'NESSUN LOG TROVATO CON I FILTRI CORRENTI',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.2,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1370,
                            child: Column(
                              children: [
                                // HEADER FISSO
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildCell('NOME FILE', 400, isHeader: true),
                                      _buildCell('TIPO DATI', 160, isHeader: true),
                                      _buildCell('DATA IMPORTAZIONE', 180, isHeader: true),
                                      _buildCell('TOTALE', 90, isHeader: true, alignment: Alignment.center),
                                      _buildCell('INSERITI', 90, isHeader: true, alignment: Alignment.center),
                                      _buildCell('AGGIORNATI', 100, isHeader: true, alignment: Alignment.center),
                                      _buildCell('SCARTATI', 90, isHeader: true, alignment: Alignment.center),
                                      _buildCell('CODICE UNIVOCO', 160, isHeader: true),
                                      _buildCell('AZIONI', 100, isHeader: true, alignment: Alignment.center),
                                    ],
                                  ),
                                ),
                                // BODY
                                Expanded(
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: paginatedRecords.length,
                                      itemBuilder: (context, index) {
                                        final log = paginatedRecords[index];
                                        final translatedType = sourceTypeLabels[log.sourceType] ?? (log.sourceType ?? 'N.D.');
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0 ? Colors.white : Colors.grey.shade50.withAlpha(120),
                                            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                                          ),
                                          child: Row(
                                            children: [
                                              _buildCell(log.fileName, 400, fontWeight: FontWeight.w500),
                                              _buildCell(translatedType, 160, color: SkyTheme.timBlue, fontWeight: FontWeight.bold),
                                              _buildCell(DateFormat('dd/MM/yyyy HH:mm').format(log.date), 180),
                                              _buildCell(log.totalRecords.toString(), 90, alignment: Alignment.center, fontWeight: FontWeight.bold),
                                              _buildCell(log.insertedRecords.toString(), 90, alignment: Alignment.center, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                                              _buildCell(log.updatedRecords.toString(), 100, alignment: Alignment.center, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                                              _buildCell(log.discardedRecords.toString(), 90, alignment: Alignment.center, color: log.discardedRecords > 0 ? Colors.orange.shade700 : Colors.grey.shade400, fontWeight: FontWeight.bold),
                                              _buildCell(log.uniqueCode, 160, color: Colors.grey.shade500),
                                              _buildCell(
                                                '',
                                                100,
                                                alignment: Alignment.center,
                                                child: IconButton(
                                                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                                  onPressed: () async {
                                                    final messenger = ScaffoldMessenger.of(context);
                                                    final confirmed = await _showConfirmationDialog(
                                                      title: 'Elimina Importazione',
                                                      content: "Sei sicuro di voler eliminare l'importazione del file '${log.fileName}' e tutti i suoi record associati?",
                                                      isDestructive: true,
                                                    );
                                                    if (confirmed == true) {
                                                      await ref.read(logHistoryProvider.notifier).deleteLogHistoryAndRecords(log.uniqueCode);
                                                      if (mounted) {
                                                        messenger.showSnackBar(
                                                          const SnackBar(
                                                            content: Text('Importazione eliminata con successo'),
                                                            backgroundColor: Colors.green,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  tooltip: 'Elimina importazione',
                                                ),
                                              ),
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

          // PAGINAZIONE
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: currentPage > 0 ? () => ref.read(logPageProvider.notifier).state-- : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('Pagina ${currentPage + 1} di $totalPages', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: currentPage < totalPages - 1 ? () => ref.read(logPageProvider.notifier).state++ : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                    const VerticalDivider(),
                    Text('Totale: ${filteredRecords.length}', style: const TextStyle(color: SkyTheme.timBlue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDrawer(BuildContext context, WidgetRef ref, List<String> availableSourceTypes) {
    final selectedSourceTypes = ref.watch(logSelectedSourceTypesProvider);
    final startDate = ref.watch(logStartDateProvider);
    final endDate = ref.watch(logEndDateProvider);

    return Drawer(
      width: 400,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [SkyTheme.timBlue, Color(0xFF0056B3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'FILTRI LOG',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // FILTRO DATE
                _buildDrawerSectionTitle('PERIODO DI IMPORTAZIONE'),
                Row(
                  children: [
                    Expanded(
                      child: _buildDatePickerFilter(
                        'Dal',
                        startDate,
                        (val) => ref.read(logStartDateProvider.notifier).state = val,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDatePickerFilter(
                        'Al',
                        endDate,
                        (val) => ref.read(logEndDateProvider.notifier).state = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // FILTRO TIPO DATI
                _buildDrawerSectionTitle('TIPO DATI'),
                _buildChipsMultiSelectFilter(
                  selectedSourceTypes,
                  availableSourceTypes,
                  (val) {
                    final set = Set<String>.from(ref.read(logSelectedSourceTypesProvider));
                    if (set.contains(val)) {
                      set.remove(val);
                    } else {
                      set.add(val);
                    }
                    ref.read(logSelectedSourceTypesProvider.notifier).state = set;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resetAllFilters(ref),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('RESET'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: SkyTheme.timBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('APPLICA'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildChipsMultiSelectFilter(
    Set<String> selectedValues,
    List<String> availableValues,
    Function(String) onToggle,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableValues.map((value) {
        final isSelected = selectedValues.contains(value);
        final label = sourceTypeLabels[value] ?? value;
        return FilterChip(
          label: Text(label, style: const TextStyle(fontSize: 12)),
          selected: isSelected,
          onSelected: (_) => onToggle(value),
          selectedColor: SkyTheme.timBlue.withAlpha(40),
          checkmarkColor: SkyTheme.timBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(
            color: isSelected ? SkyTheme.timBlue : Colors.grey.shade300,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDatePickerFilter(
    String label,
    DateTime? selectedDate,
    Function(DateTime?) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final pick = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (pick != null) onChanged(pick);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  selectedDate != null
                      ? DateFormat('dd/MM/yyyy').format(selectedDate)
                      : 'Scegli data',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }
}
