import 'dart:io';
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

// Filter providers for Trasferte SAP
final tsSelectedQueryProvider = StateProvider<String?>((ref) => null);
final tsStartDateProvider = StateProvider<DateTime?>((ref) => null);
final tsEndDateProvider = StateProvider<DateTime?>((ref) => null);
final tsSortAscendingProvider = StateProvider<bool>((ref) => false);
final tsPageProvider = StateProvider<int>((ref) => 0);
final tsSelectedLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});
final tsSelectedContabileLogHistoryIdsProvider = StateProvider<Set<String>>((ref) => {});

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
    final allLogs = ref.watch(logHistoryProvider);
    final contabileRecords = ref.watch(tracciatoContabilesProvider);

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
      startDate != null,
      endDate != null,
      selectedLogHistoryIds.isNotEmpty,
      selectedContabileLogHistoryIds.isNotEmpty,
    ].where((e) => e).length;

    // Calcolo statistiche generali
    final totalRecords = allRecords.length;

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      if (selectedLogHistoryIds.isNotEmpty && !selectedLogHistoryIds.contains(r.logHistoryId)) return false;
      if (selectedQuery != null) {
        final query = selectedQuery.toLowerCase();
        if (!r.numeroTrasferta.toLowerCase().contains(query) &&
            !r.cid.toLowerCase().contains(query)) {
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
                                  hintText: 'Cerca per trasferta o CID dipendente...', 
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
                          width: 1010,
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
    ref.read(tsStartDateProvider.notifier).state = null;
    ref.read(tsEndDateProvider.notifier).state = null;
    ref.read(tsSelectedLogHistoryIdsProvider.notifier).state = {};
    ref.read(tsSelectedContabileLogHistoryIdsProvider.notifier).state = {};
    ref.read(tsPageProvider.notifier).state = 0;
    _searchController.clear();
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

      // Header
      sheet.appendRow([
        TextCellValue('CID'),
        TextCellValue('Numero Trasferta'),
        TextCellValue('Data Inizio'),
        TextCellValue('Ora Inizio'),
        TextCellValue('Data Fine'),
        TextCellValue('Ora Fine'),
      ]);

      // Rows
      for (final r in records) {
        sheet.appendRow([
          TextCellValue(r.cid),
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
}
