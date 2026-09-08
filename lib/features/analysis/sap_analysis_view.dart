import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';

import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/shared/widgets/file_selection_dialog.dart';

// SAP Filter Providers
final sapMonthProvider = StateProvider<String?>((ref) => null);
final sapYearProvider = StateProvider<String?>((ref) => null);
final sapTrasfertaProvider = StateProvider<String?>((ref) => null);
final sapSocietaProvider = StateProvider<Set<String>>((ref) => {});
final sapTipoDipendenteProvider = StateProvider<Set<String>>((ref) => {});
final sapRichiestaProvider = StateProvider<String?>((ref) => null);
final sapSelectedLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});
final sapPageProvider = StateProvider<int>((ref) => 0);
final sapSortAscendingProvider = StateProvider<bool>((ref) => false);

enum SapTrasfertaPresenzaFilter { all, present, notPresent }
final sapTrasfertaPresenzaFilterProvider = StateProvider<SapTrasfertaPresenzaFilter>((ref) => SapTrasfertaPresenzaFilter.all);

final _sapDateRegex = RegExp(r'[./-]');

String _getSapSortKey(String data) {
  if (data.length >= 10 && data[2] == '/' && data[5] == '/') {
    return '${data.substring(6, 10)}${data.substring(3, 5)}${data.substring(0, 2)}';
  }
  final parts = data.split(_sapDateRegex);
  if (parts.length == 3) {
    if (parts[0].length == 4) {
      return '${parts[0]}${parts[1].padLeft(2, '0')}${parts[2].padLeft(2, '0')}';
    } else {
      return '${parts[2].padLeft(4, '0')}${parts[1].padLeft(2, '0')}${parts[0].padLeft(2, '0')}';
    }
  }
  return data;
}

class SapAnalysisView extends ConsumerStatefulWidget {
  const SapAnalysisView({super.key});

  @override
  ConsumerState<SapAnalysisView> createState() => _SapAnalysisViewState();
}

class _SapAnalysisViewState extends ConsumerState<SapAnalysisView> {
  final _trasfertaController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  final _statsScrollController = ScrollController();

  @override
  void dispose() {
    _trasfertaController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _statsScrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(tracciatoSapProvider);
    final selectedMonth = ref.watch(sapMonthProvider);
    final selectedYear = ref.watch(sapYearProvider);
    final selectedTrasferta = ref.watch(sapTrasfertaProvider);
    final selectedRichiesta = ref.watch(sapRichiestaProvider);
    final selectedSocieta = ref.watch(sapSocietaProvider);
    final selectedTipoDipendente = ref.watch(sapTipoDipendenteProvider);
    final selectedLogHistoryIds = ref.watch(sapSelectedLogHistoryIdsProvider);
    final allLogs = ref.watch(logHistoryProvider);
    String? selectedLogFileName;
    if (selectedLogHistoryIds.length == 1) {
      for (final log in allLogs) {
        if (log.uniqueCode == selectedLogHistoryIds.first) {
          selectedLogFileName = log.fileName;
          break;
        }
      }
    }
    final sortAscending = ref.watch(sapSortAscendingProvider);
    final currentPage = ref.watch(sapPageProvider);
    final dictionaries = ref.watch(dictionaryProvider);
    final dictionaryMap = {for (var d in dictionaries) d.code: d.value};
    final trasfertaFilter = ref.watch(sapTrasfertaPresenzaFilterProvider);
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
      selectedSocieta.isNotEmpty,
      selectedTipoDipendente.isNotEmpty,
      selectedTrasferta != null,
      selectedRichiesta != null,
      trasfertaFilter != SapTrasfertaPresenzaFilter.all,
      selectedLogHistoryIds.isNotEmpty,
    ].where((e) => e).length;

    final Set<String> yearSet = {};
    final Set<String> societaSet = {};
    final Set<String> tipoDipendenteSet = {};
    for (int i = 0; i < allRecords.length; i++) {
      final r = allRecords[i];
      if (r.societaCodice.isNotEmpty) societaSet.add(r.societaCodice);
      if (r.tipoDipendente.isNotEmpty) tipoDipendenteSet.add(r.tipoDipendente);
      final parts = r.data.split(_sapDateRegex);
      if (parts.length == 3 && parts[2].isNotEmpty) {
        yearSet.add(parts[2]);
      }
    }
    final availableYears = yearSet.toList()..sort();
    final availableSocieta = societaSet.toList()..sort();
    final availableTipoDipendente = tipoDipendenteSet.toList()..sort();

    const monthNames = {
      '01': 'Gennaio', '02': 'Febbraio', '03': 'Marzo', '04': 'Aprile',
      '05': 'Maggio', '06': 'Giugno', '07': 'Luglio', '08': 'Agosto',
      '09': 'Settembre', '10': 'Ottobre', '11': 'Novembre', '12': 'Dicembre',
    };

    final filteredRecords = <TracciatoSap>[];
    for (int i = 0; i < allRecords.length; i++) {
      final r = allRecords[i];
      if (selectedLogHistoryIds.isNotEmpty && !selectedLogHistoryIds.contains(r.logHistoryId)) continue;
      
      final parts = r.data.split(_sapDateRegex);
      String? month, year;
      if (parts.length == 3) {
        month = parts[1].padLeft(2, '0');
        year = parts[2];
      }

      if (selectedMonth != null && month != selectedMonth) continue;
      if (selectedYear != null && year != selectedYear) continue;
      if (selectedTrasferta != null) {
        final query = selectedTrasferta.toLowerCase();
        if (!r.numeroTrasferta.toLowerCase().contains(query) && 
            !r.cid.toLowerCase().contains(query) &&
            !(r.cdRichiesta?.toLowerCase().contains(query) ?? false)) {
          continue;
        }
      }
      if (selectedSocieta.isNotEmpty && !selectedSocieta.contains(r.societaCodice)) continue;
      if (selectedTipoDipendente.isNotEmpty && !selectedTipoDipendente.contains(r.tipoDipendente)) continue;
      if (selectedRichiesta != null && r.cdRichiesta != null && !r.cdRichiesta!.contains(selectedRichiesta)) continue;

      if (trasfertaFilter != SapTrasfertaPresenzaFilter.all) {
        final isPresent = contabileTrasferte.contains(r.numeroTrasferta.trim());
        if (trasfertaFilter == SapTrasfertaPresenzaFilter.present && !isPresent) continue;
        if (trasfertaFilter == SapTrasfertaPresenzaFilter.notPresent && isPresent) continue;
      }

      filteredRecords.add(r);
    }

    filteredRecords.sort((a, b) {
      final keyA = _getSapSortKey(a.data);
      final keyB = _getSapSortKey(b.data);
      return sortAscending ? keyA.compareTo(keyB) : keyB.compareTo(keyA);
    });

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    final totalFiltered = filteredRecords.length;
    double totalAmount = 0.0;
    double okAmount = 0.0;
    double koAmount = 0.0;
    final Set<String> uniqueTravelNumbers = {};
    final Set<String> okTravels = {};
    final Set<String> koTravels = {};

    for (int i = 0; i < filteredRecords.length; i++) {
      final r = filteredRecords[i];
      totalAmount += r.importo;
      final t = r.numeroTrasferta.trim();
      if (t.isNotEmpty) {
        uniqueTravelNumbers.add(t);
        if (contabileTrasferte.contains(t)) {
          okTravels.add(t);
          okAmount += r.importo;
        } else {
          koTravels.add(t);
          koAmount += r.importo;
        }
      }
    }

    final okTravelsCount = okTravels.length;
    final koTravelsCount = koTravels.length;
    final totalFilteredTravels = uniqueTravelNumbers.length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableYears, availableSocieta, availableTipoDipendente),
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
                                decoration: const InputDecoration(
                                  hintText: 'Cerca per trasferta, CID o richiesta...', 
                                  border: InputBorder.none, 
                                  isDense: true
                                ),
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
                        if (selectedTrasferta != null)
                          _buildFilterChip('Cerca: "$selectedTrasferta"', () {
                            ref.read(sapTrasfertaProvider.notifier).state = null;
                            _trasfertaController.clear();
                          }),
                        if (selectedYear != null) _buildFilterChip('Anno: $selectedYear', () => ref.read(sapYearProvider.notifier).state = null),
                        if (selectedMonth != null) _buildFilterChip('Mese: ${monthNames[selectedMonth]}', () => ref.read(sapMonthProvider.notifier).state = null),
                        ...selectedSocieta.map((soc) {
                          final socDesc = dictionaryMap[soc];
                          final label = socDesc != null ? '$soc - $socDesc' : soc;
                          return _buildFilterChip('Società: $label', () {
                            final next = Set<String>.from(selectedSocieta)..remove(soc);
                            ref.read(sapSocietaProvider.notifier).state = next;
                          });
                        }),
                        ...selectedTipoDipendente.map((tipo) {
                          final tipoDesc = dictionaryMap[tipo];
                          final label = tipoDesc != null ? '$tipo - $tipoDesc' : tipo;
                          return _buildFilterChip('Tipo Dip.: $label', () {
                            final next = Set<String>.from(selectedTipoDipendente)..remove(tipo);
                            ref.read(sapTipoDipendenteProvider.notifier).state = next;
                          });
                        }),
                        if (trasfertaFilter != SapTrasfertaPresenzaFilter.all)
                          _buildFilterChip(
                            trasfertaFilter == SapTrasfertaPresenzaFilter.present
                                ? 'Riscontro: Presenti'
                                : 'Riscontro: Non Presenti',
                            () => ref.read(sapTrasfertaPresenzaFilterProvider.notifier).state = SapTrasfertaPresenzaFilter.all,
                          ),
                        if (selectedLogHistoryIds.isNotEmpty)
                          _buildFilterChip(
                            selectedLogFileName != null
                                ? 'File: $selectedLogFileName'
                                : 'File: ${selectedLogHistoryIds.length} selezionati',
                            () => ref.read(sapSelectedLogHistoryIdsProvider.notifier).state = {},
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
                    title: 'TRASFERTE TROVATE',
                    value: '$okTravelsCount',
                    subtitle: 'Importo SAP: ${_formatAmount(okAmount)}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    bgLightColor: Colors.green.shade50,
                  );
                  final card3 = _buildSummaryCard(
                    title: 'TRASFERTE NON TROVATE',
                    value: '$koTravelsCount',
                    subtitle: 'Importo SAP: ${_formatAmount(koAmount)}',
                    icon: Icons.cancel_outlined,
                    color: Colors.red.shade700,
                    bgLightColor: Colors.red.shade50,
                  );

                  if (constraints.maxWidth >= 950) {
                    return Row(
                      children: [
                        Expanded(child: card1),
                        const SizedBox(width: 16),
                        Expanded(child: card2),
                        const SizedBox(width: 16),
                        Expanded(child: card3),
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
                    )
                  ]
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
                          width: 1200,
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
                                    _buildCell('TRASFERTA', 160, isHeader: true),
                                    _buildCell('DATA', 120, isHeader: true),
                                    _buildCell('IMPORTO', 140, isHeader: true),
                                    _buildCell('CD RICHIESTA', 150, isHeader: true),
                                    _buildCell('CODICE STATO', 120, isHeader: true),
                                    _buildCell('SOC. CODICE', 120, isHeader: true),
                                    _buildCell('TIPO SPESA', 150, isHeader: true),
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
                                            _buildCell('', 100, alignment: Alignment.center, child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                IconButton(icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20), onPressed: () => _showRecordDetails(context, record), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                                const SizedBox(width: 8),
                                                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _deleteRecord(context, ref, record), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                              ],
                                            )),
                                            _buildCopyableCell(record.cid, 140, typeLabel: 'CID', fontWeight: FontWeight.w500),
                                            _buildCopyableCell(
                                              record.numeroTrasferta,
                                              160,
                                              typeLabel: 'Trasferta',
                                              fontWeight: FontWeight.bold,
                                              color: contabileTrasferte.contains(record.numeroTrasferta.trim())
                                                  ? Colors.green.shade800
                                                  : Colors.red.shade700,
                                            ),
                                            _buildCell(record.data, 120),
                                            _buildCell('${record.importo.toStringAsFixed(2)} ${record.valuta}', 140, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                            _buildCell(record.cdRichiesta ?? '-', 150),
                                            _buildCell(record.codiceStato ?? '-', 120),
                                            _buildCell(record.societaCodice, 120),
                                            _buildCell(record.tipoSpesaCodice, 150),
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
                        ref.read(sapPageProvider.notifier).state--;
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
                        ref.read(sapPageProvider.notifier).state++;
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
    ref.read(sapYearProvider.notifier).state = null;
    ref.read(sapMonthProvider.notifier).state = null;
    ref.read(sapSocietaProvider.notifier).state = {};
    ref.read(sapTipoDipendenteProvider.notifier).state = {};
    ref.read(sapRichiestaProvider.notifier).state = null;
    ref.read(sapSelectedLogHistoryIdsProvider.notifier).state = {};
    ref.read(sapTrasfertaPresenzaFilterProvider.notifier).state = SapTrasfertaPresenzaFilter.all;
    ref.read(sapPageProvider.notifier).state = 0;
    _trasfertaController.clear();
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

  Widget _buildFilterDrawer(BuildContext context, WidgetRef ref, List<String> years, List<String> societa, List<String> tipiDipendente) {
    final monthNames = {
      '01': 'Gennaio', '02': 'Febbraio', '03': 'Marzo', '04': 'Aprile',
      '05': 'Maggio', '06': 'Giugno', '07': 'Luglio', '08': 'Agosto',
      '09': 'Settembre', '10': 'Ottobre', '11': 'Novembre', '12': 'Dicembre',
    };
    final dictionaries = ref.watch(dictionaryProvider);
    final dictionaryMap = {for (var d in dictionaries) d.code: d.value};
    final allLogs = ref.watch(logHistoryProvider);
    final sapLogs = allLogs.where((log) => log.sourceType == 'Tracciato SAP').toList();

    return Drawer(
      width: 350,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [SkyTheme.timBlue, Color(0xFF001F60)],
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
                      'FILTRI SAP',
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Filtra il tracciato SAP',
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
                _buildFilterDropdown<String?>('Seleziona Anno', ref.watch(sapYearProvider), years, (val) => ref.read(sapYearProvider.notifier).state = val, icon: Icons.calendar_today),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Seleziona Mese', ref.watch(sapMonthProvider), monthNames.keys.toList(), (val) => ref.read(sapMonthProvider.notifier).state = val, icon: Icons.calendar_month, labelMapper: (val) => monthNames[val] ?? val ?? ''),
                const SizedBox(height: 24),
                _buildChipsMultiSelectFilter(
                  'Società',
                  ref.watch(sapSocietaProvider),
                  societa,
                  (val) {
                    final current = ref.read(sapSocietaProvider);
                    final next = Set<String>.from(current);
                    if (next.contains(val)) {
                      next.remove(val);
                    } else {
                      next.add(val);
                    }
                    ref.read(sapSocietaProvider.notifier).state = next;
                  },
                  icon: Icons.business,
                  dictionaryMap: dictionaryMap,
                ),
                const SizedBox(height: 24),
                _buildChipsMultiSelectFilter(
                  'Tipo Dipendente',
                  ref.watch(sapTipoDipendenteProvider),
                  tipiDipendente,
                  (val) {
                    final current = ref.read(sapTipoDipendenteProvider);
                    final next = Set<String>.from(current);
                    if (next.contains(val)) {
                      next.remove(val);
                    } else {
                      next.add(val);
                    }
                    ref.read(sapTipoDipendenteProvider.notifier).state = next;
                  },
                  icon: Icons.badge_outlined,
                  dictionaryMap: dictionaryMap,
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.rule, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Riscontro Contabile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildChoiceFilter<SapTrasfertaPresenzaFilter>(
                  ref.watch(sapTrasfertaPresenzaFilterProvider),
                  {
                    SapTrasfertaPresenzaFilter.all: 'Tutte',
                    SapTrasfertaPresenzaFilter.present: 'Presenti',
                    SapTrasfertaPresenzaFilter.notPresent: 'Non Presenti',
                  },
                  (val) => ref.read(sapTrasfertaPresenzaFilterProvider.notifier).state = val,
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.insert_drive_file_outlined, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('File Caricati', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFileSelectionTrigger(
                  context,
                  'Seleziona File',
                  ref.watch(sapSelectedLogHistoryIdsProvider),
                  sapLogs,
                  (next) {
                    ref.read(sapSelectedLogHistoryIdsProvider.notifier).state = next;
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


  Widget _buildChipsMultiSelectFilter(
    String label,
    Set<String> selectedValues,
    List<String> options,
    Function(String) onToggle, {
    IconData? icon,
    Map<String, String>? dictionaryMap,
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
            final desc = dictionaryMap?[option];
            final optionLabel = desc != null ? '$option - $desc' : option;
            
            return FilterChip(
              label: Text(
                optionLabel, 
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
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? SkyTheme.timBlue : Colors.grey.shade300,
                  width: 1,
                ),
              ),
            );
          }).toList(),
        ),
      ],
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

  String _formatAmount(double value) {
    final absVal = value.abs();
    final isNeg = value < 0;
    
    final whole = absVal.truncate();
    final decimal = ((absVal - whole) * 100).round().toString().padLeft(2, '0');
    
    final wholeStr = whole.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < wholeStr.length; i++) {
      if (i > 0 && (wholeStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(wholeStr[i]);
    }
    
    final formattedWhole = buffer.toString();
    return '${isNeg ? "-" : ""}$formattedWhole,$decimal €';
  }
}

