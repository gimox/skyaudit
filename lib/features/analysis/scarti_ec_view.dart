import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/scarti_ec_sap_provider.dart';
import 'package:travel_check/features/upload/models/scarti_ec_sap.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';

// Filter providers for Scarti EC SAP
final scSelectedQueryProvider = StateProvider<String?>((ref) => null);
final scStartDateProvider = StateProvider<DateTime?>((ref) => null);
final scEndDateProvider = StateProvider<DateTime?>((ref) => null);
final scSelectedSpesaProvider = StateProvider<Set<String>>((ref) => {});
final scSortAscendingProvider = StateProvider<bool>((ref) => false);
final scPageProvider = StateProvider<int>((ref) => 0);

class ScartiEcView extends ConsumerStatefulWidget {
  const ScartiEcView({super.key});

  @override
  ConsumerState<ScartiEcView> createState() => _ScartiEcViewState();
}

class _ScartiEcViewState extends ConsumerState<ScartiEcView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(scartiEcSapProvider);
    final selectedQuery = ref.watch(scSelectedQueryProvider);
    final startDate = ref.watch(scStartDateProvider);
    final endDate = ref.watch(scEndDateProvider);
    final selectedSpese = ref.watch(scSelectedSpesaProvider);
    final sortAscending = ref.watch(scSortAscendingProvider);
    final currentPage = ref.watch(scPageProvider);
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
    ].where((e) => e).length;

    // Estrai giustificativi di spesa disponibili per il filtro
    final availableSpese = allRecords
        .map((r) => r.spesa)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      if (selectedQuery != null) {
        final query = selectedQuery.toLowerCase();
        if (!r.numeroTrasferta.toLowerCase().contains(query) &&
            !r.cid.toLowerCase().contains(query) &&
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
      
      return true;
    }).toList()
      ..sort((a, b) {
        return sortAscending ? a.cid.compareTo(b.cid) : b.cid.compareTo(a.cid);
      });

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, ref, availableSpese),
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
                                  hintText: 'Cerca per trasferta, CID o descrizione scarto...', 
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
                        if (startDate != null)
                          _buildFilterChip('Dal: ${startDate.day}/${startDate.month}/${startDate.year}', () => ref.read(scStartDateProvider.notifier).state = null),
                        if (endDate != null)
                          _buildFilterChip('Al: ${endDate.day}/${endDate.month}/${endDate.year}', () => ref.read(scEndDateProvider.notifier).state = null),
                        ...selectedSpese.map((spesa) => _buildFilterChip(spesa, () {
                          final current = ref.read(scSelectedSpesaProvider);
                          final next = Set<String>.from(current)..remove(spesa);
                          ref.read(scSelectedSpesaProvider.notifier).state = next;
                        })),
                        TextButton(onPressed: () => _resetAllFilters(ref), child: const Text('Reset tutto', style: TextStyle(fontSize: 12, color: Colors.red))),
                      ],
                    ),
                  ),
                ],
              ],
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1200,
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
                                _buildCell('CID', 120, isHeader: true),
                                _buildCell('TRASFERTA', 150, isHeader: true),
                                _buildCell('SPESA', 100, isHeader: true),
                                _buildCell('IMPORTO', 120, isHeader: true),
                                _buildCell('DIVISA', 80, isHeader: true),
                                _buildCell('STORNO', 100, isHeader: true),
                                _buildCell('DATA INVIO', 130, isHeader: true),
                                _buildCell('DESCRIZIONE SCARTO', 280, isHeader: true),
                                _buildCell('AZIONI', 120, isHeader: true, alignment: Alignment.center),
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
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0 ? Colors.white : Colors.grey.shade50.withAlpha(120), 
                                      border: Border(bottom: BorderSide(color: Colors.grey.shade100))
                                    ),
                                    child: Row(
                                      children: [
                                        _buildCell(
                                          record.cid,
                                          120,
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
                                          record.numeroTrasferta,
                                          150,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  record.numeroTrasferta,
                                                  style: const TextStyle(
                                                    fontSize: 13,
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
                                        _buildCell(record.storno ?? '-', 100, color: record.storno != null ? Colors.orange.shade800 : null),
                                        _buildCell(record.dataInvio, 130),
                                        _buildCell(record.descrizioneScarto, 280),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Text(
                      'Totale scarti: ${filteredRecords.length}',
                      style: const TextStyle(
                        color: SkyTheme.timRed,
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
    ref.read(scSelectedQueryProvider.notifier).state = null;
    ref.read(scStartDateProvider.notifier).state = null;
    ref.read(scEndDateProvider.notifier).state = null;
    ref.read(scSelectedSpesaProvider.notifier).state = {};
    ref.read(scPageProvider.notifier).state = 0;
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

  Widget _buildFilterDrawer(BuildContext context, WidgetRef ref, List<String> availableSpese) {
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
            
            return FilterChip(
              label: Text(
                option, 
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
                              'CID: ${record.cid}',
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

      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Numero Trasferta'),
        TextCellValue('CID'),
        TextCellValue('Descrizione Scarto'),
        TextCellValue('Spesa'),
        TextCellValue('Importo'),
        TextCellValue('Divisa'),
        TextCellValue('Storno'),
        TextCellValue('Data Invio'),
        TextCellValue('Note'),
      ]);

      for (final r in records) {
        sheet.appendRow([
          IntCellValue(r.id),
          TextCellValue(r.numeroTrasferta),
          TextCellValue(r.cid),
          TextCellValue(r.descrizioneScarto),
          TextCellValue(r.spesa),
          DoubleCellValue(r.importo),
          TextCellValue(r.divisa),
          TextCellValue(r.storno ?? ''),
          TextCellValue(r.dataInvio),
          TextCellValue(r.note ?? ''),
        ]);
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
