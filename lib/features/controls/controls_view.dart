import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/upload/models/estratto_amex.dart';
import 'package:travel_check/features/upload/providers/estratto_amex_provider.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/shared/widgets/file_selection_dialog.dart';
import 'package:intl/intl.dart';

final controlsMonthProvider = StateProvider<Set<String>>((ref) => {});
final controlsYearProvider = StateProvider<String?>((ref) => DateTime.now().year.toString());
final controlsSelectedLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});
final controlsStartDateProvider = StateProvider<DateTime?>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month - 1, 1);
});
final controlsEndDateProvider = StateProvider<DateTime?>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 0);
});
final controlsSearchProvider = StateProvider<String>((ref) => '');
final controlsSocietaProvider = StateProvider<Set<String>>((ref) => {});
final controlsTipoDipendenteProvider = StateProvider<Set<String>>((ref) => {'DR', 'IM', 'QD'});
final controlsSortAscendingProvider = StateProvider<bool>((ref) => false);
final controlsPageProvider = StateProvider<int>((ref) => 0);
final controlsExpandAllProvider = StateProvider<bool>((ref) => true);
final controlsShowOnlyOrphansProvider = StateProvider<bool>((ref) => false);
final controlsShowOnlySapOrphansProvider = StateProvider<bool>((ref) => false);
final controlsMatchStatusProvider = StateProvider<String?>((ref) => null); // null, 'match', 'diff'
final controlsMinDiffProvider = StateProvider<double?>((ref) => null);
final controlsMaxDiffProvider = StateProvider<double?>((ref) => null);
final controlsCidMismatchProvider = StateProvider<bool>((ref) => false);
final controlsMultipleHotelsProvider = StateProvider<bool>((ref) => false);

class ControlsView extends ConsumerStatefulWidget {
  const ControlsView({super.key});

  @override
  ConsumerState<ControlsView> createState() => _ControlsViewState();
}

class _ControlsViewState extends ConsumerState<ControlsView> {
  final _searchController = TextEditingController();
  final _minDiffController = TextEditingController();
  final _maxDiffController = TextEditingController();
  final _scrollController = ScrollController();
  
  static const Map<String, String> monthNames = {
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

  @override
  void dispose() {
    _searchController.dispose();
    _minDiffController.dispose();
    _maxDiffController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _cleanT(String? s) {
    if (s == null) return '';
    return s.trim().split('.')[0].replaceAll(RegExp(r'^0+'), '');
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(tracciatoContabilesProvider).where((r) => !r.isScarto).toList();
    final allEstrattiConto = ref.watch(estrattoContoProvider);
    final rawSapRecords = ref.watch(tracciatoSapProvider);
    final allLogs = ref.watch(logHistoryProvider);
    final sapLogs = allLogs.where((log) => log.sourceType == 'Tracciato SAP').toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final String? latestSapLogId = sapLogs.isNotEmpty ? sapLogs.first.uniqueCode : null;
    final List<TracciatoSap> allSapRecords = latestSapLogId != null
        ? rawSapRecords.where((sap) => sap.logHistoryId == latestSapLogId).toList()
        : rawSapRecords;
    final allAmexRecords = ref.watch(estrattoAmexProvider);
    final selectedLogHistoryIds = ref.watch(controlsSelectedLogHistoryIdsProvider);
    String? selectedLogFileName;
    if (selectedLogHistoryIds.length == 1) {
      for (final log in allLogs) {
        if (log.uniqueCode == selectedLogHistoryIds.first) {
          selectedLogFileName = log.fileName;
          break;
        }
      }
    }

    if (allRecords.isEmpty) {
      return Center(
        child: Text(
          'Nessun record presente nel database.\nVai su "Carica File" per importare i dati.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      );
    }

    final allAnagrafica = ref.watch(anagraficaProvider);
    final anagraficaMap = {for (var a in allAnagrafica) (a.cid ?? '').trim(): (a.nominativo ?? '').trim()};

    final dictionaries = ref.watch(dictionaryProvider);
    final dictionaryMap = {
      for (final entry in dictionaries) entry.code: entry.value,
    };

    final isCompactList = MediaQuery.of(context).size.width < 1100;

    final searchQuery = ref.watch(controlsSearchProvider);
    final selectedSocieta = ref.watch(controlsSocietaProvider);
    final selectedTipo = ref.watch(controlsTipoDipendenteProvider);
    final sortAscending = ref.watch(controlsSortAscendingProvider);
    final currentPage = ref.watch(controlsPageProvider);
    const pageSize = 50;

    final filteredAllRecords = selectedLogHistoryIds.isNotEmpty
        ? allRecords.where((r) => selectedLogHistoryIds.contains(r.logHistoryId)).toList()
        : allRecords;

    final Map<String, List<TracciatoContabile>> groupedRecords = {};
    for (final record in filteredAllRecords) {
      groupedRecords.putIfAbsent(record.numeroTrasferta, () => []).add(record);
    }

    var trasferte = groupedRecords.keys.toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      trasferte = trasferte.where((t) {
        final records = groupedRecords[t] ?? [];
        
        // Verifica numero trasferta
        if (t.toLowerCase().contains(query)) {
          return true;
        }
        
        // Verifica CID o Nominativo in qualsiasi record della trasferta
        if (records.any((r) {
          final cid = r.cid;
          final name = anagraficaMap[cid] ?? '';
          return cid.toLowerCase().contains(query) || name.toLowerCase().contains(query);
        })) {
          return true;
        }
        
        // Verifica località in qualsiasi record della trasferta
        if (records.any((r) => r.localita.toLowerCase().contains(query))) {
          return true;
        }
        
        return false;
      }).toList();
    }

    final startDate = ref.watch(controlsStartDateProvider);
    final endDate = ref.watch(controlsEndDateProvider);

    if (startDate != null ||
        endDate != null ||
        selectedSocieta.isNotEmpty ||
        selectedTipo.isNotEmpty) {
      trasferte = trasferte.where((t) {
        final records = groupedRecords[t] ?? [];
        final sapForT = allSapRecords.where((sap) => _cleanT(sap.numeroTrasferta) == _cleanT(t)).toList();
        final societa = records.isNotEmpty ? records.first.societa : (sapForT.isNotEmpty ? sapForT.first.societaCodice : '');
        final tipo = records.isNotEmpty ? records.first.tipoDipendente : (sapForT.isNotEmpty ? sapForT.first.tipoDipendente : '');

        if (selectedSocieta.isNotEmpty && !selectedSocieta.contains(societa)) {
          return false;
        }

        if (selectedTipo.isNotEmpty && !selectedTipo.contains(tipo)) {
          return false;
        }

        if (startDate != null || endDate != null) {
          final dataStr = records.isNotEmpty ? records.first.dataFine : (sapForT.isNotEmpty ? sapForT.first.data : '');
          try {
            final parts = dataStr.split(RegExp(r'[./-]'));
            if (parts.length == 3) {
              final recordDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[1]),
                int.parse(parts[0]),
              );

              if (startDate != null && recordDate.isBefore(startDate)) return false;
              if (endDate != null && recordDate.isAfter(endDate)) return false;
            }
          } catch (_) {
            return false;
          }
        }

        return true;
      }).toList();
    }

    final showOnlyOrphans = ref.watch(controlsShowOnlyOrphansProvider);
    if (showOnlyOrphans) {
      trasferte = trasferte.where((t) {
        final recordsTrasferta = groupedRecords[t]!;
        final bolleInTracciato = recordsTrasferta.map((r) => r.numeroBolla).toSet();
        
        final orphans = allEstrattiConto.where((ec) => 
          ec.numeroTrasferta == t && 
          !bolleInTracciato.contains(ec.bolla)
        );
        
        return orphans.isNotEmpty;
      }).toList();
    }

    final showOnlySapOrphans = ref.watch(controlsShowOnlySapOrphansProvider);
    if (showOnlySapOrphans) {
      final contabileCleanSet = filteredAllRecords.map((r) => _cleanT(r.numeroTrasferta)).toSet();
      final orphanSapSet = allSapRecords
          .where((sap) => _cleanT(sap.numeroTrasferta).isNotEmpty && !contabileCleanSet.contains(_cleanT(sap.numeroTrasferta)))
          .map((sap) => sap.numeroTrasferta)
          .toSet();
      trasferte = orphanSapSet.toList();
    }

    final matchStatusFilter = ref.watch(controlsMatchStatusProvider);
    final minDiff = ref.watch(controlsMinDiffProvider);
    final maxDiff = ref.watch(controlsMaxDiffProvider);
    final cidMismatchFilter = ref.watch(controlsCidMismatchProvider);

    if (matchStatusFilter != null || minDiff != null || maxDiff != null || cidMismatchFilter) {
      trasferte = trasferte.where((t) {
        final recordsTrasferta = groupedRecords[t] ?? [];
        double tTracciato = 0;
        for (var r in recordsTrasferta) {
          tTracciato += r.isNegative ? -r.importo : r.importo;
        }

        final ecForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == t).toList();
        final tEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
        final isMatchingEC = (tTracciato - tEC).abs() < 0.001;

        final sapForTrasferta = allSapRecords.where((sap) => _cleanT(sap.numeroTrasferta) == _cleanT(t)).toList();
        final tSap = sapForTrasferta.fold<double>(0, (sum, sap) => sum + sap.importo);
        final isMatchingSap = (tTracciato - tSap).abs() < 0.001;

        final amexForTrasferta = allAmexRecords.where((ame) => ame.numeroTrasferta == t).toList();
        final tAmex = amexForTrasferta.fold<double>(0, (sum, ame) => sum + (ame.importoLordo ?? 0));
        final isMatchingAmex = (tTracciato - tAmex).abs() < 0.001;

        if (matchStatusFilter != null) {
          if (matchStatusFilter == 'match_all' && (!isMatchingEC || !isMatchingSap || !isMatchingAmex)) return false;
          if (matchStatusFilter == 'match_ec_sap' && (!isMatchingEC || !isMatchingSap)) return false;
          if (matchStatusFilter == 'match_ec' && !isMatchingEC) return false;
          if (matchStatusFilter == 'diff_any' && (isMatchingEC && isMatchingSap && isMatchingAmex)) return false;
          if (matchStatusFilter == 'diff_ec' && isMatchingEC) return false;
          if (matchStatusFilter == 'diff_sap' && isMatchingSap) return false;
          if (matchStatusFilter == 'diff_amex' && isMatchingAmex) return false;
        }

        if (cidMismatchFilter) {
          final Set<String> cids = {};
          for (var r in recordsTrasferta) {
            cids.add(r.cid);
          }
          for (var ec in ecForTrasferta) {
            cids.add(ec.cid);
          }
          for (var sap in sapForTrasferta) {
            cids.add(sap.cid);
          }
          for (var ame in amexForTrasferta) {
            cids.add(ame.cid ?? '');
          }
          if (cids.length <= 1) return false;
        }


        if (minDiff != null && (tTracciato - tEC).abs() < minDiff) return false;
        if (maxDiff != null && (tTracciato - tEC).abs() > maxDiff) return false;

        return true;
      }).toList();
    }

    final showMultipleHotelsOnly = ref.watch(controlsMultipleHotelsProvider);
    if (showMultipleHotelsOnly) {
      trasferte = trasferte.where((t) {
        final recordsTrasferta = groupedRecords[t] ?? [];
        final hotelCount = recordsTrasferta.where((r) {
          final code = r.giustificativoSpesa.trim().toUpperCase();
          final desc = (dictionaryMap[r.giustificativoSpesa] ?? '').toLowerCase();
          return code.contains('ALP') || desc.contains('alloggio') || desc.contains('hotel');
        }).length;
        return hotelCount > 1;
      }).toList();
    }

    trasferte.sort((a, b) => sortAscending ? a.compareTo(b) : b.compareTo(a));

    double globalTracciato = 0;
    double globalEC = 0;
    double globalAmex = 0;
    for (final t in trasferte) {
      final records = groupedRecords[t] ?? [];
      for (final r in records) {
        globalTracciato += r.isNegative ? -r.importo : r.importo;
      }
      final ecForT = allEstrattiConto.where((ec) => ec.numeroTrasferta == t);
      for (final ec in ecForT) {
        globalEC += ec.totaleServizio;
      }
      final amexForT = allAmexRecords.where((ame) => ame.numeroTrasferta == t);
      for (final ame in amexForT) {
        globalAmex += ame.importoLordo ?? 0;
      }
    }
    final double globalSap = allSapRecords.fold<double>(0.0, (sum, sap) => sum + sap.importo);

    final totalPages = (trasferte.length / pageSize).ceil();
    // Protezione per evitare RangeError se i filtri riducono il numero di pagine
    // e l'utente si trova su una pagina che non esiste più.
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;

    final startIndex = (safePage * pageSize).clamp(0, trasferte.length);
    final endIndex = (startIndex + pageSize).clamp(0, trasferte.length);
    final paginatedTrasferte = trasferte.sublist(startIndex, endIndex);


    final activeFiltersCount = [
      startDate != null,
      endDate != null,
      selectedSocieta.isNotEmpty,
      selectedTipo.isNotEmpty,
      minDiff != null,
      maxDiff != null,
      matchStatusFilter != null,
      ref.watch(controlsShowOnlyOrphansProvider),
      ref.watch(controlsShowOnlySapOrphansProvider),
      cidMismatchFilter,
      showMultipleHotelsOnly,
      searchQuery.isNotEmpty,
      selectedLogHistoryIds.isNotEmpty,
    ].where((e) => e).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, dictionaryMap),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _exportToExcel(
          trasferte, 
          groupedRecords, 
          allEstrattiConto, 
          allSapRecords,
          allAmexRecords,
          dictionaryMap,
          anagraficaMap
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        tooltip: 'Esporta in Excel',
        child: const Icon(Icons.table_view_rounded),
      ),
      body: Column(
        children: [
          // HEADER SEMPLIFICATO E MODERNO
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 1100;
              final isVeryCompact = constraints.maxWidth < 700;
              final isUltraCompact = constraints.maxWidth < 500;
              return Container(
                padding: EdgeInsets.fromLTRB(
                  isUltraCompact ? 4 : (isVeryCompact ? 8 : (isCompact ? 16 : 24)),
                  isUltraCompact ? 4 : (isVeryCompact ? 6 : (isCompact ? 12 : 24)),
                  isUltraCompact ? 4 : (isVeryCompact ? 8 : (isCompact ? 16 : 24)),
                  isUltraCompact ? 4 : (isVeryCompact ? 6 : (isCompact ? 12 : 16)),
                ),
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
                    const SizedBox.shrink(),
                    SizedBox(height: isUltraCompact ? 4 : (isCompact ? 8 : 20)),
                    // TOTALI SU RIGA DEDICATA
                    Wrap(
                      spacing: isUltraCompact ? 4 : (isVeryCompact ? 6 : (isCompact ? 10 : 32)),
                      runSpacing: isUltraCompact ? 2 : (isVeryCompact ? 4 : (isCompact ? 8 : 12)),
                      alignment: WrapAlignment.start,
                      children: [
                        _buildGlobalTotal('TRACCIATO', globalTracciato, SkyTheme.timBlue, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('E.C.', globalEC, Colors.purple.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('SAP', globalSap, Colors.green.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('AMEX', globalAmex, Colors.orange.shade800, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('DISCREPANZA E.C.', globalTracciato - globalEC, Colors.red.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('DISCREPANZA SAP', globalTracciato - globalSap, Colors.red.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('DISCREPANZA AMEX', globalTracciato - globalAmex, Colors.red.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                      ],
                    ),
                    SizedBox(height: isUltraCompact ? 6 : (isVeryCompact ? 6 : (isCompact ? 12 : 24))),
                    // BARRA AZIONI E RICERCA
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: isUltraCompact ? 36 : (isVeryCompact ? 42 : 48),
                            padding: EdgeInsets.symmetric(horizontal: isUltraCompact ? 8 : 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(isUltraCompact ? 8 : 12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search, color: Colors.grey, size: isUltraCompact ? 16 : 20),
                                SizedBox(width: isUltraCompact ? 6 : 12),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Cerca per trasferta, cid, località...',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: TextStyle(fontSize: isUltraCompact ? 12 : 14),
                                    onChanged: (value) => ref.read(controlsSearchProvider.notifier).state = value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: isUltraCompact ? 6 : 12),
                        // BOTTONE FILTRI AVANZATI
                        Builder(
                          builder: (context) => Stack(
                            clipBehavior: Clip.none,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => Scaffold.of(context).openEndDrawer(),
                                icon: Icon(Icons.filter_list_rounded, size: isUltraCompact ? 14 : 18),
                                label: Text('Filtri', style: TextStyle(fontSize: isUltraCompact ? 11 : (isVeryCompact ? 12 : 14))),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isUltraCompact ? 10 : (isVeryCompact ? 14 : 20),
                                    vertical: isUltraCompact ? 8 : (isVeryCompact ? 10 : 14),
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isUltraCompact ? 8 : 12)),
                                  side: BorderSide(color: activeFiltersCount > 0 ? SkyTheme.timBlue : Colors.grey.shade300),
                                  foregroundColor: activeFiltersCount > 0 ? SkyTheme.timBlue : Colors.grey.shade700,
                                ),
                              ),
                              if (activeFiltersCount > 0)
                                Positioned(
                                  top: isUltraCompact ? -4 : -8,
                                  right: isUltraCompact ? -4 : -8,
                                  child: Container(
                                    padding: EdgeInsets.all(isUltraCompact ? 4 : 6),
                                    decoration: const BoxDecoration(
                                      color: SkyTheme.timBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$activeFiltersCount',
                                      style: TextStyle(color: Colors.white, fontSize: isUltraCompact ? 8 : 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // CHIPS FILTRI ATTIVI
                    if (activeFiltersCount > 0) ...[
                      SizedBox(height: isUltraCompact ? 4 : 12),
                      SizedBox(
                        height: isUltraCompact ? 30 : 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            if (searchQuery.isNotEmpty)
                              _buildFilterChip('Cerca: "$searchQuery"', () {
                                ref.read(controlsSearchProvider.notifier).state = '';
                                _searchController.clear();
                              }),
                            if (startDate != null)
                              _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(controlsStartDateProvider.notifier).state = null),
                            if (endDate != null)
                              _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(controlsEndDateProvider.notifier).state = null),
                            if (selectedSocieta.isNotEmpty)
                              _buildFilterChip('${selectedSocieta.length} Società', () => ref.read(controlsSocietaProvider.notifier).state = {}),
                            if (minDiff != null || maxDiff != null)
                              _buildFilterChip('Range Diff.', () {
                                _minDiffController.clear();
                                _maxDiffController.clear();
                                ref.read(controlsMinDiffProvider.notifier).state = null;
                                ref.read(controlsMaxDiffProvider.notifier).state = null;
                              }),
                            if (selectedTipo.isNotEmpty)
                              _buildFilterChip('${selectedTipo.length} Tipi', () => ref.read(controlsTipoDipendenteProvider.notifier).state = {}),
                            if (matchStatusFilter != null)
                              _buildFilterChip(
                                matchStatusFilter == 'match_all' ? 'Tutto Quadrato' : 
                                matchStatusFilter == 'match_ec_sap' ? 'EC + SAP' :
                                matchStatusFilter == 'match_ec' ? 'Quadratura EC' :
                                matchStatusFilter == 'diff_any' ? 'Qualsiasi Discrepanza' :
                                matchStatusFilter == 'diff_ec' ? 'Discrepanza E.C.' : 
                                matchStatusFilter == 'diff_sap' ? 'Discrepanza SAP' : 'Discrepanza AMEX', 
                                () => ref.read(controlsMatchStatusProvider.notifier).state = null
                              ),
                            if (ref.watch(controlsShowOnlyOrphansProvider))
                              _buildFilterChip('Solo Orfani E.C.', () => ref.read(controlsShowOnlyOrphansProvider.notifier).state = false),
                            if (ref.watch(controlsShowOnlySapOrphansProvider))
                              _buildFilterChip('Solo Orfani SAP', () => ref.read(controlsShowOnlySapOrphansProvider.notifier).state = false),
                            
                            if (ref.watch(controlsCidMismatchProvider))
                              _buildFilterChip('CID Differenti', () => ref.read(controlsCidMismatchProvider.notifier).state = false),
                            
                            if (ref.watch(controlsMultipleHotelsProvider))
                              _buildFilterChip(' >1 Tracciato Hotel', () => ref.read(controlsMultipleHotelsProvider.notifier).state = false),
                            
                            if (selectedLogHistoryIds.isNotEmpty)
                              _buildFilterChip(
                                selectedLogFileName != null
                                    ? 'File: $selectedLogFileName'
                                    : 'File: ${selectedLogHistoryIds.length} selezionati',
                                () => ref.read(controlsSelectedLogHistoryIdsProvider.notifier).state = {},
                              ),
                            
                            TextButton(
                              onPressed: () => _resetAllFilters(ref),
                              child: Text('Reset tutto', style: TextStyle(fontSize: isUltraCompact ? 10 : 12, color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

          SizedBox(height: MediaQuery.of(context).size.width < 700 ? 8 : 24),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: paginatedTrasferte.length,
              itemBuilder: (context, index) {
                final double screenWidth = MediaQuery.of(context).size.width;
                final bool isVeryCompact = screenWidth < 700;
                final bool isUltraCompact = screenWidth < 500;
                final badgePadding = EdgeInsets.symmetric(
                  horizontal: isUltraCompact ? 2.0 : (isVeryCompact ? 4.0 : (isCompactList ? 6.0 : 8.0)),
                  vertical: isUltraCompact ? 0.5 : (isVeryCompact ? 0.5 : (isCompactList ? 1.0 : 2.0)),
                );
                final badgeIconSize = isUltraCompact ? 7.0 : (isVeryCompact ? 8.0 : (isCompactList ? 10.0 : 12.0));
                final badgeFontSize = isUltraCompact ? 7.0 : (isVeryCompact ? 8.0 : (isCompactList ? 9.0 : 10.0));

                final double trailingWidth = isUltraCompact ? 85.0 : (isVeryCompact ? 100.0 : (isCompactList ? 130.0 : 160.0));
                final double horizontalPadding = isUltraCompact ? 2.0 : (isVeryCompact ? 4.0 : (isCompactList ? 10.0 : 16.0));
                final double recordVerticalPadding = isUltraCompact ? 1.5 : (isVeryCompact ? 2.0 : (isCompactList ? 6.0 : 12.0));

                final numeroTrasferta = paginatedTrasferte[index];
                final recordsTrasferta = groupedRecords[numeroTrasferta] ?? [];
                final firstRecord = recordsTrasferta.isNotEmpty ? recordsTrasferta.first : null;

                double totaleTrasferta = 0.0;
                for (var r in recordsTrasferta) {
                  totaleTrasferta += r.isNegative ? -r.importo : r.importo;
                }

                // 1-to-1 matching for AMEX
                final amexForThisT = allAmexRecords.where((ame) => ame.numeroTrasferta == numeroTrasferta).toList();
                final Map<int, EstrattoAmex> tracciatoToAmexMatch = {};
                final Set<int> matchedAmexIds = {};
                
                // Pass 1: exact/close amount matches and exact bolla for AMEX
                for (final record in recordsTrasferta) {
                  final recordImporto = record.isNegative ? -record.importo : record.importo;
                  EstrattoAmex? bestAmexMatch;
                  for (final ame in amexForThisT) {
                    if (matchedAmexIds.contains(ame.id)) continue;
                    final bollaMatch = ame.bolla != null && _cleanBolla(ame.bolla!) == _cleanBolla(record.numeroBolla);
                    final importoMatch = ((ame.importoLordo ?? 0.0) - recordImporto).abs() < 0.015;
                    if (bollaMatch && importoMatch) {
                      bestAmexMatch = ame;
                      break;
                    }
                  }
                  if (bestAmexMatch != null) {
                    tracciatoToAmexMatch[record.id] = bestAmexMatch;
                    matchedAmexIds.add(bestAmexMatch.id);
                  }
                }

                // Pass 2: exact/close amount matches and fuzzy bolla for AMEX
                for (final record in recordsTrasferta) {
                  if (tracciatoToAmexMatch.containsKey(record.id)) continue;
                  final recordImporto = record.isNegative ? -record.importo : record.importo;
                  EstrattoAmex? bestAmexMatch;
                  for (final ame in amexForThisT) {
                    if (matchedAmexIds.contains(ame.id)) continue;
                    final bollaMatch = ame.bolla != null && _fuzzyBollaMatch(ame.bolla!, record.numeroBolla);
                    final importoMatch = ((ame.importoLordo ?? 0.0) - recordImporto).abs() < 0.015;
                    if (bollaMatch && importoMatch) {
                      bestAmexMatch = ame;
                      break;
                    }
                  }
                  if (bestAmexMatch != null) {
                    tracciatoToAmexMatch[record.id] = bestAmexMatch;
                    matchedAmexIds.add(bestAmexMatch.id);
                  }
                }

                // Pass 3: exact/close amount matches only (within the same trip)
                for (final record in recordsTrasferta) {
                  if (tracciatoToAmexMatch.containsKey(record.id)) continue;
                  final recordImporto = record.isNegative ? -record.importo : record.importo;
                  EstrattoAmex? bestAmexMatch;
                  for (final ame in amexForThisT) {
                    if (matchedAmexIds.contains(ame.id)) continue;
                    final importoMatch = ((ame.importoLordo ?? 0.0) - recordImporto).abs() < 0.015;
                    if (importoMatch) {
                      bestAmexMatch = ame;
                      break;
                    }
                  }
                  if (bestAmexMatch != null) {
                    tracciatoToAmexMatch[record.id] = bestAmexMatch;
                    matchedAmexIds.add(bestAmexMatch.id);
                  }
                }
                
                // Pass 4: remaining matches by exact bolla only for AMEX (discrepancies in amount)
                for (final record in recordsTrasferta) {
                  if (tracciatoToAmexMatch.containsKey(record.id)) continue;
                  EstrattoAmex? bestAmexMatch;
                  for (final ame in amexForThisT) {
                    if (matchedAmexIds.contains(ame.id)) continue;
                    final bollaMatch = ame.bolla != null && _cleanBolla(ame.bolla!) == _cleanBolla(record.numeroBolla);
                    if (bollaMatch) {
                      bestAmexMatch = ame;
                      break;
                    }
                  }
                  if (bestAmexMatch != null) {
                    tracciatoToAmexMatch[record.id] = bestAmexMatch;
                    matchedAmexIds.add(bestAmexMatch.id);
                  }
                }

                // Pass 5: remaining matches by fuzzy bolla only for AMEX (discrepancies in amount)
                for (final record in recordsTrasferta) {
                  if (tracciatoToAmexMatch.containsKey(record.id)) continue;
                  EstrattoAmex? bestAmexMatch;
                  for (final ame in amexForThisT) {
                    if (matchedAmexIds.contains(ame.id)) continue;
                    final bollaMatch = ame.bolla != null && _fuzzyBollaMatch(ame.bolla!, record.numeroBolla);
                    if (bollaMatch) {
                      bestAmexMatch = ame;
                      break;
                    }
                  }
                  if (bestAmexMatch != null) {
                    tracciatoToAmexMatch[record.id] = bestAmexMatch;
                    matchedAmexIds.add(bestAmexMatch.id);
                  }
                }

                // 1-to-1 matching for EC
                final ecForThisT = allEstrattiConto.where((ec) => ec.numeroTrasferta == numeroTrasferta).toList();
                final Map<int, EstrattoConto> tracciatoToEcMatch = {};
                final Set<int> matchedEcIds = {};
                
                // Pass 1: exact/close amount matches and exact bolla for EC
                for (final record in recordsTrasferta) {
                  final recordImporto = record.isNegative ? -record.importo : record.importo;
                  EstrattoConto? bestEcMatch;
                  for (final ec in ecForThisT) {
                    if (matchedEcIds.contains(ec.id)) continue;
                    final bollaMatch = _cleanBolla(ec.bolla) == _cleanBolla(record.numeroBolla);
                    final importoMatch = (ec.totaleServizio - recordImporto).abs() < 0.015;
                    if (bollaMatch && importoMatch) {
                      bestEcMatch = ec;
                      break;
                    }
                  }
                  if (bestEcMatch != null) {
                    tracciatoToEcMatch[record.id] = bestEcMatch;
                    matchedEcIds.add(bestEcMatch.id);
                  }
                }

                // Pass 2: exact/close amount matches and fuzzy bolla for EC
                for (final record in recordsTrasferta) {
                  if (tracciatoToEcMatch.containsKey(record.id)) continue;
                  final recordImporto = record.isNegative ? -record.importo : record.importo;
                  EstrattoConto? bestEcMatch;
                  for (final ec in ecForThisT) {
                    if (matchedEcIds.contains(ec.id)) continue;
                    final bollaMatch = _fuzzyBollaMatch(ec.bolla, record.numeroBolla);
                    final importoMatch = (ec.totaleServizio - recordImporto).abs() < 0.015;
                    if (bollaMatch && importoMatch) {
                      bestEcMatch = ec;
                      break;
                    }
                  }
                  if (bestEcMatch != null) {
                    tracciatoToEcMatch[record.id] = bestEcMatch;
                    matchedEcIds.add(bestEcMatch.id);
                  }
                }

                // Pass 3: exact/close amount matches only (within the same trip)
                for (final record in recordsTrasferta) {
                  if (tracciatoToEcMatch.containsKey(record.id)) continue;
                  final recordImporto = record.isNegative ? -record.importo : record.importo;
                  EstrattoConto? bestEcMatch;
                  for (final ec in ecForThisT) {
                    if (matchedEcIds.contains(ec.id)) continue;
                    final importoMatch = (ec.totaleServizio - recordImporto).abs() < 0.015;
                    if (importoMatch) {
                      bestEcMatch = ec;
                      break;
                    }
                  }
                  if (bestEcMatch != null) {
                    tracciatoToEcMatch[record.id] = bestEcMatch;
                    matchedEcIds.add(bestEcMatch.id);
                  }
                }
                
                // Pass 4: remaining matches by exact bolla only for EC (discrepancies in amount)
                for (final record in recordsTrasferta) {
                  if (tracciatoToEcMatch.containsKey(record.id)) continue;
                  EstrattoConto? bestEcMatch;
                  for (final ec in ecForThisT) {
                    if (matchedEcIds.contains(ec.id)) continue;
                    final bollaMatch = _cleanBolla(ec.bolla) == _cleanBolla(record.numeroBolla);
                    if (bollaMatch) {
                      bestEcMatch = ec;
                      break;
                    }
                  }
                  if (bestEcMatch != null) {
                    tracciatoToEcMatch[record.id] = bestEcMatch;
                    matchedEcIds.add(bestEcMatch.id);
                  }
                }

                // Pass 5: remaining matches by fuzzy bolla only for EC (discrepancies in amount)
                for (final record in recordsTrasferta) {
                  if (tracciatoToEcMatch.containsKey(record.id)) continue;
                  EstrattoConto? bestEcMatch;
                  for (final ec in ecForThisT) {
                    if (matchedEcIds.contains(ec.id)) continue;
                    final bollaMatch = _fuzzyBollaMatch(ec.bolla, record.numeroBolla);
                    if (bollaMatch) {
                      bestEcMatch = ec;
                      break;
                    }
                  }
                  if (bestEcMatch != null) {
                    tracciatoToEcMatch[record.id] = bestEcMatch;
                    matchedEcIds.add(bestEcMatch.id);
                  }
                }

                final ecForTrasferta = ecForThisT;
                final totaleEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);

                final sapForTrasferta = allSapRecords.where((sap) => _cleanT(sap.numeroTrasferta) == _cleanT(numeroTrasferta)).toList();
                final totaleSap = sapForTrasferta.fold<double>(0, (sum, sap) => sum + sap.importo);

                final displayCid = firstRecord?.cid ?? (sapForTrasferta.isNotEmpty ? sapForTrasferta.first.cid : '-');
                final displayDataInizio = firstRecord?.dataInizio ?? (sapForTrasferta.isNotEmpty ? sapForTrasferta.first.data : '-');
                final displayDataFine = firstRecord?.dataFine ?? (sapForTrasferta.isNotEmpty ? sapForTrasferta.first.data : '-');
                final displaySocieta = firstRecord?.societa ?? (sapForTrasferta.isNotEmpty ? sapForTrasferta.first.societaCodice : '-');
                final displayTipo = firstRecord?.tipoDipendente ?? (sapForTrasferta.isNotEmpty ? sapForTrasferta.first.tipoDipendente : '-');

                final amexForTrasferta = allAmexRecords.where((ame) => ame.numeroTrasferta == numeroTrasferta).toList();
                final totaleAmex = amexForTrasferta.fold<double>(0, (sum, ame) => sum + (ame.importoLordo ?? 0));

                final Set<String> allCids = {};
                for (var r in recordsTrasferta) {
                  allCids.add(r.cid);
                }
                for (var ec in ecForTrasferta) {
                  allCids.add(ec.cid);
                }
                for (var sap in sapForTrasferta) {
                  allCids.add(sap.cid);
                }
                for (var ame in amexForTrasferta) {
                  allCids.add(ame.cid ?? '');
                }
                final bool hasCidMismatch = allCids.length > 1;

                final hotelRecordsCount = recordsTrasferta.where((r) {
                  final code = r.giustificativoSpesa.trim().toUpperCase();
                  final desc = (dictionaryMap[r.giustificativoSpesa] ?? '').toLowerCase();
                  return code.contains('ALP') || desc.contains('alloggio') || desc.contains('hotel');
                }).length;
                final bool hasMultipleHotels = hotelRecordsCount > 1;

                final isMatching = (totaleTrasferta - totaleEC).abs() < 0.001;
                
                final statusBgColor = isMatching ? Colors.purple.shade50 : Colors.red.shade50;
                final statusTextColor = isMatching ? Colors.purple.shade900 : Colors.red.shade900;
                final statusBorderColor = isMatching ? Colors.purple.shade200 : Colors.red.shade200;

                return Card(
                  margin: EdgeInsets.only(
                    bottom: isUltraCompact ? 4 : (isVeryCompact ? 6 : (isCompactList ? 12 : 24)),
                    left: isUltraCompact ? 2 : (isVeryCompact ? 4 : (isCompactList ? 4 : 8)),
                    right: isUltraCompact ? 2 : (isVeryCompact ? 4 : (isCompactList ? 4 : 8)),
                  ),
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isVeryCompact ? 8 : 12),
                    side: BorderSide(color: statusBorderColor),
                  ),
                  child: ExpansionTile(
                    key: Key(
                      '${numeroTrasferta}_${ref.watch(controlsExpandAllProvider)}',
                    ),
                    initiallyExpanded: ref.watch(controlsExpandAllProvider),
                    collapsedBackgroundColor: statusBgColor,
                    backgroundColor: Colors.white,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    tilePadding: isUltraCompact
                        ? const EdgeInsets.symmetric(horizontal: 4, vertical: 0)
                        : (isVeryCompact
                            ? const EdgeInsets.symmetric(horizontal: 6, vertical: 0)
                            : (isCompactList 
                                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4) 
                                : const EdgeInsets.symmetric(horizontal: 16, vertical: 8))),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: isUltraCompact ? 3 : (isVeryCompact ? 6 : (isCompactList ? 8 : 12)),
                          runSpacing: isUltraCompact ? 1 : (isVeryCompact ? 2 : (isCompactList ? 4 : 4)),
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Trasferta: $numeroTrasferta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isUltraCompact ? 9 : (isVeryCompact ? 11 : (isCompactList ? 13 : 14)),
                                    color: statusTextColor,
                                  ),
                                ),
                                if (hasMultipleHotels) ...[
                                  const SizedBox(width: 4),
                                  Tooltip(
                                    message: 'Ha $hotelRecordsCount tracciati hotel',
                                    child: Icon(
                                      Icons.hotel,
                                      size: isUltraCompact ? 12 : (isVeryCompact ? 14 : (isCompactList ? 16 : 18)),
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 6),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () {
                                      Clipboard.setData(ClipboardData(text: numeroTrasferta));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Trasferta $numeroTrasferta copiata negli appunti'),
                                          duration: const Duration(seconds: 1),
                                          backgroundColor: SkyTheme.timBlue,
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.copy_rounded, 
                                        size: isUltraCompact ? 8 : (isVeryCompact ? 10 : (isCompactList ? 12 : 14)), 
                                        color: statusTextColor.withAlpha((0.6 * 255).round()),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '|  CID: ${_formatCidWithName(displayCid, anagraficaMap)}',
                              style: TextStyle(
                                fontSize: isUltraCompact ? 8.5 : (isVeryCompact ? 10 : (isCompactList ? 11 : 13)),
                                fontWeight: FontWeight.w500,
                                color: statusTextColor.withAlpha((0.8 * 255).round()),
                              ),
                            ),
                            // BADGE E.C. (Viola/Rosso)
                            Container(
                              padding: badgePadding,
                              decoration: BoxDecoration(
                                color: isMatching ? Colors.purple.shade50 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isMatching ? Icons.check_circle : Icons.warning,
                                    size: badgeIconSize,
                                    color: statusTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isUltraCompact
                                        ? (isMatching ? 'EC OK' : 'EC DIFF: ${(totaleTrasferta - totaleEC).toStringAsFixed(2)}€')
                                        : (isMatching ? 'E.C. QUADRATA' : 'E.C. DISCREPANZA: ${(totaleTrasferta - totaleEC).toStringAsFixed(2)} €'),
                                    style: TextStyle(
                                      fontSize: badgeFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: statusTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // BADGE SAP (Verde/Arancione)
                            Builder(
                              builder: (context) {
                                final isSapMatching = (totaleTrasferta - totaleSap).abs() < 0.001;
                                final sapColor = isSapMatching ? Colors.green.shade700 : Colors.orange.shade800;
                                final sapBg = isSapMatching ? Colors.green.shade50 : Colors.orange.shade50;
                                
                                return Container(
                                  padding: badgePadding,
                                  decoration: BoxDecoration(
                                    color: sapBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isSapMatching ? Colors.green.shade200 : Colors.orange.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isSapMatching ? Icons.analytics_outlined : Icons.warning_amber_rounded,
                                        size: badgeIconSize,
                                        color: sapColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isUltraCompact
                                            ? (isSapMatching ? 'SAP OK' : 'SAP: ${(totaleTrasferta - totaleSap).toStringAsFixed(2)}€')
                                            : (isSapMatching ? 'SAP QUADRATA' : 'SAP DISCREPANZA: ${(totaleTrasferta - totaleSap).toStringAsFixed(2)} €'),
                                        style: TextStyle(
                                          fontSize: badgeFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: sapColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // BADGE AMEX (Arancione)
                            Builder(
                              builder: (context) {
                                final isAmexMatching = (totaleTrasferta - totaleAmex).abs() < 0.001;
                                final amexColor = isAmexMatching ? Colors.orange.shade800 : Colors.red.shade900;
                                final amexBg = isAmexMatching ? Colors.orange.shade50 : Colors.red.shade50;
                                
                                return Container(
                                  padding: badgePadding,
                                  decoration: BoxDecoration(
                                    color: amexBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isAmexMatching ? Colors.orange.shade200 : Colors.red.shade200),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAmexMatching ? Icons.credit_card_outlined : Icons.warning_amber_rounded,
                                        size: badgeIconSize,
                                        color: amexColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isUltraCompact
                                            ? (isAmexMatching ? 'AMEX OK' : 'AMEX: ${(totaleTrasferta - totaleAmex).toStringAsFixed(2)}€')
                                            : (isAmexMatching ? 'AMEX QUADRATA' : 'AMEX DISCREPANZA: ${(totaleTrasferta - totaleAmex).toStringAsFixed(2)} €'),
                                        style: TextStyle(
                                          fontSize: badgeFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: amexColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            // BADGE CID DIFFERENTI (Rosso Intenso)
                            if (hasCidMismatch)
                              Container(
                                padding: badgePadding,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_off_outlined, size: badgeIconSize, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      isUltraCompact ? 'CID DIFF' : 'CID DIFFERENTI',
                                      style: TextStyle(
                                        fontSize: badgeFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // BADGE MOLTEPLICI HOTEL (Ambra/Arancione scuro)
                            if (hasMultipleHotels)
                              Tooltip(
                                message: 'Trasferta con $hotelRecordsCount tracciati hotel',
                                child: Container(
                                  padding: badgePadding,
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade900,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.hotel, size: badgeIconSize, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        isUltraCompact ? '>1 HOTEL' : '>1 TRACCIATO HOTEL ($hotelRecordsCount)',
                                        style: TextStyle(
                                          fontSize: badgeFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Cid prevalente: $displayCid',
                              style: TextStyle(
                                fontSize: isUltraCompact ? 8.5 : (isVeryCompact ? 10 : (isCompactList ? 11 : 12)),
                                color: hasCidMismatch ? Colors.red.shade700 : Colors.grey.shade700,
                                fontWeight: hasCidMismatch ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4),
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: displayCid));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('CID prevalente $displayCid copiato negli appunti'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: SkyTheme.timBlue,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.copy_rounded, 
                                    size: isUltraCompact ? 8.5 : (isVeryCompact ? 10 : (isCompactList ? 11 : 13)), 
                                    color: (hasCidMismatch ? Colors.red.shade700 : Colors.grey.shade700).withAlpha((0.6 * 255).round()),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    subtitle: Text(
                      isUltraCompact
                          ? '${recordsTrasferta.length} rec • $displayDataInizio - $displayDataFine • Soc: $displaySocieta • Tipo: $displayTipo'
                          : '${recordsTrasferta.length} record • Dal $displayDataInizio al $displayDataFine • Società: $displaySocieta${dictionaryMap[displaySocieta] != null ? " (${dictionaryMap[displaySocieta]})" : ""} • Tipo: $displayTipo${dictionaryMap[displayTipo] != null ? " (${dictionaryMap[displayTipo]})" : ""}',
                      style: TextStyle(fontSize: isUltraCompact ? 8 : (isVeryCompact ? 9 : (isCompactList ? 11 : 12))),
                    ),
                    leading: isUltraCompact
                        ? null
                        : Icon(
                            Icons.flight_takeoff,
                            color: statusTextColor,
                            size: isVeryCompact ? 14 : (isCompactList ? 20 : 24),
                          ),
                    children: [
                      ...recordsTrasferta.expand<Widget>((record) {
                        final matchedEC = tracciatoToEcMatch[record.id];
                        final matchedAmex = tracciatoToAmexMatch[record.id];
                        final hasMatch = matchedEC != null;

                        return [
                          // RIGA TRACCIATO CONTABILE
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: recordVerticalPadding,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(color: SkyTheme.timBlue, width: isUltraCompact ? 1.5 : (isVeryCompact ? 2 : (isCompactList ? 3 : 4))),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              record.localita.isEmpty ? 'Località non specificata' : record.localita,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: isUltraCompact ? 9 : (isVeryCompact ? 11 : (isCompactList ? 12 : 14)),
                                              ),
                                            ),
                                          ),
                                          if (record.isScarto) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.red.shade200, width: 0.5),
                                              ),
                                              child: Text(
                                                'SCARTO',
                                                style: TextStyle(
                                                  color: Colors.red.shade800,
                                                  fontSize: isUltraCompact ? 6 : (isVeryCompact ? 8 : 9),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'CID: ${_formatCidWithName(record.cid, anagraficaMap)}',
                                        style: TextStyle(
                                          fontSize: isUltraCompact ? 7 : (isVeryCompact ? 8 : (isCompactList ? 9 : 10)), 
                                          color: (hasCidMismatch && record.cid != displayCid) ? Colors.red : Colors.grey.shade600,
                                          fontWeight: (hasCidMismatch && record.cid != displayCid) ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        'Bolla: ${record.numeroBolla} • ${record.giustificativoSpesa}${dictionaryMap[record.giustificativoSpesa] != null ? " (${dictionaryMap[record.giustificativoSpesa]})" : ""}',
                                        style: TextStyle(
                                          fontSize: isUltraCompact ? 7 : (isVeryCompact ? 8 : (isCompactList ? 9 : 10)), 
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: trailingWidth,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isUltraCompact ? 9 : (isVeryCompact ? 10 : (isCompactList ? 12 : 14)),
                                          color: record.isNegative ? Colors.red.shade700 : Colors.green.shade800,
                                        ),
                                      ),
                                      SizedBox(width: isUltraCompact ? 2 : (isVeryCompact ? 4 : 8)),
                                      IconButton(
                                        icon: Icon(Icons.visibility_outlined, color: Colors.blue, size: isUltraCompact ? 12 : (isVeryCompact ? 14 : (isCompactList ? 18 : 20))),
                                        onPressed: () => _showRecordDetails(context, record),
                                        tooltip: 'Dettaglio Tracciato',
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.all(isUltraCompact ? 1 : (isVeryCompact ? 2 : 8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // RIGA ESTRATTO CONTO (se presente)
                          if (hasMatch)
                            Container(
                              margin: EdgeInsets.only(
                                left: isUltraCompact ? 2 : (isVeryCompact ? 4 : (isCompactList ? 12 : 20)),
                                bottom: isUltraCompact ? 1 : (isVeryCompact ? 1 : (isCompactList ? 4 : 8)),
                                  right: 0,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: recordVerticalPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50.withAlpha(100),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined, size: isUltraCompact ? 8 : (isVeryCompact ? 10 : (isCompactList ? 14 : 16)), color: Colors.purple.shade700),
                                  SizedBox(width: isUltraCompact ? 2 : (isVeryCompact ? 4 : 8)),
                                  Text(
                                    'EC',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                      fontSize: isUltraCompact ? 8 : (isVeryCompact ? 9 : (isCompactList ? 11 : 12)),
                                    ),
                                  ),
                                  SizedBox(width: isUltraCompact ? 3 : (isVeryCompact ? 6 : 12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          matchedEC.descrizioneServizio,
                                          style: TextStyle(
                                            fontSize: isUltraCompact ? 8 : (isVeryCompact ? 9 : (isCompactList ? 11 : 12)), 
                                            color: Colors.grey.shade700, 
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'CID: ${_formatCidWithName(matchedEC.cid, anagraficaMap)}',
                                          style: TextStyle(
                                            fontSize: isUltraCompact ? 7 : (isVeryCompact ? 8 : (isCompactList ? 9 : 10)), 
                                            color: (hasCidMismatch && matchedEC.cid != displayCid) ? Colors.red : Colors.grey.shade500,
                                            fontWeight: (hasCidMismatch && matchedEC.cid != displayCid) ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          'Bolla: ${matchedEC.bolla}',
                                          style: TextStyle(
                                            fontSize: isUltraCompact ? 7 : (isVeryCompact ? 8 : (isCompactList ? 9 : 10)), 
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Qui applichiamo lo stesso trailingWidth per allineare perfettamente
                                  SizedBox(
                                    width: trailingWidth,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            final tracciatoVal = record.isNegative ? -record.importo : record.importo;
                                            final ecVal = matchedEC.totaleServizio;
                                            final isIdentical = (tracciatoVal - ecVal).abs() < 0.001;

                                            return Text(
                                              '${ecVal.toStringAsFixed(2)} €',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isIdentical ? Colors.green.shade800 : Colors.red.shade700,
                                                fontSize: isUltraCompact ? 9 : (isVeryCompact ? 10 : (isCompactList ? 11 : 13)),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: isUltraCompact ? 2 : (isVeryCompact ? 4 : 8)),
                                        IconButton(
                                          icon: Icon(Icons.receipt_long_outlined, color: Colors.purple, size: isUltraCompact ? 10 : (isVeryCompact ? 12 : (isCompactList ? 16 : 18))),
                                          onPressed: () => _showECRecordDetails(context, matchedEC),
                                          tooltip: 'Dettaglio Estratto Conto',
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.all(isUltraCompact ? 1 : (isVeryCompact ? 2 : 8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              margin: EdgeInsets.only(
                                  left: isUltraCompact ? 2 : (isVeryCompact ? 4 : (isCompactList ? 12 : 20)),
                                  bottom: isUltraCompact ? 1 : (isVeryCompact ? 1 : (isCompactList ? 4 : 8)),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: recordVerticalPadding,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, size: isUltraCompact ? 8 : (isVeryCompact ? 9 : (isCompactList ? 12 : 14)), color: Colors.red.shade300),
                                  SizedBox(width: isUltraCompact ? 2 : (isVeryCompact ? 4 : 8)),
                                  Text(
                                    'Nessuna corrispondenza in Estratto Conto',
                                    style: TextStyle(
                                      fontSize: isUltraCompact ? 7.5 : (isVeryCompact ? 8 : (isCompactList ? 10 : 11)), 
                                      color: Colors.red.shade300, 
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // RIGA AMEX (se presente per bolla)
                          if (matchedAmex != null)
                            Container(
                              margin: EdgeInsets.only(
                                left: isUltraCompact ? 2 : (isVeryCompact ? 4 : (isCompactList ? 12 : 20)),
                                bottom: isUltraCompact ? 1 : (isVeryCompact ? 1 : (isCompactList ? 4 : 8)),
                                right: 0,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: recordVerticalPadding,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50.withAlpha(100),
                                borderRadius: const BorderRadius.all(Radius.circular(8)),
                                border: Border.all(color: Colors.orange.shade100.withAlpha(100)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.credit_card_outlined, size: isUltraCompact ? 8 : (isVeryCompact ? 10 : (isCompactList ? 14 : 16)), color: Colors.orange.shade700),
                                  SizedBox(width: isUltraCompact ? 2 : (isVeryCompact ? 4 : 8)),
                                  Text(
                                    'AMEX',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade700,
                                      fontSize: isUltraCompact ? 8 : (isVeryCompact ? 9 : (isCompactList ? 11 : 12)),
                                    ),
                                  ),
                                  SizedBox(width: isUltraCompact ? 3 : (isVeryCompact ? 6 : 12)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          matchedAmex.nomeEsercizio ?? matchedAmex.nomeFornitore ?? 'Esercizio non specificato',
                                          style: TextStyle(
                                            fontSize: isUltraCompact ? 8 : (isVeryCompact ? 9 : (isCompactList ? 11 : 12)), 
                                            color: Colors.grey.shade700, 
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'CID: ${_formatCidWithName(matchedAmex.cid ?? "", anagraficaMap)} • Data: ${matchedAmex.dataTransazione ?? "-"}',
                                          style: TextStyle(
                                            fontSize: isUltraCompact ? 7 : (isVeryCompact ? 8 : (isCompactList ? 9 : 10)), 
                                            color: (hasCidMismatch && matchedAmex.cid != displayCid) ? Colors.red : Colors.grey.shade500,
                                            fontWeight: (hasCidMismatch && matchedAmex.cid != displayCid) ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          'Bolla: ${matchedAmex.bolla ?? "-"}',
                                          style: TextStyle(
                                            fontSize: isUltraCompact ? 7 : (isVeryCompact ? 8 : (isCompactList ? 9 : 10)), 
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: trailingWidth,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Builder(
                                          builder: (context) {
                                            final tracciatoVal = record.isNegative ? -record.importo : record.importo;
                                            final amexVal = matchedAmex.importoLordo ?? 0.0;
                                            final isIdentical = (tracciatoVal - amexVal).abs() < 0.015;

                                            return Text(
                                              '${amexVal.toStringAsFixed(2)} €',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isIdentical ? Colors.green.shade800 : Colors.red.shade700,
                                                fontSize: isUltraCompact ? 9 : (isVeryCompact ? 10 : (isCompactList ? 11 : 13)),
                                              ),
                                            );
                                          },
                                        ),
                                        SizedBox(width: isUltraCompact ? 2 : (isVeryCompact ? 4 : 8)),
                                        IconButton(
                                          icon: Icon(Icons.credit_card_outlined, color: Colors.orange, size: isUltraCompact ? 10 : (isVeryCompact ? 12 : (isCompactList ? 16 : 18))),
                                          onPressed: () => _showAmexRecordDetails(context, matchedAmex),
                                          tooltip: 'Dettaglio AMEX',
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.all(isUltraCompact ? 1 : (isVeryCompact ? 2 : 8)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ];
                      }),
                      // SEZIONE RECORD SAP
                      Builder(
                        builder: (context) {
                          final sapForTrasferta = allSapRecords.where((sap) => _cleanT(sap.numeroTrasferta) == _cleanT(numeroTrasferta)).toList();
                          if (sapForTrasferta.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(isVeryCompact ? 12 : 16, isVeryCompact ? 4 : (isCompactList ? 12 : 24), isVeryCompact ? 12 : 16, isVeryCompact ? 1 : (isCompactList ? 4 : 8)),
                                child: Row(
                                  children: [
                                    Icon(Icons.analytics_outlined, size: isVeryCompact ? 10 : (isCompactList ? 14 : 16), color: Colors.green.shade800),
                                    SizedBox(width: isVeryCompact ? 4 : 8),
                                    Text(
                                      'Record Tracciato SAP',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isVeryCompact ? 9 : (isCompactList ? 11 : 12),
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...sapForTrasferta.map((sap) => Container(
                                margin: EdgeInsets.only(
                                  left: isVeryCompact ? 4 : (isCompactList ? 12 : 20),
                                  bottom: isVeryCompact ? 1 : (isCompactList ? 4 : 8),
                                  right: isVeryCompact ? 2 : 8,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: isVeryCompact ? 2 : (isCompactList ? 6 : 10),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50.withAlpha(150),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.description_outlined, size: isVeryCompact ? 10 : (isCompactList ? 14 : 16), color: Colors.green.shade700),
                                    SizedBox(width: isVeryCompact ? 4 : 8),
                                    Text(
                                      'SAP',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                        fontSize: isVeryCompact ? 9 : (isCompactList ? 11 : 12),
                                      ),
                                    ),
                                    SizedBox(width: isVeryCompact ? 6 : 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sap.tipoSpesaDescrizione,
                                            style: TextStyle(fontSize: isVeryCompact ? 9 : (isCompactList ? 11 : 12), color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'CID: ${_formatCidWithName(sap.cid, anagraficaMap)}',
                                            style: TextStyle(
                                              fontSize: isVeryCompact ? 8 : (isCompactList ? 9 : 10), 
                                              color: (hasCidMismatch && sap.cid != displayCid) ? Colors.red : Colors.grey.shade600,
                                              fontWeight: (hasCidMismatch && sap.cid != displayCid) ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            'Data: ${sap.data} • Stato: ${sap.codiceStato ?? "-"}',
                                            style: TextStyle(fontSize: isVeryCompact ? 8 : (isCompactList ? 9 : 10), color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: trailingWidth,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${sap.importo.toStringAsFixed(2)} ${sap.valuta}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade800,
                                              fontSize: isVeryCompact ? 10 : (isCompactList ? 11 : 13),
                                            ),
                                          ),
                                          SizedBox(width: isVeryCompact ? 4 : 8),
                                          IconButton(
                                            icon: Icon(Icons.analytics_outlined, color: Colors.green, size: isVeryCompact ? 12 : (isCompactList ? 16 : 18)),
                                            onPressed: () => _showSapRecordDetails(context, sap),
                                            tooltip: 'Dettaglio SAP',
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.all(isVeryCompact ? 2 : 8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          );
                        },
                      ),
                      // SEZIONE RECORD AMEX
                      Builder(
                        builder: (context) {
                          // Solo i record AMEX che NON hanno un match in questa trasferta
                          final amexForTrasferta = allAmexRecords.where((ame) => 
                            ame.numeroTrasferta == numeroTrasferta && 
                            !matchedAmexIds.contains(ame.id)
                          ).toList();
                          if (amexForTrasferta.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(isVeryCompact ? 12 : 16, isVeryCompact ? 4 : (isCompactList ? 10 : 16), isVeryCompact ? 12 : 16, isVeryCompact ? 1 : (isCompactList ? 4 : 8)),
                                child: Row(
                                  children: [
                                    Icon(Icons.credit_card_outlined, size: isVeryCompact ? 10 : (isCompactList ? 14 : 16), color: Colors.orange.shade800),
                                    SizedBox(width: isVeryCompact ? 4 : 8),
                                    Text(
                                      'Record Estratto AMEX',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isVeryCompact ? 9 : (isCompactList ? 11 : 12),
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...amexForTrasferta.map((amex) => Container(
                                margin: EdgeInsets.only(
                                  left: isVeryCompact ? 4 : (isCompactList ? 12 : 20),
                                  bottom: isVeryCompact ? 1 : (isCompactList ? 4 : 8),
                                  right: isVeryCompact ? 2 : 8,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: isVeryCompact ? 2 : (isCompactList ? 6 : 10),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50.withAlpha(150),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.payment_outlined, size: isVeryCompact ? 10 : (isCompactList ? 14 : 16), color: Colors.orange.shade700),
                                    SizedBox(width: isVeryCompact ? 4 : 8),
                                    Text(
                                      'AMEX',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                        fontSize: isVeryCompact ? 9 : (isCompactList ? 11 : 12),
                                      ),
                                    ),
                                    SizedBox(width: isVeryCompact ? 6 : 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            amex.nomeEsercizio ?? amex.nomeFornitore ?? 'Esercizio non specificato',
                                            style: TextStyle(fontSize: isVeryCompact ? 9 : (isCompactList ? 11 : 12), color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'CID: ${_formatCidWithName(amex.cid ?? "", anagraficaMap)} • Bolla: ${amex.bolla ?? "-"}',
                                            style: TextStyle(
                                              fontSize: isVeryCompact ? 8 : (isCompactList ? 9 : 10), 
                                              color: (hasCidMismatch && amex.cid != displayCid) ? Colors.red : Colors.grey.shade600,
                                              fontWeight: (hasCidMismatch && amex.cid != displayCid) ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            'Data: ${amex.dataTransazione ?? "-"} • Fornitore: ${amex.nomeFornitore ?? "-"}',
                                            style: TextStyle(fontSize: isVeryCompact ? 8 : (isCompactList ? 9 : 10), color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: trailingWidth,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${(amex.importoLordo ?? 0).toStringAsFixed(2)} €',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange.shade800,
                                              fontSize: isVeryCompact ? 10 : (isCompactList ? 11 : 13),
                                            ),
                                          ),
                                          SizedBox(width: isVeryCompact ? 4 : 8),
                                          IconButton(
                                            icon: Icon(Icons.credit_card_outlined, color: Colors.orange, size: isVeryCompact ? 12 : (isCompactList ? 16 : 18)),
                                            onPressed: () => _showAmexRecordDetails(context, amex),
                                            tooltip: 'Dettaglio AMEX',
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.all(isVeryCompact ? 2 : 8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                          );
                        },
                      ),
                      // Sezione per EC senza match nel Tracciato
                      Builder(
                        builder: (context) {
                          final orphansForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == numeroTrasferta).toList();
                          final orphanedEC = orphansForTrasferta.where((ec) => 
                            !matchedEcIds.contains(ec.id)
                          ).toList();

                          if (orphanedEC.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(isVeryCompact ? 12 : 16, isVeryCompact ? 4 : (isCompactList ? 10 : 16), isVeryCompact ? 12 : 16, isVeryCompact ? 1 : (isCompactList ? 4 : 8)),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, size: isVeryCompact ? 10 : (isCompactList ? 14 : 16), color: Colors.purple.shade800),
                                    SizedBox(width: isVeryCompact ? 4 : 8),
                                    Text(
                                      'Record Estratto Conto senza corrispondenza nel Tracciato',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isVeryCompact ? 9 : (isCompactList ? 11 : 12),
                                        color: Colors.purple.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...orphanedEC.map((ec) => Container(
                                margin: EdgeInsets.only(
                                  left: isVeryCompact ? 4 : (isCompactList ? 12 : 20),
                                  bottom: isVeryCompact ? 1 : (isCompactList ? 4 : 8),
                                  right: isVeryCompact ? 2 : 8,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: isVeryCompact ? 2 : (isCompactList ? 4 : 8),
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50.withAlpha(100),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.purple.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet_outlined, size: isVeryCompact ? 10 : (isCompactList ? 14 : 16), color: Colors.purple.shade700),
                                    SizedBox(width: isVeryCompact ? 4 : 8),
                                    Text(
                                      'EC SOLO',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple.shade700,
                                        fontSize: isVeryCompact ? 9 : (isCompactList ? 11 : 12),
                                      ),
                                    ),
                                    SizedBox(width: isVeryCompact ? 6 : 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ec.descrizioneServizio,
                                            style: TextStyle(fontSize: isVeryCompact ? 9 : (isCompactList ? 11 : 12), color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'CID: ${_formatCidWithName(ec.cid, anagraficaMap)}',
                                            style: TextStyle(
                                              fontSize: isVeryCompact ? 8 : (isCompactList ? 9 : 10), 
                                              color: (hasCidMismatch && ec.cid != displayCid) ? Colors.red : Colors.grey.shade500,
                                              fontWeight: (hasCidMismatch && ec.cid != displayCid) ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            'Bolla: ${ec.bolla} • ${ec.fornitore}',
                                            style: TextStyle(fontSize: isVeryCompact ? 8 : (isCompactList ? 9 : 10), color: Colors.grey.shade500),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: trailingWidth,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${ec.totaleServizio.toStringAsFixed(2)} €',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple.shade700,
                                              fontSize: isVeryCompact ? 10 : (isCompactList ? 11 : 13),
                                            ),
                                          ),
                                          SizedBox(width: isVeryCompact ? 4 : 8),
                                          IconButton(
                                            icon: Icon(Icons.receipt_long_outlined, color: Colors.purple, size: isVeryCompact ? 12 : (isCompactList ? 16 : 18)),
                                            onPressed: () => _showECRecordDetails(context, ec),
                                            tooltip: 'Dettaglio Estratto Conto',
                                            constraints: const BoxConstraints(),
                                            padding: EdgeInsets.all(isVeryCompact ? 2 : 8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                      // RIGA RIEPILOGO TOTALI TRASFERTA
                      Container(
                        margin: EdgeInsets.fromLTRB(
                          isVeryCompact ? 4 : 16, 
                          isVeryCompact ? 1 : (isCompactList ? 4 : 8), 
                          isVeryCompact ? 4 : 16, 
                          isVeryCompact ? 2 : (isCompactList ? 8 : 16),
                        ),
                        padding: EdgeInsets.all(isVeryCompact ? 4 : (isCompactList ? 10 : 16)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: isVeryCompact ? 4 : (isCompactList ? 12 : 24),
                          runSpacing: isVeryCompact ? 2 : (isCompactList ? 8 : 16),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'RIEPILOGO TOTALI',
                                  style: TextStyle(
                                    fontSize: isVeryCompact ? 7 : (isCompactList ? 9 : 10),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Builder(
                                  builder: (context) {
                                    final ecForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == numeroTrasferta).toList();
                                    final totaleEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
                                    final amexForTrasferta = allAmexRecords.where((ame) => ame.numeroTrasferta == numeroTrasferta).toList();
                                    final totaleAmex = amexForTrasferta.fold<double>(0, (sum, ame) => sum + (ame.importoLordo ?? 0));

                                    return Wrap(
                                      spacing: isVeryCompact ? 6 : (isCompactList ? 16 : 32),
                                      runSpacing: isVeryCompact ? 2 : (isCompactList ? 6 : 12),
                                      children: [
                                        _buildTotalIndicator('Tracciato', totaleTrasferta, SkyTheme.timBlue, isCompact: isCompactList, isVeryCompact: isVeryCompact),
                                        _buildTotalIndicator(
                                          'Estratto Conto', 
                                          totaleEC, 
                                          Colors.purple.shade700,
                                          isCompact: isCompactList,
                                          isVeryCompact: isVeryCompact,
                                        ),
                                        _buildTotalIndicator('SAP', totaleSap, Colors.green.shade700, isCompact: isCompactList, isVeryCompact: isVeryCompact),
                                        _buildTotalIndicator('AMEX', totaleAmex, Colors.orange.shade700, isCompact: isCompactList, isVeryCompact: isVeryCompact),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                            Builder(
                              builder: (context) {
                                final ecForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == numeroTrasferta).toList();
                                final totaleEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
                                final amexForTrasferta = allAmexRecords.where((ame) => ame.numeroTrasferta == numeroTrasferta).toList();
                                final totaleAmex = amexForTrasferta.fold<double>(0, (sum, ame) => sum + (ame.importoLordo ?? 0));

                                final diffEC = totaleTrasferta - totaleEC;
                                final isMatchingEC = diffEC.abs() < 0.001;
                                
                                final diffSap = totaleTrasferta - totaleSap;
                                final isMatchingSap = diffSap.abs() < 0.001;

                                final diffAmex = totaleTrasferta - totaleAmex;
                                final hasAmex = amexForTrasferta.isNotEmpty;
                                final isMatchingAmex = !hasAmex || diffAmex.abs() < 0.001;

                                if (isMatchingEC && isMatchingSap && isMatchingAmex) {
                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: isVeryCompact ? 4 : (isCompactList ? 8 : 12), vertical: isVeryCompact ? 1.5 : (isCompactList ? 4 : 6)),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.green.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.green.shade700, size: isVeryCompact ? 10 : (isCompactList ? 14 : 16)),
                                        SizedBox(width: isVeryCompact ? 4 : 8),
                                        Text(
                                          'QUADRATO',
                                          style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: isVeryCompact ? 8 : (isCompactList ? 10 : 12)),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  List<String> labels = [];
                                  if (!isMatchingEC) labels.add('EC: ${_formatCurrency(diffEC)}');
                                  if (!isMatchingSap) labels.add('SAP: ${_formatCurrency(diffSap)}');
                                  if (!isMatchingAmex) labels.add('AMEX: ${_formatCurrency(diffAmex)}');

                                  return Container(
                                    padding: EdgeInsets.symmetric(horizontal: isVeryCompact ? 4 : (isCompactList ? 8 : 12), vertical: isVeryCompact ? 1.5 : (isCompactList ? 4 : 6)),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.warning, color: Colors.red.shade700, size: isVeryCompact ? 10 : (isCompactList ? 14 : 16)),
                                        SizedBox(width: isVeryCompact ? 4 : 8),
                                        Text(
                                          'DISCREPANZA: ${labels.join(" | ")}',
                                          style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: isVeryCompact ? 8 : (isCompactList ? 10 : 12)),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: currentPage > 0
                          ? () {
                              ref.read(controlsPageProvider.notifier).state--;
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            }
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pagina ${currentPage + 1} di $totalPages',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: currentPage < totalPages - 1
                          ? () {
                              ref.read(controlsPageProvider.notifier).state++;
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              }
                            }
                          : null,
                    ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.grey.shade300,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    Text(
                      'Totale trasferte: ${trasferte.length}',
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
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimal = parts[1];
    
    final regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    final formattedWhole = whole.replaceAll(regExp, '.');
    
    return '$formattedWhole,$decimal €';
  }

  Widget _buildGlobalTotal(String label, double value, Color color, {bool isCompact = false, bool isVeryCompact = false, bool isUltraCompact = false}) {
    if (isUltraCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              _formatCurrency(value),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }
    if (isVeryCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _formatCurrency(value),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _formatCurrency(value),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalIndicator(String label, double value, Color color, {Color? labelColor, bool isCompact = false, bool isVeryCompact = false, bool isUltraCompact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isUltraCompact ? 8 : (isVeryCompact ? 9 : (isCompact ? 10 : 11)),
            color: labelColor ?? Colors.grey.shade600,
            fontWeight: labelColor != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            fontSize: isUltraCompact ? 10 : (isVeryCompact ? 12 : (isCompact ? 14 : 18)),
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showECRecordDetails(BuildContext context, EstrattoConto record) {
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
                          _buildDetailRow('Date', '${record.dataIn} - ${record.dataOut}'),
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

  void _showSapRecordDetails(BuildContext context, TracciatoSap record) {
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

  Future<void> _exportToExcel(
    List<String> trasferte,
    Map<String, List<TracciatoContabile>> groupedRecords,
    List<EstrattoConto> allEstrattiConto,
    List<TracciatoSap> allSapRecords,
    List<EstrattoAmex> allAmexRecords,
    Map<String, String> dictionaryMap,
    Map<String, String> anagraficaMap,
  ) async {
    try {
      final excel = excel_pkg.Excel.createExcel();
      final sheet = excel['ControlliTrasferte'];
      excel.delete('Sheet1');

      // STILI
      final headerStyle = excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromHexString('#003399'), // TIM Blue
        fontColorHex: excel_pkg.ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: excel_pkg.HorizontalAlign.Center,
        verticalAlign: excel_pkg.VerticalAlign.Center,
      );

      final tripHeaderStyle = excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromHexString('#F0F2F5'),
        bold: true,
      );

      final tracciatoStyle = excel_pkg.CellStyle(fontColorHex: excel_pkg.ExcelColor.fromHexString('#003399'));
      final ecStyle = excel_pkg.CellStyle(fontColorHex: excel_pkg.ExcelColor.fromHexString('#6B21A8')); // Purple
      final sapStyle = excel_pkg.CellStyle(fontColorHex: excel_pkg.ExcelColor.fromHexString('#15803D')); // Green
      final amexStyle = excel_pkg.CellStyle(fontColorHex: excel_pkg.ExcelColor.fromHexString('#C2410C')); // Orange

      // Header principale
      final headers = [
        'TIPO RIGA', 'TRASFERTA', 'CID / PASSEGGERO', 'BOLLA', 
        'DATA INIZIO TRASF.', 'DATA FINE TRASF.',
        'LOCALITÀ / DESCRIZIONE', 'GIUSTIFICATIVO / SERVIZIO', 
        'SOCIETÀ', 'DATA SPESA/BOLLA', 'IMPORTO €', 'DISC. E.C. €', 'DISC. SAP €', 'DISC. AMEX €',
        'DISC. E.C. (SI/NO)', 'DISC. SAP (SI/NO)', 'DISC. AMEX (SI/NO)'
      ];
      
      for (var i = 0; i < headers.length; i++) {
        var cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = excel_pkg.TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }
      sheet.setRowHeight(0, 30);

      int currentRow = 1;
      for (final t in trasferte) {
        final records = groupedRecords[t] ?? [];
        final sapForT = allSapRecords.where((sap) => _cleanT(sap.numeroTrasferta) == _cleanT(t)).toList();
        final cid = records.isNotEmpty ? records.first.cid : (sapForT.isNotEmpty ? sapForT.first.cid : '');
        final dataInizio = records.isNotEmpty ? records.first.dataInizio : (sapForT.isNotEmpty ? sapForT.first.data : '');
        final dataFine = records.isNotEmpty ? records.first.dataFine : (sapForT.isNotEmpty ? sapForT.first.data : '');
        final societa = records.isNotEmpty ? records.first.societa : (sapForT.isNotEmpty ? sapForT.first.societaCodice : '');
        final ecForT = allEstrattiConto.where((ec) => ec.numeroTrasferta == t).toList();
        final amexForT = allAmexRecords.where((ame) => ame.numeroTrasferta == t).toList();
        
        double totTracciato = 0;
        for (var r in records) {
          totTracciato += r.isNegative ? -r.importo : r.importo;
        }
        
        double totEC = ecForT.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
        double totSap = sapForT.fold<double>(0, (sum, sap) => sum + sap.importo);
        double totAmex = amexForT.fold<double>(0, (sum, ame) => sum + (ame.importoLordo ?? 0));
        
        final diffEC = totTracciato - totEC;
        final diffSap = totTracciato - totSap;
        final diffAmex = totTracciato - totAmex;
        final isMatchingEC = diffEC.abs() < 0.001;
        final isMatchingSap = diffSap.abs() < 0.001;
        final isMatchingAmex = amexForT.isEmpty || diffAmex.abs() < 0.001;

        // RIGA TRASFERTA (RIEPILOGO)
        final tripHeaderRow = [
          'TRASFERTA', t, 'CID: ${_formatCidWithName(cid, anagraficaMap)}', '', 
          _normalizeDate(dataInizio), _normalizeDate(dataFine),
          'E.C.: ${isMatchingEC ? "OK" : "KO"} | SAP: ${isMatchingSap ? "OK" : "KO"} | AMEX: ${isMatchingAmex ? "OK" : "KO"}',
          '', societa, '', totTracciato, diffEC, diffSap, diffAmex,
          isMatchingEC ? 'NO' : 'SI',
          isMatchingSap ? 'NO' : 'SI',
          isMatchingAmex ? 'NO' : 'SI'
        ];

        for (var i = 0; i < tripHeaderRow.length; i++) {
          var cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
          final val = tripHeaderRow[i];
          if (val is double) {
            cell.value = excel_pkg.DoubleCellValue(val);
          } else {
            cell.value = excel_pkg.TextCellValue(val.toString());
          }
          cell.cellStyle = tripHeaderStyle;
        }
        currentRow++;

        // RIGHE TRACCIATO
        for (final r in records) {
          final rowData = [
            '  > TRACCIATO', '', r.cid, r.numeroBolla, '', '', r.localita, 
            '${r.giustificativoSpesa}${dictionaryMap[r.giustificativoSpesa] != null ? " (${dictionaryMap[r.giustificativoSpesa]})" : ""}', 
            '', _normalizeDate(r.dataSpesa), r.isNegative ? -r.importo : r.importo, '', '', '', ''
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = excel_pkg.DoubleCellValue(val);
            } else {
              cell.value = excel_pkg.TextCellValue(val.toString());
            }
            cell.cellStyle = tracciatoStyle;
          }
          currentRow++;
        }

        // RIGHE ESTRATTO CONTO
        for (final ec in ecForT) {
          final rowData = [
            '  > E. CONTO', '', ec.nomePasseggero, ec.bolla, '', '', ec.itinerario, 
            ec.descrizioneServizio, '', _normalizeDate(ec.dataBolla), ec.totaleServizio, '', '', '', ''
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = excel_pkg.DoubleCellValue(val);
            } else {
              cell.value = excel_pkg.TextCellValue(val.toString());
            }
            cell.cellStyle = ecStyle;
          }
          currentRow++;
        }

        // RIGHE SAP
        for (final sap in sapForT) {
          final rowData = [
            '  > SAP', '', sap.cid, sap.cdRichiesta ?? '', '', '', sap.tipoSpesaDescrizione, 
            sap.tipoSpesaCodice, sap.societaDescrizione, _normalizeDate(sap.data), sap.importo, '', '', '', '', '', ''
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = excel_pkg.DoubleCellValue(val);
            } else {
              cell.value = excel_pkg.TextCellValue(val.toString());
            }
            cell.cellStyle = sapStyle;
          }
          currentRow++;
        }

        // RIGHE AMEX
        for (final ame in amexForT) {
          final rowData = [
            '  > AMEX', '', ame.cid, ame.bolla, '', '', ame.nomeEsercizio ?? ame.nomeFornitore ?? 'Esercizio AMEX', 
            'AMEX Transaction', '', _normalizeDate(ame.dataTransazione ?? ''), ame.importoLordo ?? 0, '', '', '', '', '', ''
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = excel_pkg.DoubleCellValue(val);
            } else {
              cell.value = excel_pkg.TextCellValue(val.toString());
            }
            cell.cellStyle = amexStyle;
          }
          currentRow++;
        }

        currentRow++; // Riga vuota
      }

      // Autofit colonne (approssimativo)
      sheet.setColumnWidth(0, 15);
      sheet.setColumnWidth(1, 15);
      sheet.setColumnWidth(2, 25);
      sheet.setColumnWidth(3, 15);
      sheet.setColumnWidth(4, 20); // Data Inizio
      sheet.setColumnWidth(5, 20); // Data Fine
      sheet.setColumnWidth(6, 40);
      sheet.setColumnWidth(7, 30);
      sheet.setColumnWidth(8, 20);
      sheet.setColumnWidth(9, 15);
      sheet.setColumnWidth(10, 15);
      sheet.setColumnWidth(11, 15);
      sheet.setColumnWidth(12, 15);
      sheet.setColumnWidth(13, 20);
      sheet.setColumnWidth(14, 20);

      // SECONDO FOGLIO: DETTAGLIO FLAT (RIGA PER RIGA)
      final detailSheet = excel['DettaglioFlat'];
      final detailHeaders = [
        'TRASFERTA', 'FONTE', 'CID', 'PASSEGGERO / DETTAGLIO', 'BOLLA', 
        'DATA', 'LOCALITÀ / DESCRIZIONE', 'GIUSTIFICATIVO / SERVIZIO', 
        'IMPORTO €', 'SOCIETÀ', 'SCARTO (SI/NO)'
      ];
      
      for (var i = 0; i < detailHeaders.length; i++) {
        var cell = detailSheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = excel_pkg.TextCellValue(detailHeaders[i]);
        cell.cellStyle = headerStyle;
      }
      detailSheet.setRowHeight(0, 30);
      
      int dRow = 1;
      for (final t in trasferte) {
        // Records Tracciato
        for (final r in groupedRecords[t] ?? []) {
           final rowData = [
            t, 'TRACCIATO', r.cid, '', r.numeroBolla, 
            _normalizeDate(r.dataSpesa), r.localita, 
            '${r.giustificativoSpesa}${dictionaryMap[r.giustificativoSpesa] != null ? " (${dictionaryMap[r.giustificativoSpesa]})" : ""}', 
            r.isNegative ? -r.importo : r.importo, r.societa, r.isScarto ? 'SI' : 'NO'
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = detailSheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: dRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = excel_pkg.DoubleCellValue(val);
            } else {
              cell.value = excel_pkg.TextCellValue(val.toString());
            }
          }
          dRow++;
        }

        // Records EC
        final ecForT = allEstrattiConto.where((ec) => ec.numeroTrasferta == t).toList();
        for (final ec in ecForT) {
          final rowData = [
            t, 'E. CONTO', ec.cid, ec.nomePasseggero, ec.bolla, 
            _normalizeDate(ec.dataBolla), ec.itinerario, ec.descrizioneServizio, 
            ec.totaleServizio, ec.ragioneSociale, 'NO'
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = detailSheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: dRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = excel_pkg.DoubleCellValue(val);
            } else {
              cell.value = excel_pkg.TextCellValue(val.toString());
            }
          }
          dRow++;
        }

        // Records SAP
        final sapForT = allSapRecords.where((sap) => _cleanT(sap.numeroTrasferta) == _cleanT(t)).toList();
        for (final sap in sapForT) {
          final rowData = [
            t, 'SAP', sap.cid, '', sap.cdRichiesta ?? '', 
            _normalizeDate(sap.data), sap.tipoSpesaDescrizione, sap.tipoSpesaCodice, 
            sap.importo, sap.societaDescrizione, 'NO'
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = detailSheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: dRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = excel_pkg.DoubleCellValue(val);
            } else {
              cell.value = excel_pkg.TextCellValue(val.toString());
            }
          }
          dRow++;
        }

        // Records AMEX
        final amexForTDetail = allAmexRecords.where((ame) => ame.numeroTrasferta == t).toList();
        for (final ame in amexForTDetail) {
          final rowData = [
            t, 'AMEX', ame.cid, ame.nomeViaggiatore, ame.bolla, 
            _normalizeDate(ame.dataTransazione ?? ''), ame.nomeEsercizio ?? ame.nomeFornitore ?? '', 'AMEX', 
            ame.importoLordo ?? 0, '', 'NO'
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = detailSheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: dRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = excel_pkg.DoubleCellValue(val);
            } else {
              cell.value = excel_pkg.TextCellValue(val.toString());
            }
          }
          dRow++;
        }
      }

      // Autofit detailSheet
      detailSheet.setColumnWidth(0, 15);
      detailSheet.setColumnWidth(1, 15);
      detailSheet.setColumnWidth(2, 15);
      detailSheet.setColumnWidth(3, 25);
      detailSheet.setColumnWidth(4, 15);
      detailSheet.setColumnWidth(5, 15);
      detailSheet.setColumnWidth(6, 40);
      detailSheet.setColumnWidth(7, 30);
      detailSheet.setColumnWidth(8, 15);
      detailSheet.setColumnWidth(9, 25);

      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva Export Controlli',
        fileName: 'SkyAudit_Controlli_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Export completato con successo'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore durante l\'export: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _normalizeDate(String dateStr) {
    if (dateStr.trim().isEmpty) return '';
    final d = dateStr.trim();
    try {
      // 1. Prova a gestire dd/MM/yy o d/M/yy o dd/MM/yyyy
      final slashMatch = RegExp(r'^(\d{1,2})/(\d{1,2})/(\d{2,4})').firstMatch(d);
      if (slashMatch != null) {
        final day = slashMatch.group(1)!.padLeft(2, '0');
        final month = slashMatch.group(2)!.padLeft(2, '0');
        var year = slashMatch.group(3)!;
        if (year.length == 2) {
          year = "20$year";
        }
        return "$day/$month/$year";
      }

      // 2. Prova DateTime.tryParse (ISO yyyy-MM-dd)
      final dt = DateTime.tryParse(d);
      if (dt != null) {
        return DateFormat('dd/MM/yyyy').format(dt);
      }
      
      // 3. Formato compatto yyyyMMdd
      if (d.length == 8 && RegExp(r'^\d{8}$').hasMatch(d)) {
        return "${d.substring(6, 8)}/${d.substring(4, 6)}/${d.substring(0, 4)}";
      }

      return d;
    } catch (_) {
      return d;
    }
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

  void _resetAllFilters(WidgetRef ref) {
    ref.read(controlsMonthProvider.notifier).state = <String>{};
    ref.read(controlsYearProvider.notifier).state = null;
    ref.read(controlsStartDateProvider.notifier).state = null;
    ref.read(controlsEndDateProvider.notifier).state = null;
    ref.read(controlsSocietaProvider.notifier).state = <String>{};
    ref.read(controlsTipoDipendenteProvider.notifier).state = {'DR', 'IM', 'QD'};
    ref.read(controlsSearchProvider.notifier).state = '';
    ref.read(controlsSortAscendingProvider.notifier).state = false;
    ref.read(controlsPageProvider.notifier).state = 0;
    ref.read(controlsShowOnlyOrphansProvider.notifier).state = false;
    ref.read(controlsCidMismatchProvider.notifier).state = false;
    ref.read(controlsMultipleHotelsProvider.notifier).state = false;
    ref.read(controlsMinDiffProvider.notifier).state = null;
    ref.read(controlsMaxDiffProvider.notifier).state = null;
    ref.read(controlsMatchStatusProvider.notifier).state = null;
    ref.read(controlsShowOnlyOrphansProvider.notifier).state = false;
    ref.read(controlsShowOnlySapOrphansProvider.notifier).state = false;
    ref.read(controlsSelectedLogHistoryIdsProvider.notifier).state = {};

    _searchController.clear();
    _minDiffController.clear();
    _maxDiffController.clear();
  }

  Widget _buildFilterDrawer(
    BuildContext context, 
    WidgetRef ref, 
    Map<String, String> dictionaryMap
  ) {
    // Re-use options calculation or pass them
    final allTracciato = ref.watch(tracciatoContabilesProvider).where((r) => !r.isScarto).toList();
    final societaOptions = allTracciato.map((e) => e.societa).toSet().toList()..sort();
    final tipoDipendenteOptions = allTracciato.map((e) => e.tipoDipendente).toSet().toList()..sort();
    final allLogs = ref.watch(logHistoryProvider);
    final tcLogs = allLogs.where((log) => log.sourceType == 'Tracciato Contabile').toList();

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
                // SCORCIATOIE RAPIDE
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildShortcutChip('Questo Mese', () {
                      final now = DateTime.now();
                      ref.read(controlsStartDateProvider.notifier).state = DateTime(now.year, now.month, 1);
                      ref.read(controlsEndDateProvider.notifier).state = DateTime(now.year, now.month + 1, 0);
                    }),
                    Builder(
                      builder: (context) {
                        final now = DateTime.now();
                        final prevDate = DateTime(now.year, now.month - 1, 1);
                        final mKey = prevDate.month.toString().padLeft(2, '0');
                        final monthLabel = monthNames[mKey] ?? 'Mese Precedente';
                        
                        return _buildShortcutChip(monthLabel, () {
                          ref.read(controlsStartDateProvider.notifier).state = DateTime(now.year, now.month - 1, 1);
                          ref.read(controlsEndDateProvider.notifier).state = DateTime(now.year, now.month, 0);
                        });
                      }
                    ),
                    Builder(
                      builder: (context) {
                        final now = DateTime.now();
                        final twoMonthsAgoDate = DateTime(now.year, now.month - 2, 1);
                        final mKey = twoMonthsAgoDate.month.toString().padLeft(2, '0');
                        final monthLabel = monthNames[mKey] ?? '2 Mesi Fa';
                        
                        return _buildShortcutChip(monthLabel, () {
                          ref.read(controlsStartDateProvider.notifier).state = DateTime(now.year, now.month - 2, 1);
                          ref.read(controlsEndDateProvider.notifier).state = DateTime(now.year, now.month - 1, 0);
                        });
                      }
                    ),
                    _buildShortcutChip('Ultimi 6 Mesi', () {
                      final now = DateTime.now();
                      ref.read(controlsStartDateProvider.notifier).state = DateTime(now.year, now.month - 6, 1);
                      ref.read(controlsEndDateProvider.notifier).state = now;
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDatePickerFilter(
                  'Data Inizio',
                  ref.watch(controlsStartDateProvider),
                  (val) => ref.read(controlsStartDateProvider.notifier).state = val,
                ),
                const SizedBox(height: 12),
                _buildDatePickerFilter(
                  'Data Fine',
                  ref.watch(controlsEndDateProvider),
                  (val) => ref.read(controlsEndDateProvider.notifier).state = val,
                ),
                
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('ANAGRAFICA'),
                const SizedBox(height: 12),
                _buildMultiSelectFilter(
                  'Società',
                  ref.watch(controlsSocietaProvider),
                  societaOptions,
                  (val) => ref.read(controlsSocietaProvider.notifier).state = val,
                  icon: Icons.business,
                  dictionary: dictionaryMap,
                ),
                const SizedBox(height: 16),
                _buildChipsMultiSelectFilter(
                  'Tipo Dipendente',
                  ref.watch(controlsTipoDipendenteProvider),
                  tipoDipendenteOptions,
                  (val) {
                    final current = ref.read(controlsTipoDipendenteProvider);
                    final next = Set<String>.from(current);
                    if (next.contains(val)) {
                      next.remove(val);
                    } else {
                      next.add(val);
                    }
                    ref.read(controlsTipoDipendenteProvider.notifier).state = next;
                  },
                  icon: Icons.people,
                  dictionary: dictionaryMap,
                ),

                const SizedBox(height: 32),
                _buildDrawerSectionTitle('CONTABILITÀ'),
                const SizedBox(height: 12),
                _buildFilterDropdown<String?>(
                  'Stato Quadratura',
                  ref.watch(controlsMatchStatusProvider),
                  ['match_all', 'match_ec_sap', 'match_ec', 'diff_any', 'diff_ec', 'diff_sap', 'diff_amex'],
                  (val) => ref.read(controlsMatchStatusProvider.notifier).state = val,
                  icon: Icons.check_circle_outline,
                  labelMapper: (val) {
                    if (val == 'match_all') return 'Tutto Quadrato (EC + SAP + AMEX)';
                    if (val == 'match_ec_sap') return 'Quadratura EC + SAP';
                    if (val == 'match_ec') return 'Quadratura EC';
                    if (val == 'diff_any') return 'Qualsiasi Discrepanza';
                    if (val == 'diff_ec') return 'Discrepanza E.C.';
                    if (val == 'diff_sap') return 'Discrepanza SAP';
                    if (val == 'diff_amex') return 'Discrepanza AMEX';
                    return 'Tutti';
                  },
                ),
                const SizedBox(height: 16),
                const Text('Range Discrepanza (€)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDrawerTextField(
                        'Min', _minDiffController, null, 
                        (v) => ref.read(controlsMinDiffProvider.notifier).state = double.tryParse(v)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDrawerTextField(
                        'Max', _maxDiffController, null, 
                        (v) => ref.read(controlsMaxDiffProvider.notifier).state = double.tryParse(v)
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Solo Record Orfani E.C.', style: TextStyle(fontSize: 14)),
                  value: ref.watch(controlsShowOnlyOrphansProvider),
                  onChanged: (v) => ref.read(controlsShowOnlyOrphansProvider.notifier).state = v,
                  activeThumbColor: SkyTheme.timBlue,
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Solo Orfani SAP', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Mostra spese SAP assenti nel Tracciato Contabile', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  value: ref.watch(controlsShowOnlySapOrphansProvider),
                  onChanged: (v) => ref.read(controlsShowOnlySapOrphansProvider.notifier).state = v,
                  activeThumbColor: SkyTheme.timBlue,
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('CID Differenti', style: TextStyle(fontSize: 14)),
                  value: ref.watch(controlsCidMismatchProvider),
                  onChanged: (v) => ref.read(controlsCidMismatchProvider.notifier).state = v,
                  activeThumbColor: SkyTheme.timBlue,
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Più di un Tracciato Hotel', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('Mostra solo trasferte con 2+ tracciati hotel', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  value: ref.watch(controlsMultipleHotelsProvider),
                  onChanged: (v) => ref.read(controlsMultipleHotelsProvider.notifier).state = v,
                  activeThumbColor: SkyTheme.timBlue,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(Icons.insert_drive_file_outlined, size: 18, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('File Contabile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildFileSelectionTrigger(
                  context,
                  'Seleziona File',
                  ref.watch(controlsSelectedLogHistoryIdsProvider),
                  tcLogs,
                  (next) {
                    ref.read(controlsSelectedLogHistoryIdsProvider.notifier).state = next;
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
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resetAllFilters(ref),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('RESET FILTRI'),
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

  Widget _buildShortcutChip(String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: onTap,
      backgroundColor: SkyTheme.timBlue.withAlpha(15),
      labelStyle: const TextStyle(color: SkyTheme.timBlue, fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      side: BorderSide(color: SkyTheme.timBlue.withAlpha(40)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildDatePickerFilter(String label, DateTime? selectedDate, Function(DateTime?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
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
            onChanged(picked);
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
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: SkyTheme.timBlue.withAlpha(150),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildDrawerTextField(String hint, TextEditingController controller, IconData? icon, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          icon: icon != null ? Icon(icon, size: 18, color: Colors.grey) : null,
          border: InputBorder.none,
          isDense: true,
        ),
        style: const TextStyle(fontSize: 14),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFilterDropdown<T>(
    String label,
    T value,
    List<T> items,
    Function(T) onChanged, {
    IconData? icon,
    String Function(T)? labelMapper,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(label, style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          icon: Icon(icon ?? Icons.arrow_drop_down, size: 20),
          items: [
            DropdownMenuItem<T>(
              value: null as T,
              child: Text('Tutti ($label)', style: const TextStyle(fontSize: 14)),
            ),
            ...items.map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    labelMapper != null ? labelMapper(item) : item.toString(),
                    style: const TextStyle(fontSize: 14),
                  ),
                )),
          ],
          onChanged: (val) {
            if (val != null || (null is T)) {
              onChanged(val as T);
            }
          },
        ),
      ),
    );
  }

  Widget _buildChipsMultiSelectFilter(
    String label,
    Set<String> selectedValues,
    List<String> options,
    Function(String) onToggle, {
    IconData? icon,
    Map<String, String>? dictionary,
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
            final description = dictionary?[option];
            final displayLabel = description != null ? '$option - $description' : option;
            
            return FilterChip(
              label: Text(
                displayLabel, 
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
                              final displayLabel = dictionary != null 
                                  ? '${dictionary[option] ?? option} ($option)'
                                  : option;
                              return CheckboxListTile(
                                title: Text(displayLabel, style: const TextStyle(fontSize: 14)),
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

  void _showRecordDetails(BuildContext context, TracciatoContabile record) {
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
                          _buildDetailRow('Società', record.societa),
                          _buildDetailRow('Tipo Dipendente', record.tipoDipendente),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Dati Spesa', Icons.receipt_long_outlined, SkyTheme.timBlue, [
                          _buildDetailRow('Giustificativo', record.giustificativoSpesa),
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
                          if (record.isScarto)
                            _buildDetailRow(
                              'Stato Quadratura', 
                              'SCARTATO (Scarti EC SAP)',
                              isHighlight: true,
                              highlightColor: Colors.red.shade700,
                            ),
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

  void _showAmexRecordDetails(BuildContext context, EstrattoAmex record) {
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
                        _buildDetailSection('Anagrafica', Icons.info_outline, Colors.blue, [
                          _buildDetailRow('CID', record.cid ?? '-'),
                          _buildDetailRow('Numero Trasferta', record.numeroTrasferta ?? '-'),
                          _buildDetailRow('Bolla (Trasformata)', record.bolla ?? '-'),
                          _buildDetailRow('Bolla Originale', record.bollaOriginale ?? '-'),
                          _buildDetailRow('Nome Viaggiatore', record.nomeViaggiatore ?? '-'),
                          _buildDetailRow('Conto', record.conto ?? '-'),
                          _buildDetailRow('Numero di conto', record.numeroConto ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Economia', Icons.euro_symbol, Colors.green, [
                          _buildDetailRow('Importo Lordo', '${record.importoLordo?.toStringAsFixed(2) ?? "0.00"} €', isHighlight: true, highlightColor: Colors.green.shade700),
                          _buildDetailRow('Importo Netto', '${record.importoNetto?.toStringAsFixed(2) ?? "0.00"} €'),
                          _buildDetailRow('Valuta', record.valuta ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Dati Transazione', Icons.payment_outlined, Colors.purple, [
                          _buildDetailRow('Data Transazione', record.dataTransazione ?? '-'),
                          _buildDetailRow('Fornitore', record.nomeFornitore ?? '-'),
                          _buildDetailRow('Esercizio', record.nomeEsercizio ?? '-'),
                          _buildDetailRow('Agenzia Viaggi', record.agenziaViaggi ?? '-'),
                        ]),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('CHIUDI', style: TextStyle(fontWeight: FontWeight.bold)),
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

  String _formatCidWithName(String cid, Map<String, String> anagraficaMap) {
    final cleanCid = cid.trim();
    final name = anagraficaMap[cleanCid];
    if (name != null && name.isNotEmpty) {
      return '$cleanCid - $name';
    }
    return cleanCid;
  }

  String _cleanBolla(String bolla) {
    String s = bolla.replaceAll(RegExp(r'[\s\-/.]'), '').trim().toUpperCase();
    if (bolla.contains('/')) {
      final parts = bolla.split('/');
      if (parts.length == 2 && parts[0].length == 2) {
        s = '${parts[0]}0${parts[1]}';
      }
    }
    if (RegExp(r'^\d+$').hasMatch(s)) {
      s = s.padRight(12, '0');
    }
    return s;
  }

  bool _fuzzyBollaMatch(String b1, String b2) {
    final cb1 = _cleanBolla(b1);
    final cb2 = _cleanBolla(b2);
    if (cb1 == cb2) return true;
    if (RegExp(r'^\d+$').hasMatch(cb1) && RegExp(r'^\d+$').hasMatch(cb2)) {
      if (cb1.length >= 10 && cb2.length >= 10) {
        return cb1.substring(0, 10) == cb2.substring(0, 10);
      }
    }
    return false;
  }
}
