import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/trasferte_sap_provider.dart';
import 'package:travel_check/features/upload/models/trasferte_sap.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/shared/widgets/file_selection_dialog.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';

// Filter providers for Trasferte SAP
final tsSelectedQueryProvider = StateProvider<String?>((ref) => null);
final tsStartDateProvider = StateProvider<DateTime?>((ref) => null);
final tsEndDateProvider = StateProvider<DateTime?>((ref) => null);
final tsSortAscendingProvider = StateProvider<bool>((ref) => false);
final tsPageProvider = StateProvider<int>((ref) => 0);
final tsSelectedLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});
final tsSelectedContabileLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});
final tsSelectedSocietaProvider = StateProvider<Set<String>>((ref) => {});
final tsSelectedTrasferteCodesProvider = StateProvider<Set<String>?>((ref) => null);

class TrasferteSapView extends ConsumerStatefulWidget {
  const TrasferteSapView({super.key});

  @override
  ConsumerState<TrasferteSapView> createState() => _TrasferteSapViewState();
}

class _TrasferteSapViewState extends ConsumerState<TrasferteSapView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  final _statsScrollController = ScrollController();

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
    final allRecords = ref.watch(trasferteSapProvider);
    final selectedQuery = ref.watch(tsSelectedQueryProvider);
    final startDate = ref.watch(tsStartDateProvider);
    final endDate = ref.watch(tsEndDateProvider);
    final sortAscending = ref.watch(tsSortAscendingProvider);
    final currentPage = ref.watch(tsPageProvider);
    final selectedLogHistoryIds = ref.watch(tsSelectedLogHistoryIdsProvider);
    final selectedContabileLogHistoryIds = ref.watch(tsSelectedContabileLogHistoryIdsProvider);
    final selectedSocieta = ref.watch(tsSelectedSocietaProvider);
    final selectedTrasferteCodes = ref.watch(tsSelectedTrasferteCodesProvider);
    final allLogs = ref.watch(logHistoryProvider);
    final contabileRecords = ref.watch(tracciatoContabilesProvider);
    final allAnagrafica = ref.watch(anagraficaProvider);
    final dictionaries = ref.watch(dictionaryProvider);
    final dictionaryMap = {for (var d in dictionaries) d.code.trim().toUpperCase(): d.value.trim()};

    final anagraficaSocietaMap = {
      for (var a in allAnagrafica)
        if (a.cid != null && a.societa != null)
          (a.cid ?? '').trim().padLeft(8, '0'): (a.societa ?? '').trim()
    };

    final anagraficaMap = {
      for (var a in allAnagrafica)
        if (a.cid != null)
          (a.cid ?? '').trim().padLeft(8, '0'): (a.nominativo ?? '').trim()
    };

    final contabileSocietaMap = {
      for (var tc in contabileRecords)
        if (tc.numeroTrasferta.trim().isNotEmpty && tc.societa.trim().isNotEmpty)
          tc.numeroTrasferta.trim(): tc.societa.trim()
    };

    final filteredContabileRecords = selectedContabileLogHistoryIds.isEmpty
        ? contabileRecords
        : contabileRecords.where((tc) => selectedContabileLogHistoryIds.contains(tc.logHistoryId)).toList();

    final contabileTrasferte = filteredContabileRecords
        .map((tc) => tc.numeroTrasferta.trim())
        .where((t) => t.isNotEmpty)
        .toSet();

    String? selectedLogFileName;
    if (selectedLogHistoryIds.length == 1) {
      for (final log in allLogs) {
        if (log.uniqueCode == selectedLogHistoryIds.first) {
          selectedLogFileName = log.fileName;
          break;
        }
      }
    }

    const pageSize = 50;

    if (allRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flight_takeoff_outlined,
              size: 64,
              color: SkyTheme.timRed.withAlpha(50),
            ),
            const SizedBox(height: 16),
            Text(
              'NESSUN RECORD DI TRASFERTA SAP CARICATO',
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
      selectedTrasferteCodes != null && selectedTrasferteCodes.isNotEmpty,
      startDate != null,
      endDate != null,
      selectedLogHistoryIds.isNotEmpty,
      selectedContabileLogHistoryIds.isNotEmpty,
      selectedSocieta.isNotEmpty,
    ].where((e) => e).length;

    // Calcolo statistiche generali
    final totalRecords = allRecords.length;

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      if (selectedTrasferteCodes != null && selectedTrasferteCodes.isNotEmpty && !selectedTrasferteCodes.contains(r.numeroTrasferta.trim())) {
        return false;
      }
      if (selectedLogHistoryIds.isNotEmpty && !selectedLogHistoryIds.contains(r.logHistoryId)) return false;
      if (selectedSocieta.isNotEmpty) {
        final rSocieta = contabileSocietaMap[r.numeroTrasferta.trim()] ?? anagraficaSocietaMap[r.cid.trim().padLeft(8, '0')] ?? '';
        if (!selectedSocieta.contains(rSocieta)) return false;
      }
      if (selectedQuery != null) {
        final query = selectedQuery.toLowerCase();
        final nominativo = (anagraficaMap[r.cid.trim().padLeft(8, '0')] ?? '').toLowerCase();
        if (!r.numeroTrasferta.toLowerCase().contains(query) &&
            !r.cid.toLowerCase().contains(query) &&
            !nominativo.contains(query)) {
          return false;
        }
      }
      
      // Filtro Data Inizio Trasferta
      if (startDate != null || endDate != null) {
        try {
          final parts = r.dataInizioTrasferta.split('/');
          if (parts.length == 3) {
            final date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            if (startDate != null && date.isBefore(startDate)) return false;
            if (endDate != null && date.isAfter(endDate)) return false;
          }
        } catch (_) {
          // Salta il filtro data se il formato è errato
        }
      }
      
      return true;
    }).toList()
      ..sort((a, b) {
        return sortAscending 
            ? a.numeroTrasferta.compareTo(b.numeroTrasferta) 
            : b.numeroTrasferta.compareTo(a.numeroTrasferta);
      });

    final totalFiltered = filteredRecords.length;
    final okRecordsCount = filteredRecords.where((r) => contabileTrasferte.contains(r.numeroTrasferta.trim())).length;
    final koRecordsCount = totalFiltered - okRecordsCount;
    final uniqueCids = filteredRecords.map((r) => r.cid).where((c) => c.isNotEmpty).toSet().length;

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref),
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
          // HEADER DI RICERCA E FILTRI
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
                                  hintText: 'Cerca per trasferta, CID o nominativo...', 
                                  border: InputBorder.none, 
                                  isDense: true
                                ),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  ref.read(tsSelectedQueryProvider.notifier).state = value.isEmpty ? null : value;
                                  ref.read(tsPageProvider.notifier).state = 0;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showBatchVerificationDialog(context),
                      icon: const Icon(Icons.checklist_rounded, size: 20),
                      label: const Text('Verifica Codici'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                          color: (selectedTrasferteCodes != null && selectedTrasferteCodes.isNotEmpty)
                              ? SkyTheme.timRed
                              : SkyTheme.timBlue,
                        ),
                        foregroundColor: (selectedTrasferteCodes != null && selectedTrasferteCodes.isNotEmpty)
                            ? SkyTheme.timRed
                            : SkyTheme.timBlue,
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
                // FILTRI ATTIVI CHIPS
                if (activeFiltersCount > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        if (selectedQuery != null)
                          _buildFilterChip('Cerca: "$selectedQuery"', () {
                            ref.read(tsSelectedQueryProvider.notifier).state = null;
                            _searchController.clear();
                          }),
                        if (selectedTrasferteCodes != null && selectedTrasferteCodes.isNotEmpty)
                          _buildFilterChip(
                            'Verifica codici: ${selectedTrasferteCodes.length}',
                            () => ref.read(tsSelectedTrasferteCodesProvider.notifier).state = null,
                          ),
                        if (startDate != null)
                          _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(tsStartDateProvider.notifier).state = null),
                        if (endDate != null)
                          _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(tsEndDateProvider.notifier).state = null),
                        if (selectedLogHistoryIds.isNotEmpty)
                          _buildFilterChip(
                            selectedLogFileName != null
                                ? 'File: $selectedLogFileName'
                                : 'File: ${selectedLogHistoryIds.length} selezionati',
                            () => ref.read(tsSelectedLogHistoryIdsProvider.notifier).state = {},
                          ),
                        if (selectedContabileLogHistoryIds.isNotEmpty)
                          Builder(
                            builder: (context) {
                              String name = 'Tracciati: ${selectedContabileLogHistoryIds.length} selezionati';
                              if (selectedContabileLogHistoryIds.length == 1) {
                                final matching = allLogs.where((l) => l.uniqueCode == selectedContabileLogHistoryIds.first);
                                if (matching.isNotEmpty) {
                                  name = 'Tracciato: ${matching.first.fileName}';
                                }
                              }
                              return _buildFilterChip(
                                name,
                                () => ref.read(tsSelectedContabileLogHistoryIdsProvider.notifier).state = {},
                              );
                            },
                          ),
                        if (selectedSocieta.isNotEmpty)
                          _buildFilterChip(
                            'Società: ${selectedSocieta.map((s) => dictionaryMap[s.toUpperCase()] != null ? "$s (${dictionaryMap[s.toUpperCase()]})" : s).join(", ")}',
                            () => ref.read(tsSelectedSocietaProvider.notifier).state = {},
                          ),
                        TextButton(
                          onPressed: () => _resetAllFilters(ref), 
                          child: const Text('Reset tutto', style: TextStyle(fontSize: 12, color: Colors.red))
                        ),
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
                    value: '$totalFiltered',
                    subtitle: 'Dipendenti: $uniqueCids (Tot: $totalRecords)',
                    icon: Icons.flight_takeoff_rounded,
                    color: SkyTheme.timBlue,
                    bgLightColor: SkyTheme.timBlue.withAlpha(20),
                  );
                  final card2 = _buildSummaryCard(
                    title: 'RISCONTRATE (OK)',
                    value: '$okRecordsCount',
                    subtitle: 'Numero trasferta trovato',
                    icon: Icons.check_circle_outline,
                    color: Colors.green.shade700,
                    bgLightColor: Colors.green.shade50,
                  );
                  final card3 = _buildSummaryCard(
                    title: 'NON RISCONTRATE (KO)',
                    value: '$koRecordsCount',
                    subtitle: 'Numero trasferta non trovato',
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
          // TABELLA
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
                          width: 1400,
                          child: Column(
                            children: [
                              Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50, 
                                  border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                ),
                                child: Row(
                                  children: [
                                    _buildCell('AZIONI', 120, isHeader: true, alignment: Alignment.center),
                                    _buildCell('CID DIPENDENTE', 150, isHeader: true),
                                    _buildCell('NOMINATIVO', 220, isHeader: true),
                                    _buildCell('SOCIETÀ', 160, isHeader: true),
                                    _buildCell('NUMERO TRASFERTA', 180, isHeader: true),
                                    _buildCell('DATA INIZIO', 160, isHeader: true),
                                    _buildCell('ORA INIZIO', 120, isHeader: true),
                                    _buildCell('DATA FINE', 160, isHeader: true),
                                    _buildCell('ORA FINE', 120, isHeader: true),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: paginatedRecords.length,
                                    itemBuilder: (context, index) {
                                      final record = paginatedRecords[index];
                                      final rSocieta = contabileSocietaMap[record.numeroTrasferta.trim()] ?? anagraficaSocietaMap[record.cid.trim().padLeft(8, '0')] ?? '-';
                                      final displaySocieta = rSocieta != '-' && dictionaryMap[rSocieta.toUpperCase()] != null 
                                          ? '$rSocieta (${dictionaryMap[rSocieta.toUpperCase()]})' 
                                          : rSocieta;

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
                                              150,
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
                                                            content: Text('CID ${record.cid} copiato'),
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
                                              anagraficaMap[record.cid.trim().padLeft(8, '0')] ?? '',
                                              220,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            _buildCell(
                                              displaySocieta,
                                              160,
                                              color: rSocieta != '-' ? SkyTheme.timBlue : Colors.grey,
                                              fontWeight: rSocieta != '-' ? FontWeight.bold : FontWeight.normal,
                                            ),
                                            _buildCell(
                                              record.numeroTrasferta,
                                              180,
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
                                                            content: Text('Trasferta ${record.numeroTrasferta} copiata'),
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
                                            _buildCell(record.dataInizioTrasferta, 160),
                                            _buildCell(record.oraInizioTrasferta, 120),
                                            _buildCell(record.dataFineTrasferta, 160),
                                            _buildCell(record.oraFineTrasferta, 120),
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
                        ref.read(tsPageProvider.notifier).state--;
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
                        ref.read(tsPageProvider.notifier).state++;
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
    ref.read(tsSelectedQueryProvider.notifier).state = null;
    ref.read(tsSelectedTrasferteCodesProvider.notifier).state = null;
    ref.read(tsStartDateProvider.notifier).state = null;
    ref.read(tsEndDateProvider.notifier).state = null;
    ref.read(tsSelectedLogHistoryIdsProvider.notifier).state = {};
    ref.read(tsSelectedContabileLogHistoryIdsProvider.notifier).state = {};
    ref.read(tsSelectedSocietaProvider.notifier).state = {};
    ref.read(tsPageProvider.notifier).state = 0;
    _searchController.clear();
  }

  void _showBatchVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _BatchVerificationDialog(),
    );
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

  Widget _buildFilterDrawer(BuildContext context, WidgetRef ref) {
    final allLogs = ref.watch(logHistoryProvider);
    final sapLogs = allLogs.where((log) => log.sourceType == 'Trasferte SAP').toList();
    final contabileLogs = allLogs.where((log) => log.sourceType == 'Tracciato Contabile' || log.sourceType == 'contabile').toList();
    
    final allRecords = ref.watch(trasferteSapProvider);
    final allAnagrafica = ref.watch(anagraficaProvider);
    final contabileRecords = ref.watch(tracciatoContabilesProvider);
    final dictionaries = ref.watch(dictionaryProvider);
    final dictionaryMap = {for (var d in dictionaries) d.code.trim().toUpperCase(): d.value.trim()};

    final anagraficaSocietaMap = {
      for (var a in allAnagrafica)
        if (a.cid != null && a.societa != null)
          (a.cid ?? '').trim().padLeft(8, '0'): (a.societa ?? '').trim()
    };

    final contabileSocietaMap = {
      for (var tc in contabileRecords)
        if (tc.numeroTrasferta.trim().isNotEmpty && tc.societa.trim().isNotEmpty)
          tc.numeroTrasferta.trim(): tc.societa.trim()
    };

    final availableSocietaSet = <String>{};
    for (final r in allRecords) {
      final soc = contabileSocietaMap[r.numeroTrasferta.trim()] ?? anagraficaSocietaMap[r.cid.trim().padLeft(8, '0')];
      if (soc != null && soc.isNotEmpty) {
        availableSocietaSet.add(soc);
      }
    }
    if (availableSocietaSet.isEmpty) {
      availableSocietaSet.addAll(anagraficaSocietaMap.values.where((s) => s.isNotEmpty));
      availableSocietaSet.addAll(contabileSocietaMap.values.where((s) => s.isNotEmpty));
    }
    final availableSocieta = availableSocietaSet.toList()..sort();

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
                  child: const Icon(Icons.filter_list_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                const Text(
                  'FILTRI TRASFERTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDrawerSectionTitle('Intervallo Data Inizio'),
                  const SizedBox(height: 12),
                  _buildDatePickerRow(
                    label: 'Da',
                    selectedDate: ref.watch(tsStartDateProvider),
                    onChanged: (date) {
                      ref.read(tsStartDateProvider.notifier).state = date;
                      ref.read(tsPageProvider.notifier).state = 0;
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDatePickerRow(
                    label: 'A',
                    selectedDate: ref.watch(tsEndDateProvider),
                    onChanged: (date) {
                      ref.read(tsEndDateProvider.notifier).state = date;
                      ref.read(tsPageProvider.notifier).state = 0;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildDrawerSectionTitle('SOCIETÀ'),
                  const SizedBox(height: 12),
                  _buildMultiSelectFilter(
                    'Società',
                    ref.watch(tsSelectedSocietaProvider),
                    availableSocieta,
                    (next) {
                      ref.read(tsSelectedSocietaProvider.notifier).state = next;
                      ref.read(tsPageProvider.notifier).state = 0;
                    },
                    icon: Icons.business,
                    dictionary: dictionaryMap,
                  ),
                  const SizedBox(height: 24),
                  _buildDrawerSectionTitle('FILE TRASFERTE SAP'),
                  const SizedBox(height: 12),
                  _buildFileSelectionTrigger(
                    context,
                    'Seleziona File',
                    ref.watch(tsSelectedLogHistoryIdsProvider),
                    sapLogs,
                    (next) {
                      ref.read(tsSelectedLogHistoryIdsProvider.notifier).state = next;
                      ref.read(tsPageProvider.notifier).state = 0;
                    },
                    icon: Icons.insert_drive_file_outlined,
                  ),
                  const SizedBox(height: 24),
                  _buildDrawerSectionTitle('FILE TRACCIATO CONTABILE'),
                  const SizedBox(height: 12),
                  _buildFileSelectionTrigger(
                    context,
                    'Seleziona File Tracciato',
                    ref.watch(tsSelectedContabileLogHistoryIdsProvider),
                    contabileLogs,
                    (next) {
                      ref.read(tsSelectedContabileLogHistoryIdsProvider.notifier).state = next;
                      ref.read(tsPageProvider.notifier).state = 0;
                    },
                    icon: Icons.insert_drive_file_outlined,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _resetAllFilters(ref);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SkyTheme.timRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Applica'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerRow({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime?> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(width: 40, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
        Expanded(
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (picked != null) onChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
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

  void _showDeleteDialog(BuildContext context, WidgetRef ref, TrasferteSap record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Trasferta'),
        content: const Text('Sei sicuro di voler eliminare permanentemente questa trasferta dal database?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULLA')),
          ElevatedButton(
            onPressed: () {
              ref.read(trasferteSapProvider.notifier).deleteRecord(record.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ELIMINA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, TrasferteSap record) {
    final logHistories = ref.read(logHistoryProvider);
    final logHistoryMap = {
      for (final log in logHistories) log.uniqueCode: log.fileName,
    };

    final anagrafiche = ref.read(anagraficaProvider);
    final anagraficaMap = {
      for (final a in anagrafiche)
        if (a.cid != null) a.cid!.trim().padLeft(8, '0'): a.nominativo
    };

    final nominativo = anagraficaMap[record.cid.trim().padLeft(8, '0')] ?? 'Dipendente Sconosciuto';
    final fileName = logHistoryMap[record.logHistoryId] ?? 'Caricamento Manuale';

    final contabileRecords = ref.read(tracciatoContabilesProvider);
    final contabileSocietaMap = {
      for (var tc in contabileRecords)
        if (tc.numeroTrasferta.trim().isNotEmpty && tc.societa.trim().isNotEmpty)
          tc.numeroTrasferta.trim(): tc.societa.trim()
    };
    final allAnagrafica = ref.read(anagraficaProvider);
    final anagraficaSocietaMap = {
      for (var a in allAnagrafica)
        if (a.cid != null && a.societa != null)
          (a.cid ?? '').trim().padLeft(8, '0'): (a.societa ?? '').trim()
    };
    final dictionaries = ref.read(dictionaryProvider);
    final dictionaryMap = {for (var d in dictionaries) d.code.trim().toUpperCase(): d.value.trim()};

    final rSocieta = contabileSocietaMap[record.numeroTrasferta.trim()] ?? anagraficaSocietaMap[record.cid.trim().padLeft(8, '0')] ?? '-';
    final displaySocieta = rSocieta != '-' && dictionaryMap[rSocieta.toUpperCase()] != null 
        ? '$rSocieta (${dictionaryMap[rSocieta.toUpperCase()]})' 
        : rSocieta;

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
                        child: const Icon(Icons.flight_takeoff_outlined, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'DETTAGLIO TRASFERTA SAP',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white70, letterSpacing: 1.5),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Trasferta #${record.numeroTrasferta}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          _buildDetailSection('Informazioni Dipendente', Icons.person_outline, SkyTheme.timBlue, [
                            _buildDetailRow('CID Dipendente', record.cid),
                            _buildDetailRow('Nominativo', nominativo),
                            _buildDetailRow('Società', displaySocieta),
                          ]),
                          const SizedBox(height: 20),
                          _buildDetailSection('Periodo Trasferta', Icons.calendar_month_outlined, Colors.green, [
                            _buildDetailRow('Data Inizio', record.dataInizioTrasferta),
                            _buildDetailRow('Ora Inizio', record.oraInizioTrasferta),
                            _buildDetailRow('Data Fine', record.dataFineTrasferta),
                            _buildDetailRow('Ora Fine', record.oraFineTrasferta),
                          ]),
                          const SizedBox(height: 20),
                          _buildDetailSection('Meta-Dati Importazione', Icons.source_outlined, Colors.orange, [
                            _buildDetailRow('File Sorgente', fileName),
                            _buildDetailRow('ID Import', record.logHistoryId ?? 'N/D'),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  color: Colors.grey.shade100,
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SkyTheme.timRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Chiudi'),
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
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? '-' : value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 14),
            ),
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

  Future<void> _exportToExcel(List<TrasferteSap> records) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['TrasferteSap'];
      excel.delete('Sheet1'); // Rimuovi default sheet

      final contabileRecords = ref.read(tracciatoContabilesProvider);
      final contabileSocietaMap = {
        for (var tc in contabileRecords)
          if (tc.numeroTrasferta.trim().isNotEmpty && tc.societa.trim().isNotEmpty)
            tc.numeroTrasferta.trim(): tc.societa.trim()
      };
      final allAnagrafica = ref.read(anagraficaProvider);
      final anagraficaSocietaMap = {
        for (var a in allAnagrafica)
          if (a.cid != null && a.societa != null)
            (a.cid ?? '').trim().padLeft(8, '0'): (a.societa ?? '').trim()
      };
      final anagraficaMap = {
        for (var a in allAnagrafica)
          if (a.cid != null)
            (a.cid ?? '').trim().padLeft(8, '0'): (a.nominativo ?? '').trim()
      };
      final dictionaries = ref.read(dictionaryProvider);
      final dictionaryMap = {for (var d in dictionaries) d.code.trim().toUpperCase(): d.value.trim()};

      // Header
      sheet.appendRow([
        TextCellValue('CID'),
        TextCellValue('Nominativo'),
        TextCellValue('Società'),
        TextCellValue('Numero Trasferta'),
        TextCellValue('Data Inizio'),
        TextCellValue('Ora Inizio'),
        TextCellValue('Data Fine'),
        TextCellValue('Ora Fine'),
      ]);

      // Rows
      for (final r in records) {
        final rSocieta = contabileSocietaMap[r.numeroTrasferta.trim()] ?? anagraficaSocietaMap[r.cid.trim().padLeft(8, '0')] ?? '-';
        final displaySocieta = rSocieta != '-' && dictionaryMap[rSocieta.toUpperCase()] != null 
            ? '$rSocieta (${dictionaryMap[rSocieta.toUpperCase()]})' 
            : rSocieta;

        sheet.appendRow([
          TextCellValue(r.cid),
          TextCellValue(anagraficaMap[r.cid.trim().padLeft(8, '0')] ?? ''),
          TextCellValue(displaySocieta),
          TextCellValue(r.numeroTrasferta),
          TextCellValue(r.dataInizioTrasferta),
          TextCellValue(r.oraInizioTrasferta),
          TextCellValue(r.dataFineTrasferta),
          TextCellValue(r.oraFineTrasferta),
        ]);
      }

      // Salva
      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva Export Excel Trasferte SAP',
        fileName: 'export_trasferte_sap_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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

  Widget _buildMultiSelectFilter(
    String label,
    Set<String> selectedValues,
    List<String> options,
    Function(Set<String>) onChanged, {
    IconData? icon,
    Map<String, String>? dictionary,
  }) {
    final selectedCount = selectedValues.length;
    String displayText = 'Tutte le società';
    if (selectedCount == 1) {
      final val = selectedValues.first;
      displayText = dictionary != null && dictionary[val] != null
          ? '$val - ${dictionary[val]}'
          : val;
    } else if (selectedCount > 1) {
      displayText = '$selectedCount società selezionate';
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
                        width: 350,
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
                              child: options.isEmpty
                                  ? const Center(child: Text('Nessuna società disponibile'))
                                  : ListView.builder(
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final option = options[index];
                                        final displayLabel = dictionary != null && dictionary[option] != null
                                            ? '$option - ${dictionary[option]}'
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
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('ANNULLA'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, tempSelected),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SkyTheme.timRed,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('CONFERMA'),
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
}

class _VerificationItem {
  final String code;
  final bool isPresent;
  final TrasferteSap? record;
  final String? nominativo;
  final String? societa;

  _VerificationItem({
    required this.code,
    required this.isPresent,
    this.record,
    this.nominativo,
    this.societa,
  });
}

class _BatchVerificationDialog extends ConsumerStatefulWidget {
  const _BatchVerificationDialog();

  @override
  ConsumerState<_BatchVerificationDialog> createState() => _BatchVerificationDialogState();
}

class _BatchVerificationDialogState extends ConsumerState<_BatchVerificationDialog> {
  final _inputController = TextEditingController();
  final _searchFilterController = TextEditingController();
  bool _hasResults = false;
  List<_VerificationItem> _items = [];
  String _selectedTab = 'all'; // 'all', 'missing', 'present'
  int _detectedInputCount = 0;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_updateInputCount);
  }

  @override
  void dispose() {
    _inputController.removeListener(_updateInputCount);
    _inputController.dispose();
    _searchFilterController.dispose();
    super.dispose();
  }

  void _updateInputCount() {
    final count = _extractCodes(_inputController.text).length;
    if (count != _detectedInputCount) {
      setState(() {
        _detectedInputCount = count;
      });
    }
  }

  List<String> _extractCodes(String text) {
    final tokens = text.split(RegExp(r'[\r\n\t,;\s]+'));
    final unique = <String>[];
    final seen = <String>{};
    for (final raw in tokens) {
      final c = raw.trim();
      if (c.isNotEmpty && seen.add(c)) {
        unique.add(c);
      }
    }
    return unique;
  }

  void _runVerification() {
    final codes = _extractCodes(_inputController.text);
    if (codes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inserisci almeno un codice trasferta da verificare.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final allTs = ref.read(trasferteSapProvider);
    final mapByCode = <String, TrasferteSap>{};
    for (final t in allTs) {
      mapByCode[t.numeroTrasferta.trim()] = t;
    }

    final allAnagrafica = ref.read(anagraficaProvider);
    final anagraficaMap = {
      for (var a in allAnagrafica)
        if (a.cid != null) a.cid!.trim().padLeft(8, '0'): (a.nominativo ?? '').trim()
    };
    final anagraficaSocietaMap = {
      for (var a in allAnagrafica)
        if (a.cid != null && a.societa != null) a.cid!.trim().padLeft(8, '0'): a.societa!.trim()
    };
    final contabileRecords = ref.read(tracciatoContabilesProvider);
    final contabileSocietaMap = {
      for (var tc in contabileRecords)
        if (tc.numeroTrasferta.trim().isNotEmpty && tc.societa.trim().isNotEmpty)
          tc.numeroTrasferta.trim(): tc.societa.trim()
    };

    final results = <_VerificationItem>[];
    for (final code in codes) {
      final rec = mapByCode[code];
      if (rec != null) {
        final cidPadded = rec.cid.trim().padLeft(8, '0');
        final nom = anagraficaMap[cidPadded];
        final soc = contabileSocietaMap[code] ?? anagraficaSocietaMap[cidPadded];
        results.add(_VerificationItem(
          code: code,
          isPresent: true,
          record: rec,
          nominativo: (nom != null && nom.isNotEmpty) ? nom : null,
          societa: (soc != null && soc.isNotEmpty) ? soc : null,
        ));
      } else {
        results.add(_VerificationItem(
          code: code,
          isPresent: false,
        ));
      }
    }

    setState(() {
      _items = results;
      _hasResults = true;
      _selectedTab = 'all';
      _searchFilterController.clear();
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        if (_inputController.text.trim().isEmpty) {
          _inputController.text = data.text!;
        } else {
          _inputController.text = '${_inputController.text}\n${data.text!}';
        }
      });
    }
  }

  Future<void> _loadFromFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'csv'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content = '';
        if (file.bytes != null) {
          content = utf8.decode(file.bytes!);
        } else if (!kIsWeb && file.path != null) {
          content = await File(file.path!).readAsString();
        }
        if (content.isNotEmpty) {
          setState(() {
            _inputController.text = content;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore lettura file: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _copyMissingToClipboard() {
    final missing = _items.where((i) => !i.isPresent).map((i) => i.code).toList();
    if (missing.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessun codice mancante da copiare!'), backgroundColor: Colors.blue),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: missing.join('\n')));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${missing.length} codici NON presenti copiati negli appunti.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _copyAllToClipboard() {
    if (_items.isEmpty) return;
    final buffer = StringBuffer();
    buffer.writeln('Codice Trasferta\tEsito\tCID\tDipendente\tSocietà\tData Inizio\tData Fine');
    for (final item in _items) {
      if (item.isPresent && item.record != null) {
        buffer.writeln(
          '${item.code}\tPRESENTE\t${item.record!.cid}\t${item.nominativo ?? ''}\t${item.societa ?? ''}\t${item.record!.dataInizioTrasferta}\t${item.record!.dataFineTrasferta}',
        );
      } else {
        buffer.writeln('${item.code}\tNON PRESENTE\t-\t-\t-\t-\t-');
      }
    }
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report completo copiato negli appunti.'), backgroundColor: Colors.green),
    );
  }

  Future<void> _exportResultsToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Verifica Trasferte'];
      excel.delete('Sheet1');

      // STILI EXCEL
      final headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#003399'), // TIM Blue
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final presentBadgeStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#D4EDDA'), // Verde chiaro
        fontColorHex: ExcelColor.fromHexString('#155724'), // Verde scuro
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final presentRowStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F0FDF4'), // Sfumatura verde
        fontColorHex: ExcelColor.fromHexString('#0F172A'),
        verticalAlign: VerticalAlign.Center,
      );

      final presentCenterStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F0FDF4'),
        fontColorHex: ExcelColor.fromHexString('#0F172A'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final missingBadgeStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F8D7DA'), // Rosso chiaro
        fontColorHex: ExcelColor.fromHexString('#721C24'), // Rosso scuro
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      final missingRowStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#FEF2F2'), // Sfumatura rossa
        fontColorHex: ExcelColor.fromHexString('#64748B'),
        verticalAlign: VerticalAlign.Center,
      );

      final missingCenterStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#FEF2F2'),
        fontColorHex: ExcelColor.fromHexString('#64748B'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      sheet.appendRow([
        TextCellValue('Codice Trasferta'),
        TextCellValue('Esito Verifica'),
        TextCellValue('CID'),
        TextCellValue('Dipendente'),
        TextCellValue('Società'),
        TextCellValue('Data Inizio'),
        TextCellValue('Ora Inizio'),
        TextCellValue('Data Fine'),
        TextCellValue('Ora Fine'),
      ]);

      for (final item in _items) {
        if (item.isPresent && item.record != null) {
          sheet.appendRow([
            TextCellValue(item.code),
            TextCellValue('PRESENTE'),
            TextCellValue(item.record!.cid),
            TextCellValue(item.nominativo ?? ''),
            TextCellValue(item.societa ?? ''),
            TextCellValue(item.record!.dataInizioTrasferta),
            TextCellValue(item.record!.oraInizioTrasferta),
            TextCellValue(item.record!.dataFineTrasferta),
            TextCellValue(item.record!.oraFineTrasferta),
          ]);
        } else {
          sheet.appendRow([
            TextCellValue(item.code),
            TextCellValue('NON PRESENTE'),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
            TextCellValue('-'),
          ]);
        }
      }

      const colCount = 9;

      // Applica stile intestazione
      for (var col = 0; col < colCount; col++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
        cell.cellStyle = headerStyle;
      }
      sheet.setRowHeight(0, 32);

      // Applica stili alle righe dati
      for (var i = 0; i < _items.length; i++) {
        final rowIndex = i + 1;
        final item = _items[i];
        final isPresent = item.isPresent;

        sheet.setRowHeight(rowIndex, 24);

        for (var col = 0; col < colCount; col++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
          if (col == 1) {
            cell.cellStyle = isPresent ? presentBadgeStyle : missingBadgeStyle;
          } else if (col == 3) {
            cell.cellStyle = isPresent ? presentRowStyle : missingRowStyle;
          } else {
            cell.cellStyle = isPresent ? presentCenterStyle : missingCenterStyle;
          }
        }
      }

      // Imposta larghezza colonne
      sheet.setColumnWidth(0, 20); // Codice Trasferta
      sheet.setColumnWidth(1, 18); // Esito Verifica
      sheet.setColumnWidth(2, 14); // CID
      sheet.setColumnWidth(3, 30); // Dipendente
      sheet.setColumnWidth(4, 18); // Società
      sheet.setColumnWidth(5, 16); // Data Inizio
      sheet.setColumnWidth(6, 14); // Ora Inizio
      sheet.setColumnWidth(7, 16); // Data Fine
      sheet.setColumnWidth(8, 14); // Ora Fine

      final fileBytes = excel.encode();
      if (fileBytes == null) return;

      final outputFile = await FilePicker.saveFile(
        dialogTitle: 'Salva Esito Verifica Codici Trasferta',
        fileName: 'verifica_trasferte_sap_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (outputFile != null) {
        if (!kIsWeb) {
          final file = File(outputFile);
          await file.writeAsBytes(fileBytes);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File Excel esportato con successo!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore esportazione: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _filterMainTableWithPresent() {
    final presentCodes = _items.where((i) => i.isPresent).map((i) => i.code).toSet();
    if (presentCodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nessun codice presente da filtrare nella tabella.'), backgroundColor: Colors.orange),
      );
      return;
    }
    ref.read(tsSelectedTrasferteCodesProvider.notifier).state = presentCodes;
    ref.read(tsPageProvider.notifier).state = 0;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tabella filtrata con le ${presentCodes.length} trasferte presenti.'),
        backgroundColor: SkyTheme.timBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = (screenSize.width * 0.92).clamp(880.0, 1200.0);
    final dialogHeight = (screenSize.height * 0.90).clamp(650.0, 880.0);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogHeight,
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: SkyTheme.timBlue.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fact_check_outlined, color: SkyTheme.timBlue, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Verifica Elenco Codici Trasferta SAP',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SkyTheme.timBlue),
                        ),
                        Text(
                          _hasResults
                              ? 'Riepilogo codici trasferta trovati e non trovati nel database SAP'
                              : 'Inserisci o carica un elenco di codici per controllare la loro presenza',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Chiudi',
                  ),
                ],
              ),
            ),
            // BODY
            Expanded(
              child: _hasResults ? _buildResultsView() : _buildInputView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50.withAlpha(120),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.blue.shade800, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Incolla o carica l\'elenco dei codici trasferta da controllare. Puoi separarli con a capo, virgole, punti e virgola o spazi. Il sistema cercherà le corrispondenze in SAP e ti mostrerà i codici presenti e quelli mancanti.',
                    style: TextStyle(fontSize: 13, color: Colors.blue.shade900, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _inputController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13, height: 1.4),
              decoration: InputDecoration(
                hintText: 'Incolla qui i codici trasferta...\n\nEsempio:\n10054321\n10054322\n10054323, 10054324\n10054325',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: 'monospace'),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: SkyTheme.timBlue, width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste_rounded, size: 18),
                    label: const Text('Incolla da Appunti'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loadFromFile,
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('Carica File (.txt / .csv)'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_inputController.text.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _inputController.clear(),
                      icon: const Icon(Icons.clear_all_rounded, size: 18),
                      label: const Text('Pulisci'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _detectedInputCount > 0 ? SkyTheme.timBlue.withAlpha(20) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$_detectedInputCount codici unici rilevati',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _detectedInputCount > 0 ? SkyTheme.timBlue : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ANNULLA'),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _detectedInputCount > 0 ? _runVerification : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text('VERIFICA CODICI${_detectedInputCount > 0 ? ' ($_detectedInputCount)' : ''}'),
                style: FilledButton.styleFrom(
                  backgroundColor: SkyTheme.timRed,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    final presentCount = _items.where((i) => i.isPresent).length;
    final missingCount = _items.length - presentCount;
    final totalCount = _items.length;
    final presentPct = totalCount > 0 ? ((presentCount / totalCount) * 100).toStringAsFixed(1) : '0';
    final missingPct = totalCount > 0 ? ((missingCount / totalCount) * 100).toStringAsFixed(1) : '0';

    final searchQ = _searchFilterController.text.trim().toLowerCase();
    final filtered = _items.where((item) {
      if (_selectedTab == 'missing' && item.isPresent) return false;
      if (_selectedTab == 'present' && !item.isPresent) return false;
      if (searchQ.isNotEmpty) {
        final matchesCode = item.code.toLowerCase().contains(searchQ);
        final matchesCid = item.record?.cid.toLowerCase().contains(searchQ) ?? false;
        final matchesNom = item.nominativo?.toLowerCase().contains(searchQ) ?? false;
        if (!matchesCode && !matchesCid && !matchesNom) return false;
      }
      return true;
    }).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        children: [
          // STATS CARDS
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: 'TOTALE VERIFICATI',
                  value: '$totalCount',
                  icon: Icons.checklist_rounded,
                  color: SkyTheme.timBlue,
                  subtext: 'Codici unici analizzati',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  label: 'PRESENTI IN SAP',
                  value: '$presentCount',
                  icon: Icons.check_circle_outline_rounded,
                  color: Colors.green.shade700,
                  subtext: '$presentPct% del totale',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  label: 'NON PRESENTI',
                  value: '$missingCount',
                  icon: Icons.highlight_off_rounded,
                  color: Colors.red.shade700,
                  subtext: '$missingPct% del totale',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // CONTROLLI TAB E RICERCA
          Row(
            children: [
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text('Tutti ($totalCount)'),
                    selected: _selectedTab == 'all',
                    onSelected: (val) {
                      if (val) setState(() => _selectedTab = 'all');
                    },
                    selectedColor: SkyTheme.timBlue.withAlpha(30),
                  ),
                  ChoiceChip(
                    label: Text('Non Presenti ($missingCount)'),
                    selected: _selectedTab == 'missing',
                    onSelected: (val) {
                      if (val) setState(() => _selectedTab = 'missing');
                    },
                    selectedColor: Colors.red.shade50,
                    labelStyle: TextStyle(
                      color: _selectedTab == 'missing' ? Colors.red.shade800 : Colors.black87,
                      fontWeight: _selectedTab == 'missing' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  ChoiceChip(
                    label: Text('Presenti ($presentCount)'),
                    selected: _selectedTab == 'present',
                    onSelected: (val) {
                      if (val) setState(() => _selectedTab = 'present');
                    },
                    selectedColor: Colors.green.shade50,
                    labelStyle: TextStyle(
                      color: _selectedTab == 'present' ? Colors.green.shade800 : Colors.black87,
                      fontWeight: _selectedTab == 'present' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: 260,
                height: 38,
                child: TextField(
                  controller: _searchFilterController,
                  decoration: InputDecoration(
                    hintText: 'Filtra per codice o nome...',
                    hintStyle: const TextStyle(fontSize: 12),
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: _searchFilterController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _searchFilterController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onChanged: (val) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // LISTA RISULTATI
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Nessun risultato corrispondente ai filtri.',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: filtered.length,
                      separatorBuilder: (context, i) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final isPresent = item.isPresent;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isPresent ? Colors.green.shade200 : Colors.red.shade200,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(4),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: isPresent ? Colors.green.shade600 : Colors.red.shade600,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  item.code,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isPresent ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isPresent ? Colors.green.shade300 : Colors.red.shade300,
                                  ),
                                ),
                                child: Text(
                                  isPresent ? 'PRESENTE' : 'NON PRESENTE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isPresent ? Colors.green.shade800 : Colors.red.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: isPresent && item.record != null
                                    ? Text(
                                        'CID: ${item.record!.cid}  •  ${item.nominativo ?? 'Dipendente N/D'}  •  Dal ${item.record!.dataInizioTrasferta} al ${item.record!.dataFineTrasferta}${item.societa != null ? '  •  ${item.societa}' : ''}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    : Text(
                                        'Nessun record corrispondente trovato nel database Trasferte SAP',
                                        style: TextStyle(fontSize: 12, color: Colors.red.shade400, fontStyle: FontStyle.italic),
                                      ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy_rounded, size: 16),
                                tooltip: 'Copia codice',
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: item.code));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Codice ${item.code} copiato'), duration: const Duration(seconds: 1)),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          // FOOTER ACTIONS
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 10,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _hasResults = false),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Nuova Verifica'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _copyMissingToClipboard,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text('Copia Non Presenti ($missingCount)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _copyAllToClipboard,
                    icon: const Icon(Icons.playlist_add_check_rounded, size: 18),
                    label: const Text('Copia Report'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _exportResultsToExcel,
                    icon: const Icon(Icons.table_view_rounded, size: 18),
                    label: const Text('Esporta Excel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade700,
                      side: BorderSide(color: Colors.green.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (presentCount > 0)
                    FilledButton.icon(
                      onPressed: _filterMainTableWithPresent,
                      icon: const Icon(Icons.filter_alt_rounded, size: 18),
                      label: Text('Filtra in Tabella ($presentCount)'),
                      style: FilledButton.styleFrom(
                        backgroundColor: SkyTheme.timBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String subtext,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtext,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

