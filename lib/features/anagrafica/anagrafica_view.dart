import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

    final totalUsers = filteredByFileRecords.length;
    final validAges = filteredByFileRecords.map((e) => _parseAge(e.dataNascita)).whereType<int>().toList();
    final double averageAge = validAges.isEmpty ? 0.0 : validAges.reduce((a, b) => a + b) / validAges.length;

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
    return double.tryParse(cleaned);
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
}
