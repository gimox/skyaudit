import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/scarti_ec_sap_provider.dart';
import 'package:travel_check/features/upload/models/scarti_ec_sap.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/shared/widgets/file_selection_dialog.dart';


// Filter providers for Scarti EC SAP
final scSelectedQueryProvider = StateProvider<String?>((ref) => null);
final scStartDateProvider = StateProvider<DateTime?>((ref) => null);
final scEndDateProvider = StateProvider<DateTime?>((ref) => null);
final scSelectedSpesaProvider = StateProvider<Set<String>>((ref) => {});
final scSortAscendingProvider = StateProvider<bool>((ref) => false);
final scPageProvider = StateProvider<int>((ref) => 0);
final scSelectedLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});
final scSelectedSocietaProvider = StateProvider<Set<String>>((ref) => {});
final scSelectedImportoProvider = StateProvider<String?>((ref) => null);

enum ScartiIncrocioFilter { all, matched, notMatched }
final scIncrocioFilterProvider = StateProvider<ScartiIncrocioFilter>((ref) => ScartiIncrocioFilter.all);

enum ScTrasfertaPresenzaFilter { all, present, notPresent }
final scTrasfertaPresenzaFilterProvider = StateProvider<ScTrasfertaPresenzaFilter>((ref) => ScTrasfertaPresenzaFilter.all);

class ScartiEcView extends ConsumerStatefulWidget {
  const ScartiEcView({super.key});

  @override
  ConsumerState<ScartiEcView> createState() => _ScartiEcViewState();
}

class _ScartiEcViewState extends ConsumerState<ScartiEcView> {
  final _searchController = TextEditingController();
  final _importoController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  final _statsScrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _importoController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    _statsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(scartiEcSapProvider);
    final selectedQuery = ref.watch(scSelectedQueryProvider);
    final startDate = ref.watch(scStartDateProvider);
    final endDate = ref.watch(scEndDateProvider);
    final selectedSpese = ref.watch(scSelectedSpesaProvider);
    final selectedSocieta = ref.watch(scSelectedSocietaProvider);
    final selectedImporto = ref.watch(scSelectedImportoProvider);
    final sortAscending = ref.watch(scSortAscendingProvider);
    final currentPage = ref.watch(scPageProvider);
    final selectedLogHistoryIds = ref.watch(scSelectedLogHistoryIdsProvider);
    final allLogs = ref.watch(logHistoryProvider);
    final logsMap = {for (final log in allLogs) log.uniqueCode: log.fileName};
    String? selectedLogFileName;
    if (selectedLogHistoryIds.length == 1) {
      for (final log in allLogs) {
        if (log.uniqueCode == selectedLogHistoryIds.first) {
          selectedLogFileName = log.fileName;
          break;
        }
      }
    }
    final incrocioFilter = ref.watch(scIncrocioFilterProvider);
    final trasfertaFilter = ref.watch(scTrasfertaPresenzaFilterProvider);
    final contabileRecords = ref.watch(tracciatoContabilesProvider);
    final contabileTrasferte = contabileRecords
        .map((tc) => tc.numeroTrasferta.trim())
        .where((t) => t.isNotEmpty)
        .toSet();
    final allAnagrafica = ref.watch(anagraficaProvider);
    final anagraficaMap = {for (var a in allAnagrafica) (a.cid ?? '').trim().padLeft(8, '0'): (a.nominativo ?? '').trim()};
    final anagraficaSocietaMap = {for (var a in allAnagrafica) (a.cid ?? '').trim().padLeft(8, '0'): (a.societa ?? '').trim()};
    final dictionaries = ref.watch(dictionaryProvider);
    final dictionaryMap = {
      for (final entry in dictionaries) entry.code.trim().toUpperCase(): entry.value,
    };
    const pageSize = 50;

    if (allRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_outlined,
              size: 64,
              color: SkyTheme.timRed.withAlpha(50),
            ),
            const SizedBox(height: 16),
            Text(
              'NESSUN RECORD DI SCARTO TRACCIATO CARICATO',
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
      selectedQuery != null,
      startDate != null,
      endDate != null,
      selectedSpese.isNotEmpty,
      selectedSocieta.isNotEmpty,
      selectedImporto != null,
      incrocioFilter != ScartiIncrocioFilter.all,
      trasfertaFilter != ScTrasfertaPresenzaFilter.all,
      selectedLogHistoryIds.isNotEmpty,
    ].where((e) => e).length;
    
    // Estrai giustificativi di spesa disponibili per il filtro
    final availableSpese = allRecords
        .map((r) => r.spesa)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    
    final availableSocieta = allRecords
        .map((r) => anagraficaSocietaMap[r.cid.trim().padLeft(8, '0')] ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    bool hasMatch(ScartiEcSap rec) {
      return rec.isMatched;
    }

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      if (selectedLogHistoryIds.isNotEmpty && !selectedLogHistoryIds.contains(r.logHistoryId)) return false;
      if (selectedQuery != null) {
        final query = selectedQuery.toLowerCase();
        final nominativo = anagraficaMap[r.cid.trim().padLeft(8, '0')] ?? '';
        if (!r.numeroTrasferta.toLowerCase().contains(query) &&
            !r.cid.toLowerCase().contains(query) &&
            !nominativo.toLowerCase().contains(query) &&
            !r.descrizioneScarto.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Filtro Data Invio
      if (startDate != null || endDate != null) {
        try {
          final parts = r.dataInvio.split('/');
          if (parts.length == 3) {
            final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            if (startDate != null && date.isBefore(startDate)) return false;
            if (endDate != null && date.isAfter(endDate)) return false;
          }
        } catch (_) {
          // Salta il filtro data se il formato è errato
        }
      }
      
      // Filtro Tipo Spesa
      if (selectedSpese.isNotEmpty && !selectedSpese.contains(r.spesa)) return false;
      
      // Filtro Importo
      if (selectedImporto != null) {
        final query = selectedImporto.replaceAll(' ', '').replaceAll(',', '.');
        final importoStr = r.importo.toStringAsFixed(2);
        if (!importoStr.contains(query)) {
          return false;
        }
      }
      
      // Filtro Società
      if (selectedSocieta.isNotEmpty) {
        final companyCode = anagraficaSocietaMap[r.cid.trim().padLeft(8, '0')] ?? '';
        if (!selectedSocieta.contains(companyCode)) return false;
      }
      
      // Filtro Incrocio
      if (incrocioFilter == ScartiIncrocioFilter.matched && !hasMatch(r)) {
        return false;
      }
      if (incrocioFilter == ScartiIncrocioFilter.notMatched && hasMatch(r)) {
        return false;
      }
      
      // Filtro Presenza Trasferta in Tracciato Contabile
      if (trasfertaFilter != ScTrasfertaPresenzaFilter.all) {
        final isPresent = contabileTrasferte.contains(r.numeroTrasferta.trim());
        if (trasfertaFilter == ScTrasfertaPresenzaFilter.present && !isPresent) return false;
        if (trasfertaFilter == ScTrasfertaPresenzaFilter.notPresent && isPresent) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        return sortAscending ? a.cid.compareTo(b.cid) : b.cid.compareTo(a.cid);
      });

    final totalRecords = filteredRecords.length;
    final reconciledRecords = filteredRecords.where(hasMatch).length;
    final waitingRecords = totalRecords - reconciledRecords;

    final totalAmount = filteredRecords.fold<double>(0.0, (sum, r) => sum + r.importo);
    final reconciledAmount = filteredRecords.where(hasMatch).fold<double>(0.0, (sum, r) => sum + r.importo);
    final waitingAmount = filteredRecords.where((r) => !hasMatch(r)).fold<double>(0.0, (sum, r) => sum + r.importo);

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableSpese, availableSocieta, dictionaryMap),
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
                const SizedBox.shrink(),
                // BARRA DI RICERCA & FILTRI
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100, 
                          borderRadius: BorderRadius.circular(12), 
                          border: Border.all(color: Colors.grey.shade200)
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Cerca per trasferta, CID, nominativo o descrizione scarto...', 
                                  border: InputBorder.none, 
                                  isDense: true
                                ),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  ref.read(scSelectedQueryProvider.notifier).state = value.isEmpty ? null : value;
                                  ref.read(scPageProvider.notifier).state = 0;
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
                              side: BorderSide(color: activeFiltersCount > 0 ? SkyTheme.timRed : Colors.grey.shade300),
                              foregroundColor: activeFiltersCount > 0 ? SkyTheme.timRed : Colors.grey.shade700,
                            ),
                          ),
                          if (activeFiltersCount > 0)
                            Positioned(
                              top: -8, right: -8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: SkyTheme.timRed, shape: BoxShape.circle),
                                child: Text('$activeFiltersCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                // CHIP DEI FILTRI ATTIVI
                if (activeFiltersCount > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (selectedQuery != null)
                          _buildFilterChip('Cerca: "$selectedQuery"', () {
                            ref.read(scSelectedQueryProvider.notifier).state = null;
                            _searchController.clear();
                          }),
                        if (selectedImporto != null)
                          _buildFilterChip('Importo: "$selectedImporto"', () {
                            ref.read(scSelectedImportoProvider.notifier).state = null;
                            _importoController.clear();
                          }),
                        if (startDate != null)
                          _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(scStartDateProvider.notifier).state = null),
                        if (endDate != null)
                          _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(scEndDateProvider.notifier).state = null),
                        ...selectedSpese.map((spesa) => _buildFilterChip(spesa, () {
                          final current = ref.read(scSelectedSpesaProvider);
                          final next = Set<String>.from(current)..remove(spesa);
                          ref.read(scSelectedSpesaProvider.notifier).state = next;
                        })),
                        ...selectedSocieta.map((soc) {
                          final label = dictionaryMap[soc.toUpperCase()] ?? soc;
                          return _buildFilterChip(label, () {
                            final current = ref.read(scSelectedSocietaProvider);
                            final next = Set<String>.from(current)..remove(soc);
                            ref.read(scSelectedSocietaProvider.notifier).state = next;
                          });
                        }),
                         if (incrocioFilter != ScartiIncrocioFilter.all)
                          _buildFilterChip(
                            incrocioFilter == ScartiIncrocioFilter.matched
                                ? 'Incrocio: Riscontrati'
                                : 'Incrocio: In attesa',
                            () => ref.read(scIncrocioFilterProvider.notifier).state = ScartiIncrocioFilter.all,
                          ),
                        if (trasfertaFilter != ScTrasfertaPresenzaFilter.all)
                          _buildFilterChip(
                            trasfertaFilter == ScTrasfertaPresenzaFilter.present
                                ? 'Riscontro: Presenti'
                                : 'Riscontro: Non Presenti',
                            () => ref.read(scTrasfertaPresenzaFilterProvider.notifier).state = ScTrasfertaPresenzaFilter.all,
                          ),
                        if (selectedLogHistoryIds.isNotEmpty)
                          _buildFilterChip(
                            selectedLogFileName != null
                                ? 'File: $selectedLogFileName'
                                : 'File: ${selectedLogHistoryIds.length} selezionati',
                            () => ref.read(scSelectedLogHistoryIdsProvider.notifier).state = {},
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
                    title: 'TOTALE RECORD / IMPORTO',
                    value: '$totalRecords',
                    subtitle: 'Importo: ${_formatAmount(totalAmount)}',
                    icon: Icons.folder_open_rounded,
                    color: SkyTheme.timBlue,
                    bgLightColor: SkyTheme.timBlue.withAlpha(20),
                  );
                  final card2 = _buildSummaryCard(
                    title: 'RISCONTRATI / IMPORTO',
                    value: '$reconciledRecords',
                    subtitle: 'Importo: ${_formatAmount(reconciledAmount)}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    bgLightColor: Colors.green.shade50,
                  );
                  final card3 = _buildSummaryCard(
                    title: 'IN ATTESA / IMPORTO',
                    value: '$waitingRecords',
                    subtitle: 'Importo: ${_formatAmount(waitingAmount)}',
                    icon: Icons.help_outline_rounded,
                    color: Colors.orange.shade700,
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
          // TABELLA PRINCIPALE
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
                          width: 1890,
                          child: Column(
                            children: [
                          // INTESTAZIONE TABELLA (HEADER FISSO)
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50, 
                              border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                            ),
                            child: Row(
                              children: [
                                _buildCell('AZIONI', 120, isHeader: true, alignment: Alignment.center),
                                _buildCell('CID', 140, isHeader: true),
                                _buildCell('NOMINATIVO', 200, isHeader: true),
                                _buildCell('SOCIETÀ', 150, isHeader: true),
                                _buildCell('TRASFERTA', 150, isHeader: true),
                                _buildCell('SPESA', 100, isHeader: true),
                                _buildCell('IMPORTO', 120, isHeader: true),
                                _buildCell('DIVISA', 80, isHeader: true),
                                _buildCell('INCROCIO', 120, isHeader: true, alignment: Alignment.center),
                                _buildCell('STORNO', 100, isHeader: true),
                                _buildCell('FILE IMPORTAZIONE', 200, isHeader: true),
                                _buildCell('DATA INVIO', 130, isHeader: true),
                                _buildCell('DESCRIZIONE SCARTO', 280, isHeader: true),
                              ],
                            ),
                          ),
                          // RECORD CONTENUTO (SCROLLABILE)
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: paginatedRecords.length,
                                itemBuilder: (context, index) {
                                  final record = paginatedRecords[index];
                                  final nominativo = anagraficaMap[record.cid.trim().padLeft(8, '0')] ?? '';
                                  final companyCode = anagraficaSocietaMap[record.cid.trim().padLeft(8, '0')] ?? '';
                                  final companyDesc = companyCode.isNotEmpty 
                                      ? (dictionaryMap[companyCode.toUpperCase()] ?? companyCode) 
                                      : '';
                                  final displayCompany = companyDesc.isNotEmpty 
                                      ? (companyCode != companyDesc ? '$companyCode - $companyDesc' : companyCode)
                                      : '-';
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0 ? Colors.white : Colors.grey.shade50.withAlpha(120), 
                                      border: Border(bottom: BorderSide(color: Colors.grey.shade100))
                                    ),
                                    child: Row(
                                      children: [
                                        _buildCell('', 120, alignment: Alignment.center, child: Row(
                                          mainAxisSize: MainAxisSize.min, 
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20), 
                                              onPressed: () => _showRecordDetails(context, record), 
                                              padding: EdgeInsets.zero, 
                                              constraints: const BoxConstraints()
                                            ),
                                            const SizedBox(width: 12),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), 
                                              onPressed: () => _showDeleteDialog(context, ref, record), 
                                              padding: EdgeInsets.zero, 
                                              constraints: const BoxConstraints()
                                            ),
                                          ]
                                        )),
                                        _buildCell(
                                          record.cid,
                                          140,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  record.cid,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(4),
                                                  onTap: () {
                                                    Clipboard.setData(ClipboardData(text: record.cid));
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
                                          nominativo.isNotEmpty ? nominativo : 'Nominativo non trovato',
                                          200,
                                        ),
                                        _buildCell(
                                          displayCompany,
                                          150,
                                        ),
                                        _buildCell(
                                          record.numeroTrasferta,
                                          150,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  record.numeroTrasferta,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: contabileTrasferte.contains(record.numeroTrasferta.trim())
                                                        ? Colors.green.shade800
                                                        : Colors.red.shade700,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius: BorderRadius.circular(4),
                                                  onTap: () {
                                                    Clipboard.setData(ClipboardData(text: record.numeroTrasferta));
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('Trasferta ${record.numeroTrasferta} copiata negli appunti'),
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
                                        _buildCell(record.spesa, 100),
                                        _buildCell(
                                          '${record.importo.toStringAsFixed(2)} €', 
                                          120, 
                                          fontWeight: FontWeight.bold, 
                                          color: record.importo < 0 ? Colors.red.shade700 : Colors.green.shade800
                                        ),
                                        _buildCell(record.divisa, 80),
                                        _buildCell(
                                          '', 
                                          120, 
                                          alignment: Alignment.center,
                                          child: Builder(
                                            builder: (context) {
                                              final matched = hasMatch(record);
                                              return Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: matched ? Colors.green.shade50 : Colors.orange.shade50,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: matched ? Colors.green.shade200 : Colors.orange.shade200),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      matched ? Icons.check : Icons.close,
                                                      size: 12,
                                                      color: matched ? Colors.green.shade700 : Colors.orange.shade700,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      matched ? 'Riscontrato' : 'In attesa',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: matched ? Colors.green.shade800 : Colors.orange.shade800,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          ),
                                        ),
                                        _buildCell(record.storno ?? '-', 100, color: record.storno != null ? Colors.orange.shade800 : null),
                                        _buildCell(record.logHistoryId != null ? (logsMap[record.logHistoryId] ?? '') : '', 200),
                                        _buildCell(record.dataInvio, 130),
                                        _buildCell(record.descrizioneScarto, 280),
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
                        ref.read(scPageProvider.notifier).state--;
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
                        ref.read(scPageProvider.notifier).state++;
                        if (_scrollController.hasClients) {
                          _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      } : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Totale scarti: ${filteredRecords.length}',
                        style: const TextStyle(
                          color: SkyTheme.timRed,
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
    ref.read(scSelectedQueryProvider.notifier).state = null;
    ref.read(scStartDateProvider.notifier).state = null;
    ref.read(scEndDateProvider.notifier).state = null;
    ref.read(scSelectedSpesaProvider.notifier).state = {};
    ref.read(scSelectedSocietaProvider.notifier).state = {};
    ref.read(scSelectedImportoProvider.notifier).state = null;
    ref.read(scIncrocioFilterProvider.notifier).state = ScartiIncrocioFilter.all;
    ref.read(scTrasfertaPresenzaFilterProvider.notifier).state = ScTrasfertaPresenzaFilter.all;
    ref.read(scSelectedLogHistoryIdsProvider.notifier).state = {};
    ref.read(scPageProvider.notifier).state = 0;
    _searchController.clear();
    _importoController.clear();
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InputChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        onDeleted: onDeleted,
        deleteIconColor: Colors.red.shade400,
        backgroundColor: SkyTheme.timRed.withAlpha(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: SkyTheme.timRed.withAlpha(50)),
      ),
    );
  }

  Widget _buildFilterDrawer(
    BuildContext context, 
    WidgetRef ref, 
    List<String> availableSpese,
    List<String> availableSocieta,
    Map<String, String> dictionaryMap,
  ) {
    final allLogs = ref.watch(logHistoryProvider);
    final ecLogs = allLogs.where((log) => log.sourceType == 'Scarti EC SAP').toList();
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
                      'FILTRI SCARTI',
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Filtra gli scarti del Tracciato',
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
                _buildDrawerSectionTitle('PERIODO INVIO SCARTO'),
                const SizedBox(height: 12),
                _buildDatePickerFilter(
                  'Data Inizio',
                  ref.watch(scStartDateProvider),
                  (val) => ref.read(scStartDateProvider.notifier).state = val,
                ),
                const SizedBox(height: 12),
                _buildDatePickerFilter(
                  'Data Fine',
                  ref.watch(scEndDateProvider),
                  (val) => ref.read(scEndDateProvider.notifier).state = val,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('VALORI'),
                const SizedBox(height: 12),
                _buildImportoFilterField(context, ref),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('CATEGORIE DI SPESA'),
                const SizedBox(height: 12),
                _buildChipsMultiSelectFilter(
                  'Giustificativo di spesa',
                  ref.watch(scSelectedSpesaProvider),
                  availableSpese,
                  (val) {
                    final current = ref.read(scSelectedSpesaProvider);
                    final next = Set<String>.from(current);
                    if (next.contains(val)) {
                      next.remove(val);
                    } else {
                      next.add(val);
                    }
                    ref.read(scSelectedSpesaProvider.notifier).state = next;
                  },
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('SOCIETÀ'),
                const SizedBox(height: 12),
                _buildChipsMultiSelectFilter(
                  'Seleziona società',
                  ref.watch(scSelectedSocietaProvider),
                  availableSocieta,
                  (val) {
                    final current = ref.read(scSelectedSocietaProvider);
                    final next = Set<String>.from(current);
                    if (next.contains(val)) {
                      next.remove(val);
                    } else {
                      next.add(val);
                    }
                    ref.read(scSelectedSocietaProvider.notifier).state = next;
                  },
                  icon: Icons.business_outlined,
                  labelMap: dictionaryMap,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('STATO RISCONTRO / INCROCIO'),
                const SizedBox(height: 12),
                _buildChoiceFilter<ScartiIncrocioFilter>(
                  ref.watch(scIncrocioFilterProvider),
                  {
                    ScartiIncrocioFilter.all: 'Tutti',
                    ScartiIncrocioFilter.matched: 'Riscontrati',
                    ScartiIncrocioFilter.notMatched: 'In Attesa',
                  },
                  (val) => ref.read(scIncrocioFilterProvider.notifier).state = val,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('RISCONTRO TRASFERTA IN CONTABILITÀ'),
                const SizedBox(height: 12),
                _buildChoiceFilter<ScTrasfertaPresenzaFilter>(
                  ref.watch(scTrasfertaPresenzaFilterProvider),
                  {
                    ScTrasfertaPresenzaFilter.all: 'Tutte',
                    ScTrasfertaPresenzaFilter.present: 'Presenti',
                    ScTrasfertaPresenzaFilter.notPresent: 'Non Presenti',
                  },
                  (val) => ref.read(scTrasfertaPresenzaFilterProvider.notifier).state = val,
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('FILE CARICATI'),
                const SizedBox(height: 12),
                _buildFileSelectionTrigger(
                  context,
                  'Seleziona File',
                  ref.watch(scSelectedLogHistoryIdsProvider),
                  ecLogs,
                  (next) {
                    ref.read(scSelectedLogHistoryIdsProvider.notifier).state = next;
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
                      side: const BorderSide(color: Colors.red)
                    ), 
                    child: const Text('RESET FILTRI')
                  )
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context), 
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16), 
                      backgroundColor: SkyTheme.timRed, 
                      foregroundColor: Colors.white
                    ), 
                    child: const Text('APPLICA')
                  )
                ),
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
                ref.read(scSelectedImportoProvider.notifier).state = value.isEmpty ? null : value;
                ref.read(scPageProvider.notifier).state = 0;
              },
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
    Map<String, String>? labelMap,
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
            final displayLabel = labelMap != null ? (labelMap[option] ?? option) : option;
            
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
              selectedColor: SkyTheme.timRed,
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? SkyTheme.timRed : Colors.grey.shade300),
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
                      primary: SkyTheme.timRed,
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
                const Icon(Icons.calendar_today, size: 18, color: SkyTheme.timRed),
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
    return Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: SkyTheme.timRed.withAlpha(150), letterSpacing: 1.2));
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
          letterSpacing: isHeader ? 1.0 : null
        ), 
        overflow: TextOverflow.ellipsis
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ScartiEcSap record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Record Scarto'),
        content: const Text('Sei sicuro di voler eliminare permanentemente questo scarto dal database?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULLA')),
          ElevatedButton(
            onPressed: () {
              ref.read(scartiEcSapProvider.notifier).deleteRecord(record.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
                color: isHighlight ? (highlightColor ?? SkyTheme.timRed) : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, ScartiEcSap record) {
    final dictionaries = ref.read(dictionaryProvider);
    final prepagatiMap = {
      for (final d in dictionaries)
        if (d.category == 'giustificativi_prepagati') d.code: d.value
    };

    final logHistories = ref.read(logHistoryProvider);
    final logHistoryMap = {
      for (final log in logHistories) log.uniqueCode: log.fileName,
    };

    final loadingFileName = record.logHistoryId != null ? logHistoryMap[record.logHistoryId] : null;

    final allAnagrafica = ref.read(anagraficaProvider);
    final anagraficaMap = {
      for (var a in allAnagrafica) (a.cid ?? '').trim().padLeft(8, '0'): (a.nominativo ?? '').trim()
    };
    final anagraficaSocietaMap = {
      for (var a in allAnagrafica) (a.cid ?? '').trim().padLeft(8, '0'): (a.societa ?? '').trim()
    };
    final dictMap = {
      for (final d in dictionaries) d.code.trim().toUpperCase(): d.value
    };
    final nominativo = anagraficaMap[record.cid.trim().padLeft(8, '0')] ?? '';
    final cidWithNominativo = nominativo.isNotEmpty ? '${record.cid} - $nominativo' : record.cid;

    final companyCode = anagraficaSocietaMap[record.cid.trim().padLeft(8, '0')] ?? '';
    final companyDesc = companyCode.isNotEmpty 
        ? (dictMap[companyCode.toUpperCase()] ?? companyCode) 
        : '';
    final displayCompany = companyDesc.isNotEmpty 
        ? (companyCode != companyDesc ? '$companyCode - $companyDesc' : companyCode)
        : '-';

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
                // INTESTAZIONE DETTAGLI
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [SkyTheme.timRed, Color(0xFF9E0007)],
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
                        child: const Icon(Icons.warning_amber_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DETTAGLIO SCARTO TRACCIATO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'CID: $cidWithNominativo',
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
                
                // CONTENUTO MODALE
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildDetailSection('Anagrafica & Trasferta', Icons.person_outline, SkyTheme.timRed, [
                          _buildDetailRow('CID', record.cid),
                          _buildDetailRow('Nominativo', nominativo.isNotEmpty ? nominativo : 'Nominativo non trovato'),
                          _buildDetailRow('Società', displayCompany),
                          _buildDetailRow('Numero Trasferta', record.numeroTrasferta),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Dettagli Spesa', Icons.receipt_long_outlined, SkyTheme.timRed, [
                          _buildDetailRow('Giustificativo Spesa', '${record.spesa}${prepagatiMap[record.spesa] != null ? " (${prepagatiMap[record.spesa]})" : ""}'),
                          _buildDetailRow('Data Invio', record.dataInvio),
                          _buildDetailRow('Storno', record.storno ?? 'Nessuno storno'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Anomalia / Scarto', Icons.error_outline, SkyTheme.timRed, [
                          _buildDetailRow('Descrizione Scarto', record.descrizioneScarto),
                          _buildDetailRow(
                            'Importo Scarto', 
                            '${record.importo.toStringAsFixed(2)} ${record.divisa}', 
                            isHighlight: true, 
                            highlightColor: record.importo < 0 ? Colors.red.shade700 : Colors.green.shade800
                          ),
                          _buildDetailRow(
                            'Stato Quadratura', 
                            record.isMatched ? 'RISCONTRATO' : 'IN ATTESA',
                            isHighlight: record.isMatched,
                            highlightColor: record.isMatched ? Colors.green.shade700 : Colors.orange.shade700,
                          ),
                          _buildDetailRow('File Caricamento', loadingFileName ?? '-'),
                          _buildDetailRow('Note Aggiuntive', record.note ?? '-'),
                        ]),
                      ],
                    ),
                  ),
                ),
                
                // AZIONI
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SkyTheme.timRed,
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

  Future<void> _exportToExcel(List<ScartiEcSap> records) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['ScartiEcSap'];
      excel.delete('Sheet1');

      final allLogs = ref.read(logHistoryProvider);
      final logsMap = {for (final log in allLogs) log.uniqueCode: log.fileName};

      final anagrafiche = ref.read(anagraficaProvider);
      final anagraficheMap = {
        for (var a in anagrafiche) (a.cid ?? '').trim().padLeft(8, '0'): (a.nominativo ?? '').trim()
      };
      final anagraficaSocietaMap = {
        for (var a in anagrafiche) (a.cid ?? '').trim().padLeft(8, '0'): (a.societa ?? '').trim()
      };
      final dictionaries = ref.read(dictionaryProvider);
      final dictMap = {
        for (final entry in dictionaries) entry.code.trim().toUpperCase(): entry.value
      };

      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('CID'),
        TextCellValue('Nominativo'),
        TextCellValue('Società'),
        TextCellValue('Numero Trasferta'),
        TextCellValue('Descrizione Scarto'),
        TextCellValue('Spesa'),
        TextCellValue('Importo'),
        TextCellValue('Divisa'),
        TextCellValue('Storno'),
        TextCellValue('File Importazione'),
        TextCellValue('Data Invio'),
        TextCellValue('Note'),
        TextCellValue('Incrocio (SI/NO)'),
      ]);

      for (final r in records) {
        final nominativo = anagraficheMap[r.cid.trim().padLeft(8, '0')] ?? '';
        final companyCode = anagraficaSocietaMap[r.cid.trim().padLeft(8, '0')] ?? '';
        final companyDesc = companyCode.isNotEmpty 
            ? (dictMap[companyCode.toUpperCase()] ?? companyCode) 
            : '';
        final displayCompany = companyDesc.isNotEmpty 
            ? (companyCode != companyDesc ? '$companyCode - $companyDesc' : companyCode)
            : '-';

        sheet.appendRow([
          IntCellValue(r.id),
          TextCellValue(r.cid),
          TextCellValue(nominativo),
          TextCellValue(displayCompany),
          TextCellValue(r.numeroTrasferta),
          TextCellValue(r.descrizioneScarto),
          TextCellValue(r.spesa),
          DoubleCellValue(r.importo),
          TextCellValue(r.divisa),
          TextCellValue(r.storno ?? ''),
          TextCellValue(r.logHistoryId != null ? (logsMap[r.logHistoryId] ?? '') : ''),
          TextCellValue(r.dataInvio),
          TextCellValue(r.note ?? ''),
          TextCellValue(r.isMatched ? 'SI' : 'NO'),
        ]);
      }

      // STILI
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

      const colCount = 13;
      for (var col = 0; col < colCount; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }
      sheet.setRowHeight(0, 30);

      int rowIndex = 1;
      for (final r in records) {
        sheet.setRowHeight(rowIndex, 22);
        final isMatched = r.isMatched;
        final rowStyle = isMatched ? matchedStyle : waitingStyle;
        final centerStyle = isMatched ? matchedCenterStyle : waitingCenterStyle;
        final amountStyle = isMatched ? matchedAmountStyle : waitingAmountStyle;

        for (var col = 0; col < colCount; col++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
          if (col == 7) { // Importo
            cell.cellStyle = amountStyle;
          } else if (col == 0 || col == 1 || col == 4 || col == 8 || col == 10 || col == 12) { // ID, CID, Trasferta, Divisa, Data Invio, Incrocio
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
        dialogTitle: 'Salva Export Excel Scarti',
        fileName: 'export_scarti_ec_sap_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(fileBytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Esportazione scarti completata con successo!'),
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
}
