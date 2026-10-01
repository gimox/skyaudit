import 'package:universal_io/io.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/upload/models/estratto_amex.dart';
import 'package:travel_check/features/upload/providers/estratto_amex_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/shared/widgets/file_selection_dialog.dart';

// Filter providers for Estratti Conto
final ecSelectedTrasfertaProvider = StateProvider<String?>((ref) => null);
final ecSelectedSocietaProvider = StateProvider<String?>((ref) => null);
final ecStartDateProvider = StateProvider<DateTime?>((ref) => null);
final ecEndDateProvider = StateProvider<DateTime?>((ref) => null);
final ecSelectedTipiServizioProvider = StateProvider<Set<String>>((ref) => {});
final ecSelectedLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});
final ecFilterOspitiProvider = StateProvider<bool>((ref) => false);
final ecSortAscendingProvider = StateProvider<bool>((ref) => false);
final ecPageProvider = StateProvider<int>((ref) => 0);
final ecExpandAllProvider = StateProvider<bool>((ref) => true);

enum EcSapMatchFilter { all, match, diff, missing }
final ecSapMatchFilterProvider = StateProvider<EcSapMatchFilter>((ref) => EcSapMatchFilter.all);

class EstrattiContoView extends ConsumerStatefulWidget {
  const EstrattiContoView({super.key});

  @override
  ConsumerState<EstrattiContoView> createState() => _EstrattiContoViewState();
}

class _EstrattiContoViewState extends ConsumerState<EstrattiContoView> {
  final _trasfertaController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isOspitiInfoExpanded = false;

  @override
  void dispose() {
    _trasfertaController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  static String _cleanT(String? s) {
    if (s == null) return '';
    return s.trim().split('.')[0].replaceAll(RegExp(r'^0+'), '');
  }

  static String _formatCidWithName(String cid, Map<String, String> anagraficaMap) {
    final cleanCid = cid.trim();
    final name = anagraficaMap[cleanCid];
    if (name != null && name.isNotEmpty) {
      return '$cleanCid - $name';
    }
    return cleanCid.isEmpty ? '-' : cleanCid;
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(estrattoContoProvider);
    final allPositiveCount = allRecords.where((r) => r.totaleServizio > 0.001).length;
    final allSapRecords = ref.watch(tracciatoSapProvider);
    final allAmexRecords = ref.watch(estrattoAmexProvider);
    final allContabileRecords = ref.watch(tracciatoContabilesProvider);
    final allLogs = ref.watch(logHistoryProvider);
    final filterOspiti = ref.watch(ecFilterOspitiProvider);
    final logHistoryMap = {for (var log in allLogs) log.uniqueCode: log};
    final ecLogIds = allRecords.map((r) => r.logHistoryId).whereType<String>().toSet();
    final ecLogs = allLogs.where((log) => log.sourceType == 'Estratto Conto' || ecLogIds.contains(log.uniqueCode)).toList();
    final ospitiLogs = ecLogs.where((log) => log.fileName.toUpperCase().contains('OSPITI')).toList();
    final ospitiLogCodes = ospitiLogs.map((l) => l.uniqueCode).toSet();

    final selectedTrasferta = ref.watch(ecSelectedTrasfertaProvider);
    final selectedSocieta = ref.watch(ecSelectedSocietaProvider);
    final startDate = ref.watch(ecStartDateProvider);
    final endDate = ref.watch(ecEndDateProvider);
    final selectedTipi = ref.watch(ecSelectedTipiServizioProvider);
    final sapMatchFilter = ref.watch(ecSapMatchFilterProvider);
    final selectedLogHistoryIds = ref.watch(ecSelectedLogHistoryIdsProvider);
    final sortAscending = ref.watch(ecSortAscendingProvider);
    final currentPage = ref.watch(ecPageProvider);
    final expandAll = ref.watch(ecExpandAllProvider);

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
        if (a.cid != null) a.cid!.trim(): a.nominativo ?? ''
    };

    const pageSize = 50;
    final isCompactList = MediaQuery.of(context).size.width < 1100;
    final isVeryCompact = MediaQuery.of(context).size.width < 900;
    final isUltraCompact = MediaQuery.of(context).size.width < 700;

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
      sapMatchFilter != EcSapMatchFilter.all,
      selectedLogHistoryIds.isNotEmpty,
      filterOspiti,
    ].where((e) => e).length;

    // Filtra record Estratto Conto di base
    final filteredRecords = allRecords.where((r) {
      if (filterOspiti && (r.logHistoryId == null || !ospitiLogCodes.contains(r.logHistoryId))) return false;
      if (selectedLogHistoryIds.isNotEmpty && !selectedLogHistoryIds.contains(r.logHistoryId)) return false;
      if (selectedSocieta != null && r.ragioneSociale != selectedSocieta) return false;
      if (selectedTipi.isNotEmpty && !selectedTipi.contains(r.tipoServizio)) return false;

      // Filtro Data Bolla
      if (startDate != null || endDate != null) {
        try {
          final parts = r.dataBolla.split('/');
          if (parts.length == 3) {
            final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            if (startDate != null && date.isBefore(startDate)) return false;
            if (endDate != null && date.isAfter(endDate)) return false;
          }
        } catch (_) {}
      }

      return true;
    }).toList();

    // Mappe di lookup O(1) per riscontro SAP ed AMEX
    final Map<String, List<TracciatoSap>> sapMapByCleanedT = {};
    for (final s in allSapRecords) {
      final key = _cleanT(s.numeroTrasferta);
      if (key.isNotEmpty) {
        sapMapByCleanedT.putIfAbsent(key, () => []).add(s);
      }
    }

    final Map<String, List<EstrattoAmex>> amexMapByT = {};
    for (final a in allAmexRecords) {
      final numTr = a.numeroTrasferta?.trim();
      if (numTr != null && numTr.isNotEmpty) {
        amexMapByT.putIfAbsent(numTr, () => []).add(a);
      }
    }

    // Raggruppamento primario per trasferta basato su Estratto Conto
    final Map<String, List<EstrattoConto>> groupedRecords = {};
    for (final record in filteredRecords) {
      final t = record.numeroTrasferta.trim().isEmpty ? 'SENZA TRASFERTA' : record.numeroTrasferta.trim();
      groupedRecords.putIfAbsent(t, () => []).add(record);
    }

    var trasferte = groupedRecords.keys.toList();

    // Filtro Ricerca testuale
    if (selectedTrasferta != null && selectedTrasferta.trim().isNotEmpty) {
      final query = selectedTrasferta.toLowerCase().trim();
      trasferte = trasferte.where((t) {
        if (t.toLowerCase().contains(query)) return true;
        final list = groupedRecords[t] ?? [];
        return list.any((r) {
          final name = anagraficheMap[r.cid.trim()] ?? '';
          final sourceFile = logHistoryMap[r.logHistoryId]?.fileName ?? '';
          return r.cid.toLowerCase().contains(query) ||
              name.toLowerCase().contains(query) ||
              r.bolla.toLowerCase().contains(query) ||
              r.descrizioneServizio.toLowerCase().contains(query) ||
              r.fornitore.toLowerCase().contains(query) ||
              sourceFile.toLowerCase().contains(query);
        });
      }).toList();
    }

    // Filtro Quadratura SAP
    if (sapMatchFilter != EcSapMatchFilter.all) {
      trasferte = trasferte.where((t) {
        final list = groupedRecords[t] ?? [];
        final tEC = list.fold<double>(0, (sum, r) => sum + r.totaleServizio);
        final sapList = sapMapByCleanedT[_cleanT(t)] ?? const [];

        if (sapMatchFilter == EcSapMatchFilter.missing) {
          return sapList.isEmpty;
        }

        if (sapList.isEmpty) return false;
        final tSap = sapList.fold<double>(0, (sum, s) => sum + s.importo);
        final isMatching = (tEC - tSap).abs() < 0.01;

        if (sapMatchFilter == EcSapMatchFilter.match) return isMatching;
        if (sapMatchFilter == EcSapMatchFilter.diff) return !isMatching;
        return true;
      }).toList();
    }

    // Ordinamento trasferte
    trasferte.sort((a, b) => sortAscending ? a.compareTo(b) : b.compareTo(a));

    // Calcolo statistiche globali (Single-pass O(N))
    double globalEC = 0.0;
    double globalPositiveEC = 0.0;
    double globalSap = 0.0;
    double globalAmex = 0.0;
    int ospitiRecordsCount = 0;
    int totalRecordsCount = 0;
    int totalPositiveRecordsCount = 0;

    for (final t in trasferte) {
      final list = groupedRecords[t] ?? [];
      totalRecordsCount += list.length;
      for (final r in list) {
        globalEC += r.totaleServizio;
        if (r.totaleServizio > 0.001) {
          totalPositiveRecordsCount++;
          globalPositiveEC += r.totaleServizio;
        }
        if (r.logHistoryId != null && ospitiLogCodes.contains(r.logHistoryId)) {
          ospitiRecordsCount++;
        }
      }

      final sapList = sapMapByCleanedT[_cleanT(t)] ?? const [];
      for (final s in sapList) {
        globalSap += s.importo;
      }

      final amexList = amexMapByT[t] ?? const [];
      for (final a in amexList) {
        globalAmex += a.importoLordo ?? 0;
      }
    }

    final totalPages = (trasferte.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, trasferte.length);
    final endIndex = (startIndex + pageSize).clamp(0, trasferte.length);
    final paginatedTrasferte = trasferte.sublist(startIndex, endIndex);

    // Società e Tipi disponibili per filtri
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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableSocieta, availableTipi, ecLogs, ospitiLogs),
      floatingActionButton: filteredRecords.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _exportToExcel(
                trasferte,
                groupedRecords,
                allSapRecords,
                allAmexRecords,
                allContabileRecords,
                anagraficheMap,
                logHistoryMap,
                filteredRecords,
              ),
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              tooltip: 'Esporta in Excel',
              child: const Icon(Icons.table_view_rounded),
            )
          : null,
      body: Column(
        children: [
          // HEADER CON TOTALI IN ALTO, RICERCA E AZIONI RAPIDE
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
                    SizedBox(height: isUltraCompact ? 4 : (isCompact ? 8 : 20)),
                    // TOTALI SU RIGA DEDICATA (IDENTICO A CONTROLLI TRASFERTE)
                    Wrap(
                      spacing: isUltraCompact ? 4 : (isVeryCompact ? 6 : (isCompact ? 10 : 32)),
                      runSpacing: isUltraCompact ? 2 : (isVeryCompact ? 4 : (isCompact ? 8 : 12)),
                      alignment: WrapAlignment.start,
                      children: [
                        _buildGlobalRecordCount(
                          'TOTALE RECORD',
                          totalRecordsCount,
                          allRecords.length,
                          SkyTheme.timBlue,
                          isCompact: isCompact,
                          isVeryCompact: isVeryCompact,
                          isUltraCompact: isUltraCompact,
                        ),
                        _buildGlobalRecordCount(
                          'RECORD (> 0 €)',
                          totalPositiveRecordsCount,
                          allPositiveCount,
                          Colors.teal.shade700,
                          tooltip: 'Record con importo > 0 € (Totale: ${_formatAmount(globalPositiveEC)})',
                          isCompact: isCompact,
                          isVeryCompact: isVeryCompact,
                          isUltraCompact: isUltraCompact,
                        ),
                        _buildGlobalTotal('E.C. (> 0 €)', globalPositiveEC, Colors.indigo.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('E.C.', globalEC, Colors.purple.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('AMEX', globalAmex, Colors.orange.shade800, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('DISCREPANZA AMEX', globalEC - globalAmex, (globalEC - globalAmex).abs() < 0.01 ? Colors.green.shade700 : Colors.red.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('SAP', globalSap, Colors.green.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                        _buildGlobalTotal('DISCREPANZA SAP', globalEC - globalSap, (globalEC - globalSap).abs() < 0.01 ? Colors.green.shade700 : Colors.red.shade700, isCompact: isCompact, isVeryCompact: isVeryCompact, isUltraCompact: isUltraCompact),
                      ],
                    ),
                    SizedBox(height: isUltraCompact ? 6 : (isVeryCompact ? 6 : (isCompact ? 12 : 24))),
                    // BARRA AZIONI E RICERCA
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
                                controller: _trasfertaController,
                                decoration: const InputDecoration(
                                  hintText: 'Cerca per trasferta, CID, nominativo, bolla, file...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
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
                    // Pulsante rapido Espandi/Comprimi tutti
                    OutlinedButton.icon(
                      onPressed: () {
                        ref.read(ecExpandAllProvider.notifier).state = !expandAll;
                      },
                      icon: Icon(
                        expandAll ? Icons.unfold_less : Icons.unfold_more,
                        size: 18,
                      ),
                      label: Text(
                        expandAll ? 'Comprimi' : 'Espandi',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Pulsante rapido File OSPITI
                    Tooltip(
                      message: ospitiLogs.isNotEmpty
                          ? 'Filtra i record dai ${ospitiLogs.length} file contenenti la parola "OSPITI"'
                          : 'Nessun file Estratto Conto contiene "OSPITI" nel nome',
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(ecFilterOspitiProvider.notifier).state = !filterOspiti;
                          ref.read(ecPageProvider.notifier).state = 0;
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
                    // Tasto Filtri avanzati
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
                              top: -8,
                              right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: SkyTheme.timBlue, shape: BoxShape.circle),
                                child: Text(
                                  '$activeFiltersCount',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
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
                        if (selectedTrasferta != null)
                          _buildFilterChip('Cerca: "$selectedTrasferta"', () {
                            ref.read(ecSelectedTrasfertaProvider.notifier).state = null;
                            _trasfertaController.clear();
                          }),
                        if (selectedSocieta != null)
                          _buildFilterChip('Società: $selectedSocieta', () => ref.read(ecSelectedSocietaProvider.notifier).state = null),
                        if (startDate != null)
                          _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(ecStartDateProvider.notifier).state = null),
                        if (endDate != null)
                          _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(ecEndDateProvider.notifier).state = null),
                        if (selectedTipi.isNotEmpty)
                          _buildFilterChip('Tipi: ${selectedTipi.length}', () => ref.read(ecSelectedTipiServizioProvider.notifier).state = {}),
                        if (sapMatchFilter != EcSapMatchFilter.all)
                          _buildFilterChip(
                            sapMatchFilter == EcSapMatchFilter.match
                                ? 'Riscontro SAP: Quadrati (OK)'
                                : (sapMatchFilter == EcSapMatchFilter.diff ? 'Riscontro SAP: Discrepanze (KO)' : 'Riscontro SAP: Assenti'),
                            () => ref.read(ecSapMatchFilterProvider.notifier).state = EcSapMatchFilter.all,
                          ),
                        if (selectedLogHistoryIds.isNotEmpty)
                          _buildFilterChip(
                            selectedLogFileName != null ? 'File: $selectedLogFileName' : 'File: ${selectedLogHistoryIds.length} selezionati',
                            () => ref.read(ecSelectedLogHistoryIdsProvider.notifier).state = {},
                          ),
                        if (filterOspiti)
                          _buildFilterChip(
                            'File OSPITI (${ospitiLogs.length} file)',
                            () {
                              ref.read(ecFilterOspitiProvider.notifier).state = false;
                              ref.read(ecPageProvider.notifier).state = 0;
                            },
                          ),
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
          );
        },
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
                                        : 'Nessun file Estratto Conto caricato contiene la parola "OSPITI" nel nome.',
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
                              ref.read(ecFilterOspitiProvider.notifier).state = false;
                              ref.read(ecPageProvider.notifier).state = 0;
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

          // LISTA A CARD PER TRASFERTA (STILE CONTROLLI TRASFERTE)
          Expanded(
            child: paginatedTrasferte.isEmpty
                ? Center(
                    child: Text(
                      'Nessuna trasferta corrisponde ai filtri selezionati.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: paginatedTrasferte.length,
                    itemBuilder: (context, index) {
                      final numeroTrasferta = paginatedTrasferte[index];
                      final recordsTrasferta = groupedRecords[numeroTrasferta] ?? [];
                      final totaleEC = recordsTrasferta.fold<double>(0, (sum, r) => sum + r.totaleServizio);

                      final sapForTrasferta = sapMapByCleanedT[_cleanT(numeroTrasferta)] ?? const [];
                      final totaleSap = sapForTrasferta.fold<double>(0, (sum, s) => sum + s.importo);
                      final hasSap = sapForTrasferta.isNotEmpty;
                      final isSapMatching = hasSap && (totaleEC - totaleSap).abs() < 0.01;
                      final hasSapDiff = hasSap && !isSapMatching;

                      final amexForTrasferta = amexMapByT[numeroTrasferta] ?? const [];
                      final totaleAmex = amexForTrasferta.fold<double>(0, (sum, a) => sum + (a.importoLordo ?? 0));
                      final hasAmex = amexForTrasferta.isNotEmpty;
                      final isAmexMatching = hasAmex && (totaleEC - totaleAmex).abs() < 0.01;

                      final displayCid = recordsTrasferta.isNotEmpty ? recordsTrasferta.first.cid : '';

                      final Color statusBorderColor = hasSapDiff
                          ? Colors.red.shade300
                          : (isSapMatching ? Colors.green.shade300 : Colors.grey.shade300);
                      final Color statusBgColor = hasSapDiff
                          ? Colors.red.shade50.withAlpha(50)
                          : (isSapMatching ? Colors.green.shade50.withAlpha(50) : Colors.grey.shade50.withAlpha(120));

                      return Card(
                        margin: EdgeInsets.only(
                          bottom: isUltraCompact ? 6 : (isVeryCompact ? 8 : (isCompactList ? 12 : 16)),
                        ),
                        elevation: 1,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isVeryCompact ? 10 : 14),
                          side: BorderSide(color: statusBorderColor),
                        ),
                        child: ExpansionTile(
                          key: Key('${numeroTrasferta}_$expandAll'),
                          initiallyExpanded: expandAll,
                          collapsedBackgroundColor: statusBgColor,
                          backgroundColor: Colors.white,
                          shape: const Border(),
                          collapsedShape: const Border(),
                          tilePadding: isUltraCompact
                              ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                              : (isVeryCompact
                                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
                          leading: Icon(
                            Icons.flight_takeoff,
                            color: isSapMatching ? Colors.green.shade700 : (hasSapDiff ? Colors.red.shade700 : SkyTheme.timBlue),
                            size: isVeryCompact ? 18 : 22,
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: isUltraCompact ? 4 : (isVeryCompact ? 6 : 10),
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Trasferta: $numeroTrasferta',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: isUltraCompact ? 10 : (isVeryCompact ? 12 : 14),
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
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
                                              size: isUltraCompact ? 10 : 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '|  CID: ${_formatCidWithName(displayCid, anagraficheMap)}',
                                    style: TextStyle(
                                      fontSize: isUltraCompact ? 9 : (isVeryCompact ? 11 : 12),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  // BADGE SAP
                                  if (hasSap)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isSapMatching ? Colors.green.shade50 : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSapMatching ? Colors.green.shade300 : Colors.red.shade300,
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSapMatching ? Icons.check_circle : Icons.warning_amber_rounded,
                                            size: 12,
                                            color: isSapMatching ? Colors.green.shade800 : Colors.red.shade800,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            isSapMatching
                                                ? 'SAP OK'
                                                : 'SAP DIFF: ${(totaleEC - totaleSap).toStringAsFixed(2)} €',
                                            style: TextStyle(
                                              fontSize: isUltraCompact ? 8 : 10,
                                              fontWeight: FontWeight.bold,
                                              color: isSapMatching ? Colors.green.shade800 : Colors.red.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.shade300, width: 0.5),
                                      ),
                                      child: Text(
                                        'SAP ASSENTE',
                                        style: TextStyle(
                                          fontSize: isUltraCompact ? 8 : 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  // BADGE AMEX (Arancione come in Controlli Trasferte)
                                  if (hasAmex)
                                    Builder(
                                      builder: (context) {
                                        final amexColor = isAmexMatching ? Colors.orange.shade800 : Colors.red.shade900;
                                        final amexBg = isAmexMatching ? Colors.orange.shade50 : Colors.red.shade50;

                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                                size: isUltraCompact ? 10 : 12,
                                                color: amexColor,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isUltraCompact
                                                    ? (isAmexMatching ? 'AMEX OK' : 'AMEX: ${(totaleEC - totaleAmex).toStringAsFixed(2)}€')
                                                    : (isAmexMatching ? 'AMEX QUADRATA' : 'AMEX DISCREPANZA: ${(totaleEC - totaleAmex).toStringAsFixed(2)} €'),
                                                style: TextStyle(
                                                  fontSize: isUltraCompact ? 8 : 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: amexColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${totaleEC.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: isUltraCompact ? 11 : (isVeryCompact ? 13 : 15),
                                  fontWeight: FontWeight.bold,
                                  color: totaleEC < 0 ? Colors.red.shade700 : Colors.green.shade800,
                                ),
                              ),
                              Text(
                                '${recordsTrasferta.length} ${recordsTrasferta.length == 1 ? "record" : "record"}',
                                style: TextStyle(
                                  fontSize: isUltraCompact ? 8 : 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            // 1. ELENCO RECORD ESTRATTO CONTO (MASTER)
                            ...recordsTrasferta.map((record) {
                              final sourceFile = logHistoryMap[record.logHistoryId]?.fileName ?? record.logHistoryId ?? '-';
                              final isOspiti = sourceFile.toUpperCase().contains('OSPITI');

                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isVeryCompact ? 12 : 20,
                                  vertical: isVeryCompact ? 8 : 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                    left: BorderSide(
                                      color: isOspiti ? Colors.orange.shade600 : SkyTheme.timBlue,
                                      width: 4,
                                    ),
                                    bottom: BorderSide(color: Colors.grey.shade100),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.receipt_long_outlined,
                                      size: isVeryCompact ? 16 : 20,
                                      color: isOspiti ? Colors.orange.shade800 : SkyTheme.timBlue,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  record.descrizioneServizio.isEmpty ? 'Servizio non specificato' : record.descrizioneServizio,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isUltraCompact ? 10 : (isVeryCompact ? 11 : 13),
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: SkyTheme.timBlue.withAlpha(20),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  record.tipoServizio,
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: SkyTheme.timBlue,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                'CID: ${_formatCidWithName(record.cid, anagraficheMap)}',
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                              ),
                                              Text(
                                                'Bolla: ${record.bolla}',
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                              ),
                                              if (record.fornitore.isNotEmpty)
                                                Text(
                                                  'Fornitore: ${record.fornitore}',
                                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                                ),
                                              if (record.ragioneSociale.isNotEmpty)
                                                Text(
                                                  'Società: ${record.ragioneSociale}',
                                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                                ),
                                              Text(
                                                'Data: ${record.dataBolla}',
                                                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          // File sorgente chip
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.description_outlined,
                                                size: 12,
                                                color: isOspiti ? Colors.orange.shade800 : Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  'File: $sourceFile',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: isOspiti ? FontWeight.bold : FontWeight.normal,
                                                    color: isOspiti ? Colors.orange.shade900 : Colors.grey.shade600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (isOspiti) ...[
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${record.totaleServizio.toStringAsFixed(2)} €',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isUltraCompact ? 10 : (isVeryCompact ? 11 : 13),
                                            color: record.totaleServizio < 0 ? Colors.red.shade700 : Colors.green.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        IconButton(
                                          icon: Icon(Icons.visibility_outlined, color: Colors.blue, size: isVeryCompact ? 16 : 18),
                                          onPressed: () => _showRecordDetails(context, record, logHistoryMap),
                                          tooltip: 'Dettaglio Estratto Conto',
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),

                            // 2. RISCONTRO TRACCIATO SAP (se presente)
                            if (hasSap) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                color: Colors.blue.shade50.withAlpha(120),
                                child: Row(
                                  children: [
                                    Icon(Icons.business_outlined, size: 14, color: Colors.blue.shade800),
                                    const SizedBox(width: 8),
                                    Text(
                                      'RISCONTRO TRACCIATO SAP (${sapForTrasferta.length} voci • Totale: ${_formatAmount(totaleSap)})',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...sapForTrasferta.map((sap) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50.withAlpha(40),
                                    border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sap.tipoSpesaDescrizione.isEmpty ? sap.tipoSpesaCodice : sap.tipoSpesaDescrizione,
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'CID: ${_formatCidWithName(sap.cid, anagraficheMap)} • Data: ${sap.data} • Società: ${sap.societaCodice}',
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${sap.importo.toStringAsFixed(2)} €',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: sap.importo < 0 ? Colors.red.shade700 : Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],

                            // 3. SEZIONE RECORD AMEX (Grafica identica a Controlli Trasferte)
                            if (hasAmex) ...[
                              Padding(
                                padding: EdgeInsets.fromLTRB(isVeryCompact ? 12 : 16, isVeryCompact ? 4 : 10, isVeryCompact ? 12 : 16, isVeryCompact ? 1 : 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.credit_card_outlined, size: isVeryCompact ? 10 : 14, color: Colors.orange.shade800),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Record Estratto AMEX (${amexForTrasferta.length} voci • Totale: ${_formatAmount(totaleAmex)})',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isVeryCompact ? 9 : 11,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...amexForTrasferta.map((amex) => Container(
                                margin: EdgeInsets.only(
                                  left: isVeryCompact ? 4 : 20,
                                  bottom: isVeryCompact ? 1 : 4,
                                  right: isVeryCompact ? 2 : 8,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isVeryCompact ? 10 : 16,
                                  vertical: isVeryCompact ? 2 : 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50.withAlpha(150),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.payment_outlined, size: isVeryCompact ? 10 : 14, color: Colors.orange.shade700),
                                    const SizedBox(width: 8),
                                    Text(
                                      'AMEX',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                        fontSize: isVeryCompact ? 9 : 11,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            amex.nomeEsercizio ?? amex.nomeFornitore ?? 'Esercizio non specificato',
                                            style: TextStyle(
                                              fontSize: isVeryCompact ? 9 : 11,
                                              color: Colors.grey.shade800,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'CID: ${_formatCidWithName(amex.cid ?? "", anagraficheMap)} • Bolla: ${amex.bolla ?? "-"}',
                                            style: TextStyle(
                                              fontSize: isVeryCompact ? 8 : 9,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Text(
                                            'Data: ${amex.dataTransazione ?? "-"} • Fornitore: ${amex.nomeFornitore ?? "-"}',
                                            style: TextStyle(fontSize: isVeryCompact ? 8 : 9, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${(amex.importoLordo ?? 0).toStringAsFixed(2)} €',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange.shade800,
                                            fontSize: isVeryCompact ? 10 : 12,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: Icon(Icons.credit_card_outlined, color: Colors.orange, size: isVeryCompact ? 12 : 16),
                                          onPressed: () => _showAmexRecordDetails(context, amex),
                                          tooltip: 'Dettaglio AMEX',
                                          constraints: const BoxConstraints(),
                                          padding: const EdgeInsets.all(4),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                            ],

                            // FOOTER DI TRASFERTA (RIEPILOGO TOTALI IDENTICO A CONTROLLI TRASFERTE)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isVeryCompact ? 8 : 20,
                                vertical: isVeryCompact ? 4 : 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16),
                                ),
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'RIEPILOGO TOTALI',
                                        style: TextStyle(
                                          fontSize: isVeryCompact ? 7 : 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: isVeryCompact ? 8 : 20,
                                        runSpacing: 4,
                                        children: [
                                          _buildTotalIndicator('Estratto Conto', totaleEC, SkyTheme.timBlue, isVeryCompact: isVeryCompact),
                                          if (hasSap)
                                            _buildTotalIndicator('SAP', totaleSap, Colors.green.shade700, isVeryCompact: isVeryCompact),
                                          if (hasAmex)
                                            _buildTotalIndicator('AMEX', totaleAmex, Colors.orange.shade700, isVeryCompact: isVeryCompact),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Builder(
                                    builder: (context) {
                                      final diffSap = totaleEC - totaleSap;
                                      final diffAmex = totaleEC - totaleAmex;
                                      final isAllMatching = (!hasSap || isSapMatching) && (!hasAmex || isAmexMatching);

                                      if (isAllMatching) {
                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isVeryCompact ? 6 : 12,
                                            vertical: isVeryCompact ? 2 : 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.green.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green.shade700, size: isVeryCompact ? 12 : 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'QUADRATO',
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isVeryCompact ? 8 : 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        List<String> labels = [];
                                        if (hasSap && !isSapMatching) labels.add('SAP: ${diffSap.toStringAsFixed(2)} €');
                                        if (hasAmex && !isAmexMatching) labels.add('AMEX: ${diffAmex.toStringAsFixed(2)} €');

                                        return Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: isVeryCompact ? 6 : 12,
                                            vertical: isVeryCompact ? 2 : 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.red.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: isVeryCompact ? 12 : 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'DISCREPANZA: ${labels.join(" | ")}',
                                                style: TextStyle(
                                                  color: Colors.red.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isVeryCompact ? 8 : 11,
                                                ),
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
                      onPressed: currentPage > 0
                          ? () {
                              ref.read(ecPageProvider.notifier).state--;
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Pagina ${currentPage + 1} di $totalPages',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: currentPage < totalPages - 1
                          ? () {
                              ref.read(ecPageProvider.notifier).state++;
                              if (_scrollController.hasClients) {
                                _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
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
    ref.read(ecSapMatchFilterProvider.notifier).state = EcSapMatchFilter.all;
    ref.read(ecSelectedLogHistoryIdsProvider.notifier).state = {};
    ref.read(ecFilterOspitiProvider.notifier).state = false;
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

  Widget _buildFilterDrawer(
    BuildContext context,
    WidgetRef ref,
    List<String> societa,
    List<String> availableTipi,
    List<LogHistory> ecLogs,
    List<LogHistory> ospitiLogs,
  ) {
    final filterOspiti = ref.watch(ecFilterOspitiProvider);
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
                _buildDrawerSectionTitle('ANAGRAFICA & SOCIETÀ'),
                const SizedBox(height: 12),
                _buildFilterDropdown<String?>(
                  'Società',
                  ref.watch(ecSelectedSocietaProvider),
                  societa,
                  (val) => ref.read(ecSelectedSocietaProvider.notifier).state = val,
                  icon: Icons.business,
                ),
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
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('QUADRATURA SAP'),
                const SizedBox(height: 12),
                _buildChoiceFilter<EcSapMatchFilter>(
                  ref.watch(ecSapMatchFilterProvider),
                  {
                    EcSapMatchFilter.all: 'Tutte',
                    EcSapMatchFilter.match: 'Quadrati (OK)',
                    EcSapMatchFilter.diff: 'Discrepanze (KO)',
                    EcSapMatchFilter.missing: 'SAP Assente',
                  },
                  (val) => ref.read(ecSapMatchFilterProvider.notifier).state = val,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('FILE CARICATI'),
                const SizedBox(height: 12),
                _buildFileSelectionTrigger(
                  context,
                  'Seleziona File',
                  ref.watch(ecSelectedLogHistoryIdsProvider),
                  ecLogs,
                  (next) {
                    ref.read(ecSelectedLogHistoryIdsProvider.notifier).state = next;
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
                          ref.read(ecFilterOspitiProvider.notifier).state = val;
                          ref.read(ecPageProvider.notifier).state = 0;
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
                            'Nessun file Estratto Conto contiene la parola "OSPITI" nel nome.',
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
              Icon(icon, size: 16, color: SkyTheme.timBlue),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selectedValues.contains(opt);
            return FilterChip(
              label: Text(opt.isEmpty ? '-' : opt),
              selected: isSelected,
              onSelected: (_) => onToggle(opt),
              selectedColor: SkyTheme.timBlue.withAlpha(40),
              checkmarkColor: SkyTheme.timBlue,
              labelStyle: TextStyle(
                color: isSelected ? SkyTheme.timBlue : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? SkyTheme.timBlue : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
        borderRadius: BorderRadius.circular(10),
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? SkyTheme.timBlue : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterDropdown<T>(
    String label,
    T selectedValue,
    List<T> items,
    Function(T?) onChanged, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: SkyTheme.timBlue),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: selectedValue,
              isExpanded: true,
              hint: Text('Tutti', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
              items: [
                DropdownMenuItem<T>(
                  value: null,
                  child: const Text('Tutti', style: TextStyle(fontSize: 13)),
                ),
                ...items.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(item?.toString() ?? '', style: const TextStyle(fontSize: 13)),
                  );
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerFilter(String label, DateTime? value, Function(DateTime?) onChanged) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          value != null ? '${value.day}/${value.month}/${value.year}' : label,
          style: TextStyle(
            fontSize: 13,
            color: value != null ? Colors.black87 : Colors.grey.shade500,
            fontFamily: 'TIMSans',
          ),
        ),
        trailing: value != null
            ? IconButton(
                icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                onPressed: () => onChanged(null),
              )
            : const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: SkyTheme.timBlue,
                    onPrimary: Colors.white,
                    onSurface: Colors.black87,
                  ),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            onChanged(picked);
          }
        },
      ),
    );
  }

  Widget _buildFileSelectionTrigger(
    BuildContext context,
    String label,
    Set<String> selectedCodes,
    List<LogHistory> availableLogs,
    Function(Set<String>) onChanged, {
    IconData? icon,
  }) {
    final count = selectedCodes.length;
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => FileSelectionDialog(
            logs: availableLogs,
            initialSelected: selectedCodes,
            onSelectedChanged: onChanged,
          ),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: count > 0 ? SkyTheme.timBlue : Colors.grey.shade300,
            width: count > 0 ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: count > 0 ? SkyTheme.timBlue : Colors.grey.shade600),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                count == 0
                    ? 'Tutti i file (${availableLogs.length})'
                    : '$count file selezionat${count == 1 ? "o" : "i"}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                  color: count > 0 ? SkyTheme.timBlue : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: SkyTheme.timBlue,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildGlobalMetric(
    String label,
    String valueText,
    Color color, {
    bool isCompact = false,
    bool isVeryCompact = false,
    bool isUltraCompact = false,
  }) {
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
              valueText,
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
              valueText,
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
              valueText,
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
          valueText,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w300,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalTotal(String label, double value, Color color, {bool isCompact = false, bool isVeryCompact = false, bool isUltraCompact = false}) {
    return _buildGlobalMetric(
      label,
      _formatAmount(value),
      color,
      isCompact: isCompact,
      isVeryCompact: isVeryCompact,
      isUltraCompact: isUltraCompact,
    );
  }

  Widget _buildGlobalRecordCount(
    String label,
    int currentCount,
    int totalCount,
    Color color, {
    String? tooltip,
    bool isCompact = false,
    bool isVeryCompact = false,
    bool isUltraCompact = false,
  }) {
    final text = currentCount == totalCount
        ? _formatCount(totalCount)
        : '${_formatCount(currentCount)} / ${_formatCount(totalCount)}';
    final widget = _buildGlobalMetric(
      label,
      text,
      color,
      isCompact: isCompact,
      isVeryCompact: isVeryCompact,
      isUltraCompact: isUltraCompact,
    );
    if (tooltip != null) {
      return Tooltip(message: tooltip, child: widget);
    }
    return widget;
  }

  String _formatCount(int count) {
    final s = count.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  String _formatAmount(double amount, [String currency = '€']) {
    final isNeg = amount < 0;
    final absVal = amount.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimals = parts[1];

    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formattedWhole = whole.replaceAllMapped(reg, (Match match) => '${match[1]}.');

    return '${isNeg ? "-" : ""}$formattedWhole,$decimals $currency';
  }

  void _showRecordDetails(BuildContext context, EstrattoConto record, Map<String, LogHistory> logHistoryMap) {
    final sourceFile = logHistoryMap[record.logHistoryId]?.fileName ?? record.logHistoryId ?? '-';
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
                        _buildDetailSection('Origine & File', Icons.insert_drive_file_outlined, Colors.purple.shade700, [
                          _buildDetailRow('File Sorgente', sourceFile),
                          _buildDetailRow('Riga File', '${record.sourceFileLine ?? '-'}'),
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

  Widget _buildTotalIndicator(String label, double value, Color color, {bool isVeryCompact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isVeryCompact ? 8 : 10,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          _formatAmount(value),
          style: TextStyle(
            fontSize: isVeryCompact ? 11 : 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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

  String _normalizeDate(String dateStr) {
    if (dateStr.trim().isEmpty) return '';
    final d = dateStr.trim();
    try {
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

      final dt = DateTime.tryParse(d);
      if (dt != null) {
        return DateFormat('dd/MM/yyyy').format(dt);
      }
      
      if (d.length == 8 && RegExp(r'^\d{8}$').hasMatch(d)) {
        return "${d.substring(6, 8)}/${d.substring(4, 6)}/${d.substring(0, 4)}";
      }

      return d;
    } catch (_) {
      return d;
    }
  }

  Future<void> _exportToExcel(
    List<String> trasferte,
    Map<String, List<EstrattoConto>> groupedRecords,
    List<TracciatoSap> allSapRecords,
    List<EstrattoAmex> allAmexRecords,
    List<TracciatoContabile> allContabileRecords,
    Map<String, String> anagraficaMap,
    Map<String, LogHistory> logHistoryMap,
    List<EstrattoConto> rawRecords,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['ControlliEstrattiConto'];
      excel.delete('Sheet1');

      // STILI (Identici a Controlli Trasferte)
      final headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#003399'), // TIM Blue
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final tripHeaderStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F0F2F5'),
        bold: true,
      );

      final ecStyle = CellStyle(fontColorHex: ExcelColor.fromHexString('#6B21A8')); // Purple
      final sapStyle = CellStyle(fontColorHex: ExcelColor.fromHexString('#15803D')); // Green
      final amexStyle = CellStyle(fontColorHex: ExcelColor.fromHexString('#C2410C')); // Orange
      final tracciatoStyle = CellStyle(fontColorHex: ExcelColor.fromHexString('#003399')); // Blue

      // Header principale
      final headers = [
        'TIPO RIGA', 'TRASFERTA', 'CID / PASSEGGERO', 'BOLLA', 
        'DATA INIZIO / DATA', 'DATA FINE',
        'LOCALITÀ / ITINERARIO', 'GIUSTIFICATIVO / SERVIZIO', 
        'SOCIETÀ', 'DATA BOLLA/SPESA', 'IMPORTO €', 'DISC. SAP €', 'DISC. AMEX €', 'DISC. TRACCIATO €',
        'DISC. SAP (SI/NO)', 'DISC. AMEX (SI/NO)', 'DISC. TRACCIATO (SI/NO)'
      ];
      
      for (var i = 0; i < headers.length; i++) {
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }
      sheet.setRowHeight(0, 30);

      // Pre-indicizzazione O(1) per lookup veloce
      final Map<String, List<TracciatoSap>> sapMap = {};
      for (final s in allSapRecords) {
        final key = _cleanT(s.numeroTrasferta);
        if (key.isNotEmpty) {
          sapMap.putIfAbsent(key, () => []).add(s);
        }
      }

      final Map<String, List<EstrattoAmex>> amexMap = {};
      for (final a in allAmexRecords) {
        final key = a.numeroTrasferta?.trim() ?? '';
        if (key.isNotEmpty) {
          amexMap.putIfAbsent(key, () => []).add(a);
        }
      }

      final Map<String, List<TracciatoContabile>> contabileMap = {};
      for (final c in allContabileRecords) {
        if (!c.isScarto) {
          final key = c.numeroTrasferta.trim();
          if (key.isNotEmpty) {
            contabileMap.putIfAbsent(key, () => []).add(c);
          }
        }
      }

      int currentRow = 1;
      for (final t in trasferte) {
        final records = groupedRecords[t] ?? [];
        final sapForT = sapMap[_cleanT(t)] ?? const [];
        final amexForT = amexMap[t] ?? const [];
        final contabileForT = contabileMap[t] ?? const [];

        final firstEc = records.isNotEmpty ? records.first : null;
        final cid = firstEc?.cid ?? (sapForT.isNotEmpty ? sapForT.first.cid : (contabileForT.isNotEmpty ? contabileForT.first.cid : ''));
        final dataInizio = firstEc?.dataIn ?? (contabileForT.isNotEmpty ? contabileForT.first.dataInizio : (sapForT.isNotEmpty ? sapForT.first.data : ''));
        final dataFine = firstEc?.dataOut ?? (contabileForT.isNotEmpty ? contabileForT.first.dataFine : (sapForT.isNotEmpty ? sapForT.first.data : ''));
        final societa = firstEc?.ragioneSociale ?? (sapForT.isNotEmpty ? sapForT.first.societaDescrizione : (contabileForT.isNotEmpty ? contabileForT.first.societa : ''));

        final double totEC = records.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
        final double totSap = sapForT.fold<double>(0, (sum, sap) => sum + sap.importo);
        final double totAmex = amexForT.fold<double>(0, (sum, ame) => sum + (ame.importoLordo ?? 0));
        final double totTracciato = contabileForT.fold<double>(0, (sum, r) => sum + (r.isNegative ? -r.importo : r.importo));

        final diffSap = totEC - totSap;
        final diffAmex = totEC - totAmex;
        final diffTracciato = totEC - totTracciato;

        final isMatchingSap = sapForT.isEmpty || diffSap.abs() < 0.01;
        final isMatchingAmex = amexForT.isEmpty || diffAmex.abs() < 0.01;
        final isMatchingTracciato = contabileForT.isEmpty || diffTracciato.abs() < 0.01;

        final statusStr = 'SAP: ${sapForT.isEmpty ? "-" : (isMatchingSap ? "OK" : "KO")} | AMEX: ${amexForT.isEmpty ? "-" : (isMatchingAmex ? "OK" : "KO")}${contabileForT.isNotEmpty ? " | TRACC.: ${isMatchingTracciato ? 'OK' : 'KO'}" : ""}';

        // RIGA TRASFERTA (RIEPILOGO)
        final tripHeaderRow = [
          'TRASFERTA', t, 'CID: ${_formatCidWithName(cid, anagraficaMap)}', '', 
          _normalizeDate(dataInizio), _normalizeDate(dataFine),
          statusStr, '', societa, '', totEC, diffSap, diffAmex, diffTracciato,
          isMatchingSap ? 'NO' : 'SI',
          isMatchingAmex ? 'NO' : 'SI',
          isMatchingTracciato ? 'NO' : 'SI',
        ];

        for (var i = 0; i < tripHeaderRow.length; i++) {
          var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
          final val = tripHeaderRow[i];
          if (val is double) {
            cell.value = DoubleCellValue(val);
          } else {
            cell.value = TextCellValue(val.toString());
          }
          cell.cellStyle = tripHeaderStyle;
        }
        currentRow++;

        // RIGHE ESTRATTO CONTO
        for (final ec in records) {
          final rowData = [
            '  > E. CONTO', '', ec.nomePasseggero.isNotEmpty ? ec.nomePasseggero : ec.cid, ec.bolla, 
            _normalizeDate(ec.dataIn), _normalizeDate(ec.dataOut), ec.itinerario, 
            ec.descrizioneServizio, ec.ragioneSociale, _normalizeDate(ec.dataBolla), ec.totaleServizio, '', '', '', '', '', ''
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = DoubleCellValue(val);
            } else {
              cell.value = TextCellValue(val.toString());
            }
            cell.cellStyle = ecStyle;
          }
          currentRow++;
        }

        // RIGHE SAP
        for (final sap in sapForT) {
          final rowData = [
            '  > SAP', '', sap.cid, sap.cdRichiesta ?? '', 
            _normalizeDate(sap.data), '', sap.tipoSpesaDescrizione, 
            sap.tipoSpesaCodice, sap.societaDescrizione, _normalizeDate(sap.data), sap.importo, '', '', '', '', '', ''
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = DoubleCellValue(val);
            } else {
              cell.value = TextCellValue(val.toString());
            }
            cell.cellStyle = sapStyle;
          }
          currentRow++;
        }

        // RIGHE AMEX
        for (final ame in amexForT) {
          final rowData = [
            '  > AMEX', '', ame.cid ?? '', ame.bolla ?? '', 
            _normalizeDate(ame.dataTransazione ?? ''), '', ame.nomeEsercizio ?? ame.nomeFornitore ?? 'Esercizio AMEX', 
            'AMEX Transaction', '', _normalizeDate(ame.dataTransazione ?? ''), ame.importoLordo ?? 0, '', '', '', '', '', ''
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = DoubleCellValue(val);
            } else {
              cell.value = TextCellValue(val.toString());
            }
            cell.cellStyle = amexStyle;
          }
          currentRow++;
        }

        // RIGHE TRACCIATO CONTABILE (se presenti)
        for (final r in contabileForT) {
          final rowData = [
            '  > TRACCIATO', '', r.cid, r.numeroBolla, 
            _normalizeDate(r.dataInizio), _normalizeDate(r.dataFine), r.localita, 
            r.giustificativoSpesa, r.societa, _normalizeDate(r.dataSpesa), r.isNegative ? -r.importo : r.importo, '', '', '', '', '', ''
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = DoubleCellValue(val);
            } else {
              cell.value = TextCellValue(val.toString());
            }
            cell.cellStyle = tracciatoStyle;
          }
          currentRow++;
        }

        currentRow++; // Riga vuota separatrice
      }

      // Larghezze colonne
      sheet.setColumnWidth(0, 15);
      sheet.setColumnWidth(1, 15);
      sheet.setColumnWidth(2, 25);
      sheet.setColumnWidth(3, 15);
      sheet.setColumnWidth(4, 20);
      sheet.setColumnWidth(5, 20);
      sheet.setColumnWidth(6, 40);
      sheet.setColumnWidth(7, 30);
      sheet.setColumnWidth(8, 25);
      sheet.setColumnWidth(9, 15);
      sheet.setColumnWidth(10, 15);
      sheet.setColumnWidth(11, 15);
      sheet.setColumnWidth(12, 15);
      sheet.setColumnWidth(13, 15);
      sheet.setColumnWidth(14, 20);
      sheet.setColumnWidth(15, 20);
      sheet.setColumnWidth(16, 20);

      // FOGLIO 2: DETTAGLIO FLAT (RIGA PER RIGA)
      final detailSheet = excel['DettaglioFlat'];
      final detailHeaders = [
        'TRASFERTA', 'FONTE', 'CID', 'PASSEGGERO / DETTAGLIO', 'BOLLA', 
        'DATA', 'LOCALITÀ / DESCRIZIONE', 'GIUSTIFICATIVO / SERVIZIO', 
        'IMPORTO €', 'SOCIETÀ', 'FILE SORGENTE'
      ];

      for (var i = 0; i < detailHeaders.length; i++) {
        var cell = detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(detailHeaders[i]);
        cell.cellStyle = headerStyle;
      }
      detailSheet.setRowHeight(0, 30);

      int dRow = 1;
      for (final t in trasferte) {
        // Records EC
        for (final ec in groupedRecords[t] ?? []) {
          final rowData = [
            t, 'E. CONTO', ec.cid, ec.nomePasseggero, ec.bolla, 
            _normalizeDate(ec.dataBolla), ec.itinerario, ec.descrizioneServizio, 
            ec.totaleServizio, ec.ragioneSociale, logHistoryMap[ec.logHistoryId]?.fileName ?? ec.logHistoryId ?? '-'
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: dRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = DoubleCellValue(val);
            } else {
              cell.value = TextCellValue(val.toString());
            }
          }
          dRow++;
        }

        // Records SAP
        for (final sap in sapMap[_cleanT(t)] ?? const []) {
          final rowData = [
            t, 'SAP', sap.cid, '', sap.cdRichiesta ?? '', 
            _normalizeDate(sap.data), sap.tipoSpesaDescrizione, sap.tipoSpesaCodice, 
            sap.importo, sap.societaDescrizione, '-'
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: dRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = DoubleCellValue(val);
            } else {
              cell.value = TextCellValue(val.toString());
            }
          }
          dRow++;
        }

        // Records AMEX
        for (final ame in amexMap[t] ?? const []) {
          final rowData = [
            t, 'AMEX', ame.cid ?? '', ame.nomeViaggiatore ?? '', ame.bolla ?? '', 
            _normalizeDate(ame.dataTransazione ?? ''), ame.nomeEsercizio ?? ame.nomeFornitore ?? '', 'AMEX', 
            ame.importoLordo ?? 0, '', '-'
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: dRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = DoubleCellValue(val);
            } else {
              cell.value = TextCellValue(val.toString());
            }
          }
          dRow++;
        }

        // Records Tracciato
        for (final r in contabileMap[t] ?? const []) {
          final rowData = [
            t, 'TRACCIATO', r.cid, '', r.numeroBolla, 
            _normalizeDate(r.dataSpesa), r.localita, 
            r.giustificativoSpesa, r.isNegative ? -r.importo : r.importo, r.societa, '-'
          ];
          for (var i = 0; i < rowData.length; i++) {
            var cell = detailSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: dRow));
            final val = rowData[i];
            if (val is double) {
              cell.value = DoubleCellValue(val);
            } else {
              cell.value = TextCellValue(val.toString());
            }
          }
          dRow++;
        }
      }

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
      detailSheet.setColumnWidth(10, 25);

      // FOGLIO 3: DATI ORIGINALI ESTRATTO CONTO
      final rawSheet = excel['DatiCompletiEC'];
      final rawHeaders = [
        'ID', 'Nr Estratto Conto', 'Nr Bolla', 'Bolla Calcolata', 'Data Bolla', 'Data Competenza',
        'Codice Cliente', 'Ragione Sociale', 'Tipo Transazione', 'Tipo Servizio', 'Descrizione Servizio',
        'Itinerario', 'Fornitore', 'Codice Viaggio', 'Nr Pax', 'Nr Tkt Bolla', 'Nome Passeggero',
        'Met Pagamento Serv', 'Met Pagamento Fee', 'Importo Servizio', 'Tasse', 'Fee', 'Codice Iva',
        'Iva Servizio', 'Iva Tasse', 'Iva Fee', 'Totale Servizio', 'Totale Tasse', 'Totale Servizio Generale',
        'Totale Fee', 'Data In', 'Data Out', 'Località Partenza', 'Località Arrivo', 'Codice Trattamento',
        'Codice Sistemazione', 'Richiedente', 'CID', 'Nominativo', 'Centro Costo', 'Numero Trasferta',
        'Campo Statistico 4', 'Riga CRM', 'SAP NO SAP', 'Campo Statistico 7', 'Campo Statistico 8',
        'Campo Statistico 9', 'Campo Statistico 10', 'Numero CC Servizio', 'Numero CC Fee',
        'Numero Docum Servizio', 'Numero Docum Fee', 'Nr Notti', 'Segue Fattura Servizi',
        'Servizio Da Pagare', 'Merchant Fee', 'Descrizione Spedire A', 'Descrizione Righe Pratiche',
        'Riga File Originale', 'File Sorgente'
      ];
      for (var i = 0; i < rawHeaders.length; i++) {
        var cell = rawSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = TextCellValue(rawHeaders[i]);
        cell.cellStyle = headerStyle;
      }
      rawSheet.setRowHeight(0, 30);

      int rRow = 1;
      for (final r in rawRecords) {
        final rowVals = [
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
          TextCellValue(anagraficaMap[r.cid.trim()] ?? ''),
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
          TextCellValue(logHistoryMap[r.logHistoryId]?.fileName ?? r.logHistoryId ?? '-'),
        ];
        for (var i = 0; i < rowVals.length; i++) {
          var cell = rawSheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rRow));
          cell.value = rowVals[i];
        }
        rRow++;
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva Export Estratti Conto',
        fileName: 'SkyAudit_EstrattiConto_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx',
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
}
