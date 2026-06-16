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
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/features/upload/providers/trasferte_sap_provider.dart';
import 'package:travel_check/shared/widgets/file_selection_dialog.dart';
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
final tcSelectedLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});
final selectedImportoProvider = StateProvider<String?>((ref) => null);

enum ContabileIncrocioFilter {
  all,
  matched,
  notMatched,
}

final tcIncrocioFilterProvider = StateProvider<ContabileIncrocioFilter>((ref) => ContabileIncrocioFilter.all);

enum ContabileScartoFilter {
  all,
  scarti,
  regolari,
}

final tcScartoFilterProvider = StateProvider<ContabileScartoFilter>((ref) => ContabileScartoFilter.all);

class AnalysisView extends ConsumerStatefulWidget {
  const AnalysisView({super.key});

  @override
  ConsumerState<AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends ConsumerState<AnalysisView> {
  final _trasfertaController = TextEditingController();
  final _importoController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  final _statsScrollController = ScrollController();

  @override
  void dispose() {
    _trasfertaController.dispose();
    _importoController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _statsScrollController.dispose();
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
    final selectedImporto = ref.watch(selectedImportoProvider);
    final sortAscending = ref.watch(sortAscendingProvider);
    final currentPage = ref.watch(analysisPageProvider);
    final selectedLogHistoryIds = ref.watch(tcSelectedLogHistoryIdsProvider);
    final allLogs = ref.watch(logHistoryProvider);
    final incrocioFilter = ref.watch(tcIncrocioFilterProvider);
    final scartoFilter = ref.watch(tcScartoFilterProvider);
    final sapRecords = ref.watch(trasferteSapProvider);
    final sapTrasferte = sapRecords
        .map((r) => r.numeroTrasferta.trim())
        .where((t) => t.isNotEmpty)
        .toSet();
    String? selectedLogFileName;
    if (selectedLogHistoryIds.length == 1) {
      for (final log in allLogs) {
        if (log.uniqueCode == selectedLogHistoryIds.first) {
          selectedLogFileName = log.fileName;
          break;
        }
      }
    }
    final anagrafiche = ref.watch(anagraficaProvider);
    final anagraficheMap = {
      for (var a in anagrafiche)
        if (a.cid != null) a.cid!.trim().padLeft(8, '0'): (a.nominativo ?? '').trim()
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
      selectedImporto != null,
      selectedLogHistoryIds.isNotEmpty,
      incrocioFilter != ContabileIncrocioFilter.all,
      scartoFilter != ContabileScartoFilter.all,
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
    final logsMap = {for (final log in allLogs) log.uniqueCode: log.fileName};

    // Filtra i record
    final filteredRecords =
        allRecords.where((r) {
          if (selectedLogHistoryIds.isNotEmpty && !selectedLogHistoryIds.contains(r.logHistoryId)) return false;
          final parts = r.dataSpesa.split('/');
          if (parts.length != 3) return false;
          final month = parts[1];
          final year = parts[2];

          if (selectedMonth != null && month != selectedMonth) return false;
          if (selectedYear != null && year != selectedYear) return false;
          if (selectedTrasferta != null) {
            final query = selectedTrasferta.toLowerCase();
            final name = anagraficheMap[r.cid.trim().padLeft(8, '0')] ?? '';
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
          if (selectedImporto != null) {
            final query = selectedImporto.replaceAll(' ', '').replaceAll(',', '.');
            final importoStr = r.importo.toStringAsFixed(2);
            final formattedImporto = '${r.isNegative ? "-" : ""}$importoStr';
            if (!formattedImporto.contains(query) && !importoStr.contains(query)) {
              return false;
            }
          }

          // Filtro Stato Riscontro
          if (incrocioFilter != ContabileIncrocioFilter.all) {
            final isMatched = sapTrasferte.contains(r.numeroTrasferta.trim());
            if (incrocioFilter == ContabileIncrocioFilter.matched && !isMatched) return false;
            if (incrocioFilter == ContabileIncrocioFilter.notMatched && isMatched) return false;
          }

          // Filtro Stato Scarto
          if (scartoFilter != ContabileScartoFilter.all) {
            if (scartoFilter == ContabileScartoFilter.scarti && !r.isScarto) return false;
            if (scartoFilter == ContabileScartoFilter.regolari && r.isScarto) return false;
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

    final totalFiltered = filteredRecords.length;
    final uniqueTravelNumbers = filteredRecords.map((r) => r.numeroTrasferta.trim()).where((t) => t.isNotEmpty).toSet();
    final okTravels = uniqueTravelNumbers.where((t) => sapTrasferte.contains(t)).toSet();
    final koTravels = uniqueTravelNumbers.where((t) => !sapTrasferte.contains(t)).toSet();

    final okTravelsCount = okTravels.length;
    final koTravelsCount = koTravels.length;
    final totalFilteredTravels = uniqueTravelNumbers.length;

    final double totalAmount = filteredRecords.fold(0.0, (sum, r) => sum + (r.isNegative ? -r.importo : r.importo));
    final double okAmount = filteredRecords
        .where((r) => okTravels.contains(r.numeroTrasferta.trim()))
        .fold(0.0, (sum, r) => sum + (r.isNegative ? -r.importo : r.importo));
    final double koAmount = filteredRecords
        .where((r) => koTravels.contains(r.numeroTrasferta.trim()))
        .fold(0.0, (sum, r) => sum + (r.isNegative ? -r.importo : r.importo));

    final scartiRecords = filteredRecords.where((r) => r.isScarto).toList();
    final scartiCount = scartiRecords.length;
    final double scartiAmount = scartiRecords.fold(0.0, (sum, r) => sum + (r.isNegative ? -r.importo : r.importo));


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
                                decoration: const InputDecoration(hintText: 'Cerca per trasferta, CID, nominativo o bolla...', border: InputBorder.none, isDense: true),
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
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                        try {
                          await ref.read(tracciatoContabilesProvider.notifier).recalculateScarti();
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Elaborazione scarti completata con successo!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          navigator.pop();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('Errore durante l\'elaborazione: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Aggiorna Scarti'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: SkyTheme.timBlue,
                        side: const BorderSide(color: SkyTheme.timBlue),
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
                        if (selectedImporto != null)
                          _buildFilterChip('Importo: "$selectedImporto"', () {
                            ref.read(selectedImportoProvider.notifier).state = null;
                            _importoController.clear();
                          }),
                        if (selectedYear != null) _buildFilterChip('Anno: $selectedYear', () => ref.read(selectedYearProvider.notifier).state = null),
                        if (selectedMonth != null) _buildFilterChip('Mese: ${monthNames[selectedMonth]}', () => ref.read(selectedMonthProvider.notifier).state = null),
                        if (selectedSocieta != null) _buildFilterChip('Società: $selectedSocieta', () => ref.read(selectedSocietaProvider.notifier).state = null),
                        if (selectedTipi.isNotEmpty)
                          _buildFilterChip(
                            'Tipi: ${selectedTipi.join(", ")}',
                            () => ref.read(selectedTipiProvider.notifier).state = [],
                          ),
                        if (selectedLogHistoryIds.isNotEmpty)
                          _buildFilterChip(
                            selectedLogFileName != null
                                ? 'File: $selectedLogFileName'
                                : 'File: ${selectedLogHistoryIds.length} selezionati',
                            () => ref.read(tcSelectedLogHistoryIdsProvider.notifier).state = {},
                          ),
                        if (incrocioFilter != ContabileIncrocioFilter.all)
                          _buildFilterChip(
                            incrocioFilter == ContabileIncrocioFilter.matched ? 'Stato: Riscontrati SAP' : 'Stato: Non Riscontrati SAP',
                            () => ref.read(tcIncrocioFilterProvider.notifier).state = ContabileIncrocioFilter.all,
                          ),
                        if (scartoFilter != ContabileScartoFilter.all)
                          _buildFilterChip(
                            scartoFilter == ContabileScartoFilter.scarti ? 'Stato: Scarti' : 'Stato: Regolari',
                            () => ref.read(tcScartoFilterProvider.notifier).state = ContabileScartoFilter.all,
                          ),
                        TextButton(onPressed: () => _resetAllFilters(ref), child: const Text('Reset tutto', style: TextStyle(fontSize: 12, color: Colors.red))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // CARTELLINI STATISTICHE
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100.withAlpha(120),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final card1 = _buildSummaryCard(
                    title: 'TOTALE TRASFERTE',
                    value: '$totalFilteredTravels',
                    subtitle: 'Importo: ${_formatAmount(totalAmount)} | Record: $totalFiltered',
                    icon: Icons.analytics_outlined,
                    color: SkyTheme.timBlue,
                    bgLightColor: SkyTheme.timBlue.withAlpha(20),
                  );
                  final card2 = _buildSummaryCard(
                    title: 'RISCONTRATI SAP (OK)',
                    value: '$okTravelsCount',
                    subtitle: 'Importo: ${_formatAmount(okAmount)}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    bgLightColor: Colors.green.shade50,
                  );
                  final card3 = _buildSummaryCard(
                    title: 'NON RISCONTRATI SAP (KO)',
                    value: '$koTravelsCount',
                    subtitle: 'Importo: ${_formatAmount(koAmount)}',
                    icon: Icons.cancel_outlined,
                    color: Colors.red.shade700,
                    bgLightColor: Colors.red.shade50,
                  );
                  final card4 = _buildSummaryCard(
                    title: 'TOTALE SCARTI',
                    value: '$scartiCount',
                    subtitle: 'Importo: ${_formatAmount(scartiAmount)}',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange.shade700,
                    bgLightColor: Colors.orange.shade50,
                  );

                  if (constraints.maxWidth >= 1200) {
                    return Row(
                      children: [
                        Expanded(child: card1),
                        const SizedBox(width: 16),
                        Expanded(child: card2),
                        const SizedBox(width: 16),
                        Expanded(child: card3),
                        const SizedBox(width: 16),
                        Expanded(child: card4),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_statsScrollController.hasClients) {
                              _statsScrollController.animateTo(
                                (_statsScrollController.offset - 200).clamp(0, _statsScrollController.position.maxScrollExtent),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          icon: const Icon(Icons.chevron_left_rounded, color: SkyTheme.timBlue),
                          hoverColor: SkyTheme.timBlue.withAlpha(20),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            controller: _statsScrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                SizedBox(width: 290, child: card1),
                                const SizedBox(width: 16),
                                SizedBox(width: 290, child: card2),
                                const SizedBox(width: 16),
                                SizedBox(width: 290, child: card3),
                                const SizedBox(width: 16),
                                SizedBox(width: 290, child: card4),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_statsScrollController.hasClients) {
                              _statsScrollController.animateTo(
                                (_statsScrollController.offset + 200).clamp(0, _statsScrollController.position.maxScrollExtent),
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          icon: const Icon(Icons.chevron_right_rounded, color: SkyTheme.timBlue),
                          hoverColor: SkyTheme.timBlue.withAlpha(20),
                        ),
                      ],
                    );
                  }
                },
              ),
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
                          width: 2180,
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
                                    _buildCell('SCARTO', 110, isHeader: true, alignment: Alignment.center),
                                    _buildCell('IMPORTO', 140, isHeader: true),
                                    _buildCell('SEGNO', 80, isHeader: true),
                                    _buildCell('GIUSTIFICATIVO', 250, isHeader: true),
                                    _buildCell('BOLLA', 150, isHeader: true),
                                    _buildCell('FILE IMPORTAZIONE', 200, isHeader: true),
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
                                            _buildCell('', 100, alignment: Alignment.center, child: IconButton(
                                              icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20), 
                                              onPressed: () {
                                                final fileName = record.logHistoryId != null ? logsMap[record.logHistoryId] : null;
                                                _showRecordDetails(context, record, dictionaryMap, fileName);
                                              }, 
                                              padding: EdgeInsets.zero, 
                                              constraints: const BoxConstraints(),
                                            )),
                                            _buildCopyableCell(record.cid, 140, typeLabel: 'CID', fontWeight: FontWeight.w500),
                                            _buildCell(anagraficheMap[record.cid.trim().padLeft(8, '0')] ?? '', 220, fontWeight: FontWeight.w500),
                                            _buildCopyableCell(
                                              record.numeroTrasferta,
                                              160,
                                              typeLabel: 'Trasferta',
                                              color: sapTrasferte.contains(record.numeroTrasferta.trim())
                                                  ? Colors.green.shade800
                                                  : Colors.red.shade700,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            _buildCell(
                                              '',
                                              110,
                                              alignment: Alignment.center,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: record.isScarto ? Colors.red.shade50 : Colors.green.shade50,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: record.isScarto ? Colors.red.shade200 : Colors.green.shade200),
                                                ),
                                                child: Text(
                                                  record.isScarto ? 'SCARTO' : 'REGOLARE',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: record.isScarto ? Colors.red.shade700 : Colors.green.shade700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            _buildCell('${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}', 140, fontWeight: FontWeight.bold, color: record.isNegative ? Colors.red.shade700 : Colors.green.shade800),
                                            _buildCell('', 80, child: Icon(record.isNegative ? Icons.remove_circle_outline : Icons.add_circle_outline, color: record.isNegative ? Colors.red.shade300 : Colors.green.shade300, size: 18)),
                                            _buildCell(dictionaryMap[record.giustificativoSpesa] != null ? '${record.giustificativoSpesa} - ${dictionaryMap[record.giustificativoSpesa]}' : record.giustificativoSpesa, 250, color: dictionaryMap[record.giustificativoSpesa] != null ? SkyTheme.timBlue : null),
                                            _buildCopyableCell(record.numeroBolla, 150, typeLabel: 'Bolla'),
                                            _buildCell(record.logHistoryId != null ? (logsMap[record.logHistoryId] ?? '') : '', 200),
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
    ref.read(selectedImportoProvider.notifier).state = null;
    ref.read(tcSelectedLogHistoryIdsProvider.notifier).state = {};
    ref.read(tcIncrocioFilterProvider.notifier).state = ContabileIncrocioFilter.all;
    ref.read(tcScartoFilterProvider.notifier).state = ContabileScartoFilter.all;
    ref.read(analysisPageProvider.notifier).state = 0;
    _trasfertaController.clear();
    _importoController.clear();
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
    final allLogs = ref.watch(logHistoryProvider);
    final ecLogs = allLogs.where((log) => log.sourceType == 'Tracciato Contabile').toList();
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
                _buildDrawerSectionTitle('VALORI'),
                const SizedBox(height: 12),
                _buildImportoFilterField(context, ref),
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
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('STATO RISCONTRO'),
                const SizedBox(height: 12),
                _buildChoiceFilter<ContabileIncrocioFilter>(
                  ref.watch(tcIncrocioFilterProvider),
                  {
                    ContabileIncrocioFilter.all: 'Tutti',
                    ContabileIncrocioFilter.matched: 'Riscontrati SAP',
                    ContabileIncrocioFilter.notMatched: 'Non Riscontrati SAP',
                  },
                  (val) => ref.read(tcIncrocioFilterProvider.notifier).state = val,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('STATO SCARTO'),
                const SizedBox(height: 12),
                _buildChoiceFilter<ContabileScartoFilter>(
                  ref.watch(tcScartoFilterProvider),
                  {
                    ContabileScartoFilter.all: 'Tutti',
                    ContabileScartoFilter.scarti: 'Scarti',
                    ContabileScartoFilter.regolari: 'Regolari',
                  },
                  (val) => ref.read(tcScartoFilterProvider.notifier).state = val,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('FILE CARICATI'),
                const SizedBox(height: 12),
                _buildFileSelectionTrigger(
                  context,
                  'Seleziona File',
                  ref.watch(tcSelectedLogHistoryIdsProvider),
                  ecLogs,
                  (next) {
                    ref.read(tcSelectedLogHistoryIdsProvider.notifier).state = next;
                  },
                  icon: Icons.insert_drive_file_outlined,
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

  Widget _buildImportoFilterField(BuildContext context, WidgetRef ref) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.euro_symbol_rounded, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _importoController,
              decoration: const InputDecoration(
                hintText: 'Filtra per importo...',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                ref.read(selectedImportoProvider.notifier).state = value.isEmpty ? null : value;
                ref.read(analysisPageProvider.notifier).state = 0;
              },
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

  Widget _buildFileSelectionTrigger(
    BuildContext context,
    String label,
    Set<String> selectedValues,
    List<LogHistory> logs,
    Function(Set<String>) onSelectedChanged, {
    IconData? icon,
  }) {
    final selectedCount = selectedValues.length;
    String displayText = 'Tutti i file';
    if (selectedCount == 1) {
      final matching = logs.where((l) => l.uniqueCode == selectedValues.first);
      if (matching.isNotEmpty) {
        displayText = matching.first.fileName;
      }
    } else if (selectedCount > 1) {
      displayText = '$selectedCount file selezionati';
    }

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
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showFileSelectionModal(context, selectedValues, logs, onSelectedChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: selectedCount == 0 ? Colors.grey : Colors.black87,
                      fontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFileSelectionModal(
    BuildContext context,
    Set<String> initialSelected,
    List<LogHistory> logs,
    Function(Set<String>) onSelectedChanged,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return FileSelectionDialog(
          logs: logs,
          initialSelected: initialSelected,
          onSelectedChanged: onSelectedChanged,
        );
      },
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

  void _showRecordDetails(BuildContext context, TracciatoContabile record, Map<String, String> dictionaryMap, String? loadingFileName) {
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
                          _buildDetailRow(
                            'Stato Quadratura', 
                            record.isScarto ? 'SCARTATO' : 'REGOLARE',
                            isHighlight: record.isScarto,
                            highlightColor: record.isScarto ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                          _buildDetailRow('File Caricamento', loadingFileName ?? '-'),
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
          if (a.cid != null) a.cid!.trim().padLeft(8, '0'): (a.nominativo ?? '').trim()
      };
      final unitaOrgMap = {
        for (var a in anagrafiche)
          if (a.cid != null) a.cid!.trim().padLeft(8, '0'): (a.unitaOrganizzativa ?? '').trim()
      };

      final dictionaries = ref.read(dictionaryProvider);
      final dictMap = {
        for (final d in dictionaries) d.code.trim().toUpperCase(): d.value
      };

      final sapRecords = ref.read(trasferteSapProvider);
      final sapTrasferte = sapRecords
          .map((r) => r.numeroTrasferta.trim())
          .where((t) => t.isNotEmpty)
          .toSet();

      final allLogs = ref.read(logHistoryProvider);
      final logsMap = {for (final log in allLogs) log.uniqueCode: log.fileName};

      // STILI
      final headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#003399'), // TIM Blue
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final okStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#D4EDDA'), // Light green
        fontColorHex: ExcelColor.fromHexString('#155724'), // Dark green
      );

      final okAmountStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#D4EDDA'),
        fontColorHex: ExcelColor.fromHexString('#155724'),
        horizontalAlign: HorizontalAlign.Right,
      );

      final koStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F8D7DA'), // Light red
        fontColorHex: ExcelColor.fromHexString('#721C24'), // Dark red
      );

      final koAmountStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F8D7DA'),
        fontColorHex: ExcelColor.fromHexString('#721C24'),
        horizontalAlign: HorizontalAlign.Right,
      );

      // Header
      sheet.appendRow([
        TextCellValue('CID'),
        TextCellValue('Nominativo'),
        TextCellValue('Unità Org.'),
        TextCellValue('Trasferta'),
        TextCellValue('Progressivo'),
        TextCellValue('Società'),
        TextCellValue('Nome Società'),
        TextCellValue('Tipo Dipendente'),
        TextCellValue('Descrizione Tipo Dipendente'),
        TextCellValue('Giustificativo Spesa'),
        TextCellValue('Descrizione Giustificativo'),
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
        TextCellValue('Stato Riscontro SAP'),
        TextCellValue('Scarto (SI/NO)'),
        TextCellValue('Nome File Ingresso'),
      ]);

      // Dati
      for (final r in records) {
        final amountValue = r.isNegative ? -r.importo : r.importo;
        final isMatched = sapTrasferte.contains(r.numeroTrasferta.trim());
        
        final socCode = r.societa.trim().toUpperCase();
        final socName = dictMap[socCode] ?? '';

        final tdCode = r.tipoDipendente.trim().toUpperCase();
        final tdDesc = dictMap[tdCode] ?? '';

        final giustCode = r.giustificativoSpesa.trim().toUpperCase();
        final giustDesc = dictMap[giustCode] ?? '';

        final inputFileName = (r.logHistoryId != null ? logsMap[r.logHistoryId] : null) ??
            (r.scartoLogHistoryId != null ? logsMap[r.scartoLogHistoryId] : null) ??
            '';

        sheet.appendRow([
          TextCellValue(r.cid),
          TextCellValue(anagraficheMap[r.cid.trim().padLeft(8, '0')] ?? ''),
          TextCellValue(unitaOrgMap[r.cid.trim().padLeft(8, '0')] ?? ''),
          TextCellValue(r.numeroTrasferta),
          TextCellValue(r.progressivo),
          TextCellValue(r.societa),
          TextCellValue(socName),
          TextCellValue(r.tipoDipendente),
          TextCellValue(tdDesc),
          TextCellValue(r.giustificativoSpesa),
          TextCellValue(giustDesc),
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
          TextCellValue(isMatched ? 'RISCONTRATO SAP' : 'NON RISCONTRATO SAP'),
          TextCellValue(r.isScarto ? 'SI' : 'NO'),
          TextCellValue(inputFileName),
        ]);
      }

      // Applica stili alle righe
      const colCount = 25;
      for (var col = 0; col < colCount; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }
      sheet.setRowHeight(0, 30);

      int rowIndex = 1;
      for (final r in records) {
        final isMatched = sapTrasferte.contains(r.numeroTrasferta.trim());
        final rowStyle = isMatched ? okStyle : koStyle;
        final amountStyle = isMatched ? okAmountStyle : koAmountStyle;

        for (var col = 0; col < colCount; col++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
          if (col == 19) { // Column per Importo
            cell.cellStyle = amountStyle;
          } else {
            cell.cellStyle = rowStyle;
          }
        }
        rowIndex++;
      }

      // Imposta larghezza colonne
      sheet.setColumnWidth(0, 12);  // CID
      sheet.setColumnWidth(1, 25);  // Nominativo
      sheet.setColumnWidth(2, 25);  // Unità Org.
      sheet.setColumnWidth(3, 15);  // Trasferta
      sheet.setColumnWidth(4, 12);  // Progressivo
      sheet.setColumnWidth(5, 10);  // Società
      sheet.setColumnWidth(6, 25);  // Nome Società
      sheet.setColumnWidth(7, 15);  // Tipo Dipendente
      sheet.setColumnWidth(8, 25);  // Descrizione Tipo Dipendente
      sheet.setColumnWidth(9, 15);  // Giustificativo Spesa
      sheet.setColumnWidth(10, 30); // Descrizione Giustificativo
      sheet.setColumnWidth(11, 15); // Numero Bolla
      sheet.setColumnWidth(12, 15); // Data Spesa
      sheet.setColumnWidth(13, 35); // Località
      sheet.setColumnWidth(14, 15); // Data Inizio
      sheet.setColumnWidth(15, 12); // Ora Inizio
      sheet.setColumnWidth(16, 15); // Data Fine
      sheet.setColumnWidth(17, 12); // Ora Fine
      sheet.setColumnWidth(18, 12); // Tipo Attività
      sheet.setColumnWidth(19, 15); // Importo
      sheet.setColumnWidth(20, 10); // Valuta
      sheet.setColumnWidth(21, 10); // Segno
      sheet.setColumnWidth(22, 20); // Stato Riscontro
      sheet.setColumnWidth(23, 18); // Scarto (SI/NO)
      sheet.setColumnWidth(24, 30); // Nome File Ingresso

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

  String _formatAmount(double amount, [String currency = 'EUR']) {
    final isNeg = amount < 0;
    final absVal = amount.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimals = parts[1];
    
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formattedWhole = whole.replaceAllMapped(reg, (Match match) => '${match[1]}.');
    
    return '${isNeg ? "-" : ""}$formattedWhole,$decimals $currency';
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgLightColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgLightColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
