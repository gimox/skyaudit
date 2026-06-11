import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:universal_io/io.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/features/upload/models/anagrafica.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/shared/widgets/file_selection_dialog.dart';
import 'package:travel_check/features/upload/models/log_history.dart';

final anagraficaSearchProvider = StateProvider<String?>((ref) => null);
final anagraficaPageProvider = StateProvider<int>((ref) => 0);
final anagraficaSortAscendingProvider = StateProvider<bool>((ref) => true);

// Advanced Filter Providers
final selectedAnagLivelliProvider = StateProvider<List<String>>((ref) => []);
enum GradoFilterType { all, specific, range }
final gradoFilterTypeProvider = StateProvider<GradoFilterType>((ref) => GradoFilterType.all);
final selectedGradoSpecificProvider = StateProvider<String?>((ref) => null);
final selectedGradoMinProvider = StateProvider<double?>((ref) => null);
final selectedGradoMaxProvider = StateProvider<double?>((ref) => null);

enum EtaFilterType { all, specific, range }
final etaFilterTypeProvider = StateProvider<EtaFilterType>((ref) => EtaFilterType.all);
final selectedEtaSpecificProvider = StateProvider<int?>((ref) => null);
final selectedEtaMinProvider = StateProvider<double?>((ref) => null);
final selectedEtaMaxProvider = StateProvider<double?>((ref) => null);

final selectedAnagContrSolidarietaProvider = StateProvider<String?>((ref) => null);
final selectedAnagSocietaProvider = StateProvider<List<String>>((ref) => []);
final selectedAnagSedeComuneProvider = StateProvider<List<String>>((ref) => []);
final selectedAnagProvinciaProvider = StateProvider<List<String>>((ref) => []);
final selectedAnagPartFullTimeProvider = StateProvider<String?>((ref) => null);
final selectedAnagResponsabileProvider = StateProvider<List<String>>((ref) => []);
final selectedAnagGestoreProvider = StateProvider<List<String>>((ref) => []);
final selectedAnagStatusProvider = StateProvider<List<String>>((ref) => []);
final selectedAnagLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});

class AnagraficaView extends ConsumerStatefulWidget {
  const AnagraficaView({super.key});

  @override
  ConsumerState<AnagraficaView> createState() => _AnagraficaViewState();
}

class _AnagraficaViewState extends ConsumerState<AnagraficaView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  final _statsScrollController = ScrollController();

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        return DateFormat('dd/MM/yyyy').format(dt);
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _calculateAge(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return '-';
      final now = DateTime.now();
      int age = now.year - dt.year;
      if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
        age--;
      }
      return '$age anni';
    } catch (e) {
      return '-';
    }
  }

  String _calculateSeniority(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return '-';
      final now = DateTime.now();
      
      int years = now.year - dt.year;
      int months = now.month - dt.month;
      
      if (now.day < dt.day) {
        months--;
      }
      
      if (months < 0) {
        years--;
        months += 12;
      }
      
      return '$years anni e $months mesi';
    } catch (e) {
      return '-';
    }
  }

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
    final allRecords = ref.watch(anagraficaProvider);
    final searchQuery = ref.watch(anagraficaSearchProvider);
    final currentPage = ref.watch(anagraficaPageProvider);
    final sortAscending = ref.watch(anagraficaSortAscendingProvider);
    final selectedLogHistoryIds = ref.watch(selectedAnagLogHistoryIdsProvider);
    const pageSize = 50;

    final logs = ref.watch(logHistoryProvider);
    final anagLogs = logs.where((l) => l.sourceType == 'Anagrafica').toList();

    String? selectedLogFileName;
    if (selectedLogHistoryIds.length == 1) {
      for (final log in anagLogs) {
        if (log.uniqueCode == selectedLogHistoryIds.first) {
          selectedLogFileName = log.fileName;
          break;
        }
      }
    }

    final filteredByFileRecords = selectedLogHistoryIds.isNotEmpty
        ? allRecords.where((r) => selectedLogHistoryIds.contains(r.importBatch)).toList()
        : allRecords;

    DateTime? lastImportDate;
    if (selectedLogHistoryIds.isNotEmpty) {
      final selectedLogs = anagLogs.where((l) => selectedLogHistoryIds.contains(l.uniqueCode)).toList();
      if (selectedLogs.isNotEmpty) {
        lastImportDate = selectedLogs.first.date;
      }
    } else {
      if (anagLogs.isNotEmpty) {
        lastImportDate = anagLogs.first.date;
      }
    }

    final lastImportDateStr = lastImportDate != null
        ? DateFormat('dd/MM/yyyy HH:mm:ss').format(lastImportDate)
        : 'Mai caricata';

    if (allRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
            ),
            const SizedBox(height: 16),
            Text(
              'NESSUNA ANAGRAFICA CARICATA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w200,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Vai nella sezione "Carica File" per importare i dati.'),
            if (lastImportDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Ultimo caricamento di sistema: $lastImportDateStr',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Watch advanced filters
    final selectedLivelli = ref.watch(selectedAnagLivelliProvider);
    final gradoFilterType = ref.watch(gradoFilterTypeProvider);
    final selectedGradoSpecific = ref.watch(selectedGradoSpecificProvider);
    final selectedGradoMin = ref.watch(selectedGradoMinProvider);
    final selectedGradoMax = ref.watch(selectedGradoMaxProvider);
    final etaFilterType = ref.watch(etaFilterTypeProvider);
    final selectedEtaSpecific = ref.watch(selectedEtaSpecificProvider);
    final selectedEtaMin = ref.watch(selectedEtaMinProvider);
    final selectedEtaMax = ref.watch(selectedEtaMaxProvider);
    final selectedSolidarieta = ref.watch(selectedAnagContrSolidarietaProvider);
    final selectedSocieta = ref.watch(selectedAnagSocietaProvider);
    final selectedComune = ref.watch(selectedAnagSedeComuneProvider);
    final selectedProvincia = ref.watch(selectedAnagProvinciaProvider);
    final selectedPartFull = ref.watch(selectedAnagPartFullTimeProvider);
    final selectedResponsabile = ref.watch(selectedAnagResponsabileProvider);
    final selectedGestore = ref.watch(selectedAnagGestoreProvider);
    final selectedStatus = ref.watch(selectedAnagStatusProvider);

    final activeFiltersCount = [
      selectedLivelli.isNotEmpty,
      gradoFilterType != GradoFilterType.all,
      etaFilterType != EtaFilterType.all,
      selectedSolidarieta != null,
      selectedSocieta.isNotEmpty,
      selectedComune.isNotEmpty,
      selectedProvincia.isNotEmpty,
      selectedPartFull != null,
      selectedResponsabile.isNotEmpty,
      selectedGestore.isNotEmpty,
      selectedStatus.isNotEmpty,
      selectedLogHistoryIds.isNotEmpty,
    ].where((e) => e).length;

    // Estrattori valori unici per i filtri
    final livelliList = allRecords.map((e) => e.livello ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final gradiList = allRecords.map((e) => e.gradoOccupaz ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final etaList = allRecords.map((e) => _parseAge(e.dataNascita)).whereType<int>().toSet().toList()..sort();
    final solidarietaList = allRecords.map((e) => e.contrSolidarieta ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final societaList = allRecords.map((e) => e.societa ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final comuniList = allRecords.map((e) => e.sedeComune ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final provinceList = allRecords.map((e) => e.provincia ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final partFullList = allRecords.map((e) => e.partTimeFullTime ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final responsabiliList = allRecords.map((e) => e.nominativoResponsabileUO ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final gestoriList = allRecords.map((e) => e.nominativoGestore ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final statusList = allRecords.map((e) => e.status ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      // Filtro File Caricato
      if (selectedLogHistoryIds.isNotEmpty && !selectedLogHistoryIds.contains(r.importBatch)) return false;

      // Ricerca testuale
      bool matchSearch = true;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        matchSearch = (r.cid?.toLowerCase().contains(q) ?? false) ||
                      (r.nominativo?.toLowerCase().contains(q) ?? false) ||
                      (r.codiceFiscale?.toLowerCase().contains(q) ?? false) ||
                      (r.matricolaAziendaleUID?.toLowerCase().contains(q) ?? false);
      }
      if (!matchSearch) return false;

      // Filtri avanzati
      if (selectedLivelli.isNotEmpty && !selectedLivelli.contains(r.livello ?? '')) return false;
      
      // Filtro Grado Occupazione
      if (gradoFilterType == GradoFilterType.specific && selectedGradoSpecific != null) {
        if (r.gradoOccupaz != selectedGradoSpecific) return false;
      } else if (gradoFilterType == GradoFilterType.range && (selectedGradoMin != null || selectedGradoMax != null)) {
        final val = _parseGrado(r.gradoOccupaz);
        if (val == null) return false;
        if (selectedGradoMin != null && val < selectedGradoMin) return false;
        if (selectedGradoMax != null && val > selectedGradoMax) return false;
      }

      // Filtro Età
      if (etaFilterType == EtaFilterType.specific && selectedEtaSpecific != null) {
        if (_parseAge(r.dataNascita) != selectedEtaSpecific) return false;
      } else if (etaFilterType == EtaFilterType.range && (selectedEtaMin != null || selectedEtaMax != null)) {
        final val = _parseAge(r.dataNascita);
        if (val == null) return false;
        if (selectedEtaMin != null && val < selectedEtaMin) return false;
        if (selectedEtaMax != null && val > selectedEtaMax) return false;
      }

      if (selectedSolidarieta != null && r.contrSolidarieta != selectedSolidarieta) return false;
      if (selectedSocieta.isNotEmpty && !selectedSocieta.contains(r.societa ?? '')) return false;
      if (selectedComune.isNotEmpty && !selectedComune.contains(r.sedeComune ?? '')) return false;
      if (selectedProvincia.isNotEmpty && !selectedProvincia.contains(r.provincia ?? '')) return false;
      if (selectedPartFull != null && r.partTimeFullTime != selectedPartFull) return false;
      if (selectedResponsabile.isNotEmpty && !selectedResponsabile.contains(r.nominativoResponsabileUO ?? '')) return false;
      if (selectedGestore.isNotEmpty && !selectedGestore.contains(r.nominativoGestore ?? '')) return false;
      if (selectedStatus.isNotEmpty && !selectedStatus.contains(r.status ?? '')) return false;

      return true;
    }).toList()..sort((a, b) {
      final nomA = a.nominativo ?? '';
      final nomB = b.nominativo ?? '';
      return sortAscending ? nomA.compareTo(nomB) : nomB.compareTo(nomA);
    });

    final totalUsers = filteredRecords.length;
    final malesCount = filteredRecords.where((r) => r.sesso?.toUpperCase() == 'M' || r.sesso?.toLowerCase() == 'maschio').length;
    final femalesCount = filteredRecords.where((r) => r.sesso?.toUpperCase() == 'F' || r.sesso?.toLowerCase() == 'femmina').length;
    final validAges = filteredRecords.map((e) => _parseAge(e.dataNascita)).whereType<int>().toList();
    final double averageAge = validAges.isEmpty ? 0.0 : validAges.reduce((a, b) => a + b) / validAges.length;

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(
        context, 
        ref, 
        livelliList, 
        gradiList, 
        solidarietaList, 
        societaList, 
        comuniList, 
        provinceList, 
        partFullList, 
        responsabiliList, 
        gestoriList,
        etaList,
        statusList,
      ),
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
          // HEADER CON RICERCA
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
                              child: LayoutBuilder(
                                builder: (context, constraints) => Autocomplete<Anagrafica>(
                                  displayStringForOption: (e) => '${e.cid ?? ""} - ${e.nominativo ?? ""}',
                                  optionsBuilder: (textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<Anagrafica>.empty();
                                    }
                                    return allRecords.where((e) =>
                                      (e.cid?.toLowerCase().contains(textEditingValue.text.toLowerCase()) ?? false) ||
                                      (e.nominativo?.toLowerCase().contains(textEditingValue.text.toLowerCase()) ?? false) ||
                                      (e.codiceFiscale?.toLowerCase().contains(textEditingValue.text.toLowerCase()) ?? false)
                                    ).take(10);
                                  },
                                  onSelected: (e) {
                                    ref.read(anagraficaSearchProvider.notifier).state = e.nominativo;
                                    ref.read(anagraficaPageProvider.notifier).state = 0;
                                  },
                                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                    return TextField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      decoration: const InputDecoration(
                                        hintText: 'Cerca per CID, Nominativo, Codice Fiscale...',
                                        border: InputBorder.none,
                                        isDense: true,
                                      ),
                                      style: const TextStyle(fontSize: 14),
                                      onChanged: (value) {
                                        ref.read(anagraficaSearchProvider.notifier).state = value.isEmpty ? null : value;
                                        ref.read(anagraficaPageProvider.notifier).state = 0;
                                      },
                                    );
                                  },
                                  optionsViewBuilder: (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 8,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: constraints.maxWidth,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            itemBuilder: (context, index) {
                                              final option = options.elementAt(index);
                                              return ListTile(
                                                title: Text(option.nominativo ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                subtitle: Text('CID: ${option.cid} • CF: ${option.codiceFiscale}'),
                                                leading: const Icon(Icons.person_outline, color: Color(0xFF003399)),
                                                onTap: () => onSelected(option),
                                              );
                                            },
                                          ),
                                        ),
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
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        ref.read(anagraficaSortAscendingProvider.notifier).state = !sortAscending;
                      },
                      icon: Icon(sortAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined),
                      tooltip: 'Ordina per Nominativo',
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showComuneDistributionMap(context, filteredRecords),
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Mostra cartina'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: SkyTheme.timBlue),
                        foregroundColor: SkyTheme.timBlue,
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
                        if (selectedLivelli.isNotEmpty) 
                          _buildFilterChip('Livelli: ${selectedLivelli.length}', () => ref.read(selectedAnagLivelliProvider.notifier).state = []),
                        if (gradoFilterType == GradoFilterType.specific && selectedGradoSpecific != null)
                          _buildFilterChip('Grado: $selectedGradoSpecific', () {
                            ref.read(selectedGradoSpecificProvider.notifier).state = null;
                            ref.read(gradoFilterTypeProvider.notifier).state = GradoFilterType.all;
                          }),
                        if (gradoFilterType == GradoFilterType.range && (selectedGradoMin != null || selectedGradoMax != null))
                          _buildFilterChip(
                            'Grado: ${(selectedGradoMin ?? 0.0).toStringAsFixed(0)} - ${(selectedGradoMax ?? 100.0).toStringAsFixed(0)}%', 
                            () {
                              ref.read(selectedGradoMinProvider.notifier).state = null;
                              ref.read(selectedGradoMaxProvider.notifier).state = null;
                              ref.read(gradoFilterTypeProvider.notifier).state = GradoFilterType.all;
                            }
                          ),
                        if (etaFilterType == EtaFilterType.specific && selectedEtaSpecific != null)
                          _buildFilterChip('Età: $selectedEtaSpecific anni', () {
                            ref.read(selectedEtaSpecificProvider.notifier).state = null;
                            ref.read(etaFilterTypeProvider.notifier).state = EtaFilterType.all;
                          }),
                        if (etaFilterType == EtaFilterType.range && (selectedEtaMin != null || selectedEtaMax != null))
                          _buildFilterChip(
                            'Età: ${(selectedEtaMin ?? 18.0).toStringAsFixed(0)} - ${(selectedEtaMax ?? 75.0).toStringAsFixed(0)} anni', 
                            () {
                              ref.read(selectedEtaMinProvider.notifier).state = null;
                              ref.read(selectedEtaMaxProvider.notifier).state = null;
                              ref.read(etaFilterTypeProvider.notifier).state = EtaFilterType.all;
                            }
                          ),
                        if (selectedSolidarieta != null) 
                          _buildFilterChip('Solidarietà: $selectedSolidarieta', () => ref.read(selectedAnagContrSolidarietaProvider.notifier).state = null),
                        if (selectedPartFull != null) 
                          _buildFilterChip('Part/Full-Time: $selectedPartFull', () => ref.read(selectedAnagPartFullTimeProvider.notifier).state = null),
                        if (selectedSocieta.isNotEmpty) 
                          _buildFilterChip('Società: ${selectedSocieta.length}', () => ref.read(selectedAnagSocietaProvider.notifier).state = []),
                        if (selectedComune.isNotEmpty) 
                          _buildFilterChip('Comune: ${selectedComune.length}', () => ref.read(selectedAnagSedeComuneProvider.notifier).state = []),
                        if (selectedProvincia.isNotEmpty) 
                          _buildFilterChip('Provincia: ${selectedProvincia.length}', () => ref.read(selectedAnagProvinciaProvider.notifier).state = []),
                        if (selectedResponsabile.isNotEmpty) 
                          _buildFilterChip('Responsabile: ${selectedResponsabile.length}', () => ref.read(selectedAnagResponsabileProvider.notifier).state = []),
                        if (selectedGestore.isNotEmpty) 
                          _buildFilterChip('Gestore: ${selectedGestore.length}', () => ref.read(selectedAnagGestoreProvider.notifier).state = []),
                        if (selectedStatus.isNotEmpty)
                          _buildFilterChip('Stato: ${selectedStatus.length}', () => ref.read(selectedAnagStatusProvider.notifier).state = []),
                        if (selectedLogHistoryIds.isNotEmpty)
                          _buildFilterChip(
                            selectedLogFileName != null
                                ? 'File: $selectedLogFileName'
                                : 'File: ${selectedLogHistoryIds.length} selezionati',
                            () {
                              ref.read(selectedAnagLogHistoryIdsProvider.notifier).state = {};
                              ref.read(anagraficaPageProvider.notifier).state = 0;
                            },
                          ),
                        TextButton(
                          onPressed: () => _resetAllFiltersAnag(ref), 
                          child: const Text('Reset tutto', style: TextStyle(fontSize: 12, color: Colors.red))
                        ),
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
                    title: 'TOTALE UTENTI',
                    value: '$totalUsers utenti',
                    subtitle: '$malesCount M / $femalesCount F',
                    icon: Icons.people_outline,
                    color: SkyTheme.timBlue,
                    bgLightColor: SkyTheme.timBlue.withAlpha(20),
                  );
                  final card2 = _buildSummaryCard(
                    title: 'ETÀ MEDIA',
                    value: averageAge > 0 ? '${averageAge.toStringAsFixed(1).replaceAll('.', ',')} anni' : '-',
                    icon: Icons.cake_outlined,
                    color: Colors.green.shade700,
                    bgLightColor: Colors.green.shade50,
                  );
                  final card3 = _buildSummaryCard(
                    title: 'ULTIMA IMPORTAZIONE',
                    value: lastImportDateStr,
                    icon: Icons.cloud_upload_outlined,
                    color: Colors.orange.shade800,
                    bgLightColor: Colors.orange.shade50,
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

          // TABELLA
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
                          width: 1730, // Larghezza fissa per scorrimento orizzontale
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
                                    _buildCell('AZIONI', 100, isHeader: true, alignment: Alignment.center),
                                    _buildCell('CID', 150, isHeader: true),
                                    _buildCell('UID (MATRICOLA)', 140, isHeader: true),
                                    _buildCell('NOMINATIVO', 250, isHeader: true),
                                    _buildCell('ETÀ', 80, isHeader: true),
                                    _buildCell('UNITÀ ORG. 3 DES.', 250, isHeader: true),
                                    _buildCell('REGIONE', 150, isHeader: true),
                                    _buildCell('SEDE COMUNE', 150, isHeader: true),
                                    _buildCell('MANSIONE', 250, isHeader: true),
                                    _buildCell('EMAIL', 210, isHeader: true),
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
                                  final record = paginatedRecords[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0 ? Colors.white : Colors.grey.shade50.withAlpha(120),
                                      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildCell('', 100, alignment: Alignment.center, child: IconButton(
                                          icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20),
                                          onPressed: () => _showAnagraficaDetails(context, record),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        )),
                                        _buildCell(
                                          record.cid ?? '-',
                                          150,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  record.cid ?? '-',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (record.cid != null && record.cid!.isNotEmpty && record.cid != '-')
                                                Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(4),
                                                    onTap: () {
                                                      Clipboard.setData(ClipboardData(text: record.cid!));
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('CID ${record.cid} copiato negli appunti'),
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
                                        ),
                                        _buildCell(
                                          record.matricolaAziendaleUID ?? '-',
                                          140,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  record.matricolaAziendaleUID ?? '-',
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (record.matricolaAziendaleUID != null && record.matricolaAziendaleUID!.isNotEmpty && record.matricolaAziendaleUID != '-')
                                                Material(
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    borderRadius: BorderRadius.circular(4),
                                                    onTap: () {
                                                      Clipboard.setData(ClipboardData(text: record.matricolaAziendaleUID!));
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        SnackBar(
                                                          content: Text('UID ${record.matricolaAziendaleUID} copiato negli appunti'),
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
                                        ),
                                        _buildCell(record.nominativo ?? '-', 250, color: SkyTheme.timBlue, fontWeight: FontWeight.bold),
                                        _buildCell(
                                          _parseAge(record.dataNascita)?.toString() ?? '-',
                                          80,
                                        ),
                                        _buildCell(record.unitaOrg3Des ?? '-', 250),
                                        _buildCell(record.regione ?? '-', 150),
                                        _buildCell(record.sedeComune ?? '-', 150),
                                        _buildCell(record.mansione ?? '-', 250),
                                          _buildCell(
                                            record.indirizzoMail ?? '-',
                                            210,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    record.indirizzoMail ?? '-',
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (record.indirizzoMail != null && record.indirizzoMail!.isNotEmpty && record.indirizzoMail != '-')
                                                  Material(
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      borderRadius: BorderRadius.circular(4),
                                                      onTap: () {
                                                        Clipboard.setData(ClipboardData(text: record.indirizzoMail!));
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('Email ${record.indirizzoMail} copiata negli appunti'),
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
                      onPressed: currentPage > 0 ? () => ref.read(anagraficaPageProvider.notifier).state-- : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('Pagina ${currentPage + 1} di $totalPages', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: currentPage < totalPages - 1 ? () => ref.read(anagraficaPageProvider.notifier).state++ : null,
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

  Widget _buildCell(String text, double width, {bool isHeader = false, Color? color, FontWeight? fontWeight, Alignment alignment = Alignment.centerLeft, Widget? child}) {
    return Container(
      width: width,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: alignment,
      child: child ?? Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 11 : 13,
          fontWeight: isHeader ? FontWeight.bold : (fontWeight ?? FontWeight.normal),
          color: isHeader ? Colors.grey.shade700 : (color ?? Colors.black87),
          letterSpacing: isHeader ? 1.0 : null,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showAnagraficaDetails(BuildContext context, Anagrafica record) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
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
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withAlpha(40),
                        child: const Icon(Icons.person, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.nominativo ?? 'N/D',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'CID: ${record.cid} | CF: ${record.codiceFiscale}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Dati Personali', Icons.person_outline, Colors.blue, [
                          _buildDetailRow('Sesso', record.sesso ?? '-'),
                          _buildDetailRow('Data Nascita', _formatDate(record.dataNascita)),
                          _buildDetailRow('Età', _calculateAge(record.dataNascita)),
                          _buildDetailRow('Luogo Nascita', record.luogoNascita ?? '-'),
                          _buildDetailRow('Codice Fiscale', record.codiceFiscale ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Formazione', Icons.school_outlined, Colors.teal, [
                          _buildDetailRow('Tipo Scuola', record.tipoScuola ?? '-'),
                          _buildDetailRow('Formazione', record.formazione ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Rapporto di Lavoro', Icons.work_outline, Colors.orange, [
                          _buildDetailRow('CID', record.cid ?? '-', context: context, copyValue: record.cid),
                          _buildDetailRow('Matricola', record.matricolaAziendaleUID ?? '-', context: context, copyValue: record.matricolaAziendaleUID),
                          _buildDetailRow('Data Assunzione', _formatDate(record.dataAssunzione)),
                          _buildDetailRow('Data Assunzione Gruppo', _formatDate(record.dataAssunzioneGruppo)),
                          _buildDetailRow('Anzianità di servizio', _calculateSeniority(record.dataAssunzioneGruppo)),
                          _buildDetailRow('Tipo Dipendente', record.tipoDip ?? '-'),
                          _buildDetailRow('Livello', record.livello ?? '-'),
                          _buildDetailRow('Mansione', record.mansione ?? '-'),
                          _buildDetailRow('Posizione', record.posizione ?? '-'),
                          _buildDetailRow('Tipo Contratto', record.tipoContratto ?? '-'),
                          _buildDetailRow('Orario', record.partTimeFullTime ?? '-'),
                          _buildDetailRow('Stato', record.status ?? '-'),
                          _buildDetailRow('Responsabilità', record.responsabileSINO ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Organizzazione', Icons.business_outlined, Colors.purple, [
                          _buildDetailRow('Società', record.societa ?? '-'),
                          _buildDetailRow('Unità Org.', record.unitaOrganizzativa ?? '-'),
                          _buildDetailRow('U.O. 3', record.unitaOrg3Des ?? '-'),
                          _buildDetailRow('U.O. 4', record.unitaOrg4Des ?? '-'),
                          _buildDetailRow('U.O. 5', record.unitaOrg5Des ?? '-'),
                          _buildDetailRow('Responsabile', record.nominativoResponsabileUO ?? '-'),
                          _buildDetailRow('Key Account', record.nominativoKeyAccount ?? '-'),
                          _buildDetailRow('Gestore', record.nominativoGestore ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Contatti e Sede', Icons.location_on_outlined, Colors.green, [
                          _buildDetailRow('Email', record.indirizzoMail ?? '-', context: context, copyValue: record.indirizzoMail),
                          _buildDetailRow('Sede Comune', record.sedeComune ?? '-'),
                          _buildDetailRow('Sede Indirizzo', record.sedeIndirizzo ?? '-'),
                          _buildDetailRow('Regione', record.regione ?? '-'),
                          _buildDetailRow('Provincia', record.provincia ?? '-'),
                        ]),
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

  Widget _buildFilterDrawer(
    BuildContext context, 
    WidgetRef ref, 
    List<String> livelli,
    List<String> gradi,
    List<String> solidarieta,
    List<String> societa,
    List<String> comuni,
    List<String> province,
    List<String> partFull,
    List<String> responsabili,
    List<String> gestori,
    List<int> etaList,
    List<String> statusList,
  ) {
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
              padding: const EdgeInsets.all(24),
              children: [
                _buildDrawerSectionTitle('LAVORO'),
                _buildMultiSelectFilter(
                  'Livello',
                  ref.watch(selectedAnagLivelliProvider),
                  livelli,
                  (val) {
                    ref.read(selectedAnagLivelliProvider.notifier).state = val;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                  icon: Icons.layers_outlined,
                ),
                const SizedBox(height: 16),
                _buildGradoOccupazioneFilter(context, ref, gradi),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Contr. Solidarietà', ref.watch(selectedAnagContrSolidarietaProvider), solidarieta, (val) {
                  ref.read(selectedAnagContrSolidarietaProvider.notifier).state = val;
                  ref.read(anagraficaPageProvider.notifier).state = 0;
                }, icon: Icons.handshake_outlined),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Part-Time / Full-Time', ref.watch(selectedAnagPartFullTimeProvider), partFull, (val) {
                  ref.read(selectedAnagPartFullTimeProvider.notifier).state = val;
                  ref.read(anagraficaPageProvider.notifier).state = 0;
                }, icon: Icons.timer_outlined),
                const SizedBox(height: 16),
                _buildEtaFilter(context, ref, etaList),
                const SizedBox(height: 16),
                _buildMultiSelectFilter(
                  'Stato',
                  ref.watch(selectedAnagStatusProvider),
                  statusList,
                  (val) {
                    ref.read(selectedAnagStatusProvider.notifier).state = val;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                  icon: Icons.info_outline,
                ),
                
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('SEDE E SOCIETÀ'),
                _buildMultiSelectFilter(
                  'Società',
                  ref.watch(selectedAnagSocietaProvider),
                  societa,
                  (val) {
                    ref.read(selectedAnagSocietaProvider.notifier).state = val;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 16),
                _buildMultiSelectFilter(
                  'Sede Comune',
                  ref.watch(selectedAnagSedeComuneProvider),
                  comuni,
                  (val) {
                    ref.read(selectedAnagSedeComuneProvider.notifier).state = val;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 16),
                _buildMultiSelectFilter(
                  'Sede Provincia',
                  ref.watch(selectedAnagProvinciaProvider),
                  province,
                  (val) {
                    ref.read(selectedAnagProvinciaProvider.notifier).state = val;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                  icon: Icons.map_outlined,
                ),
                
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('FILE CARICATI'),
                const SizedBox(height: 12),
                _buildFileSelectionTrigger(
                  context,
                  'Seleziona File',
                  ref.watch(selectedAnagLogHistoryIdsProvider),
                  ref.watch(logHistoryProvider).where((l) => l.sourceType == 'Anagrafica').toList(),
                  (next) {
                    ref.read(selectedAnagLogHistoryIdsProvider.notifier).state = next;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                  icon: Icons.insert_drive_file_outlined,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('GERARCHIA'),
                _buildMultiSelectFilter(
                  'Responsabile',
                  ref.watch(selectedAnagResponsabileProvider),
                  responsabili,
                  (val) {
                    ref.read(selectedAnagResponsabileProvider.notifier).state = val;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                  icon: Icons.supervisor_account_outlined,
                ),
                const SizedBox(height: 16),
                _buildMultiSelectFilter(
                  'Gestore',
                  ref.watch(selectedAnagGestoreProvider),
                  gestori,
                  (val) {
                    ref.read(selectedAnagGestoreProvider.notifier).state = val;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                  icon: Icons.manage_accounts_outlined,
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
                    onPressed: () => _resetAllFiltersAnag(ref),
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

  double? _parseGrado(String? s) {
    if (s == null) return null;
    final cleaned = s.replaceAll('%', '').replaceAll(',', '.').replaceAll(RegExp(r'\s+'), '');
    final val = double.tryParse(cleaned);
    if (val == null) return null;
    if (val > 0 && val <= 1.0) {
      return val * 100.0;
    }
    return val;
  }

  int? _parseAge(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return null;
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return null;
      final now = DateTime.now();
      int age = now.year - dt.year;
      if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }

  Widget _buildEtaFilter(
    BuildContext context,
    WidgetRef ref,
    List<int> etaList,
  ) {
    final filterType = ref.watch(etaFilterTypeProvider);
    final selectedSpecific = ref.watch(selectedEtaSpecificProvider);
    final selectedMin = ref.watch(selectedEtaMinProvider);
    final selectedMax = ref.watch(selectedEtaMaxProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Età',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSegmentButton(
                  'Tutti',
                  filterType == EtaFilterType.all,
                  () {
                    ref.read(etaFilterTypeProvider.notifier).state = EtaFilterType.all;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                ),
              ),
              Expanded(
                child: _buildSegmentButton(
                  'Specifico',
                  filterType == EtaFilterType.specific,
                  () {
                    ref.read(etaFilterTypeProvider.notifier).state = EtaFilterType.specific;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                ),
              ),
              Expanded(
                child: _buildSegmentButton(
                  'Intervallo',
                  filterType == EtaFilterType.range,
                  () {
                    ref.read(etaFilterTypeProvider.notifier).state = EtaFilterType.range;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                ),
              ),
            ],
          ),
        ),
        if (filterType == EtaFilterType.specific) ...[
          const SizedBox(height: 12),
          _buildFilterDropdown<int?>(
            'Seleziona Valore',
            selectedSpecific,
            etaList,
            (val) {
              ref.read(selectedEtaSpecificProvider.notifier).state = val;
              ref.read(anagraficaPageProvider.notifier).state = 0;
            },
            icon: Icons.cake_outlined,
            labelMapper: (val) => '$val anni',
          ),
        ],
        if (filterType == EtaFilterType.range) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${(selectedMin ?? 18.0).toStringAsFixed(0)} anni',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                'Max: ${(selectedMax ?? 75.0).toStringAsFixed(0)} anni',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          RangeSlider(
            values: RangeValues(
              (selectedMin ?? 18.0).clamp(18.0, 75.0),
              (selectedMax ?? 75.0).clamp(18.0, 75.0),
            ),
            min: 18.0,
            max: 75.0,
            divisions: 57,
            labels: RangeLabels(
              '${(selectedMin ?? 18.0).toStringAsFixed(0)} anni',
              '${(selectedMax ?? 75.0).toStringAsFixed(0)} anni',
            ),
            activeColor: SkyTheme.timBlue,
            inactiveColor: Colors.grey.shade300,
            onChanged: (RangeValues newValues) {
              ref.read(selectedEtaMinProvider.notifier).state = newValues.start;
              ref.read(selectedEtaMaxProvider.notifier).state = newValues.end;
              ref.read(anagraficaPageProvider.notifier).state = 0;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildGradoOccupazioneFilter(
    BuildContext context,
    WidgetRef ref,
    List<String> gradiList,
  ) {
    final filterType = ref.watch(gradoFilterTypeProvider);
    final selectedSpecific = ref.watch(selectedGradoSpecificProvider);
    final selectedMin = ref.watch(selectedGradoMinProvider);
    final selectedMax = ref.watch(selectedGradoMaxProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Grado Occupazione',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildSegmentButton(
                  'Tutti',
                  filterType == GradoFilterType.all,
                  () {
                    ref.read(gradoFilterTypeProvider.notifier).state = GradoFilterType.all;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                ),
              ),
              Expanded(
                child: _buildSegmentButton(
                  'Specifico',
                  filterType == GradoFilterType.specific,
                  () {
                    ref.read(gradoFilterTypeProvider.notifier).state = GradoFilterType.specific;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                ),
              ),
              Expanded(
                child: _buildSegmentButton(
                  'Intervallo',
                  filterType == GradoFilterType.range,
                  () {
                    ref.read(gradoFilterTypeProvider.notifier).state = GradoFilterType.range;
                    ref.read(anagraficaPageProvider.notifier).state = 0;
                  },
                ),
              ),
            ],
          ),
        ),
        if (filterType == GradoFilterType.specific) ...[
          const SizedBox(height: 12),
          _buildFilterDropdown<String?>(
            'Seleziona Valore',
            selectedSpecific,
            gradiList,
            (val) {
              ref.read(selectedGradoSpecificProvider.notifier).state = val;
              ref.read(anagraficaPageProvider.notifier).state = 0;
            },
            icon: Icons.work_history_outlined,
          ),
        ],
        if (filterType == GradoFilterType.range) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Min: ${(selectedMin ?? 0.0).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              Text(
                'Max: ${(selectedMax ?? 100.0).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          RangeSlider(
            values: RangeValues(
              (selectedMin ?? 0.0).clamp(0.0, 100.0),
              (selectedMax ?? 100.0).clamp(0.0, 100.0),
            ),
            min: 0.0,
            max: 100.0,
            divisions: 100,
            labels: RangeLabels(
              '${(selectedMin ?? 0.0).toStringAsFixed(0)}%',
              '${(selectedMax ?? 100.0).toStringAsFixed(0)}%',
            ),
            activeColor: SkyTheme.timBlue,
            inactiveColor: Colors.grey.shade300,
            onChanged: (RangeValues newValues) {
              ref.read(selectedGradoMinProvider.notifier).state = newValues.start;
              ref.read(selectedGradoMaxProvider.notifier).state = newValues.end;
              ref.read(anagraficaPageProvider.notifier).state = 0;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildSegmentButton(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? SkyTheme.timBlue : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown<T>(String label, T value, List<T> items, ValueChanged<T?> onChanged, {IconData? icon, String Function(T)? labelMapper}) {
    final effectiveItems = List<T>.from(items);
    if (value != null && !effectiveItems.contains(value)) {
      effectiveItems.add(value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          isDense: true,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: [
            DropdownMenuItem<T>(
              value: null, 
              child: Text(
                'Tutti', 
                style: TextStyle(color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...effectiveItems.map((item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelMapper != null ? labelMapper(item) : item.toString(), 
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          selectedItemBuilder: (context) {
            return [
              Text('Tutti', style: TextStyle(color: Colors.grey.shade600, fontSize: 13), overflow: TextOverflow.ellipsis),
              ...effectiveItems.map((item) => Text(
                labelMapper != null ? labelMapper(item) : item.toString(),
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              )),
            ];
          },
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMultiSelectFilter(
    String label,
    List<String> selectedItems,
    List<String> allItems,
    Function(List<String>) onChanged, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final results = await showDialog<List<String>>(
              context: context,
              builder: (context) {
                List<String> tempSelected = List<String>.from(selectedItems);
                String searchQuery = "";
                return StatefulBuilder(
                  builder: (context, setModalState) {
                    final filteredItems = allItems.where((item) =>
                        item.toLowerCase().contains(searchQuery.toLowerCase())).toList();

                    return AlertDialog(
                      title: Text('Seleziona $label'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      content: SizedBox(
                        width: 400,
                        height: 450,
                        child: Column(
                          children: [
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Cerca...',
                                prefixIcon: const Icon(Icons.search, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onChanged: (val) {
                                setModalState(() {
                                  searchQuery = val;
                                });
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    setModalState(() {
                                      for (final item in filteredItems) {
                                        if (!tempSelected.contains(item)) {
                                          tempSelected.add(item);
                                        }
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.select_all, size: 16),
                                  label: const Text('Tutti', style: TextStyle(fontSize: 12)),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    setModalState(() {
                                      for (final item in filteredItems) {
                                        tempSelected.remove(item);
                                      }
                                    });
                                  },
                                  icon: const Icon(Icons.deselect, size: 16),
                                  label: const Text('Reset', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                            const Divider(height: 8),
                            Expanded(
                              child: filteredItems.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Nessun risultato trovato',
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        final isSelected = tempSelected.contains(item);
                                        return CheckboxListTile(
                                          title: Text(item, style: const TextStyle(fontSize: 13)),
                                          value: isSelected,
                                          onChanged: (val) {
                                            setModalState(() {
                                              if (val == true) {
                                                if (!tempSelected.contains(item)) {
                                                  tempSelected.add(item);
                                                }
                                              } else {
                                                tempSelected.remove(item);
                                              }
                                            });
                                          },
                                          dense: true,
                                          visualDensity: VisualDensity.compact,
                                          controlAffinity: ListTileControlAffinity.leading,
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annulla'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, tempSelected),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SkyTheme.timBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Conferma'),
                        ),
                      ],
                    );
                  },
                );
              },
            );
            if (results != null) {
              onChanged(results);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    selectedItems.isEmpty
                        ? 'Tutti / Nessuno selezionato'
                        : selectedItems.length == 1
                            ? selectedItems.first
                            : '${selectedItems.length} selezionati',
                    style: TextStyle(
                      fontSize: 13,
                      color: selectedItems.isEmpty ? Colors.grey.shade600 : Colors.black87,
                      fontWeight: selectedItems.isEmpty ? FontWeight.normal : FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey.shade600),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _resetAllFiltersAnag(WidgetRef ref) {
    ref.read(selectedAnagLivelliProvider.notifier).state = [];
    ref.read(gradoFilterTypeProvider.notifier).state = GradoFilterType.all;
    ref.read(selectedGradoSpecificProvider.notifier).state = null;
    ref.read(selectedGradoMinProvider.notifier).state = null;
    ref.read(selectedGradoMaxProvider.notifier).state = null;
    ref.read(etaFilterTypeProvider.notifier).state = EtaFilterType.all;
    ref.read(selectedEtaSpecificProvider.notifier).state = null;
    ref.read(selectedEtaMinProvider.notifier).state = null;
    ref.read(selectedEtaMaxProvider.notifier).state = null;
    ref.read(selectedAnagContrSolidarietaProvider.notifier).state = null;
    ref.read(selectedAnagSocietaProvider.notifier).state = [];
    ref.read(selectedAnagSedeComuneProvider.notifier).state = [];
    ref.read(selectedAnagProvinciaProvider.notifier).state = [];
    ref.read(selectedAnagPartFullTimeProvider.notifier).state = null;
    ref.read(selectedAnagResponsabileProvider.notifier).state = [];
    ref.read(selectedAnagGestoreProvider.notifier).state = [];
    ref.read(selectedAnagStatusProvider.notifier).state = [];
    ref.read(selectedAnagLogHistoryIdsProvider.notifier).state = {};
    ref.read(anagraficaSearchProvider.notifier).state = null;
    _searchController.clear();
  }

  Widget _buildDetailSection(String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.0)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {BuildContext? context, String? copyValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (copyValue != null && value != '-' && value.isNotEmpty && context != null) ...[
                  const SizedBox(width: 6),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: copyValue));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$label ($copyValue) copiato negli appunti'),
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgLightColor,
    String? subtitle,
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
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: color == SkyTheme.timRed ? Colors.black87 : color,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
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

  Future<void> _exportToExcel(List<Anagrafica> records) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Anagrafica'];
      excel.setDefaultSheet('Anagrafica');

      sheet.appendRow([
        TextCellValue('CID'),
        TextCellValue('Matricola Aziendale UID'),
        TextCellValue('Nominativo'),
        TextCellValue('Codice Fiscale'),
        TextCellValue('Sesso'),
        TextCellValue('Data Nascita'),
        TextCellValue('Luogo Nascita'),
        TextCellValue('Tipo Scuola'),
        TextCellValue('Formazione'),
        TextCellValue('Data Assunzione'),
        TextCellValue('Data Assunzione Gruppo'),
        TextCellValue('Tipo Dipendente'),
        TextCellValue('Livello'),
        TextCellValue('Mansione'),
        TextCellValue('Posizione'),
        TextCellValue('Tipo Contratto'),
        TextCellValue('Orario (Part/Full Time)'),
        TextCellValue('Status'),
        TextCellValue('Responsabile SI/NO'),
        TextCellValue('Società'),
        TextCellValue('Unità Organizzativa'),
        TextCellValue('U.O. 3 Des'),
        TextCellValue('U.O. 4 Des'),
        TextCellValue('U.O. 5 Des'),
        TextCellValue('Nominativo Responsabile UO'),
        TextCellValue('Nominativo Key Account'),
        TextCellValue('Nominativo Gestore'),
        TextCellValue('Email'),
        TextCellValue('Sede Comune'),
        TextCellValue('Sede Indirizzo'),
        TextCellValue('Regione'),
        TextCellValue('Provincia'),
        TextCellValue('Contratto Solidarietà'),
        TextCellValue('Grado Occupazione'),
      ]);

      for (final r in records) {
        sheet.appendRow([
          TextCellValue(r.cid ?? ''),
          TextCellValue(r.matricolaAziendaleUID ?? ''),
          TextCellValue(r.nominativo ?? ''),
          TextCellValue(r.codiceFiscale ?? ''),
          TextCellValue(r.sesso ?? ''),
          TextCellValue(r.dataNascita ?? ''),
          TextCellValue(r.luogoNascita ?? ''),
          TextCellValue(r.tipoScuola ?? ''),
          TextCellValue(r.formazione ?? ''),
          TextCellValue(r.dataAssunzione ?? ''),
          TextCellValue(r.dataAssunzioneGruppo ?? ''),
          TextCellValue(r.tipoDip ?? ''),
          TextCellValue(r.livello ?? ''),
          TextCellValue(r.mansione ?? ''),
          TextCellValue(r.posizione ?? ''),
          TextCellValue(r.tipoContratto ?? ''),
          TextCellValue(r.partTimeFullTime ?? ''),
          TextCellValue(r.status ?? ''),
          TextCellValue(r.responsabileSINO ?? ''),
          TextCellValue(r.societa ?? ''),
          TextCellValue(r.unitaOrganizzativa ?? ''),
          TextCellValue(r.unitaOrg3Des ?? ''),
          TextCellValue(r.unitaOrg4Des ?? ''),
          TextCellValue(r.unitaOrg5Des ?? ''),
          TextCellValue(r.nominativoResponsabileUO ?? ''),
          TextCellValue(r.nominativoKeyAccount ?? ''),
          TextCellValue(r.nominativoGestore ?? ''),
          TextCellValue(r.indirizzoMail ?? ''),
          TextCellValue(r.sedeComune ?? ''),
          TextCellValue(r.sedeIndirizzo ?? ''),
          TextCellValue(r.regione ?? ''),
          TextCellValue(r.provincia ?? ''),
          TextCellValue(r.contrSolidarieta ?? ''),
          TextCellValue(r.gradoOccupaz ?? ''),
        ]);
      }

      // Applica stili alle intestazioni (TIM Blue con testo bianco grassetto)
      final headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#003399'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      const colCount = 34;
      for (var col = 0; col < colCount; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }
      sheet.setRowHeight(0, 30);

      // Configura larghezze colonne ottimali
      final widths = [
        12, // CID
        22, // Matricola Aziendale UID
        25, // Nominativo
        18, // Codice Fiscale
        8,  // Sesso
        15, // Data Nascita
        20, // Luogo Nascita
        20, // Tipo Scuola
        25, // Formazione
        15, // Data Assunzione
        18, // Data Assunzione Gruppo
        18, // Tipo Dipendente
        10, // Livello
        25, // Mansione
        20, // Posizione
        18, // Tipo Contratto
        22, // Orario (Part/Full Time)
        12, // Status
        18, // Responsabile SI/NO
        12, // Società
        25, // Unità Organizzativa
        25, // U.O. 3 Des
        25, // U.O. 4 Des
        25, // U.O. 5 Des
        28, // Nominativo Responsabile UO
        28, // Nominativo Key Account
        28, // Nominativo Gestore
        25, // Email
        20, // Sede Comune
        30, // Sede Indirizzo
        18, // Regione
        10, // Provincia
        22, // Contratto Solidarietà
        18, // Grado Occupazione
      ];

      for (var col = 0; col < widths.length; col++) {
        sheet.setColumnWidth(col, widths[col].toDouble());
      }

      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva Export Anagrafica',
        fileName: 'export_anagrafica_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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

  void _showComuneDistributionMap(BuildContext context, List<Anagrafica> records) {
    final Map<String, int> cityCounts = {};
    for (final r in records) {
      final city = r.sedeComune?.trim() ?? '';
      if (city.isNotEmpty) {
        final normalizedCity = city[0].toUpperCase() + city.substring(1).toLowerCase();
        cityCounts[normalizedCity] = (cityCounts[normalizedCity] ?? 0) + 1;
      }
    }
    final totalCount = cityCounts.values.fold(0, (sum, val) => sum + val);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 700),
            child: _ComuneDistributionDialogContent(
              cityCounts: cityCounts,
              totalCount: totalCount,
              records: records,
            ),
          ),
        );
      },
    );
  }
}

class _ComuneDistributionDialogContent extends StatefulWidget {
  final Map<String, int> cityCounts;
  final int totalCount;
  final List<Anagrafica> records;

  const _ComuneDistributionDialogContent({
    required this.cityCounts,
    required this.totalCount,
    required this.records,
  });

  @override
  State<_ComuneDistributionDialogContent> createState() => _ComuneDistributionDialogContentState();
}

class _ComuneDistributionDialogContentState extends State<_ComuneDistributionDialogContent> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _employeeSearchQuery = '';
  String? _hoveredCity;
  String? _selectedCity;
  late AnimationController _pulseController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  static const Map<String, LatLng> _cityCoordinates = {
    'roma': LatLng(41.9028, 12.4964),
    'rome': LatLng(41.9028, 12.4964),
    'milano': LatLng(45.4642, 9.1900),
    'milan': LatLng(45.4642, 9.1900),
    'torino': LatLng(45.0703, 7.6869),
    'turin': LatLng(45.0703, 7.6869),
    'napoli': LatLng(40.8518, 14.2681),
    'naples': LatLng(40.8518, 14.2681),
    'firenze': LatLng(43.7696, 11.2558),
    'florence': LatLng(43.7696, 11.2558),
    'bologna': LatLng(44.4949, 11.3426),
    'venezia': LatLng(45.4408, 12.3155),
    'venice': LatLng(45.4408, 12.3155),
    'palermo': LatLng(38.1157, 13.3615),
    'genova': LatLng(44.4056, 8.9463),
    'bari': LatLng(41.1171, 16.8719),
    'catanzaro': LatLng(38.9098, 16.5877),
    'cagliari': LatLng(39.2238, 9.1217),
    'perugia': LatLng(43.1107, 12.3908),
    'ancona': LatLng(43.6158, 13.5189),
    'potenza': LatLng(40.6404, 15.8056),
    'campobasso': LatLng(41.5603, 14.6596),
    'aosta': LatLng(45.7349, 7.3130),
    'trento': LatLng(46.0748, 11.1217),
    'trieste': LatLng(45.6495, 13.7768),
    'l\'aquila': LatLng(42.3489, 13.3980),
    'laquila': LatLng(42.3489, 13.3980),
    'verona': LatLng(45.4384, 10.9916),
    'padova': LatLng(45.4064, 11.8768),
    'brescia': LatLng(45.5398, 10.2181),
    'monza': LatLng(45.5845, 9.2744),
    'bergamo': LatLng(45.6983, 9.6773),
    'taranto': LatLng(40.4677, 17.2470),
    'reggio calabria': LatLng(38.1144, 15.6500),
    'messina': LatLng(38.1938, 15.5540),
    'catania': LatLng(37.5079, 15.0830),
    'sassari': LatLng(40.7272, 8.5595),
    'salerno': LatLng(40.6780, 14.7591),
    'foggia': LatLng(41.4622, 15.5446),
    'pescara': LatLng(42.4618, 14.2142),
    'latina': LatLng(41.4676, 12.9037),
    'modena': LatLng(44.6471, 10.9252),
    'parma': LatLng(44.8015, 10.3279),
    'reggio emilia': LatLng(44.6982, 10.6312),
    'livorno': LatLng(43.5485, 10.3106),
    'pisa': LatLng(43.7085, 10.4036),
    'siena': LatLng(43.3188, 11.3308),
    'lucca': LatLng(43.8429, 10.5027),
    'prato': LatLng(43.8777, 11.1022),
    'ferrara': LatLng(44.8381, 11.6198),
    'ravenna': LatLng(44.4184, 12.2035),
    'rimini': LatLng(44.0576, 12.5653),
    'forli': LatLng(44.2227, 12.0407),
    'forli`': LatLng(44.2227, 12.0407),
    'cesena': LatLng(44.1396, 12.2435),
    'vicenza': LatLng(45.5467, 11.5475),
    'treviso': LatLng(45.6669, 12.2429),
    'udine': LatLng(46.0711, 13.2446),
    'bolzano': LatLng(46.4981, 11.3548),
    'pavia': LatLng(45.1850, 9.1559),
    'cremona': LatLng(45.1332, 10.0242),
    'mantova': LatLng(45.1564, 10.7914),
    'piacenza': LatLng(45.0526, 9.6930),
    'novara': LatLng(45.4468, 8.6214),
    'alessandria': LatLng(44.9129, 8.6151),
    'asti': LatLng(44.9005, 8.2069),
    'cuneo': LatLng(44.3833, 7.5417),
    'como': LatLng(45.8081, 9.0852),
    'varese': LatLng(45.8190, 8.8250),
    'lecco': LatLng(45.8559, 9.3977),
    'lodi': LatLng(45.3139, 9.5032),
    // Newly Added missing communes from Excel:
    'affi': LatLng(45.5492, 10.7958),
    'afragola': LatLng(40.9168, 14.3069),
    'agrigento': LatLng(37.3111, 13.5765),
    'albenga': LatLng(44.0483, 8.2127),
    'aprilia': LatLng(41.5915, 12.6508),
    'arese': LatLng(45.5539, 9.0776),
    'assago': LatLng(45.4017, 9.1308),
    'albano laziale': LatLng(41.7287, 12.6599),
    'arezzo': LatLng(43.4633, 11.8817),
    'bassano del grappa': LatLng(45.7663, 11.7342),
    'beinasco': LatLng(45.0232, 7.5830),
    'bellinzago lombardo': LatLng(45.5398, 9.4800),
    'belpasso': LatLng(37.5898, 14.9785),
    'borgo maggiore rsm': LatLng(43.9431, 12.4473),
    'borgo maggiore - san marino': LatLng(43.9431, 12.4473),
    'brindisi': LatLng(40.6327, 17.9417),
    'brugherio': LatLng(45.5517, 9.3006),
    'busnago': LatLng(45.6133, 9.4678),
    'bussolengo': LatLng(45.4746, 10.8497),
    'belgio': LatLng(50.8503, 4.3517),
    'brasile': LatLng(-14.2350, -51.9253),
    'campi bisenzio': LatLng(43.8267, 11.1350),
    'cantu\'': LatLng(45.7389, 9.1242),
    'cantu': LatLng(45.7389, 9.1242),
    'carasco': LatLng(44.3514, 9.3444),
    'carini': LatLng(38.1332, 13.1813),
    'carpi': LatLng(44.7838, 10.8856),
    'carugate': LatLng(45.5492, 9.3422),
    'casalecchio di reno': LatLng(44.4789, 11.2789),
    'caselle torinese': LatLng(45.1783, 7.6439),
    'cassina rizzardi': LatLng(45.7331, 9.0303),
    'castelfranco veneto': LatLng(45.6722, 11.9272),
    'castenaso': LatLng(44.5106, 11.4706),
    'cento': LatLng(44.7278, 11.2886),
    'chieri': LatLng(45.0084, 7.8227),
    'chieti': LatLng(42.3510, 14.1675),
    'chivasso': LatLng(45.1925, 7.8872),
    'cinisello balsamo': LatLng(45.5594, 9.2239),
    'cirie\'': LatLng(45.2346, 7.6019),
    'cirie': LatLng(45.2346, 7.6019),
    'citta\' sant\'angelo': LatLng(42.5168, 14.1317),
    'citta sant\'angelo': LatLng(42.5168, 14.1317),
    'collegno': LatLng(45.0784, 7.5750),
    'colonnella': LatLng(42.8724, 13.8697),
    'comacchio': LatLng(44.6936, 12.1852),
    'concesio': LatLng(45.6025, 10.2183),
    'conegliano': LatLng(45.8858, 12.2964),
    'corte franca': LatLng(45.6294, 9.9819),
    'crema': LatLng(45.3629, 9.6848),
    'curno': LatLng(45.6917, 9.6139),
    'curtatone': LatLng(45.1508, 10.7183),
    'caltanissetta': LatLng(37.4901, 14.0621),
    'cassinadepecchi': LatLng(45.5186, 9.3625),
    'cassina de\' pecchi': LatLng(45.5186, 9.3625),
    'cesano maderno': LatLng(45.6289, 9.1458),
    'cosenza': LatLng(39.2983, 16.2536),
    'domagnano rsm': LatLng(43.9511, 12.4702),
    'erba': LatLng(45.8078, 9.2272),
    'erbusco': LatLng(45.5919, 9.9861),
    'faenza': LatLng(44.2858, 11.8822),
    'fermo': LatLng(43.1610, 13.7184),
    'fiano romano': LatLng(42.1664, 12.5969),
    'fiume veneto': LatLng(45.9287, 12.7297),
    'formia': LatLng(41.2585, 13.6062),
    'frosinone': LatLng(41.6395, 13.3411),
    'gadesco pieve delmona': LatLng(45.1611, 10.0917),
    'giussano': LatLng(45.6953, 9.2131),
    'grandate': LatLng(45.7761, 9.0600),
    'gravina di catania': LatLng(37.5619, 15.0608),
    'grugliasco': LatLng(45.0694, 7.5794),
    'guidonia montecelio': LatLng(41.9961, 12.7275),
    'ivrea': LatLng(45.4678, 7.8767),
    'lentate sul seveso': LatLng(45.6811, 9.1231),
    'limbiate': LatLng(45.5989, 9.1283),
    'lonato del garda': LatLng(45.4608, 10.4858),
    'lugo': LatLng(44.4178, 11.9064),
    'lagonegro': LatLng(40.1287, 15.7633),
    'lecce': LatLng(40.3515, 18.1750),
    'macerata': LatLng(43.3003, 13.4533),
    'marcianise': LatLng(41.0317, 14.2989),
    'marcon': LatLng(45.5606, 12.2178),
    'martignacco': LatLng(46.0950, 13.1367),
    'massa': LatLng(44.0358, 10.1417),
    'mazzano': LatLng(45.5200, 10.3667),
    'melilli': LatLng(37.1814, 15.1278),
    'merate': LatLng(45.6989, 9.4217),
    'molfetta': LatLng(41.2003, 16.5969),
    'moncalieri': LatLng(45.0028, 7.6833),
    'mondovi\'': LatLng(44.3892, 7.8256),
    'mondovi': LatLng(44.3892, 7.8256),
    'montano lucino': LatLng(45.7833, 9.0167),
    'montebello della battaglia': LatLng(45.0028, 9.1028),
    'mortara': LatLng(45.2519, 8.7367),
    'mugnano di napoli': LatLng(40.9083, 14.2083),
    'mazara del vallo': LatLng(37.6522, 12.5898),
    'nichelino': LatLng(44.9961, 7.6433),
    'nola': LatLng(40.9256, 14.5294),
    'olbia': LatLng(40.9238, 9.4975),
    'orio al serio': LatLng(45.6692, 9.7042),
    'orvieto': LatLng(42.7186, 12.1128),
    'paderno dugnano': LatLng(45.5714, 9.1678),
    'palazzolo sull\'oglio': LatLng(45.5989, 9.8833),
    'palazzolo sulloglio': LatLng(45.5989, 9.8833),
    'parona': LatLng(45.2819, 8.7619),
    'pavone canavese': LatLng(45.4419, 7.8528),
    'piantedo': LatLng(46.1344, 9.4319),
    'pieve fissiraga': LatLng(45.2639, 9.4447),
    'pinerolo': LatLng(44.8856, 7.3325),
    'piove di sacco': LatLng(45.2975, 11.9767),
    'pompei': LatLng(40.7511, 14.5006),
    'pontecagnano faiano': LatLng(40.6394, 14.8825),
    'portogruaro': LatLng(45.7761, 12.8364),
    'pomezia': LatLng(41.6708, 12.5022),
    'quartucciu': LatLng(39.2522, 9.1764),
    'ragusa': LatLng(36.9269, 14.7258),
    'rescaldina': LatLng(45.6200, 8.9556),
    'rivoli': LatLng(45.0706, 7.5186),
    'roncadelle': LatLng(45.5300, 10.1500),
    'rozzano': LatLng(45.3831, 9.1553),
    'rubano': LatLng(45.4350, 11.7850),
    's.stef.ticino': LatLng(45.4858, 8.9189),
    'san giuliano milanese': LatLng(45.3986, 9.2889),
    'san martino buon albergo': LatLng(45.4222, 11.0989),
    'san martino siccomario': LatLng(45.1561, 9.1417),
    'sanremo': LatLng(43.8159, 7.7761),
    'sant\'angelo lodigiano': LatLng(45.2403, 9.4128),
    'santangelo lodigiano': LatLng(45.2403, 9.4128),
    'sarzana': LatLng(44.1119, 9.9608),
    'savignano sul rubicone': LatLng(44.0903, 12.3967),
    'savona': LatLng(44.3072, 8.4811),
    'senigallia': LatLng(43.7169, 13.2189),
    'seriate': LatLng(45.6847, 9.7214),
    'serravalle rsm': LatLng(43.9689, 12.4775),
    'serravalle scrivia': LatLng(44.7231, 8.8592),
    'sesto san giovanni': LatLng(45.5328, 9.2319),
    'sestu': LatLng(39.2994, 9.0950),
    'solbiate olona': LatLng(45.6514, 8.8872),
    'stezzano': LatLng(45.6517, 9.6531),
    'settimotorinese': LatLng(45.1400, 7.7667),
    'settimo torinese': LatLng(45.1400, 7.7667),
    'taggia': LatLng(43.8436, 7.8486),
    'teramo': LatLng(42.6586, 13.7044),
    'torre annunziata': LatLng(40.7578, 14.4444),
    'tortona': LatLng(44.8967, 8.8661),
    'terni': LatLng(42.5644, 12.6414),
    'turkey': LatLng(38.9637, 35.2433),
    'venaria reale': LatLng(45.1350, 7.6350),
    'vercelli': LatLng(45.3242, 8.4183),
    'vigliano biellese': LatLng(45.5606, 8.1067),
    'vignate': LatLng(45.4961, 9.3739),
    'villasanta': LatLng(45.6033, 9.3039),
    'villesse': LatLng(45.8631, 13.4358),
    'vimodrone': LatLng(45.5153, 9.2858),
    'rieti': LatLng(42.4045, 12.8567),
    'l`aquila': LatLng(42.3489, 13.3980),
    'mazara del vall': LatLng(37.6522, 12.5898),
  };

  @override
  Widget build(BuildContext context) {
    final listEntries = widget.cityCounts.entries.where((e) {
      return e.key.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList()..sort((a, b) => b.value.compareTo(a.value));

    final int maxVal = widget.cityCounts.values.isEmpty 
        ? 1 
        : widget.cityCounts.values.reduce((a, b) => a > b ? a : b);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFF0F172A),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: LatLng(41.8719, 12.5674),
                        initialZoom: 6,
                        maxZoom: 18,
                        minZoom: 3,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                          userAgentPackageName: 'com.skyaudit.app',
                        ),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final pulseValue = _pulseController.value;
                            final markers = widget.cityCounts.entries.map((entry) {
                              final cityName = entry.key;
                              final count = entry.value;
                              final coords = _cityCoordinates[cityName.toLowerCase()];
                              if (coords == null) return null;

                              final isHovered = _hoveredCity == cityName;
                              final isSelected = _selectedCity == cityName;
                              final double relativeSize = maxVal > 0 ? (count / maxVal) : 0.0;
                              final double pinSize = 12.0 + (relativeSize * 16.0);
                              final double pulseMultiplier = 1.3 + (pulseValue * 0.5);
                              final double glowSize = pinSize * (isHovered ? 2.5 : (isSelected ? 2.2 : pulseMultiplier));

                              return Marker(
                                point: coords,
                                width: glowSize + 80,
                                height: glowSize + 40,
                                alignment: Alignment.center,
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  onEnter: (_) => setState(() => _hoveredCity = cityName),
                                  onExit: (_) => setState(() => _hoveredCity = null),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedCity = _selectedCity == cityName ? null : cityName;
                                        _employeeSearchQuery = '';
                                      });
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: glowSize,
                                          height: glowSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: (isSelected 
                                                ? SkyTheme.timBlue 
                                                : (isHovered ? Colors.orange : SkyTheme.timRed))
                                                .withAlpha(isHovered || isSelected ? 70 : 40),
                                          ),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          width: pinSize,
                                          height: pinSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected 
                                                ? SkyTheme.timBlue 
                                                : (isHovered ? Colors.orange : SkyTheme.timRed),
                                            border: Border.all(color: Colors.white, width: 1.5),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isHovered || isSelected || count > (maxVal * 0.3))
                                          Positioned(
                                            top: glowSize - 2,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius: BorderRadius.circular(4),
                                                border: Border.all(color: Colors.white24, width: 0.5),
                                              ),
                                              child: Text(
                                                '$cityName: $count',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).whereType<Marker>().toList();

                            return MarkerLayer(markers: markers);
                          },
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 24,
                    left: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'DISTRIBUZIONE GEOGRAFICA',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Totale sedi tracciate: ${widget.cityCounts.length}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 24,
                    right: 24,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Positioned(
                    right: 24,
                    top: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(_mapController.camera.center, currentZoom + 1);
                            },
                            icon: const Icon(Icons.add, color: SkyTheme.timBlue),
                            tooltip: 'Zoom In',
                          ),
                          const Divider(height: 1, indent: 8, endIndent: 8),
                          IconButton(
                            onPressed: () {
                              final currentZoom = _mapController.camera.zoom;
                              _mapController.move(_mapController.camera.center, currentZoom - 1);
                            },
                            icon: const Icon(Icons.remove, color: SkyTheme.timBlue),
                            tooltip: 'Zoom Out',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedCity != null || _hoveredCity != null)
                    Positioned(
                      bottom: 24,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(80),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: () {
                          final activeCity = _selectedCity ?? _hoveredCity!;
                          final count = widget.cityCounts[activeCity] ?? 0;
                          final double pct = widget.totalCount > 0 ? (count / widget.totalCount) * 100 : 0.0;
                          return Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: SkyTheme.timBlue.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.location_on, color: SkyTheme.timBlue, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    activeCity.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Sede Comune',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$count dipendenti',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${pct.toStringAsFixed(1).replaceAll('.', ',')}% del totale filtrato',
                                    style: TextStyle(
                                      color: Colors.green.shade400,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            width: 380,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade200)),
            ),
            child: _selectedCity != null
                ? () {
                    final cityEmployees = widget.records.where((r) {
                      final matchCity = (r.sedeComune?.trim().toLowerCase() ?? '') == _selectedCity!.toLowerCase();
                      if (!matchCity) return false;
                      if (_employeeSearchQuery.isEmpty) return true;
                      return (r.nominativo?.toLowerCase() ?? '').contains(_employeeSearchQuery.toLowerCase()) ||
                             (r.cid?.toLowerCase() ?? '').contains(_employeeSearchQuery.toLowerCase());
                    }).toList()..sort((a, b) => (a.nominativo ?? '').compareTo(b.nominativo ?? ''));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 20, 16),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: SkyTheme.timBlue),
                                onPressed: () {
                                  setState(() {
                                    _selectedCity = null;
                                    _employeeSearchQuery = '';
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedCity!.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${cityEmployees.length} dipendenti',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            onChanged: (value) => setState(() => _employeeSearchQuery = value),
                            decoration: InputDecoration(
                              hintText: 'Cerca nominativo o CID...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: cityEmployees.isEmpty
                              ? Center(
                                  child: Text(
                                    'Nessun dipendente trovato',
                                    style: TextStyle(color: Colors.grey.shade500),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: cityEmployees.length,
                                  itemBuilder: (context, index) {
                                    final emp = cityEmployees[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          radius: 16,
                                          backgroundColor: SkyTheme.timBlue.withAlpha(20),
                                          child: Text(
                                            emp.nominativo != null && emp.nominativo!.isNotEmpty
                                                ? emp.nominativo!.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
                                                : '?',
                                            style: const TextStyle(
                                              color: SkyTheme.timBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          emp.nominativo ?? '-',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'CID: ${emp.cid ?? "-"} | ${emp.societa ?? "-"}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dettaglio Sedi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              onChanged: (value) => setState(() => _searchQuery = value),
                              decoration: InputDecoration(
                                hintText: 'Cerca comune...',
                                prefixIcon: const Icon(Icons.search, size: 20),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: listEntries.length,
                          itemBuilder: (context, index) {
                            final entry = listEntries[index];
                            final cityName = entry.key;
                            final count = entry.value;
                            final double pct = widget.totalCount > 0 ? (count / widget.totalCount) : 0.0;
                            final hasCoords = _cityCoordinates.containsKey(cityName.toLowerCase());

                            final isSelected = _selectedCity == cityName;

                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected ? SkyTheme.timBlue.withAlpha(15) : null,
                                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                              ),
                              child: ListTile(
                                onTap: () {
                                  setState(() {
                                    _selectedCity = isSelected ? null : cityName;
                                    _employeeSearchQuery = '';
                                  });
                                },
                                leading: Icon(
                                  Icons.location_on_outlined, 
                                  color: hasCoords ? SkyTheme.timBlue : Colors.grey.shade400,
                                  size: 20,
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      cityName,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    if (!hasCoords) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Non mappato', 
                                          style: TextStyle(fontSize: 9, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: Colors.grey.shade100,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isSelected ? SkyTheme.timBlue : SkyTheme.timBlue.withAlpha(180),
                                    ),
                                    minHeight: 4,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$count',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    Text(
                                      '${(pct * 100).toStringAsFixed(1).replaceAll('.', ',')}%',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.grey.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Totale filtrato:',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black54),
                            ),
                            Text(
                              '${widget.totalCount} dipendenti',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
