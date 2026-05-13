import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:intl/intl.dart';

final controlsMonthProvider = StateProvider<Set<String>>((ref) => {});
final controlsYearProvider = StateProvider<String?>((ref) => DateTime.now().year.toString());
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
final controlsMatchStatusProvider = StateProvider<String?>((ref) => null); // null, 'match', 'diff'
final controlsMinDiffProvider = StateProvider<double?>((ref) => null);
final controlsMaxDiffProvider = StateProvider<double?>((ref) => null);
final controlsCidMismatchProvider = StateProvider<bool>((ref) => false);

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

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(tracciatoContabilesProvider);
    final allEstrattiConto = ref.watch(estrattoContoProvider);
    final allSapRecords = ref.watch(tracciatoSapProvider);

    if (allRecords.isEmpty) {
      return Center(
        child: Text(
          'Nessun record presente nel database.\nVai su "Carica File" per importare i dati.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      );
    }

    final searchQuery = ref.watch(controlsSearchProvider);
    final selectedSocieta = ref.watch(controlsSocietaProvider);
    final selectedTipo = ref.watch(controlsTipoDipendenteProvider);
    final sortAscending = ref.watch(controlsSortAscendingProvider);
    final currentPage = ref.watch(controlsPageProvider);
    const pageSize = 100;

    final Map<String, List<TracciatoContabile>> groupedRecords = {};
    for (final record in allRecords) {
      groupedRecords.putIfAbsent(record.numeroTrasferta, () => []).add(record);
    }

    var trasferte = groupedRecords.keys.toList();

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      trasferte = trasferte.where((t) {
        final records = groupedRecords[t]!;
        
        // Verifica numero trasferta
        if (t.toLowerCase().contains(query)) return true;
        
        // Verifica CID in qualsiasi record della trasferta
        if (records.any((r) => r.cid.toLowerCase().contains(query))) return true;
        
        // Verifica località in qualsiasi record della trasferta
        if (records.any((r) => r.localita.toLowerCase().contains(query))) return true;
        
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
        final firstRecord = groupedRecords[t]!.first;

        if (selectedSocieta.isNotEmpty &&
            !selectedSocieta.contains(firstRecord.societa)) {
          return false;
        }

        if (selectedTipo.isNotEmpty &&
            !selectedTipo.contains(firstRecord.tipoDipendente)) {
          return false;
        }

        if (startDate != null || endDate != null) {
          try {
            final parts = firstRecord.dataFine.split('/');
            if (parts.length != 3) return false;
            final recordDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );

            if (startDate != null && recordDate.isBefore(startDate)) return false;
            if (endDate != null && recordDate.isAfter(endDate)) return false;
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

    final matchStatusFilter = ref.watch(controlsMatchStatusProvider);
    final minDiff = ref.watch(controlsMinDiffProvider);
    final maxDiff = ref.watch(controlsMaxDiffProvider);
    final cidMismatchFilter = ref.watch(controlsCidMismatchProvider);

    if (matchStatusFilter != null || minDiff != null || maxDiff != null || cidMismatchFilter) {
      trasferte = trasferte.where((t) {
        final recordsTrasferta = groupedRecords[t]!;
        double tTracciato = 0;
        for (var r in recordsTrasferta) {
          tTracciato += r.isNegative ? -r.importo : r.importo;
        }

        final ecForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == t).toList();
        final tEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
        final isMatchingEC = (tTracciato - tEC).abs() < 0.001;

        final sapForTrasferta = allSapRecords.where((sap) => sap.numeroTrasferta == t).toList();
        final tSap = sapForTrasferta.fold<double>(0, (sum, sap) => sum + sap.importo);
        final isMatchingSap = (tTracciato - tSap).abs() < 0.001;

        if (matchStatusFilter != null) {
          if (matchStatusFilter == 'match' && (!isMatchingEC || !isMatchingSap)) return false;
          if (matchStatusFilter == 'diff' && (isMatchingEC && isMatchingSap)) return false;
          if (matchStatusFilter == 'diff_ec' && isMatchingEC) return false;
          if (matchStatusFilter == 'diff_sap' && isMatchingSap) return false;
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
          if (cids.length <= 1) return false;
        }


        if (minDiff != null && (tTracciato - tEC).abs() < minDiff) return false;
        if (maxDiff != null && (tTracciato - tEC).abs() > maxDiff) return false;

        return true;
      }).toList();
    }

    trasferte.sort((a, b) => sortAscending ? a.compareTo(b) : b.compareTo(a));

    double globalTracciato = 0;
    double globalEC = 0;
    double globalSap = 0;
    for (final t in trasferte) {
      final records = groupedRecords[t]!;
      for (final r in records) {
        globalTracciato += r.isNegative ? -r.importo : r.importo;
      }
      final ecForT = allEstrattiConto.where((ec) => ec.numeroTrasferta == t);
      for (final ec in ecForT) {
        globalEC += ec.totaleServizio;
      }
      final sapForT = allSapRecords.where((sap) => sap.numeroTrasferta == t);
      for (final sap in sapForT) {
        globalSap += sap.importo;
      }
    }

    final totalPages = (trasferte.length / pageSize).ceil();
    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize) > trasferte.length
        ? trasferte.length
        : (startIndex + pageSize);
    final paginatedTrasferte = trasferte.sublist(startIndex, endIndex);

    final dictionaries = ref.watch(dictionaryProvider);
    final dictionaryMap = {
      for (final entry in dictionaries) entry.code: entry.value,
    };

    final activeFiltersCount = [
      startDate != null,
      endDate != null,
      selectedSocieta.isNotEmpty,
      selectedTipo.isNotEmpty,
      minDiff != null,
      maxDiff != null,
      matchStatusFilter != null,
      ref.watch(controlsShowOnlyOrphansProvider),
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
          dictionaryMap
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        tooltip: 'Esporta in Excel',
        child: const Icon(Icons.table_view_rounded),
      ),
      body: Column(
        children: [
          // HEADER SEMPLIFICATO E MODERNO
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
                const SizedBox.shrink(),
                const SizedBox(height: 20),
                // TOTALI SU RIGA DEDICATA
                Wrap(
                  spacing: 32,
                  runSpacing: 12,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildGlobalTotal('TRACCIATO', globalTracciato, SkyTheme.timBlue),
                    _buildGlobalTotal('E.C.', globalEC, Colors.purple.shade700),
                    _buildGlobalTotal('SAP', globalSap, Colors.green.shade700),
                    _buildGlobalTotal('DISCREPANZA E.C.', globalTracciato - globalEC, Colors.red.shade700),
                    _buildGlobalTotal('DISCREPANZA SAP', globalTracciato - globalSap, Colors.orange.shade800),
                  ],
                ),
                const SizedBox(height: 24),
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
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Cerca per trasferta, cid, località...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (value) => ref.read(controlsSearchProvider.notifier).state = value,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // BOTTONE FILTRI AVANZATI
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
                                decoration: const BoxDecoration(
                                  color: SkyTheme.timBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$activeFiltersCount',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // ESPORTA EXCEL

                  ],
                ),
                // CHIPS FILTRI ATTIVI
                if (activeFiltersCount > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (startDate != null)
                          _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(controlsStartDateProvider.notifier).state = null),
                        if (endDate != null)
                          _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(controlsEndDateProvider.notifier).state = null),
                        if (selectedSocieta.isNotEmpty)
                          _buildFilterChip('${selectedSocieta.length} Società', () => ref.read(controlsSocietaProvider.notifier).state = {}),
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
                            matchStatusFilter == 'match' ? 'Tutto Quadrato' : 
                            matchStatusFilter == 'diff' ? 'Qualsiasi Discrepanza' :
                            matchStatusFilter == 'diff_ec' ? 'Discrepanza E.C.' : 'Discrepanza SAP', 
                            () => ref.read(controlsMatchStatusProvider.notifier).state = null
                          ),
                        if (ref.watch(controlsShowOnlyOrphansProvider))
                          _buildFilterChip('Solo Orfani', () => ref.read(controlsShowOnlyOrphansProvider.notifier).state = false),
                        
                        if (ref.watch(controlsCidMismatchProvider))
                          _buildFilterChip('CID Differenti', () => ref.read(controlsCidMismatchProvider.notifier).state = false),
                        
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

          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: paginatedTrasferte.length,
              itemBuilder: (context, index) {
                final numeroTrasferta = paginatedTrasferte[index];
                final recordsTrasferta = groupedRecords[numeroTrasferta]!;
                final firstRecord = recordsTrasferta.first;

                double totaleTrasferta = 0.0;
                for (var r in recordsTrasferta) {
                  totaleTrasferta += r.isNegative ? -r.importo : r.importo;
                }

                final ecForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == numeroTrasferta).toList();
                final totaleEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);

                final sapForTrasferta = allSapRecords.where((sap) => sap.numeroTrasferta == numeroTrasferta).toList();
                final totaleSap = sapForTrasferta.fold<double>(0, (sum, sap) => sum + sap.importo);

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
                final bool hasCidMismatch = allCids.length > 1;

                final isMatching = (totaleTrasferta - totaleEC).abs() < 0.001;
                
                final statusBgColor = isMatching ? Colors.purple.shade50 : Colors.red.shade50;
                final statusTextColor = isMatching ? Colors.purple.shade900 : Colors.red.shade900;
                final statusBorderColor = isMatching ? Colors.purple.shade200 : Colors.red.shade200;

                return Card(
                  margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Trasferta: $numeroTrasferta',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusTextColor,
                              ),
                            ),
                            // BADGE E.C. (Viola/Rosso)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isMatching ? Colors.purple.shade50 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isMatching ? Icons.check_circle : Icons.warning,
                                    size: 12,
                                    color: statusTextColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isMatching ? 'E.C. QUADRATA' : 'E.C. DISCREPANZA: ${(totaleTrasferta - totaleEC).toStringAsFixed(2)} €',
                                    style: TextStyle(
                                      fontSize: 10,
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
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                                        size: 12,
                                        color: sapColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isSapMatching ? 'SAP QUADRATA' : 'SAP DISCREPANZA: ${(totaleTrasferta - totaleSap).toStringAsFixed(2)} €',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: sapColor,
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade900,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_off_outlined, size: 12, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      'CID DIFFERENTI',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        Text(
                          'Cid prevalente: ${firstRecord.cid}',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasCidMismatch ? Colors.red.shade700 : Colors.grey.shade700,
                            fontWeight: hasCidMismatch ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${recordsTrasferta.length} record • Dal ${firstRecord.dataInizio} al ${firstRecord.dataFine} • Società: ${firstRecord.societa}${dictionaryMap[firstRecord.societa] != null ? " (${dictionaryMap[firstRecord.societa]})" : ""} • Tipo: ${firstRecord.tipoDipendente}${dictionaryMap[firstRecord.tipoDipendente] != null ? " (${dictionaryMap[firstRecord.tipoDipendente]})" : ""}',
                    ),
                    leading: Icon(
                      Icons.flight_takeoff,
                      color: statusTextColor,
                    ),
                    children: recordsTrasferta.expand<Widget>((record) {
                      final matchingEC = allEstrattiConto.where(
                        (ec) => ec.bolla == record.numeroBolla,
                      ).toList();
                      final hasMatch = matchingEC.isNotEmpty;

                      // Costanti per l'allineamento
                      const double trailingWidth = 160.0;
                      const double horizontalPadding = 16.0;

                      return [
                        // RIGA TRACCIATO CONTABILE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: SkyTheme.timBlue, width: 4),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.localita.isEmpty ? 'Località non specificata' : record.localita,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'CID: ${record.cid}',
                                      style: TextStyle(
                                        fontSize: 10, 
                                        color: (hasCidMismatch && record.cid != firstRecord.cid) ? Colors.red : Colors.grey.shade600,
                                        fontWeight: (hasCidMismatch && record.cid != firstRecord.cid) ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Bolla: ${record.numeroBolla} • ${record.giustificativoSpesa}${dictionaryMap[record.giustificativoSpesa] != null ? " (${dictionaryMap[record.giustificativoSpesa]})" : ""}',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
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
                                        fontSize: 14,
                                        color: record.isNegative ? Colors.red.shade700 : Colors.green.shade800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20),
                                      onPressed: () => _showRecordDetails(context, record),
                                      tooltip: 'Dettaglio Tracciato',
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(8),
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
                            margin: const EdgeInsets.only(left: 20, bottom: 8, right: 0),
                            padding: const EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50.withAlpha(100),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.purple.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'EC',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        matchingEC.first.descrizioneServizio,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'CID: ${matchingEC.first.cid}',
                                        style: TextStyle(
                                          fontSize: 10, 
                                          color: (hasCidMismatch && matchingEC.first.cid != firstRecord.cid) ? Colors.red : Colors.grey.shade500,
                                          fontWeight: (hasCidMismatch && matchingEC.first.cid != firstRecord.cid) ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Bolla: ${matchingEC.first.bolla}',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
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
                                          final ecVal = matchingEC.first.totaleServizio;
                                          final isIdentical = (tracciatoVal - ecVal).abs() < 0.001;

                                          return Text(
                                            '${ecVal.toStringAsFixed(2)} €',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isIdentical ? Colors.green.shade800 : Colors.red.shade700,
                                              fontSize: 13,
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.receipt_long_outlined, color: Colors.purple, size: 18),
                                        onPressed: () => _showECRecordDetails(context, matchingEC.first),
                                        tooltip: 'Dettaglio Estratto Conto',
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            margin: const EdgeInsets.only(left: 20, bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 14, color: Colors.red.shade300),
                                const SizedBox(width: 8),
                                Text(
                                  'Nessuna corrispondenza in Estratto Conto',
                                  style: TextStyle(fontSize: 11, color: Colors.red.shade300, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                      ];
                    }).toList()
                      ..addAll([
                        // SEZIONE RECORD SAP
                        Builder(
                          builder: (context) {
                            final sapForTrasferta = allSapRecords.where((sap) => sap.numeroTrasferta == numeroTrasferta).toList();
                            if (sapForTrasferta.isEmpty) return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.analytics_outlined, size: 16, color: Colors.green.shade800),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Record Tracciato SAP',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...sapForTrasferta.map((sap) => Container(
                                  margin: const EdgeInsets.only(left: 20, bottom: 8, right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50.withAlpha(150),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.green.shade100),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.description_outlined, size: 16, color: Colors.green.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        'SAP',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sap.tipoSpesaDescrizione,
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'CID: ${sap.cid}',
                                              style: TextStyle(
                                                fontSize: 10, 
                                                color: (hasCidMismatch && sap.cid != firstRecord.cid) ? Colors.red : Colors.grey.shade600,
                                                fontWeight: (hasCidMismatch && sap.cid != firstRecord.cid) ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Data: ${sap.data} • Stato: ${sap.codiceStato ?? "-"}',
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 160,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${sap.importo.toStringAsFixed(2)} ${sap.valuta}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade800,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.analytics_outlined, color: Colors.green, size: 18),
                                              onPressed: () => _showSapRecordDetails(context, sap),
                                              tooltip: 'Dettaglio SAP',
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(8),
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
                            final bolleInTracciato = recordsTrasferta.map((r) => r.numeroBolla).toSet();
                            final orphansForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == numeroTrasferta).toList();
                            final orphanedEC = orphansForTrasferta.where((ec) => 
                              !bolleInTracciato.contains(ec.bolla)
                            ).toList();

                            if (orphanedEC.isEmpty) return const SizedBox.shrink();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 16, color: Colors.orange.shade800),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Record Estratto Conto senza corrispondenza nel Tracciato',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...orphanedEC.map((ec) => Container(
                                  margin: const EdgeInsets.only(left: 20, bottom: 8, right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50.withAlpha(100),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange.shade100),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.orange.shade700),
                                      const SizedBox(width: 8),
                                      Text(
                                        'EC SOLO',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange.shade700,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              ec.descrizioneServizio,
                                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'CID: ${ec.cid}',
                                              style: TextStyle(
                                                fontSize: 10, 
                                                color: (hasCidMismatch && ec.cid != firstRecord.cid) ? Colors.red : Colors.grey.shade500,
                                                fontWeight: (hasCidMismatch && ec.cid != firstRecord.cid) ? FontWeight.bold : FontWeight.normal,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Bolla: ${ec.bolla} • ${ec.fornitore}',
                                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 160,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${ec.totaleServizio.toStringAsFixed(2)} €',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange.shade700,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.receipt_long_outlined, color: Colors.orange, size: 18),
                                              onPressed: () => _showECRecordDetails(context, ec),
                                              tooltip: 'Dettaglio Estratto Conto',
                                              constraints: const BoxConstraints(),
                                              padding: const EdgeInsets.all(8),
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
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 24,
                            runSpacing: 16,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'RIEPILOGO TOTALI',
                                    style: TextStyle(
                                      fontSize: 10,
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

                                      return Wrap(
                                        spacing: 32,
                                        runSpacing: 12,
                                        children: [
                                          _buildTotalIndicator('Tracciato', totaleTrasferta, SkyTheme.timBlue),
                                          _buildTotalIndicator(
                                            'Estratto Conto', 
                                            totaleEC, 
                                            Colors.purple.shade700,
                                          ),
                                          _buildTotalIndicator('SAP', totaleSap, Colors.green.shade700),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                              Builder(
                                builder: (context) {
                                  final diffEC = totaleTrasferta - totaleEC;
                                  final isMatchingEC = diffEC.abs() < 0.001;
                                  
                                  final diffSap = totaleTrasferta - totaleSap;
                                  final isMatchingSap = diffSap.abs() < 0.001;

                                  if (isMatchingEC && isMatchingSap) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            'QUADRATO',
                                            style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    List<String> labels = [];
                                    if (!isMatchingEC) labels.add('EC: ${_formatCurrency(diffEC)}');
                                    if (!isMatchingSap) labels.add('SAP: ${_formatCurrency(diffSap)}');

                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.warning, color: Colors.red.shade700, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            'DISCREPANZA: ${labels.join(" | ")}',
                                            style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12),
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
                      ]),
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
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
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
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
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

  Widget _buildGlobalTotal(String label, double value, Color color) {
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

  Widget _buildTotalIndicator(String label, double value, Color color, {Color? labelColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: labelColor ?? Colors.grey.shade600, fontWeight: labelColor != null ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          _formatCurrency(value),
          style: TextStyle(
            fontSize: 18,
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
    Map<String, String> dictionaryMap,
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

      // Header principale
      final headers = [
        'TIPO RIGA', 'TRASFERTA', 'CID / PASSEGGERO', 'BOLLA', 
        'DATA INIZIO TRASF.', 'DATA FINE TRASF.',
        'LOCALITÀ / DESCRIZIONE', 'GIUSTIFICATIVO / SERVIZIO', 
        'SOCIETÀ', 'DATA SPESA/BOLLA', 'IMPORTO €', 'DISC. E.C. €', 'DISC. SAP €',
        'DISC. E.C. (SI/NO)', 'DISC. SAP (SI/NO)'
      ];
      
      for (var i = 0; i < headers.length; i++) {
        var cell = sheet.cell(excel_pkg.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = excel_pkg.TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }
      sheet.setRowHeight(0, 30);

      int currentRow = 1;
      for (final t in trasferte) {
        final records = groupedRecords[t]!;
        final first = records.first;
        final ecForT = allEstrattiConto.where((ec) => ec.numeroTrasferta == t).toList();
        final sapForT = allSapRecords.where((sap) => sap.numeroTrasferta == t).toList();
        
        double totTracciato = 0;
        for (var r in records) {
          totTracciato += r.isNegative ? -r.importo : r.importo;
        }
        
        double totEC = ecForT.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
        double totSap = sapForT.fold<double>(0, (sum, sap) => sum + sap.importo);
        
        final diffEC = totTracciato - totEC;
        final diffSap = totTracciato - totSap;
        final isMatchingEC = diffEC.abs() < 0.001;
        final isMatchingSap = diffSap.abs() < 0.001;

        // RIGA TRASFERTA (RIEPILOGO)
        final tripHeaderRow = [
          'TRASFERTA', t, 'CID: ${first.cid}', '', 
          _normalizeDate(first.dataInizio), _normalizeDate(first.dataFine),
          'Stato: ${isMatchingEC ? "OK" : "KO"} | SAP: ${isMatchingSap ? "OK" : "KO"}',
          '', first.societa, '', totTracciato, diffEC, diffSap,
          isMatchingEC ? 'NO' : 'SI',
          isMatchingSap ? 'NO' : 'SI'
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
            sap.tipoSpesaCodice, sap.societaDescrizione, _normalizeDate(sap.data), sap.importo, '', '', '', ''
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
        'IMPORTO €', 'SOCIETÀ'
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
        for (final r in groupedRecords[t]!) {
           final rowData = [
            t, 'TRACCIATO', r.cid, '', r.numeroBolla, 
            _normalizeDate(r.dataSpesa), r.localita, 
            '${r.giustificativoSpesa}${dictionaryMap[r.giustificativoSpesa] != null ? " (${dictionaryMap[r.giustificativoSpesa]})" : ""}', 
            r.isNegative ? -r.importo : r.importo, r.societa
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
            ec.totaleServizio, ec.ragioneSociale
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
        final sapForT = allSapRecords.where((sap) => sap.numeroTrasferta == t).toList();
        for (final sap in sapForT) {
          final rowData = [
            t, 'SAP', sap.cid, '', sap.cdRichiesta ?? '', 
            _normalizeDate(sap.data), sap.tipoSpesaDescrizione, sap.tipoSpesaCodice, 
            sap.importo, sap.societaDescrizione
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
    ref.read(controlsMinDiffProvider.notifier).state = null;
    ref.read(controlsMaxDiffProvider.notifier).state = null;
    ref.read(controlsMatchStatusProvider.notifier).state = null;
    ref.read(controlsShowOnlyOrphansProvider.notifier).state = false;

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
    final allTracciato = ref.watch(tracciatoContabilesProvider);
    final societaOptions = allTracciato.map((e) => e.societa).toSet().toList()..sort();
    final tipoDipendenteOptions = allTracciato.map((e) => e.tipoDipendente).toSet().toList()..sort();

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
                  ['match', 'diff', 'diff_ec', 'diff_sap'],
                  (val) => ref.read(controlsMatchStatusProvider.notifier).state = val,
                  icon: Icons.check_circle_outline,
                  labelMapper: (val) {
                    if (val == 'match') return 'Tutto Quadrato (EC + SAP)';
                    if (val == 'diff') return 'Qualsiasi Discrepanza';
                    if (val == 'diff_ec') return 'Discrepanza E.C.';
                    if (val == 'diff_sap') return 'Discrepanza SAP';
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
                  title: const Text('Solo Record Orfani', style: TextStyle(fontSize: 14)),
                  value: ref.watch(controlsShowOnlyOrphansProvider),
                  onChanged: (v) => ref.read(controlsShowOnlyOrphansProvider.notifier).state = v,
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

}
