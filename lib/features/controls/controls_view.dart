import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';

final controlsMonthProvider = StateProvider<Set<String>>((ref) => {});
final controlsYearProvider = StateProvider<String?>((ref) => null);
final controlsSearchProvider = StateProvider<String>((ref) => '');
final controlsSocietaProvider = StateProvider<Set<String>>((ref) => {});
final controlsTipoDipendenteProvider = StateProvider<Set<String>>((ref) => {});
final controlsCidProvider = StateProvider<String>((ref) => '');
final controlsSortAscendingProvider = StateProvider<bool>((ref) => false);
final controlsPageProvider = StateProvider<int>((ref) => 0);
final controlsExpandAllProvider = StateProvider<bool>((ref) => true);
final controlsShowOnlyOrphansProvider = StateProvider<bool>((ref) => false);
final controlsMatchStatusProvider = StateProvider<String?>((ref) => null); // null, 'match', 'diff'

class ControlsView extends ConsumerStatefulWidget {
  const ControlsView({super.key});

  @override
  ConsumerState<ControlsView> createState() => _ControlsViewState();
}

class _ControlsViewState extends ConsumerState<ControlsView> {
  final _searchController = TextEditingController();
  final _cidController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _cidController.dispose();
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

    final availableYears =
        allRecords
            .map((r) {
              final parts = r.dataFine.split('/');
              return parts.length == 3 ? parts[2] : '';
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

    final availableTipo =
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
    if (matchStatusFilter != null) {
      trasferte = trasferte.where((t) {
        final recordsTrasferta = groupedRecords[t]!;
        double tTracciato = 0;
        for (var r in recordsTrasferta) {
          tTracciato += r.isNegative ? -r.importo : r.importo;
        }

        final ecForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == t).toList();
        final tEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);

        final isMatching = (tTracciato - tEC).abs() < 0.01;
        return matchStatusFilter == 'match' ? isMatching : !isMatching;
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

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final headerContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTROLLI TRASFERTE',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w200,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dati visualizzati raggruppati per trasferta',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              );

              if (isWide) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    headerContent,
                    Row(
                      children: [
                        _buildGlobalTotal('TOTALE TRACCIATO', globalTracciato, SkyTheme.timBlue),
                        const SizedBox(width: 48),
                        _buildGlobalTotal('TOTALE E.C.', globalEC, Colors.purple.shade700),
                        const SizedBox(width: 48),
                        _buildGlobalTotal('TOTALE DISCREPANZE', globalTracciato - globalEC, Colors.red.shade700),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerContent,
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildGlobalTotal('TRACCIATO', globalTracciato, SkyTheme.timBlue),
                        const SizedBox(width: 24),
                        _buildGlobalTotal('E.C.', globalEC, Colors.purple.shade700),
                        const SizedBox(width: 24),
                        _buildGlobalTotal('DIFF.', globalTracciato - globalEC, Colors.red.shade700),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Filtro Mese (Multi-select Dialog)
              InkWell(
                onTap: () => _showMultiSelectMesi(context, monthNames),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        selectedMonth.isEmpty
                            ? 'Tutti i Mesi'
                            : '${selectedMonth.length} Mesi Selezionati',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
              // Filtro Anno
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: selectedYear,
                    hint: const Text('Tutti gli Anni'),
                    icon: const Icon(Icons.calendar_today, size: 20),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tutti gli Anni'),
                      ),
                      ...availableYears.map(
                        (y) => DropdownMenuItem(value: y, child: Text(y)),
                      ),
                    ],
                    onChanged: (value) {
                      ref.read(controlsYearProvider.notifier).state = value;
                      ref.read(controlsPageProvider.notifier).state = 0;
                    },
                  ),
                ),
              ),
              // Filtro Società (Multi-select Dialog)
              InkWell(
                onTap: () => _showMultiSelectSocieta(context, availableSocieta),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.business, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        selectedSocieta.isEmpty
                            ? 'Tutte le Società'
                            : '${selectedSocieta.length} Società Selezionate',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
              // Filtro Tipo Dipendente (Multi-select Dialog)
              InkWell(
                onTap: () =>
                    _showMultiSelectTipo(context, availableTipo, dictionaryMap),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        selectedTipo.isEmpty
                            ? 'Tutti i Tipi'
                            : '${selectedTipo.length} Tipi Selezionati',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
              // Ricerca Trasferta
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cerca Trasferta...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(controlsSearchProvider.notifier).state = value;
                    ref.read(controlsPageProvider.notifier).state = 0;
                  },
                ),
              ),
              // Ricerca CID
              SizedBox(
                width: 180,
                child: TextField(
                  controller: _cidController,
                  decoration: InputDecoration(
                    hintText: 'Cerca CID...',
                    prefixIcon: const Icon(Icons.badge, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(controlsCidProvider.notifier).state = value;
                    ref.read(controlsPageProvider.notifier).state = 0;
                  },
                ),
              ),

              // Filtro EC Orfani
              InkWell(
                onTap: () {
                  ref.read(controlsShowOnlyOrphansProvider.notifier).state = !ref.read(controlsShowOnlyOrphansProvider);
                  ref.read(controlsPageProvider.notifier).state = 0;
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: ref.watch(controlsShowOnlyOrphansProvider) ? Colors.orange.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ref.watch(controlsShowOnlyOrphansProvider) ? Colors.orange.shade300 : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined, 
                        size: 20, 
                        color: ref.watch(controlsShowOnlyOrphansProvider) ? Colors.orange.shade800 : Colors.grey.shade700
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'EC Orfani',
                        style: TextStyle(
                          color: ref.watch(controlsShowOnlyOrphansProvider) ? Colors.orange.shade900 : Colors.grey.shade800,
                          fontSize: 16,
                          fontWeight: ref.watch(controlsShowOnlyOrphansProvider) ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Filtro Stato Quadratura
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: ref.watch(controlsMatchStatusProvider),
                    hint: const Text('Stato Quadratura'),
                    icon: const Icon(Icons.account_balance, size: 20),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Qualsiasi Stato')),
                      DropdownMenuItem(
                        value: 'match', 
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 16),
                            SizedBox(width: 8),
                            Text('Solo Quadrati'),
                          ],
                        )
                      ),
                      DropdownMenuItem(
                        value: 'diff', 
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Text('Solo Discrepanze'),
                          ],
                        )
                      ),
                    ],
                    onChanged: (value) {
                      ref.read(controlsMatchStatusProvider.notifier).state = value;
                      ref.read(controlsPageProvider.notifier).state = 0;
                    },
                  ),
                ),
              ),
              // Ordinamento
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  tooltip: sortAscending
                      ? 'Dal numero più basso'
                      : 'Dal numero più alto',
                  icon: Icon(
                    sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () =>
                      ref.read(controlsSortAscendingProvider.notifier).state =
                          !sortAscending,
                ),
              ),
              // Espandi/Contrai Tutto
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  tooltip: ref.watch(controlsExpandAllProvider)
                      ? 'Contrai tutti'
                      : 'Espandi tutti',
                  icon: Icon(
                    ref.watch(controlsExpandAllProvider)
                        ? Icons.unfold_less
                        : Icons.unfold_more,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () =>
                      ref.read(controlsExpandAllProvider.notifier).state = !ref
                          .read(controlsExpandAllProvider),
                ),
              ),
              // Reset Filtri
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    ref.read(controlsMonthProvider.notifier).state = <String>{};
                    ref.read(controlsYearProvider.notifier).state = null;
                    ref.read(controlsSocietaProvider.notifier).state =
                        <String>{};
                    ref.read(controlsTipoDipendenteProvider.notifier).state =
                        <String>{};
                    ref.read(controlsSearchProvider.notifier).state = '';
                    ref.read(controlsCidProvider.notifier).state = '';
                    ref.read(controlsSortAscendingProvider.notifier).state =
                        false;
                    ref.read(controlsPageProvider.notifier).state = 0;
                    _searchController.clear();
                    _cidController.clear();
                  },
                  icon: Icon(
                    Icons.filter_alt_off,
                    size: 20,
                    color: Colors.red.shade700,
                  ),
                  label: Text(
                    'Reset Filtri',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
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

                return Card(
                  margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ExpansionTile(
                    key: Key(
                      '${numeroTrasferta}_${ref.watch(controlsExpandAllProvider)}',
                    ),
                    initiallyExpanded: ref.watch(controlsExpandAllProvider),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trasferta: $numeroTrasferta',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                      '${recordsTrasferta.length} record • Dal ${firstRecord.dataInizio} al ${firstRecord.dataFine} • Totale: ${totaleTrasferta.toStringAsFixed(2)} EUR • Società: ${firstRecord.societa}${dictionaryMap[firstRecord.societa] != null ? " (${dictionaryMap[firstRecord.societa]})" : ""} • Tipo: ${firstRecord.tipoDipendente}${dictionaryMap[firstRecord.tipoDipendente] != null ? " (${dictionaryMap[firstRecord.tipoDipendente]})" : ""}',
                    ),
                    leading: const Icon(Icons.flight_takeoff),
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
                                          final isIdentical = (tracciatoVal - ecVal).abs() < 0.01;

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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Row(
                                    children: [
                                      _buildTotalIndicator('Tracciato', totaleTrasferta, SkyTheme.timBlue),
                                      const SizedBox(width: 32),
                                      Builder(
                                        builder: (context) {
                                          final ecForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == numeroTrasferta).toList();
                                          final totaleEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
                                          final diff = (totaleTrasferta - totaleEC).abs();
                                          final isMatching = diff < 0.01;

                                          return _buildTotalIndicator(
                                            'Estratto Conto', 
                                            totaleEC, 
                                            isMatching ? Colors.green.shade700 : Colors.red.shade700
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Builder(
                                builder: (context) {
                                  final ecForTrasferta = allEstrattiConto.where((ec) => ec.numeroTrasferta == numeroTrasferta).toList();
                                  final totaleEC = ecForTrasferta.fold<double>(0, (sum, ec) => sum + ec.totaleServizio);
                                  final diff = totaleTrasferta - totaleEC;
                                  final isMatching = diff.abs() < 0.01;

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
                    const VerticalDivider(width: 32, indent: 8, endIndent: 8),
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

  void _showMultiSelectMesi(
    BuildContext context,
    Map<String, String> monthNames,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final selectedMonths = ref.watch(controlsMonthProvider);
            return AlertDialog(
              title: const Text('Seleziona Mesi'),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: monthNames.entries.map((e) {
                      final monthCode = e.key;
                      return CheckboxListTile(
                        title: Text(e.value),
                        value: selectedMonths.contains(monthCode),
                        onChanged: (value) {
                          final newMonths = Set<String>.from(selectedMonths);
                          if (value == true) {
                            newMonths.add(monthCode);
                          } else {
                            newMonths.remove(monthCode);
                          }
                          ref.read(controlsMonthProvider.notifier).state =
                              newMonths;
                          ref.read(controlsPageProvider.notifier).state = 0;
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(controlsMonthProvider.notifier).state = {};
                    ref.read(controlsPageProvider.notifier).state = 0;
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Chiudi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMultiSelectTipo(
    BuildContext context,
    List<String> options,
    Map<String, String> dictionaryMap,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final selected = ref.watch(controlsTipoDipendenteProvider);
            return AlertDialog(
              title: const Text('Seleziona Tipo Dipendente'),
              content: SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: options.map((option) {
                      final decoded = dictionaryMap[option];
                      final displayLabel = decoded != null
                          ? '$option - $decoded'
                          : option;

                      return CheckboxListTile(
                        title: Text(displayLabel),
                        value: selected.contains(option),
                        onChanged: (value) {
                          final newSelection = Set<String>.from(selected);
                          if (value == true) {
                            newSelection.add(option);
                          } else {
                            newSelection.remove(option);
                          }
                          ref
                                  .read(controlsTipoDipendenteProvider.notifier)
                                  .state =
                              newSelection;
                          ref.read(controlsPageProvider.notifier).state = 0;
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(controlsTipoDipendenteProvider.notifier).state =
                        {};
                  },
                  child: const Text('Reset'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Chiudi'),
                ),
              ],
            );
          },
        );
      },
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

  void _showMultiSelectSocieta(
    BuildContext context,
    List<String> availableSocieta,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final selectedSocieta = ref.watch(controlsSocietaProvider);
            return AlertDialog(
              title: const Text('Seleziona Società'),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: availableSocieta.map((s) {
                      final isSelected = selectedSocieta.contains(s);
                      return CheckboxListTile(
                        title: Text(s),
                        value: isSelected,
                        onChanged: (bool? value) {
                          final notifier = ref.read(
                            controlsSocietaProvider.notifier,
                          );
                          if (value == true) {
                            notifier.state = {...selectedSocieta, s};
                          } else {
                            notifier.state = {...selectedSocieta}..remove(s);
                          }
                          ref.read(controlsPageProvider.notifier).state = 0;
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ref.read(controlsSocietaProvider.notifier).state =
                        <String>{};
                    ref.read(controlsPageProvider.notifier).state = 0;
                  },
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Chiudi'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
