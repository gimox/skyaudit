import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' as excel_pkg;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';

final controlsMonthProvider = StateProvider<Set<String>>((ref) => {});
final controlsYearProvider = StateProvider<String?>((ref) => DateTime.now().year.toString());
final controlsSearchProvider = StateProvider<String>((ref) => '');
final controlsSocietaProvider = StateProvider<Set<String>>((ref) => {});
final controlsTipoDipendenteProvider = StateProvider<Set<String>>((ref) => {});
final controlsCidProvider = StateProvider<String>((ref) => '');
final controlsSortAscendingProvider = StateProvider<bool>((ref) => false);
final controlsPageProvider = StateProvider<int>((ref) => 0);
final controlsExpandAllProvider = StateProvider<bool>((ref) => true);
final controlsShowOnlyOrphansProvider = StateProvider<bool>((ref) => false);
final controlsMatchStatusProvider = StateProvider<String?>((ref) => null); // null, 'match', 'diff'
final controlsMinDiffProvider = StateProvider<double?>((ref) => null);
final controlsMaxDiffProvider = StateProvider<double?>((ref) => null);

class ControlsView extends ConsumerStatefulWidget {
  const ControlsView({super.key});

  @override
  ConsumerState<ControlsView> createState() => _ControlsViewState();
}

class _ControlsViewState extends ConsumerState<ControlsView> {
  final _searchController = TextEditingController();
  final _cidController = TextEditingController();
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
    _cidController.dispose();
    _minDiffController.dispose();
    _maxDiffController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(tracciatoContabilesProvider);
    final allEstrattiConto = ref.watch(estrattoContoProvider);

    if (allRecords.isEmpty) {
      return Center(
        child: Text(
          'Nessun record presente nel database.\nVai su "Carica File" per importare i dati.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
        ),
      );
    }

    final selectedMonth = ref.watch(controlsMonthProvider);
    final selectedYear = ref.watch(controlsYearProvider);
    final searchQuery = ref.watch(controlsSearchProvider);
    final selectedSocieta = ref.watch(controlsSocietaProvider);
    final selectedTipo = ref.watch(controlsTipoDipendenteProvider);
    final searchCid = ref.watch(controlsCidProvider);
    final sortAscending = ref.watch(controlsSortAscendingProvider);
    final currentPage = ref.watch(controlsPageProvider);
    const pageSize = 100;

    final Map<String, List<TracciatoContabile>> groupedRecords = {};
    for (final record in allRecords) {
      groupedRecords.putIfAbsent(record.numeroTrasferta, () => []).add(record);
    }

    var trasferte = groupedRecords.keys.toList();

    if (searchQuery.isNotEmpty) {
      trasferte = trasferte
          .where((t) => t.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (searchCid.isNotEmpty) {
      trasferte = trasferte
          .where((t) => groupedRecords[t]!.first.cid.contains(searchCid))
          .toList();
    }

    if (selectedMonth.isNotEmpty ||
        selectedYear != null ||
        selectedSocieta.isNotEmpty) {
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

        if (selectedMonth.isNotEmpty || selectedYear != null) {
          final parts = firstRecord.dataFine.split('/');
          if (parts.length != 3) return false;

          final m = parts[1];
          final y = parts[2];

          if (selectedMonth.isNotEmpty && !selectedMonth.contains(m)) {
            return false;
          }
          if (selectedYear != null && selectedYear != y) {
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
          !bolleInTracciato.contains(ec.bolla) &&
          ec.totaleServizio.abs() > 0.001
        );
        
        return orphans.isNotEmpty;
      }).toList();
    }

    final matchStatusFilter = ref.watch(controlsMatchStatusProvider);
    final minDiff = ref.watch(controlsMinDiffProvider);
    final maxDiff = ref.watch(controlsMaxDiffProvider);

    if (matchStatusFilter != null || minDiff != null || maxDiff != null) {
      trasferte = trasferte.where((t) {
        final recordsTrasferta = groupedRecords[t]!;
        double tTracciato = 0;
        for (var r in recordsTrasferta) {
          tTracciato += r.isNegative ? -r.importo : r.importo;
        }

        final ecForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == t).toList();
        final tEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);

        final diff = (tTracciato - tEC).abs();
        final isMatching = diff < 0.001;

        if (matchStatusFilter != null) {
          if (matchStatusFilter == 'match' && !isMatching) return false;
          if (matchStatusFilter == 'diff' && isMatching) return false;
        }

        if (minDiff != null && diff < minDiff) return false;
        if (maxDiff != null && diff > maxDiff) return false;

        return true;
      }).toList();
    }

    trasferte.sort((a, b) => sortAscending ? a.compareTo(b) : b.compareTo(a));

    // Calcolo totali globali filtrati
    double globalTracciato = 0;
    double globalEC = 0;
    for (final t in trasferte) {
      final records = groupedRecords[t]!;
      for (final r in records) {
        globalTracciato += r.isNegative ? -r.importo : r.importo;
      }
      final ecForT = allEstrattiConto.where((ec) => ec.numeroTrasferta == t);
      for (final ec in ecForT) {
        globalEC += ec.totaleServizio;
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
      selectedMonth.isNotEmpty,
      selectedYear != null,
      selectedSocieta.isNotEmpty,
      selectedTipo.isNotEmpty,
      ref.watch(controlsCidProvider).isNotEmpty,
      minDiff != null,
      maxDiff != null,
      matchStatusFilter != null,
      ref.watch(controlsShowOnlyOrphansProvider),
    ].where((e) => e).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, dictionaryMap),
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
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWideHeader = constraints.maxWidth > 900;
                    
                    final headerContent = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CONTROLLI TRASFERTE',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w200,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Audit e quadratura dati contabili',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    );

                    final totalsWrap = Wrap(
                      spacing: 24,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        _buildGlobalTotal('TRACCIATO', globalTracciato, SkyTheme.timBlue),
                        _buildGlobalTotal('E.C.', globalEC, Colors.purple.shade700),
                        _buildGlobalTotal('DISCREPANZA', globalTracciato - globalEC, Colors.red.shade700),
                      ],
                    );

                    if (isWideHeader) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: headerContent),
                          totalsWrap,
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerContent,
                          const SizedBox(height: 16),
                          totalsWrap,
                        ],
                      );
                    }
                  },
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
                    ElevatedButton.icon(
                      onPressed: () => _exportToExcel(trasferte, groupedRecords, allEstrattiConto, dictionaryMap),
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Esporta'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
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
                        if (selectedYear != null)
                          _buildFilterChip('Anno: $selectedYear', () => ref.read(controlsYearProvider.notifier).state = null),
                        if (selectedMonth.isNotEmpty)
                          _buildFilterChip(
                            selectedMonth.length == 1 
                                ? 'Mese: ${monthNames[selectedMonth.first]}' 
                                : '${selectedMonth.length} Mesi', 
                            () => ref.read(controlsMonthProvider.notifier).state = {}
                          ),
                        if (selectedSocieta.isNotEmpty)
                          _buildFilterChip('${selectedSocieta.length} Società', () => ref.read(controlsSocietaProvider.notifier).state = {}),
                        if (ref.watch(controlsCidProvider).isNotEmpty)
                          _buildFilterChip('CID: ${ref.watch(controlsCidProvider)}', () {
                            _cidController.clear();
                            ref.read(controlsCidProvider.notifier).state = '';
                          }),
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
                            matchStatusFilter == 'match' ? 'Stato: Quadrate' : 'Stato: Discrepanze', 
                            () => ref.read(controlsMatchStatusProvider.notifier).state = null
                          ),
                        if (ref.watch(controlsShowOnlyOrphansProvider))
                          _buildFilterChip('Solo Orfani', () => ref.read(controlsShowOnlyOrphansProvider.notifier).state = false),
                        
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
                final isMatching = (totaleTrasferta - totaleEC).abs() < 0.001;
                
                final statusBgColor = isMatching ? Colors.green.shade50 : Colors.red.shade50;
                final statusTextColor = isMatching ? Colors.green.shade900 : Colors.red.shade900;
                final statusBorderColor = isMatching ? Colors.green.shade200 : Colors.red.shade200;

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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isMatching ? Colors.green.shade100 : Colors.red.shade100,
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
                                    isMatching ? 'QUADRATA' : 'DISCREPANZA: ${(totaleTrasferta - totaleEC).toStringAsFixed(2)} €',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: statusTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Cid: ${firstRecord.cid}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
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
                                      'Tracciato • Bolla: ${record.numeroBolla} • ${record.giustificativoSpesa}${dictionaryMap[record.giustificativoSpesa] != null ? " (${dictionaryMap[record.giustificativoSpesa]})" : ""}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
                                  child: Text(
                                    matchingEC.first.descrizioneServizio,
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    overflow: TextOverflow.ellipsis,
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
                        // Sezione per EC senza match nel Tracciato
                        Builder(
                          builder: (context) {
                            final bolleInTracciato = recordsTrasferta.map((r) => r.numeroBolla).toSet();
                            final orphansForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == numeroTrasferta).toList();
                            final orphanedEC = orphansForTrasferta.where((ec) => 
                              !bolleInTracciato.contains(ec.bolla) && 
                              ec.totaleServizio.abs() > 0.001
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
                                      final diffVal = (totaleTrasferta - totaleEC).abs();
                                      final isMatching = diffVal < 0.001;

                                      return Wrap(
                                        spacing: 32,
                                        runSpacing: 12,
                                        children: [
                                          _buildTotalIndicator('Tracciato', totaleTrasferta, SkyTheme.timBlue),
                                          _buildTotalIndicator(
                                            'Estratto Conto', 
                                            totaleEC, 
                                            isMatching ? Colors.green.shade700 : Colors.red.shade700
                                          ),
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
                                  final diff = totaleTrasferta - totaleEC;
                                  final isMatching = diff.abs() < 0.001;


                                  if (isMatching) {
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
                                            'DISCREPANZA: ${_formatCurrency(diff)}',
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
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
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
                    const SizedBox(width: 16),
                    Text(
                      'Pagina ${currentPage + 1} di $totalPages',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
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

  Widget _buildTotalIndicator(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
        return AlertDialog(
          title: Text(
            'Dettaglio Estratto Conto - ${record.bolla}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('CID', record.cid),
                  _buildDetailRow('Trasferta', record.numeroTrasferta),
                  _buildDetailRow('Bolla', record.bolla),
                  _buildDetailRow('NR Bolla', record.nrBolla),
                  _buildDetailRow('Data Bolla', record.dataBolla),
                  _buildDetailRow('Data Competenza', record.dataCompetenza),
                  _buildDetailRow('Società', record.ragioneSociale),
                  _buildDetailRow('Tipo Servizio', record.tipoServizio),
                  _buildDetailRow('Descrizione', record.descrizioneServizio),
                  _buildDetailRow('Itinerario', record.itinerario),
                  _buildDetailRow('Fornitore', record.fornitore),
                  _buildDetailRow('Passeggero', record.nomePasseggero),
                  _buildDetailRow('Importo Servizio', '${record.importoServizio.toStringAsFixed(2)} €'),
                  _buildDetailRow('Tasse', '${record.tasse.toStringAsFixed(2)} €'),
                  _buildDetailRow('Fee', '${record.fee.toStringAsFixed(2)} €'),
                  _buildDetailRow('Totale Servizio', '${record.totaleServizio.toStringAsFixed(2)} €', isHighlight: true),
                  _buildDetailRow('Località Partenza', record.localitaPartenza),
                  _buildDetailRow('Località Arrivo', record.localitaArrivo),
                  _buildDetailRow('Data In', record.dataIn),
                  _buildDetailRow('Data Out', record.dataOut),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportToExcel(
    List<String> trasferte,
    Map<String, List<TracciatoContabile>> groupedRecords,
    List<EstrattoConto> allEstrattiConto,
    Map<String, String> dictionaryMap,
  ) async {
    try {
      final excel = excel_pkg.Excel.createExcel();
      final sheet = excel['ControlliTrasferte'];
      excel.delete('Sheet1');

      // Header principale
      sheet.appendRow([
        excel_pkg.TextCellValue('TIPO RIGA'),
        excel_pkg.TextCellValue('TRASFERTA'),
        excel_pkg.TextCellValue('CID / PASSEGGERO'),
        excel_pkg.TextCellValue('BOLLA'),
        excel_pkg.TextCellValue('LOCALITÀ / DESCRIZIONE'),
        excel_pkg.TextCellValue('GIUSTIFICATIVO / SERVIZIO'),
        excel_pkg.TextCellValue('SOCIETÀ'),
        excel_pkg.TextCellValue('DATA'),
        excel_pkg.TextCellValue('IMPORTO €'),
        excel_pkg.TextCellValue('DISCREPANZA €'),
      ]);

      for (final t in trasferte) {
        final records = groupedRecords[t]!;
        final first = records.first;
        final ecForT = allEstrattiConto.where((ec) => ec.numeroTrasferta == t).toList();
        
        double totTracciato = 0;
        for (var r in records) {
          totTracciato += r.isNegative ? -r.importo : r.importo;
        }
        
        double totEC = ecForT.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
        final diff = totTracciato - totEC;
        final isMatching = diff.abs() < 0.001;

        // RIGA TESTATA TRASFERTA (Grigio Chiaro)
        sheet.appendRow([
          excel_pkg.TextCellValue('TESTATA'),
          excel_pkg.TextCellValue(t),
          excel_pkg.TextCellValue('CID: ${first.cid}'),
          excel_pkg.TextCellValue(''),
          excel_pkg.TextCellValue('Dal ${first.dataInizio} al ${first.dataFine}'),
          excel_pkg.TextCellValue(isMatching ? 'QUADRATA' : 'DISCREPANZA'),
          excel_pkg.TextCellValue(first.societa),
          excel_pkg.TextCellValue(''),
          excel_pkg.DoubleCellValue(totTracciato),
          excel_pkg.DoubleCellValue(diff),
        ]);

        // RIGHE TRACCIATO
        for (final r in records) {
          sheet.appendRow([
            excel_pkg.TextCellValue('  > TRACCIATO'),
            excel_pkg.TextCellValue(''),
            excel_pkg.TextCellValue(r.cid),
            excel_pkg.TextCellValue(r.numeroBolla),
            excel_pkg.TextCellValue(r.localita),
            excel_pkg.TextCellValue('${r.giustificativoSpesa}${dictionaryMap[r.giustificativoSpesa] != null ? " (${dictionaryMap[r.giustificativoSpesa]})" : ""}'),
            excel_pkg.TextCellValue(''),
            excel_pkg.TextCellValue(r.dataSpesa),
            excel_pkg.DoubleCellValue(r.isNegative ? -r.importo : r.importo),
            excel_pkg.TextCellValue(''),
          ]);
        }

        // RIGHE ESTRATTO CONTO
        for (final ec in ecForT) {
          sheet.appendRow([
            excel_pkg.TextCellValue('  > E. CONTO'),
            excel_pkg.TextCellValue(''),
            excel_pkg.TextCellValue(ec.nomePasseggero),
            excel_pkg.TextCellValue(ec.bolla),
            excel_pkg.TextCellValue(ec.itinerario),
            excel_pkg.TextCellValue(ec.descrizioneServizio),
            excel_pkg.TextCellValue(''),
            excel_pkg.TextCellValue(ec.dataBolla),
            excel_pkg.DoubleCellValue(ec.totaleServizio),
            excel_pkg.TextCellValue(''),
          ]);
        }

        // Riga vuota tra trasferte
        sheet.appendRow([excel_pkg.TextCellValue('')]);
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva Report Controlli',
        fileName: 'report_controlli_trasferte_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report esportato con successo!'),
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
    ref.read(controlsSocietaProvider.notifier).state = <String>{};
    ref.read(controlsTipoDipendenteProvider.notifier).state = <String>{};
    ref.read(controlsSearchProvider.notifier).state = '';
    ref.read(controlsCidProvider.notifier).state = '';
    ref.read(controlsSortAscendingProvider.notifier).state = false;
    ref.read(controlsPageProvider.notifier).state = 0;
    ref.read(controlsMinDiffProvider.notifier).state = null;
    ref.read(controlsMaxDiffProvider.notifier).state = null;
    ref.read(controlsMatchStatusProvider.notifier).state = null;
    ref.read(controlsShowOnlyOrphansProvider.notifier).state = false;

    _searchController.clear();
    _cidController.clear();
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
    final years = allTracciato.map((e) => e.dataFine.split('/').last).toSet().toList()..sort();
    final months = ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'];
    final societaOptions = allTracciato.map((e) => e.societa).toSet().toList()..sort();
    final tipoDipendenteOptions = allTracciato.map((e) => e.tipoDipendente).toSet().toList()..sort();

    return Drawer(
      width: 350,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            color: const Color(0xFF001529), // Navy scuro professionale per distinguersi dal TIM Blue
            child: Row(
              children: [
                const Icon(Icons.filter_alt_outlined, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'FILTRI AVANZATI',
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
              padding: const EdgeInsets.all(20),
              children: [
                _buildDrawerSectionTitle('PERIODI'),
                const SizedBox(height: 12),
                _buildFilterDropdown<String?>(
                  'Seleziona Anno',
                  ref.watch(controlsYearProvider),
                  years,
                  (val) => ref.read(controlsYearProvider.notifier).state = val,
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 16),
                _buildMultiSelectFilter(
                  'Seleziona Mesi',
                  ref.watch(controlsMonthProvider),
                  months,
                  (val) => ref.read(controlsMonthProvider.notifier).state = val,
                  icon: Icons.calendar_month,
                  dictionary: monthNames,
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
                _buildMultiSelectFilter(
                  'Tipo Dipendente',
                  ref.watch(controlsTipoDipendenteProvider),
                  tipoDipendenteOptions,
                  (val) => ref.read(controlsTipoDipendenteProvider.notifier).state = val,
                  icon: Icons.people,
                  dictionary: dictionaryMap,
                ),
                const SizedBox(height: 16),
                _buildDrawerTextField(
                  'Cerca per CID',
                  _cidController,
                  Icons.person_search,
                  (val) => ref.read(controlsCidProvider.notifier).state = val,
                ),

                const SizedBox(height: 32),
                _buildDrawerSectionTitle('CONTABILITÀ'),
                const SizedBox(height: 12),
                _buildFilterDropdown<String?>(
                  'Stato Quadratura',
                  ref.watch(controlsMatchStatusProvider),
                  ['match', 'diff'],
                  (val) => ref.read(controlsMatchStatusProvider.notifier).state = val,
                  icon: Icons.check_circle_outline,
                  labelMapper: (val) {
                    if (val == 'match') return 'Quadrate';
                    if (val == 'diff') return 'Discrepanze';
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
        return AlertDialog(
          title: Text(
            'Dettaglio Record - ${record.numeroBolla}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('CID', record.cid),
                  _buildDetailRow('Trasferta', record.numeroTrasferta),
                  _buildDetailRow('Progressivo', record.progressivo),
                  _buildDetailRow(
                    'Società',
                    ref
                            .read(dictionaryProvider)
                            .any(
                              (e) =>
                                  e.code == record.societa &&
                                  e.category == 'societa',
                            )
                        ? '${record.societa} - ${ref.read(dictionaryProvider).firstWhere((e) => e.code == record.societa && e.category == 'societa').value}'
                        : record.societa,
                  ),
                  _buildDetailRow(
                    'Tipo Dipendente',
                    ref
                            .read(dictionaryProvider)
                            .any(
                              (e) =>
                                  e.code == record.tipoDipendente &&
                                  e.category == 'tipo_dipendente',
                            )
                        ? '${record.tipoDipendente} - ${ref.read(dictionaryProvider).firstWhere((e) => e.code == record.tipoDipendente && e.category == 'tipo_dipendente').value}'
                        : record.tipoDipendente,
                  ),
                  _buildDetailRow(
                    'Giustificativo',
                    ref
                            .read(dictionaryProvider)
                            .any(
                              (e) =>
                                  e.code == record.giustificativoSpesa &&
                                  e.category == 'giustificativi_prepagati',
                            )
                        ? '${record.giustificativoSpesa} - ${ref.read(dictionaryProvider).firstWhere((e) => e.code == record.giustificativoSpesa && e.category == 'giustificativi_prepagati').value}'
                        : record.giustificativoSpesa,
                  ),
                  _buildDetailRow('Numero Bolla', record.numeroBolla),
                  _buildDetailRow('Data Spesa', record.dataSpesa),
                  _buildDetailRow('Località', record.localita),
                  _buildDetailRow(
                    'Inizio',
                    '${record.dataInizio} ${record.oraInizio}',
                  ),
                  _buildDetailRow(
                    'Fine',
                    '${record.dataFine} ${record.oraFine}',
                  ),
                  _buildDetailRow('Tipo Attività', record.tipoAttivita),
                  _buildDetailRow(
                    'Importo',
                    '${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}',
                    isHighlight: true,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Chiudi'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.blue.shade700 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
