import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border, TextSpan;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/estratto_amex_provider.dart';
import 'package:travel_check/features/upload/models/estratto_amex.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';
import 'package:travel_check/core/theme/app_theme.dart';

import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/shared/widgets/file_selection_dialog.dart';

// Filter providers for Estratti AMEX
final amexSelectedSearchProvider = StateProvider<String?>((ref) => null);
final amexSelectedFornitoreProvider = StateProvider<String?>((ref) => null);
final amexSelectedNumeroContoProvider = StateProvider<Set<String>>((ref) => {});
final amexStartDateProvider = StateProvider<DateTime?>((ref) => null);
final amexEndDateProvider = StateProvider<DateTime?>((ref) => null);
final amexSelectedLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});
final amexFilterOspitiProvider = StateProvider<bool>((ref) => false);
final amexFilterTopProvider = StateProvider<bool>((ref) => false);
final amexSortAscendingProvider = StateProvider<bool>((ref) => false);
final amexPageProvider = StateProvider<int>((ref) => 0);

enum AmexTrasfertaPresenzaFilter { all, present, notPresent }
final amexTrasfertaPresenzaFilterProvider = StateProvider<AmexTrasfertaPresenzaFilter>((ref) => AmexTrasfertaPresenzaFilter.all);

enum AmexSapPresenzaFilter { all, present, notPresent, matching, discrepancy }
final amexSapPresenzaFilterProvider = StateProvider<AmexSapPresenzaFilter>((ref) => AmexSapPresenzaFilter.all);

final _leadingZerosRegex = RegExp(r'^0+');

String _cleanT(String? s) {
  if (s == null) return '';
  return s.trim().split('.')[0].replaceAll(_leadingZerosRegex, '');
}

class AmexAnalysisView extends ConsumerStatefulWidget {
  const AmexAnalysisView({super.key});

  @override
  ConsumerState<AmexAnalysisView> createState() => _AmexAnalysisViewState();
}

class _AmexAnalysisViewState extends ConsumerState<AmexAnalysisView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  final _statsScrollController = ScrollController();
  bool _isOspitiInfoExpanded = false;
  bool _isTopInfoExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _statsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(estrattoAmexProvider);
    final searchFilter = ref.watch(amexSelectedSearchProvider);
    final selectedFornitore = ref.watch(amexSelectedFornitoreProvider);
    final selectedNumeroConto = ref.watch(amexSelectedNumeroContoProvider);
    final startDate = ref.watch(amexStartDateProvider);
    final endDate = ref.watch(amexEndDateProvider);
    final selectedLogHistoryIds = ref.watch(amexSelectedLogHistoryIdsProvider);
    final filterOspiti = ref.watch(amexFilterOspitiProvider);
    final filterTop = ref.watch(amexFilterTopProvider);
    final allLogs = ref.watch(logHistoryProvider);
    final logsMap = {for (var log in allLogs) log.uniqueCode: log.fileName};
    final amexLogIds = allRecords.map((r) => r.logHistoryId).whereType<String>().toSet();
    final amexLogs = allLogs.where((log) => log.sourceType == 'Estratto AMEX' || amexLogIds.contains(log.uniqueCode)).toList();
    final ospitiLogs = amexLogs.where((log) => log.fileName.toUpperCase().contains('OSPITI')).toList();
    final ospitiLogCodes = ospitiLogs.expand((l) => [l.uniqueCode, l.fileName]).toSet();
    final topLogs = amexLogs.where((log) => log.fileName.toUpperCase().contains('TOP')).toList();
    final topLogCodes = topLogs.expand((l) => [l.uniqueCode, l.fileName]).toSet();
    String? selectedLogFileName;
    if (selectedLogHistoryIds.length == 1) {
      for (final log in allLogs) {
        if (log.uniqueCode == selectedLogHistoryIds.first) {
          selectedLogFileName = log.fileName;
          break;
        }
      }
    }
    final sortAscending = ref.watch(amexSortAscendingProvider);
    final currentPage = ref.watch(amexPageProvider);
    final trasfertaFilter = ref.watch(amexTrasfertaPresenzaFilterProvider);
    final sapFilter = ref.watch(amexSapPresenzaFilterProvider);
    final contabileRecords = ref.watch(tracciatoContabilesProvider);
    final sapRecords = ref.watch(tracciatoSapProvider);
    final contabileTrasferte = contabileRecords
        .map((tc) => tc.numeroTrasferta.trim())
        .where((t) => t.isNotEmpty)
        .toSet();

    // Mappatura e totali SAP per Trasferta normalizzata
    final sapMapByCleanedT = <String, List<TracciatoSap>>{};
    final sapTotalByCleanedT = <String, double>{};
    for (final sap in sapRecords) {
      final ct = _cleanT(sap.numeroTrasferta);
      if (ct.isNotEmpty) {
        sapMapByCleanedT.putIfAbsent(ct, () => []).add(sap);
        sapTotalByCleanedT[ct] = (sapTotalByCleanedT[ct] ?? 0.0) + sap.importo;
      }
    }

    // Matching 1:1 EstrattoAmex <-> TracciatoSap
    final amexToSapMatch = <int, TracciatoSap>{};
    final amexGroupedByCleanT = <String, List<EstrattoAmex>>{};
    for (final ame in allRecords) {
      final ct = _cleanT(ame.numeroTrasferta);
      if (ct.isNotEmpty) {
        amexGroupedByCleanT.putIfAbsent(ct, () => []).add(ame);
      }
    }

    for (final entry in amexGroupedByCleanT.entries) {
      final ct = entry.key;
      final amexes = entry.value;
      final saps = sapMapByCleanedT[ct];
      if (saps == null || saps.isEmpty) continue;

      final matchedSapIds = <int>{};
      // Pass 1: match esatto importo
      for (final ame in amexes) {
        if (ame.importoLordo == null) continue;
        for (final sap in saps) {
          if (matchedSapIds.contains(sap.id)) continue;
          if ((sap.importo - ame.importoLordo!).abs() < 0.015) {
            amexToSapMatch[ame.id] = sap;
            matchedSapIds.add(sap.id);
            break;
          }
        }
      }

      // Pass 2: se 1 solo rimasto
      final remainingAmexes = amexes.where((a) => !amexToSapMatch.containsKey(a.id)).toList();
      final remainingSaps = saps.where((s) => !matchedSapIds.contains(s.id)).toList();
      if (remainingAmexes.length == 1 && remainingSaps.length == 1) {
        amexToSapMatch[remainingAmexes.first.id] = remainingSaps.first;
        matchedSapIds.add(remainingSaps.first.id);
      } else if (remainingAmexes.isNotEmpty && remainingSaps.isNotEmpty) {
        // Pass 3: match più vicino
        for (final ame in remainingAmexes) {
          if (ame.importoLordo == null) continue;
          TracciatoSap? closestSap;
          double minDiff = double.infinity;
          for (final sap in remainingSaps) {
            if (matchedSapIds.contains(sap.id)) continue;
            final diff = (sap.importo - ame.importoLordo!).abs();
            if (diff < minDiff) {
              minDiff = diff;
              closestSap = sap;
            }
          }
          if (closestSap != null) {
            amexToSapMatch[ame.id] = closestSap;
            matchedSapIds.add(closestSap.id);
          }
        }
      }
    }

    final anagrafiche = ref.watch(anagraficaProvider);
    final anagraficheMap = {
      for (var a in anagrafiche)
        if (a.cid != null) a.cid!.trim(): a.nominativo ?? ''
    };
    final dictionaries = ref.watch(dictionaryProvider);
    final contoDictionaryMap = {
      for (var d in dictionaries)
        if (d.category == 'conto') d.code: d.value
    };
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
      selectedNumeroConto.isNotEmpty,
      startDate != null,
      endDate != null,
      trasfertaFilter != AmexTrasfertaPresenzaFilter.all,
      sapFilter != AmexSapPresenzaFilter.all,
      selectedLogHistoryIds.isNotEmpty,
      filterOspiti,
      filterTop,
    ].where((e) => e).length;

    // Estrai fornitori disponibili per il filtro
    final availableFornitori = allRecords
        .map((r) => r.nomeFornitore ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Estrai numero conto disponibili per il filtro
    final availableNumeroConto = allRecords
        .map((r) => r.numeroConto ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      if (filterOspiti && (r.logHistoryId == null || !ospitiLogCodes.contains(r.logHistoryId))) return false;
      if (filterTop && (r.logHistoryId == null || !topLogCodes.contains(r.logHistoryId))) return false;
      if (selectedLogHistoryIds.isNotEmpty && !selectedLogHistoryIds.contains(r.logHistoryId)) return false;
      if (searchFilter != null) {
        final query = searchFilter.toLowerCase();
        final nominativo = anagraficheMap[r.cid?.trim()] ?? '';
        if (!(r.numeroTrasferta?.toLowerCase().contains(query) ?? false) &&
            !(r.cid?.toLowerCase().contains(query) ?? false) &&
            !(r.bolla?.toLowerCase().contains(query) ?? false) &&
            !(r.rifViaggio1?.toLowerCase().contains(query) ?? false) &&
            !(r.dataEstrattoConto?.toLowerCase().contains(query) ?? false) &&
            !nominativo.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (selectedFornitore != null && r.nomeFornitore != selectedFornitore) return false;
      if (selectedNumeroConto.isNotEmpty && (r.numeroConto == null || !selectedNumeroConto.contains(r.numeroConto))) return false;
      
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

      // Filtro Riscontro SAP
      if (sapFilter != AmexSapPresenzaFilter.all) {
        final ct = _cleanT(r.numeroTrasferta);
        final saps = sapMapByCleanedT[ct];
        final hasSap = saps != null && saps.isNotEmpty;
        if (sapFilter == AmexSapPresenzaFilter.present && !hasSap) return false;
        if (sapFilter == AmexSapPresenzaFilter.notPresent && hasSap) return false;
        if (sapFilter == AmexSapPresenzaFilter.matching) {
          if (!hasSap || r.importoLordo == null) return false;
          final matched = amexToSapMatch[r.id];
          if (matched == null || (matched.importo - r.importoLordo!).abs() >= 0.015) {
            return false;
          }
        }
        if (sapFilter == AmexSapPresenzaFilter.discrepancy) {
          if (!hasSap) return false;
          final matched = amexToSapMatch[r.id];
          if (matched != null && r.importoLordo != null && (matched.importo - r.importoLordo!).abs() < 0.015) {
            return false;
          }
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        final cidA = a.cid ?? '';
        final cidB = b.cid ?? '';
        return sortAscending ? cidA.compareTo(cidB) : cidB.compareTo(cidA);
      });

    final totalRecords = filteredRecords.length;
    final reconciledRecordsList = filteredRecords.where((r) => r.numeroTrasferta != null && contabileTrasferte.contains(r.numeroTrasferta!.trim())).toList();
    final reconciledRecords = reconciledRecordsList.length;
    final waitingRecords = totalRecords - reconciledRecords;

    final totalAmountAbsolute = filteredRecords.fold<double>(0.0, (sum, r) => sum + (r.importoLordo ?? 0.0).abs());
    final totalAmountSigned = filteredRecords.fold<double>(0.0, (sum, r) => sum + (r.importoLordo ?? 0.0));

    final reconciledAmountAbsolute = reconciledRecordsList.fold<double>(0.0, (sum, r) => sum + (r.importoLordo ?? 0.0).abs());
    final reconciledAmountSigned = reconciledRecordsList.fold<double>(0.0, (sum, r) => sum + (r.importoLordo ?? 0.0));

    final waitingRecordsList = filteredRecords.where((r) => !(r.numeroTrasferta != null && contabileTrasferte.contains(r.numeroTrasferta!.trim())));
    final waitingAmountAbsolute = waitingRecordsList.fold<double>(0.0, (sum, r) => sum + (r.importoLordo ?? 0.0).abs());
    final waitingAmountSigned = waitingRecordsList.fold<double>(0.0, (sum, r) => sum + (r.importoLordo ?? 0.0));

    // Statistiche SAP
    final Set<String> uniqueFilteredCleanTravels = {};
    final Set<String> uniqueCleanTravelsWithSap = {};
    double totalSapAmount = 0.0;
    for (final r in filteredRecords) {
      final ct = _cleanT(r.numeroTrasferta);
      if (ct.isNotEmpty) {
        uniqueFilteredCleanTravels.add(ct);
        if (sapMapByCleanedT.containsKey(ct) && !uniqueCleanTravelsWithSap.contains(ct)) {
          uniqueCleanTravelsWithSap.add(ct);
          totalSapAmount += sapTotalByCleanedT[ct] ?? 0.0;
        }
      }
    }
    final matchedSapTravelsCount = uniqueCleanTravelsWithSap.length;
    final totalUniqueTravelsCount = uniqueFilteredCleanTravels.length;
    final sapDiscrepancy = totalAmountSigned - totalSapAmount;

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    final ospitiRecordsCount = filteredRecords.where((r) => r.logHistoryId != null && ospitiLogCodes.contains(r.logHistoryId)).length;
    final topRecordsCount = filteredRecords.where((r) => r.logHistoryId != null && topLogCodes.contains(r.logHistoryId)).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableFornitori, availableNumeroConto, contoDictionaryMap, amexLogs, ospitiLogs, topLogs),
      floatingActionButton: filteredRecords.isNotEmpty 
          ? FloatingActionButton(
              onPressed: () => _exportToExcel(filteredRecords, amexToSapMatch),
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
                                decoration: const InputDecoration(hintText: 'Cerca per trasferta, CID, nominativo o bolla...', border: InputBorder.none, isDense: true),
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
                    // Pulsante rapido File OSPITI
                    Tooltip(
                      message: ospitiLogs.isNotEmpty
                          ? 'Filtra i record dai ${ospitiLogs.length} file contenenti la parola "OSPITI"'
                          : 'Nessun file Estratto AMEX contiene "OSPITI" nel nome',
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(amexFilterOspitiProvider.notifier).state = !filterOspiti;
                          ref.read(amexPageProvider.notifier).state = 0;
                        },
                        icon: Icon(
                          filterOspiti ? Icons.check_circle_rounded : Icons.people_alt_outlined,
                          size: 18,
                        ),
                        label: Text('File OSPITI (${ospitiLogs.length})'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: filterOspiti ? Colors.orange.shade700 : Colors.white,
                          foregroundColor: filterOspiti ? Colors.white : (ospitiLogs.isNotEmpty ? Colors.orange.shade900 : Colors.grey),
                          side: BorderSide(
                            color: filterOspiti ? Colors.orange.shade700 : (ospitiLogs.isNotEmpty ? Colors.orange.shade300 : Colors.grey.shade300),
                            width: filterOspiti ? 1.5 : 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Pulsante rapido File TOP
                    Tooltip(
                      message: topLogs.isNotEmpty
                          ? 'Filtra i record dai ${topLogs.length} file contenenti la parola "TOP"'
                          : 'Nessun file Estratto AMEX contiene "TOP" nel nome',
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(amexFilterTopProvider.notifier).state = !filterTop;
                          ref.read(amexPageProvider.notifier).state = 0;
                        },
                        icon: Icon(
                          filterTop ? Icons.check_circle_rounded : Icons.star_rounded,
                          size: 18,
                        ),
                        label: Text('File TOP (${topLogs.length})'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          backgroundColor: filterTop ? Colors.teal.shade700 : Colors.white,
                          foregroundColor: filterTop ? Colors.white : (topLogs.isNotEmpty ? Colors.teal.shade900 : Colors.grey),
                          side: BorderSide(
                            color: filterTop ? Colors.teal.shade700 : (topLogs.isNotEmpty ? Colors.teal.shade300 : Colors.grey.shade300),
                            width: filterTop ? 1.5 : 1,
                          ),
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
                        if (selectedNumeroConto.isNotEmpty) _buildFilterChip('Num. Conto: ${selectedNumeroConto.map((code) => contoDictionaryMap[code] ?? code).join(", ")}', () => ref.read(amexSelectedNumeroContoProvider.notifier).state = {}),
                        if (startDate != null) _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(amexStartDateProvider.notifier).state = null),
                        if (endDate != null) _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(amexEndDateProvider.notifier).state = null),
                        if (trasfertaFilter != AmexTrasfertaPresenzaFilter.all)
                          _buildFilterChip(
                            trasfertaFilter == AmexTrasfertaPresenzaFilter.present
                                ? 'Riscontro: Presenti'
                                : 'Riscontro: Non Presenti',
                            () => ref.read(amexTrasfertaPresenzaFilterProvider.notifier).state = AmexTrasfertaPresenzaFilter.all,
                          ),
                        if (sapFilter != AmexSapPresenzaFilter.all)
                          _buildFilterChip(
                            switch (sapFilter) {
                              AmexSapPresenzaFilter.present => 'SAP: Presenti',
                              AmexSapPresenzaFilter.notPresent => 'SAP: Non Presenti',
                              AmexSapPresenzaFilter.matching => 'SAP: Match Esatto',
                              AmexSapPresenzaFilter.discrepancy => 'SAP: Discrepanza',
                              AmexSapPresenzaFilter.all => '',
                            },
                            () => ref.read(amexSapPresenzaFilterProvider.notifier).state = AmexSapPresenzaFilter.all,
                          ),
                        if (selectedLogHistoryIds.isNotEmpty)
                          _buildFilterChip(
                            selectedLogFileName != null
                                ? 'File: $selectedLogFileName'
                                : 'File: ${selectedLogHistoryIds.length} selezionati',
                            () => ref.read(amexSelectedLogHistoryIdsProvider.notifier).state = {},
                          ),
                        if (filterOspiti)
                          _buildFilterChip(
                            'File OSPITI (${ospitiLogs.length} file)',
                            () {
                              ref.read(amexFilterOspitiProvider.notifier).state = false;
                              ref.read(amexPageProvider.notifier).state = 0;
                            },
                          ),
                        if (filterTop)
                          _buildFilterChip(
                            'File TOP (${topLogs.length} file)',
                            () {
                              ref.read(amexFilterTopProvider.notifier).state = false;
                              ref.read(amexPageProvider.notifier).state = 0;
                            },
                          ),
                        TextButton(onPressed: () => _resetAllFilters(ref), child: const Text('Reset tutto', style: TextStyle(fontSize: 12, color: Colors.red))),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          // DASHBOARD STATS SUMMARY
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
                    title: 'TOTALE IMPORTI / SOMME',
                    value: _formatAmount(totalAmountAbsolute),
                    subtitle: 'Netto (con neg.): ${_formatAmount(totalAmountSigned)}',
                    icon: Icons.folder_open_rounded,
                    color: SkyTheme.timBlue,
                    bgLightColor: SkyTheme.timBlue.withAlpha(20),
                  );
                  final card2 = _buildSummaryCard(
                    title: 'RISCONTRATI / IMPORTO',
                    value: '$reconciledRecords trasferte',
                    subtitle: 'Ass: ${_formatAmount(reconciledAmountAbsolute)} | Net: ${_formatAmount(reconciledAmountSigned)}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    bgLightColor: Colors.green.shade50,
                  );
                  final card3 = _buildSummaryCard(
                    title: 'IN ATTESA / IMPORTO',
                    value: '$waitingRecords trasferte',
                    subtitle: 'Ass: ${_formatAmount(waitingAmountAbsolute)} | Net: ${_formatAmount(waitingAmountSigned)}',
                    icon: Icons.help_outline_rounded,
                    color: Colors.red.shade700,
                    bgLightColor: Colors.red.shade50,
                  );
                  final card4 = _buildSummaryCard(
                    title: 'TOTALE SAP',
                    value: _formatAmount(totalSapAmount),
                    subtitle: 'Riscontro: $matchedSapTravelsCount/$totalUniqueTravelsCount | Disc: ${_formatAmount(sapDiscrepancy)}',
                    icon: Icons.analytics_outlined,
                    color: Colors.green.shade800,
                    bgLightColor: Colors.green.shade50,
                  );

                  if (constraints.maxWidth >= 1200) {
                    return Row(
                      children: [
                        Expanded(child: card1),
                        const SizedBox(width: 12),
                        Expanded(child: card2),
                        const SizedBox(width: 12),
                        Expanded(child: card3),
                        const SizedBox(width: 12),
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
                                SizedBox(width: 280, child: card1),
                                const SizedBox(width: 12),
                                SizedBox(width: 280, child: card2),
                                const SizedBox(width: 12),
                                SizedBox(width: 280, child: card3),
                                const SizedBox(width: 12),
                                SizedBox(width: 280, child: card4),
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
          // BANNER INFORMATIVO FILE OSPITI SE ATTIVO
          if (filterOspiti)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Material(
                color: Colors.orange.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.orange.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.people_alt_outlined, color: Colors.orange.shade900, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FILTRO OSPITI ATTIVO • $ospitiRecordsCount RECORD DA ${ospitiLogs.length} FILE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.orange.shade900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (_isOspitiInfoExpanded) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    ospitiLogs.isNotEmpty
                                        ? 'Record estratti esclusivamente dai file contenenti la parola "OSPITI":'
                                        : 'Nessun file Estratto AMEX caricato contiene la parola "OSPITI" nel nome.',
                                    style: TextStyle(fontSize: 11, color: Colors.orange.shade900.withAlpha(220)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (ospitiLogs.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isOspitiInfoExpanded = !_isOspitiInfoExpanded;
                                });
                              },
                              icon: Icon(
                                _isOspitiInfoExpanded ? Icons.expand_less : Icons.expand_more,
                                size: 18,
                                color: Colors.orange.shade900,
                              ),
                              label: Text(
                                _isOspitiInfoExpanded ? 'Nascondi file' : 'Mostra file (${ospitiLogs.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                backgroundColor: Colors.orange.shade100.withAlpha(160),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: Colors.orange.shade900,
                            onPressed: () {
                              ref.read(amexFilterOspitiProvider.notifier).state = false;
                              ref.read(amexPageProvider.notifier).state = 0;
                            },
                            tooltip: 'Disattiva filtro OSPITI',
                          ),
                        ],
                      ),
                      if (_isOspitiInfoExpanded && ospitiLogs.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ospitiLogs.map((log) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withAlpha(20),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.description_outlined, size: 14, color: Colors.orange.shade800),
                                  const SizedBox(width: 6),
                                  Text(
                                    log.fileName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${log.totalRecords} record',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          // BANNER INFORMATIVO FILE TOP SE ATTIVO
          if (filterTop)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Material(
                color: Colors.teal.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.teal.shade300),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.star_rounded, color: Colors.teal.shade900, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FILTRO TOP ATTIVO • $topRecordsCount RECORD DA ${topLogs.length} FILE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.teal.shade900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (_isTopInfoExpanded) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    topLogs.isNotEmpty
                                        ? 'Record estratti esclusivamente dai file contenenti la parola "TOP":'
                                        : 'Nessun file Estratto AMEX caricato contiene la parola "TOP" nel nome.',
                                    style: TextStyle(fontSize: 11, color: Colors.teal.shade900.withAlpha(220)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (topLogs.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isTopInfoExpanded = !_isTopInfoExpanded;
                                });
                              },
                              icon: Icon(
                                _isTopInfoExpanded ? Icons.expand_less : Icons.expand_more,
                                size: 18,
                                color: Colors.teal.shade900,
                              ),
                              label: Text(
                                _isTopInfoExpanded ? 'Nascondi file' : 'Mostra file (${topLogs.length})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade900,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                backgroundColor: Colors.teal.shade100.withAlpha(160),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            color: Colors.teal.shade900,
                            onPressed: () {
                              ref.read(amexFilterTopProvider.notifier).state = false;
                              ref.read(amexPageProvider.notifier).state = 0;
                            },
                            tooltip: 'Disattiva filtro TOP',
                          ),
                        ],
                      ),
                      if (_isTopInfoExpanded && topLogs.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: topLogs.map((log) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.teal.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.withAlpha(20),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.description_outlined, size: 14, color: Colors.teal.shade800),
                                  const SizedBox(width: 6),
                                  Text(
                                    log.fileName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${log.totalRecords} record',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
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
                          width: 2570,
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
                                _buildCell('AZIONI', 120, isHeader: true, alignment: Alignment.center),
                                _buildCell('CID', 200, isHeader: true),
                                _buildCell('NOMINATIVO', 220, isHeader: true),
                                _buildCell('TRASFERTA', 180, isHeader: true),
                                _buildCell('RISCONTRO SAP', 160, isHeader: true),
                                _buildCell('IMPORTO SAP', 140, isHeader: true),
                                _buildCell('DISC. SAP', 130, isHeader: true),
                                _buildCell('IMPORTO AMEX', 120, isHeader: true),
                                _buildCell('NUMERO CONTO', 220, isHeader: true),
                                _buildCell('VIAGGIATORE', 200, isHeader: true),
                                _buildCell('BOLLA', 150, isHeader: true),
                                _buildCell('FILE IMPORTAZIONE', 200, isHeader: true),
                                _buildCell('FORNITORE', 250, isHeader: true),
                                _buildCell('DATA TRANS.', 120, isHeader: true),
                                _buildCell('DATA ESTRATTO CONTO', 160, isHeader: true),
                              ],
                            ),
                          ),
                          // BODY SCROLLABILE
                          Expanded(
                            child: paginatedRecords.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          filterOspiti
                                              ? Icons.people_outline
                                              : (filterTop ? Icons.star_outline_rounded : Icons.search_off),
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          filterOspiti
                                              ? 'Nessun record trovato per i file OSPITI selezionati'
                                              : (filterTop
                                                  ? 'Nessun record trovato per i file TOP selezionati'
                                                  : 'Nessun record corrisponde ai filtri selezionati'),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    controller: _scrollController,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: paginatedRecords.length,
                                      itemBuilder: (context, index) {
                                        final record = paginatedRecords[index];
                                        final matchedSap = amexToSapMatch[record.id];
                                        final ct = _cleanT(record.numeroTrasferta);
                                        final hasAnySapForT = ct.isNotEmpty && sapMapByCleanedT.containsKey(ct);
                                        final sapAmount = matchedSap?.importo;
                                        final hasExactMatch = sapAmount != null && record.importoLordo != null && (sapAmount - record.importoLordo!).abs() < 0.015;
                                        final rowDiscrepancy = (record.importoLordo != null && sapAmount != null) ? (record.importoLordo! - sapAmount) : null;
                                        final sourceFile = record.logHistoryId != null ? (logsMap[record.logHistoryId] ?? record.logHistoryId ?? '-') : '-';
                                        final isOspiti = sourceFile.toUpperCase().contains('OSPITI');
                                        final isTop = sourceFile.toUpperCase().contains('TOP');
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: isOspiti
                                                ? Colors.orange.shade50.withAlpha(160)
                                                : (isTop
                                                    ? Colors.teal.shade50.withAlpha(160)
                                                    : (index % 2 == 0 ? Colors.white : Colors.grey.shade50.withAlpha(120))), 
                                            border: Border(
                                              bottom: BorderSide(
                                                color: isOspiti ? Colors.orange.shade200 : (isTop ? Colors.teal.shade200 : Colors.grey.shade100),
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                      children: [
                                        _buildCell('', 120, alignment: Alignment.center, child: Row(mainAxisSize: MainAxisSize.min, children: [
                                          IconButton(icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20), onPressed: () => _showRecordDetails(context, record, matchedSap, sapMapByCleanedT[ct]), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                          const SizedBox(width: 12),
                                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _showDeleteDialog(context, ref, record), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                                        ])),
                                        _buildCopyableCell(record.cid ?? '-', 200, typeLabel: 'CID', fontWeight: FontWeight.w500),
                                        _buildCell(anagraficheMap[record.cid?.trim()] ?? '-', 220),
                                        _buildCopyableCell(
                                          record.numeroTrasferta ?? '-',
                                          180,
                                          typeLabel: 'Trasferta',
                                          fontWeight: FontWeight.bold,
                                          color: record.numeroTrasferta != null && contabileTrasferte.contains(record.numeroTrasferta!.trim())
                                              ? Colors.green.shade800
                                              : Colors.red.shade700,
                                        ),
                                        // BADGE RISCONTRO SAP
                                        _buildCell('', 160, child: Builder(
                                          builder: (context) {
                                            if (matchedSap != null) {
                                              final color = hasExactMatch ? Colors.green.shade700 : Colors.orange.shade800;
                                              final bg = hasExactMatch ? Colors.green.shade50 : Colors.orange.shade50;
                                              final border = hasExactMatch ? Colors.green.shade200 : Colors.orange.shade200;
                                              final label = hasExactMatch ? 'SAP QUADRATO' : 'SAP RISCONTRATO';
                                              return InkWell(
                                                onTap: () => _showSapRecordDetails(context, matchedSap),
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: bg,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: border),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(hasExactMatch ? Icons.check_circle_outline : Icons.analytics_outlined, size: 14, color: color),
                                                      const SizedBox(width: 4),
                                                      Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else if (hasAnySapForT) {
                                              return InkWell(
                                                onTap: () {
                                                  final list = sapMapByCleanedT[ct];
                                                  if (list != null && list.isNotEmpty) {
                                                    _showSapRecordDetails(context, list.first);
                                                  }
                                                },
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber.shade50,
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(color: Colors.amber.shade300),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.info_outline, size: 14, color: Colors.amber.shade900),
                                                      const SizedBox(width: 4),
                                                      Text('SU TRASFERTA', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.grey.shade300),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.remove_circle_outline, size: 14, color: Colors.grey.shade600),
                                                    const SizedBox(width: 4),
                                                    Text('NON PRESENTE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        )),
                                        // IMPORTO SAP
                                        _buildCell(
                                          sapAmount != null ? '${sapAmount.toStringAsFixed(2)} €' : '-',
                                          140,
                                          color: sapAmount != null ? Colors.green.shade800 : Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        // DISCREPANZA SAP
                                        _buildCell(
                                          rowDiscrepancy != null
                                              ? '${rowDiscrepancy >= 0 ? "+" : ""}${rowDiscrepancy.toStringAsFixed(2)} €'
                                              : '-',
                                          130,
                                          color: rowDiscrepancy == null
                                              ? Colors.grey
                                              : (hasExactMatch ? Colors.green.shade700 : Colors.red.shade700),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        _buildCell('${record.importoLordo?.toStringAsFixed(2) ?? '0.00'} €', 120, fontWeight: FontWeight.bold, color: (record.importoLordo ?? 0) < 0 ? Colors.red.shade700 : Colors.green.shade800),
                                        _buildCopyableCell(record.numeroConto ?? '-', 220, typeLabel: 'Numero Conto'),
                                        _buildCopyableCell(record.nomeViaggiatore ?? '-', 200, typeLabel: 'Viaggiatore'),
                                        _buildCell(record.bolla ?? '-', 150),
                                        _buildCell(
                                          '',
                                          200,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.description_outlined,
                                                size: 14,
                                                color: isOspiti ? Colors.orange.shade800 : (isTop ? Colors.teal.shade800 : Colors.grey.shade600),
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  sourceFile,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: (isOspiti || isTop) ? FontWeight.bold : FontWeight.normal,
                                                    color: isOspiti ? Colors.orange.shade900 : (isTop ? Colors.teal.shade900 : Colors.black87),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isOspiti) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange.shade100,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'OSPITI',
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.orange.shade900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                              if (isTop) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.teal.shade100,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    'TOP',
                                                    style: TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.teal.shade900,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        _buildCell(record.nomeFornitore ?? '-', 250),
                                        _buildCell(record.dataTransazione ?? '-', 120),
                                        _buildCell(record.dataEstrattoConto ?? '-', 160),
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
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Totale record: ${filteredRecords.length}',
                        style: const TextStyle(
                          color: SkyTheme.timBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
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
    ref.read(amexSelectedNumeroContoProvider.notifier).state = {};
    ref.read(amexStartDateProvider.notifier).state = null;
    ref.read(amexEndDateProvider.notifier).state = null;
    ref.read(amexSelectedLogHistoryIdsProvider.notifier).state = {};
    ref.read(amexFilterOspitiProvider.notifier).state = false;
    ref.read(amexFilterTopProvider.notifier).state = false;
    ref.read(amexTrasfertaPresenzaFilterProvider.notifier).state = AmexTrasfertaPresenzaFilter.all;
    ref.read(amexSapPresenzaFilterProvider.notifier).state = AmexSapPresenzaFilter.all;
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

  Widget _buildFilterDrawer(
    BuildContext context,
    WidgetRef ref,
    List<String> fornitori,
    List<String> numeroContoOptions,
    Map<String, String> contoDictionaryMap,
    List<LogHistory> amexLogs,
    List<LogHistory> ospitiLogs,
    List<LogHistory> topLogs,
  ) {
    final filterOspiti = ref.watch(amexFilterOspitiProvider);
    final filterTop = ref.watch(amexFilterTopProvider);
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
                _buildDrawerSectionTitle('NUMERO CONTO'),
                const SizedBox(height: 12),
                _buildMultiSelectFilter('Numero Conto', ref.watch(amexSelectedNumeroContoProvider), numeroContoOptions, (val) => ref.read(amexSelectedNumeroContoProvider.notifier).state = val, icon: Icons.account_balance_outlined, dictionary: contoDictionaryMap),
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
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('RISCONTRO SAP'),
                const SizedBox(height: 12),
                _buildChoiceFilter<AmexSapPresenzaFilter>(
                  ref.watch(amexSapPresenzaFilterProvider),
                  {
                    AmexSapPresenzaFilter.all: 'Tutte',
                    AmexSapPresenzaFilter.present: 'Presenti',
                    AmexSapPresenzaFilter.notPresent: 'Non Presenti',
                    AmexSapPresenzaFilter.matching: 'Match Esatto',
                    AmexSapPresenzaFilter.discrepancy: 'Discrepanza',
                  },
                  (val) => ref.read(amexSapPresenzaFilterProvider.notifier).state = val,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('FILE CARICATI'),
                const SizedBox(height: 12),
                _buildFileSelectionTrigger(
                  context,
                  'Seleziona File',
                  ref.watch(amexSelectedLogHistoryIdsProvider),
                  amexLogs,
                  (next) {
                    ref.read(amexSelectedLogHistoryIdsProvider.notifier).state = next;
                  },
                  icon: Icons.insert_drive_file_outlined,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('FILTRO OSPITI'),
                const SizedBox(height: 12),
                Material(
                  color: filterOspiti ? Colors.orange.shade50 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: filterOspiti ? Colors.orange.shade300 : Colors.grey.shade200),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeTrackColor: Colors.orange.shade600,
                        title: const Text('Solo File OSPITI', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Mostra solo record dai file con "OSPITI" (${ospitiLogs.length} file)',
                          style: const TextStyle(fontSize: 11),
                        ),
                        value: filterOspiti,
                        onChanged: (val) {
                          ref.read(amexFilterOspitiProvider.notifier).state = val;
                          ref.read(amexPageProvider.notifier).state = 0;
                        },
                      ),
                      if (ospitiLogs.isNotEmpty) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'File OSPITI rilevati:',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              ...ospitiLogs.map((log) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.description_outlined, size: 14, color: Colors.deepOrange),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                log.fileName,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${log.totalRecords} record • ${log.date.day}/${log.date.month}/${log.date.year}',
                                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(
                            'Nessun file Estratto AMEX contiene la parola "OSPITI" nel nome.',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDrawerSectionTitle('FILTRO TOP'),
                const SizedBox(height: 12),
                Material(
                  color: filterTop ? Colors.teal.shade50 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: filterTop ? Colors.teal.shade300 : Colors.grey.shade200),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SwitchListTile(
                        activeTrackColor: Colors.teal.shade600,
                        title: const Text('Solo File TOP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          'Mostra solo record dai file con "TOP" (${topLogs.length} file)',
                          style: const TextStyle(fontSize: 11),
                        ),
                        value: filterTop,
                        onChanged: (val) {
                          ref.read(amexFilterTopProvider.notifier).state = val;
                          ref.read(amexPageProvider.notifier).state = 0;
                        },
                      ),
                      if (topLogs.isNotEmpty) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'File TOP rilevati:',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 8),
                              ...topLogs.map((log) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Icon(Icons.description_outlined, size: 14, color: Colors.teal.shade800),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                log.fileName,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '${log.totalRecords} record • ${log.date.day}/${log.date.month}/${log.date.year}',
                                                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ] else ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(
                            'Nessun file Estratto AMEX contiene la parola "TOP" nel nome.',
                            style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                          ),
                        ),
                      ],
                    ],
                  ),
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

  Widget _buildMultiSelectFilter(
    String label,
    Set<String> selectedValues,
    List<String> options,
    Function(Set<String>) onChanged, {
    IconData? icon,
    Map<String, String>? dictionary,
  }) {
    return InkWell(
      onTap: () async {
        final results = await showDialog<Set<String>>(
          context: context,
          builder: (context) {
            Set<String> tempSelected = Set.from(selectedValues);
            return StatefulBuilder(
              builder: (context, setModalState) {
                return AlertDialog(
                  title: Text('Seleziona $label'),
                  content: SizedBox(
                    width: 300,
                    height: 400,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => setModalState(() => tempSelected = Set.from(options)),
                              child: const Text('Tutti'),
                            ),
                            TextButton(
                              onPressed: () => setModalState(() => tempSelected.clear()),
                              child: const Text('Reset'),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index];
                              final hasTranslation = dictionary != null && dictionary[option] != null;
                              return CheckboxListTile(
                               title: Text(
                                  hasTranslation ? dictionary[option]! : option,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: hasTranslation ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: hasTranslation
                                    ? Text(
                                        option,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      )
                                    : null,
                                value: tempSelected.contains(option),
                                onChanged: (val) {
                                  setModalState(() {
                                    if (val == true) {
                                      tempSelected.add(option);
                                    } else {
                                      tempSelected.remove(option);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annulla')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, tempSelected), child: const Text('Conferma')),
                  ],
                );
              },
            );
          },
        );
        if (results != null) onChanged(results);
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
            if (icon != null) Icon(icon, size: 18, color: Colors.grey),
            if (icon != null) const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedValues.isEmpty ? label : '${selectedValues.length} selezionati',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
          ],
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

  void _showRecordDetails(
    BuildContext context,
    EstrattoAmex record, [
    TracciatoSap? matchedSap,
    List<TracciatoSap>? sapListForTrip,
  ]) {
    final anagrafiche = ref.read(anagraficaProvider);
    final anagraficheMap = {
      for (var a in anagrafiche)
        if (a.cid != null) a.cid!.trim(): a.nominativo ?? ''
    };
    final dictionaries = ref.read(dictionaryProvider);
    final contoDictionaryMap = {
      for (var d in dictionaries)
        if (d.category == 'conto') d.code: d.value
    };
    final allLogs = ref.read(logHistoryProvider);
    final logsMap = {for (var log in allLogs) log.uniqueCode: log.fileName};
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550, maxHeight: 850),
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
                          _buildDetailRow('CID', record.cid ?? '-', copyable: true),
                          _buildDetailRow('Nominativo', anagraficheMap[record.cid?.trim()] ?? '-'),
                          _buildDetailRow('Numero Trasferta', record.numeroTrasferta ?? '-', copyable: true),
                          _buildDetailRow('Bolla (Trasformata)', record.bolla ?? '-', copyable: true),
                          _buildDetailRow('Bolla Originale', record.bollaOriginale ?? '-', copyable: true),
                          _buildDetailRow('File Importazione', record.logHistoryId != null ? (logsMap[record.logHistoryId] ?? '-') : '-'),
                          _buildDetailRow('Nome Viaggiatore', record.nomeViaggiatore ?? '-'),
                          _buildDetailRow('Conto', record.conto ?? '-'),
                          _buildDetailRow('Numero di conto', record.numeroConto ?? '-', copyable: true),
                          _buildDetailRow('Nome del conto', record.numeroConto != null ? (contoDictionaryMap[record.numeroConto?.trim()] ?? contoDictionaryMap[record.numeroConto] ?? '-') : '-'),
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
                        // SEZIONE RISCONTRO SAP
                        _buildDetailSection('RISCONTRO TRACCIATO SAP', Icons.analytics_outlined, Colors.green.shade800, [
                          if (matchedSap != null) ...[
                            _buildDetailRow(
                              'Stato Riscontro', 
                              (record.importoLordo != null && (matchedSap.importo - record.importoLordo!).abs() < 0.015) ? 'MATCH ESATTO' : 'DISCREPANZA', 
                              isHighlight: true, 
                              highlightColor: (record.importoLordo != null && (matchedSap.importo - record.importoLordo!).abs() < 0.015) ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                            _buildDetailRow('Importo SAP', '${matchedSap.importo.toStringAsFixed(2)} ${matchedSap.valuta}', isHighlight: true, highlightColor: Colors.green.shade800),
                            _buildDetailRow('Discrepanza', '${((record.importoLordo ?? 0) - matchedSap.importo).toStringAsFixed(2)} €', isHighlight: true, highlightColor: (record.importoLordo != null && (matchedSap.importo - record.importoLordo!).abs() < 0.015) ? Colors.green.shade700 : Colors.red.shade700),
                            _buildDetailRow('Società SAP', '${matchedSap.societaDescrizione} (${matchedSap.societaCodice})'),
                            _buildDetailRow('Tipo Spesa SAP', '${matchedSap.tipoSpesaDescrizione} (${matchedSap.tipoSpesaCodice})'),
                            _buildDetailRow('Data SAP', matchedSap.data),
                            _buildDetailRow('CD Richiesta', matchedSap.cdRichiesta ?? '-'),
                            _buildDetailRow('Codice Stato', matchedSap.codiceStato ?? '-'),
                          ] else if (sapListForTrip != null && sapListForTrip.isNotEmpty) ...[
                            _buildDetailRow('Stato Riscontro', 'PRESENTE SU TRASFERTA (${sapListForTrip.length} record SAP)', isHighlight: true, highlightColor: Colors.amber.shade900),
                            _buildDetailRow('Totale SAP Trasferta', '${sapListForTrip.fold<double>(0, (sum, s) => sum + s.importo).toStringAsFixed(2)} €', isHighlight: true, highlightColor: Colors.green.shade800),
                          ] else ...[
                            _buildDetailRow('Stato Riscontro', 'NON PRESENTE IN SAP', isHighlight: true, highlightColor: Colors.grey.shade600),
                          ],
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('DETTAGLI TRANSAZIONE', Icons.payment_outlined, Colors.purple, [
                          _buildDetailRow('Data Transazione', record.dataTransazione ?? '-'),
                          _buildDetailRow('Data Estratto Conto', record.dataEstrattoConto ?? '-'),
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
                          _buildDetailRow('File Importazione', record.logHistoryId != null ? (logsMap[record.logHistoryId] ?? '-') : '-'),
                          _buildDetailRow('Rif. Viaggio 1', record.rifViaggio1 ?? '-'),
                          _buildDetailRow('Rif. Viaggio 2', record.rifViaggio2 ?? '-'),
                          _buildDetailRow('Rif. Viaggio 3', record.rifViaggio3 ?? '-'),
                          _buildDetailRow('Fattura SE', record.numFatturaSE ?? '-'),
                          _buildDetailRow('ID Log', record.logHistoryId ?? '-'),
                        ]),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (matchedSap != null) ...[
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _showSapRecordDetails(context, matchedSap);
                                  },
                                  icon: const Icon(Icons.analytics_outlined, size: 18),
                                  label: const Text('DETTAGLIO SAP'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green.shade800,
                                    side: BorderSide(color: Colors.green.shade300),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade800,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('CHIUDI', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
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

  void _showSapRecordDetails(BuildContext context, TracciatoSap record) {
    final anagrafiche = ref.read(anagraficaProvider);
    final anagraficheMap = {
      for (var a in anagrafiche)
        if (a.cid != null) a.cid!.trim().padLeft(8, '0'): a.nominativo ?? ''
    };
    final nominativo = record.nomeDipendente.trim().isNotEmpty
        ? record.nomeDipendente
        : (anagraficheMap[record.cid.trim().padLeft(8, '0')] ?? '-');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 800),
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
                          _buildDetailRow('CID', record.cid, copyable: true),
                          _buildDetailRow('Nome', nominativo),
                          _buildDetailRow('Tipo', record.tipoDipendente),
                          _buildDetailRow('Classe Retr.', record.classeRetributiva),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Società e Trasferta', Icons.business_outlined, Colors.green.shade700, [
                          _buildDetailRow('Società', '${record.societaDescrizione} (${record.societaCodice})'),
                          _buildDetailRow('Trasferta', record.numeroTrasferta, copyable: true),
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

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false, Color? highlightColor, bool copyable = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w400))),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                      color: isHighlight ? (highlightColor ?? Colors.purple.shade700) : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (copyable && value != '-') ...[
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: value));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$label $value copiato negli appunti'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel(
    List<EstrattoAmex> records, [
    Map<int, TracciatoSap>? amexToSapMatch,
  ]) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Estratti_AMEX'];
      excel.delete('Sheet1');

      final anagrafiche = ref.read(anagraficaProvider);
      final anagraficheMap = {
        for (var a in anagrafiche)
          if (a.cid != null) a.cid!.trim(): a.nominativo ?? ''
      };

      final allLogs = ref.read(logHistoryProvider);
      final logsMap = {for (var log in allLogs) log.uniqueCode: log.fileName};

      final contabileRecords = ref.read(tracciatoContabilesProvider);
      final contabileTrasferte = contabileRecords
          .map((tc) => tc.numeroTrasferta.trim())
          .where((t) => t.isNotEmpty)
          .toSet();

      final dictionaries = ref.read(dictionaryProvider);
      final contoDictionaryMap = {
        for (var d in dictionaries)
          if (d.category == 'conto') d.code: d.value
      };

      // Headers
      sheet.appendRow([
        TextCellValue('CID'),
        TextCellValue('NOMINATIVO'),
        TextCellValue('TRASFERTA'),
        TextCellValue('IMPORTO AMEX'),
        TextCellValue('RISCONTRO SAP'),
        TextCellValue('IMPORTO SAP'),
        TextCellValue('DISCREPANZA SAP'),
        TextCellValue('NUMERO CONTO'),
        TextCellValue('NOME CONTO'),
        TextCellValue('VIAGGIATORE'),
        TextCellValue('BOLLA'),
        TextCellValue('RIF. VIAGGIO 1'),
        TextCellValue('FILE IMPORTAZIONE'),
        TextCellValue('FORNITORE'),
        TextCellValue('DATA TRANS.'),
        TextCellValue('DATA ESTRATTO CONTO'),
        TextCellValue('VALUTA'),
        TextCellValue('RISCONTRO (TRACCIATO CONTABILE)'),
      ]);

      for (var r in records) {
        final isMatched = r.numeroTrasferta != null && contabileTrasferte.contains(r.numeroTrasferta!.trim());
        final nomeConto = r.numeroConto != null ? (contoDictionaryMap[r.numeroConto?.trim()] ?? contoDictionaryMap[r.numeroConto] ?? '') : '';
        final matchedSap = amexToSapMatch?[r.id];
        final sapAmount = matchedSap?.importo;
        final hasExactMatch = sapAmount != null && r.importoLordo != null && (sapAmount - r.importoLordo!).abs() < 0.015;
        final sapStatus = matchedSap != null
            ? (hasExactMatch ? 'MATCH ESATTO' : 'DISCREPANZA')
            : 'NON PRESENTE';
        final sapDisc = (r.importoLordo != null && sapAmount != null) ? (r.importoLordo! - sapAmount) : null;

        sheet.appendRow([
          TextCellValue(r.cid ?? ''),
          TextCellValue(anagraficheMap[r.cid?.trim()] ?? ''),
          TextCellValue(r.numeroTrasferta ?? ''),
          DoubleCellValue(r.importoLordo ?? 0.0),
          TextCellValue(sapStatus),
          sapAmount != null ? DoubleCellValue(sapAmount) : TextCellValue(''),
          sapDisc != null ? DoubleCellValue(sapDisc) : TextCellValue(''),
          TextCellValue(r.numeroConto ?? ''),
          TextCellValue(nomeConto),
          TextCellValue(r.nomeViaggiatore ?? ''),
          TextCellValue(r.bolla ?? ''),
          TextCellValue(r.rifViaggio1 ?? ''),
          TextCellValue(r.logHistoryId != null ? (logsMap[r.logHistoryId] ?? '') : ''),
          TextCellValue(r.nomeFornitore ?? ''),
          TextCellValue(r.dataTransazione ?? ''),
          TextCellValue(r.dataEstrattoConto ?? ''),
          TextCellValue(r.valuta ?? ''),
          TextCellValue(isMatched ? 'PRESENTI' : 'IN ATTESA'),
        ]);
      }

      // STILI (Simili a Scarti Tracciato)
      final headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#C4121A'), // TIM Red
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final matchedStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#D4EDDA'), // Light green
        fontColorHex: ExcelColor.fromHexString('#155724'), // Dark green
        verticalAlign: VerticalAlign.Center,
      );

      final matchedCenterStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#D4EDDA'),
        fontColorHex: ExcelColor.fromHexString('#155724'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final matchedAmountStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#D4EDDA'),
        fontColorHex: ExcelColor.fromHexString('#155724'),
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
      );

      final waitingStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#FFF3CD'), // Light orange
        fontColorHex: ExcelColor.fromHexString('#856404'), // Dark orange
        verticalAlign: VerticalAlign.Center,
      );

      final waitingCenterStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#FFF3CD'),
        fontColorHex: ExcelColor.fromHexString('#856404'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final waitingAmountStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#FFF3CD'),
        fontColorHex: ExcelColor.fromHexString('#856404'),
        horizontalAlign: HorizontalAlign.Right,
        verticalAlign: VerticalAlign.Center,
      );

      const colCount = 18;
      for (var col = 0; col < colCount; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }
      sheet.setRowHeight(0, 30);

      int rowIndex = 1;
      for (final r in records) {
        sheet.setRowHeight(rowIndex, 22);
        final isMatched = r.numeroTrasferta != null && contabileTrasferte.contains(r.numeroTrasferta!.trim());
        final rowStyle = isMatched ? matchedStyle : waitingStyle;
        final centerStyle = isMatched ? matchedCenterStyle : waitingCenterStyle;
        final amountStyle = isMatched ? matchedAmountStyle : waitingAmountStyle;

        for (var col = 0; col < colCount; col++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
          if (col == 3 || col == 5 || col == 6) { // Importo AMEX, Importo SAP, Discrepanza SAP
            cell.cellStyle = amountStyle;
          } else if (col == 0 || col == 2 || col == 4 || col == 7 || col == 11 || col == 12 || col == 14 || col == 15 || col == 16 || col == 17) {
            cell.cellStyle = centerStyle;
          } else {
            cell.cellStyle = rowStyle;
          }
        }
        rowIndex++;
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva export Excel Estratti AMEX',
        fileName: 'export_amex_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esportazione Estratti AMEX completata con successo!'),
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgLightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgLightColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: color == SkyTheme.timRed ? Colors.black87 : color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
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

  String _formatAmount(double amount) {
    final isNeg = amount < 0;
    final absVal = amount.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimals = parts[1];
    
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formattedWhole = whole.replaceAllMapped(reg, (Match match) => '${match[1]}.');
    
    return '${isNeg ? "-" : ""}$formattedWhole,$decimals €';
  }
}
