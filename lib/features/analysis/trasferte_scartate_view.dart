import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:universal_io/io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:travel_check/features/upload/providers/scarti_ec_sap_provider.dart';
import 'package:travel_check/features/upload/models/scarti_ec_sap.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';

enum ReinseritoFilter { all, daReinserire, reinseriti }

class GroupedScarto {
  final String numeroTrasferta;
  final double importo;
  final String cid;
  final String spesa;
  final List<ScartiEcSap> items;

  GroupedScarto({
    required this.numeroTrasferta,
    required this.importo,
    required this.cid,
    required this.spesa,
    required this.items,
  });

  DateTime get oldestDate {
    DateTime oldest = DateTime(2999);
    for (final item in items) {
      final date = _parseDate(item.dataInvio);
      if (date.isBefore(oldest)) {
        oldest = date;
      }
    }
    return oldest;
  }
}

DateTime _parseDate(String dateStr) {
  try {
    final parts = dateStr.split('/');
    if (parts.length == 3) {
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    }
  } catch (_) {}
  return DateTime(1970);
}

class TrasferteScartateView extends ConsumerStatefulWidget {
  const TrasferteScartateView({super.key});

  @override
  ConsumerState<TrasferteScartateView> createState() => _TrasferteScartateViewState();
}

class _TrasferteScartateViewState extends ConsumerState<TrasferteScartateView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  int _currentPage = 0;
  String _searchQuery = '';
  static const int _pageSize = 50;

  // Filters State
  ReinseritoFilter _statusFilter = ReinseritoFilter.all;
  final Set<String> _selectedSociete = {};
  final Set<String> _selectedSpese = {};
  final Set<String> _selectedTipiDip = {};
  DateTime? _startDate;
  DateTime? _endDate;

  // Track expanded groups by their unique key
  final Set<String> _expandedGroups = {};

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  bool _hasActiveFilters() {
    return _statusFilter != ReinseritoFilter.all ||
        _selectedSociete.isNotEmpty ||
        _selectedSpese.isNotEmpty ||
        _selectedTipiDip.isNotEmpty ||
        _startDate != null ||
        _endDate != null;
  }

  String _formatAmount(double amount, [String currency = 'EUR']) {
    final isNeg = amount < 0;
    final absVal = amount.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final decimals = parts[1];

    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formattedWhole = whole.replaceAllMapped(reg, (Match match) => '${match[1]}.');

    return '${isNeg ? "-" : ""}$formattedWhole,$decimals $currency';
  }

  Widget _buildCell(String text, double width, {bool isHeader = false, Color? color, FontWeight? fontWeight, Alignment alignment = Alignment.centerLeft, Widget? child}) {
    return Container(
      width: width,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: alignment,
      child: child ?? Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 11 : 13,
          fontWeight: isHeader ? FontWeight.bold : (fontWeight ?? FontWeight.normal),
          color: isHeader ? Colors.grey.shade700 : (color ?? Colors.black87),
          letterSpacing: isHeader ? 1.0 : null,
          fontFamily: 'TIMSans',
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubCell(String text, double width, {bool isHeader = false, Alignment alignment = Alignment.centerLeft, Widget? child}) {
    return Container(
      width: width,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: alignment,
      child: child ?? Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 10 : 12,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.grey.shade600 : Colors.black87,
          fontFamily: 'TIMSans',
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
            fontFamily: 'TIMSans',
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : Colors.black87,
        fontFamily: 'TIMSans',
      ),
      selectedColor: SkyTheme.timBlue,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: isSelected ? SkyTheme.timBlue : Colors.grey.shade300),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? SkyTheme.timRed : Colors.grey.shade800,
        fontFamily: 'TIMSans',
      ),
      selectedColor: SkyTheme.timRed.withAlpha(25),
      checkmarkColor: SkyTheme.timRed,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: isSelected ? SkyTheme.timRed : Colors.grey.shade300),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontFamily: 'TIMSans', color: Colors.black87),
        ),
        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.grey),
        onDeleted: onDelete,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }

  Widget _buildFilterDrawer(
    BuildContext context,
    List<String> availableSpese,
    List<String> availableSocieta,
    List<String> availableTipiDip,
    Map<String, String> dictionaryMap,
  ) {
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
                        fontFamily: 'TIMSans',
                      ),
                    ),
                    Text(
                      'Affina la tua ricerca',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        letterSpacing: 0.2,
                        fontFamily: 'TIMSans',
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
                _buildDrawerSectionTitle('STATO REINSERIMENTO'),
                const SizedBox(height: 12),
                _buildChoiceFilter<ReinseritoFilter>(
                  _statusFilter,
                  {
                    ReinseritoFilter.all: 'Tutti',
                    ReinseritoFilter.daReinserire: 'Da Reinserire',
                    ReinseritoFilter.reinseriti: 'Reinseriti',
                  },
                  (val) => setState(() {
                    _statusFilter = val;
                    _currentPage = 0;
                  }),
                ),
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('PERIODO INVIO (ULTIMO)'),
                const SizedBox(height: 12),
                _buildDatePickerFilter(
                  'Data Inizio',
                  _startDate,
                  (val) => setState(() {
                    _startDate = val;
                    _currentPage = 0;
                  }),
                ),
                const SizedBox(height: 12),
                _buildDatePickerFilter(
                  'Data Fine',
                  _endDate,
                  (val) => setState(() {
                    _endDate = val;
                    _currentPage = 0;
                  }),
                ),
                const SizedBox(height: 32),
                if (availableSocieta.isNotEmpty) ...[
                  _buildDrawerSectionTitle('SOCIETÀ'),
                  const SizedBox(height: 12),
                  _buildChipsMultiSelectFilter(
                    'Seleziona società',
                    _selectedSociete,
                    availableSocieta,
                    (val) {
                      setState(() {
                        if (_selectedSociete.contains(val)) {
                          _selectedSociete.remove(val);
                        } else {
                          _selectedSociete.add(val);
                        }
                        _currentPage = 0;
                      });
                    },
                    icon: Icons.business_outlined,
                    labelMap: dictionaryMap,
                  ),
                  const SizedBox(height: 32),
                ],
                if (availableTipiDip.isNotEmpty) ...[
                  _buildDrawerSectionTitle('TIPO DIPENDENTE'),
                  const SizedBox(height: 12),
                  _buildChipsMultiSelectFilter(
                    'Seleziona tipo dipendente',
                    _selectedTipiDip,
                    availableTipiDip,
                    (val) {
                      setState(() {
                        if (_selectedTipiDip.contains(val)) {
                          _selectedTipiDip.remove(val);
                        } else {
                          _selectedTipiDip.add(val);
                        }
                        _currentPage = 0;
                      });
                    },
                    icon: Icons.badge_outlined,
                    labelMap: dictionaryMap,
                  ),
                  const SizedBox(height: 32),
                ],
                if (availableSpese.isNotEmpty) ...[
                  _buildDrawerSectionTitle('CATEGORIE DI SPESA'),
                  const SizedBox(height: 12),
                  _buildChipsMultiSelectFilter(
                    'Giustificativo di spesa',
                    _selectedSpese,
                    availableSpese,
                    (val) {
                      setState(() {
                        if (_selectedSpese.contains(val)) {
                          _selectedSpese.remove(val);
                        } else {
                          _selectedSpese.add(val);
                        }
                        _currentPage = 0;
                      });
                    },
                    icon: Icons.receipt_long_outlined,
                    labelMap: dictionaryMap,
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _statusFilter = ReinseritoFilter.all;
                        _selectedSociete.clear();
                        _selectedSpese.clear();
                        _selectedTipiDip.clear();
                        _startDate = null;
                        _endDate = null;
                        _currentPage = 0;
                      });
                    },
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
                      backgroundColor: SkyTheme.timRed,
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
        fontFamily: 'TIMSans',
      ),
    );
  }

  Widget _buildDatePickerFilter(String label, DateTime? value, Function(DateTime?) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
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
                    surface: Colors.white,
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
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      ),
    );
  }

  Widget _buildChoiceFilter<T>(T groupValue, Map<T, String> options, Function(T) onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((entry) {
        final isSelected = groupValue == entry.key;
        return ChoiceChip(
          label: Text(entry.value),
          selected: isSelected,
          onSelected: (_) => onChanged(entry.key),
          labelStyle: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.black87,
            fontFamily: 'TIMSans',
          ),
          selectedColor: SkyTheme.timRed,
          backgroundColor: Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: isSelected ? SkyTheme.timRed : Colors.grey.shade300),
          ),
        );
      }).toList(),
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
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'TIMSans'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selectedValues.contains(option);
            final displayLabel = labelMap != null
                ? (labelMap[option.toUpperCase()] ?? option)
                : option;
            
            return FilterChip(
              label: Text(
                labelMap != null && option != displayLabel ? '$option - $displayLabel' : displayLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'TIMSans',
                ),
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

  Widget _buildExpandedSection(GroupedScarto group, Map<String, String> dictionaryMap, List<LogHistory> allLogs) {
    return Container(
      width: 1600,
      padding: const EdgeInsets.only(left: 50, right: 0, top: 8, bottom: 16),
      color: Colors.grey.shade50.withAlpha(230),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: SkyTheme.timBlue),
                const SizedBox(width: 8),
                Text(
                  'DETTAGLIO OCCORRENZE (${group.items.length} record)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: SkyTheme.timBlue,
                    fontFamily: 'TIMSans',
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Column(
                children: [
                  // Sub-header
                  Container(
                    height: 36,
                    color: Colors.grey.shade100,
                    child: Row(
                      children: [
                        _buildSubCell('N°', 60, isHeader: true),
                        _buildSubCell('DATA INVIO', 120, isHeader: true),
                        _buildSubCell('DESCRIZIONE SCARTO', 420, isHeader: true),
                        _buildSubCell('STORNO', 100, isHeader: true),
                        _buildSubCell('STATO', 140, isHeader: true, alignment: Alignment.center),
                        _buildSubCell('FILE DI ORIGINE', 408, isHeader: true),
                      ],
                    ),
                  ),
                  // Sub-rows
                  ...group.items.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    final log = allLogs.firstWhere(
                      (l) => l.uniqueCode == item.logHistoryId,
                      orElse: () => LogHistory(
                        fileName: 'Sconosciuto',
                        date: DateTime.now(),
                        uniqueCode: '',
                        totalRecords: 0,
                        insertedRecords: 0,
                        updatedRecords: 0,
                        discardedRecords: 0,
                        sourceType: '',
                      ),
                    );
                    final fileName = log.fileName;
                    final isMatched = item.isMatched;

                    return Container(
                      height: 38,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade100),
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildSubCell('#$idx', 60),
                          _buildSubCell(item.dataInvio, 120),
                          _buildSubCell(item.descrizioneScarto, 420),
                          _buildSubCell(item.storno ?? '-', 100),
                          _buildSubCell(
                            '',
                            140,
                            alignment: Alignment.center,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isMatched
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isMatched
                                      ? Colors.green.shade200
                                      : Colors.orange.shade200,
                                ),
                              ),
                              child: Text(
                                isMatched ? 'RISCONTRATO' : 'IN ATTESA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isMatched
                                      ? Colors.green.shade800
                                      : Colors.orange.shade800,
                                  fontFamily: 'TIMSans',
                                ),
                              ),
                            ),
                          ),
                          _buildSubCell(fileName, 408),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
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
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    fontFamily: 'TIMSans',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontFamily: 'TIMSans',
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                      fontFamily: 'TIMSans',
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

  Future<void> _exportToExcel(
    List<GroupedScarto> groups,
    Map<String, bool> groupMatchCache,
    Map<String, String> anagraficaMap,
    Map<String, String> anagraficaSocietaMap,
    Map<String, String> anagraficaTipoDipMap,
    Map<String, String> dictionaryMap,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Trasferte Scartate'];
      excel.delete('Sheet1');

      // Styles
      final titleStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#0A0A0A'),
        fontSize: 16,
        bold: true,
        verticalAlign: VerticalAlign.Center,
      );

      final filterHeaderStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#C4121A'), // TIM Red
        fontSize: 11,
        bold: true,
        verticalAlign: VerticalAlign.Center,
      );

      final filterLabelStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#555555'),
        fontSize: 10,
        bold: true,
        verticalAlign: VerticalAlign.Center,
      );

      final filterValueStyle = CellStyle(
        fontColorHex: ExcelColor.fromHexString('#111111'),
        fontSize: 10,
        verticalAlign: VerticalAlign.Center,
      );

      final tableHeaderStyle = CellStyle(
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

      // Write Header/Filters Info at the top
      // Row 0: Title
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
        ..value = TextCellValue('SKYCHECK - REPORT TRASFERTE SCARTATE')
        ..cellStyle = titleStyle;
      sheet.setRowHeight(0, 35);

      // Row 2: Filter Header
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        ..value = TextCellValue('FILTRI APPLICATI:')
        ..cellStyle = filterHeaderStyle;
      sheet.setRowHeight(2, 20);

      // Row 3: Filters Part 1
      // 1. Stato Reinserimento
      String statusStr = 'Tutti';
      if (_statusFilter == ReinseritoFilter.daReinserire) statusStr = 'Da Reinserire';
      if (_statusFilter == ReinseritoFilter.reinseriti) statusStr = 'Reinseriti';
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        ..value = TextCellValue('Stato Reinserimento:')
        ..cellStyle = filterLabelStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
        ..value = TextCellValue(statusStr)
        ..cellStyle = filterValueStyle;

      // 2. Società
      String societeStr = _selectedSociete.isEmpty
          ? 'Tutte'
          : _selectedSociete.map((s) => dictionaryMap[s.toUpperCase()] ?? s).join(', ');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 3))
        ..value = TextCellValue('Società:')
        ..cellStyle = filterLabelStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 3))
        ..value = TextCellValue(societeStr)
        ..cellStyle = filterValueStyle;

      // 3. Tipi Dipendente
      String tipiDipStr = _selectedTipiDip.isEmpty
          ? 'Tutti'
          : _selectedTipiDip.map((t) => dictionaryMap[t.toUpperCase()] ?? t).join(', ');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 3))
        ..value = TextCellValue('Tipi Dipendente:')
        ..cellStyle = filterLabelStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 3))
        ..value = TextCellValue(tipiDipStr)
        ..cellStyle = filterValueStyle;

      sheet.setRowHeight(3, 20);

      // Row 4: Filters Part 2
      // 4. Spese
      String speseStr = _selectedSpese.isEmpty
          ? 'Tutte'
          : _selectedSpese.map((s) => '$s - ${dictionaryMap[s.toUpperCase()] ?? s}').join(', ');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 4))
        ..value = TextCellValue('Categorie Spesa:')
        ..cellStyle = filterLabelStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 4))
        ..value = TextCellValue(speseStr)
        ..cellStyle = filterValueStyle;

      // 5. Periodo Invio
      String dateStr = 'Sempre';
      if (_startDate != null && _endDate != null) {
        dateStr = 'Dal ${_startDate!.day}/${_startDate!.month}/${_startDate!.year} Al ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
      } else if (_startDate != null) {
        dateStr = 'Dal ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}';
      } else if (_endDate != null) {
        dateStr = 'Al ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}';
      }
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 4))
        ..value = TextCellValue('Periodo Invio:')
        ..cellStyle = filterLabelStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 4))
        ..value = TextCellValue(dateStr)
        ..cellStyle = filterValueStyle;

      // 6. Cerca
      String queryStr = _searchQuery.isEmpty ? '-' : _searchQuery;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 4))
        ..value = TextCellValue('Cerca:')
        ..cellStyle = filterLabelStyle;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 4))
        ..value = TextCellValue(queryStr)
        ..cellStyle = filterValueStyle;

      sheet.setRowHeight(4, 20);

      // Row 6: Table Headers
      final List<String> tableHeaders = [
        'CID',
        'Nominativo',
        'Tipo Dipendente',
        'Società',
        'Numero Trasferta',
        'Tipo Spesa',
        'Data Invio (Più Vecchia)',
        'Ultimo Invio',
        'Occorrenze',
        'Stato',
        'Importo'
      ];

      for (int i = 0; i < tableHeaders.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 6));
        cell.value = TextCellValue(tableHeaders[i]);
        cell.cellStyle = tableHeaderStyle;
      }
      sheet.setRowHeight(6, 26);

      // Data Rows
      int rowIndex = 7;
      for (final group in groups) {
        final groupKey = "${group.numeroTrasferta}_${group.importo}_${group.cid}_${group.spesa}";
        final isReinserted = groupMatchCache[groupKey] ?? false;

        final nominativo = anagraficaMap[group.cid] ?? '-';
        final dipType = anagraficaTipoDipMap[group.cid] ?? '';
        final dipTypeDesc = dipType.isNotEmpty ? (dictionaryMap[dipType.toUpperCase()] ?? dipType) : '';
        final displayDipType = dipType.isNotEmpty
            ? (dipType != dipTypeDesc ? '$dipType - $dipTypeDesc' : dipType)
            : '-';

        final companyCode = anagraficaSocietaMap[group.cid] ?? '';
        final companyDesc = companyCode.isNotEmpty
            ? (dictionaryMap[companyCode.toUpperCase()] ?? companyCode)
            : '';
        final displayCompany = companyDesc.isNotEmpty
            ? (companyCode != companyDesc ? '$companyCode - $companyDesc' : companyCode)
            : '-';

        final spesaDesc = dictionaryMap[group.spesa.toUpperCase()] ?? '';
        final displaySpesa = spesaDesc.isNotEmpty
            ? '${group.spesa} - $spesaDesc'
            : group.spesa;

        final isMatched = isReinserted;
        final rowStyle = isMatched ? matchedStyle : waitingStyle;
        final centerStyle = isMatched ? matchedCenterStyle : waitingCenterStyle;
        final amountStyle = isMatched ? matchedAmountStyle : waitingAmountStyle;

        sheet.setRowHeight(rowIndex, 22);

        // Cells definition
        final rowCells = [
          TextCellValue(group.cid),
          TextCellValue(nominativo),
          TextCellValue(displayDipType),
          TextCellValue(displayCompany),
          TextCellValue(group.numeroTrasferta),
          TextCellValue(displaySpesa),
          TextCellValue(group.items.first.dataInvio),
          TextCellValue(group.items.last.dataInvio),
          IntCellValue(group.items.length),
          TextCellValue(isReinserted ? 'REINSERITO' : 'DA REINSERIRE'),
          DoubleCellValue(group.importo),
        ];

        for (int col = 0; col < rowCells.length; col++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: rowIndex));
          cell.value = rowCells[col];
          if (col == 10) { // Importo
            cell.cellStyle = amountStyle;
          } else if (col == 0 || col == 2 || col == 4 || col == 6 || col == 7 || col == 8 || col == 9) {
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
        dialogTitle: 'Salva Export Excel Trasferte Scartate',
        fileName: 'export_trasferte_scartate_${DateTime.now().millisecondsSinceEpoch}.xlsx',
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

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(scartiEcSapProvider);
    final allAnagrafica = ref.watch(anagraficaProvider);
    final dictionaries = ref.watch(dictionaryProvider);
    final allLogs = ref.watch(logHistoryProvider);
    final contabileRecords = ref.watch(tracciatoContabilesProvider);

    final anagraficaMap = {
      for (var a in allAnagrafica)
        (a.cid ?? '').trim().padLeft(8, '0'): (a.nominativo ?? '').trim()
    };
    final anagraficaSocietaMap = {
      for (var a in allAnagrafica)
        (a.cid ?? '').trim().padLeft(8, '0'): (a.societa ?? '').trim()
    };
    final anagraficaTipoDipMap = {
      for (var a in allAnagrafica)
        (a.cid ?? '').trim().padLeft(8, '0'): (a.tipoDip ?? '').trim()
    };
    final dictionaryMap = {
      for (final entry in dictionaries)
        entry.code.trim().toUpperCase(): entry.value.trim()
    };

    // Filter values extraction
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

    final availableTipiDip = allRecords
        .map((r) => anagraficaTipoDipMap[r.cid.trim().padLeft(8, '0')] ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    // Parse LogHistory fileName periods (yyyyMM) into integers for comparison
    final Map<String, int> logPeriodMap = {};
    for (final log in allLogs) {
      final match = RegExp(r'\d{6}').firstMatch(log.fileName);
      if (match != null) {
        final periodStr = match.group(0)!;
        final year = int.tryParse(periodStr.substring(0, 4)) ?? 0;
        final month = int.tryParse(periodStr.substring(4, 6)) ?? 0;
        logPeriodMap[log.uniqueCode] = year * 12 + month;
      }
    }

    // Sort all records chronologically by dataInvio (oldest to newest)
    final sortedRecords = List<ScartiEcSap>.from(allRecords)..sort((a, b) {
      final dateA = _parseDate(a.dataInvio);
      final dateB = _parseDate(b.dataInvio);
      return dateA.compareTo(dateB);
    });

    // Group sorted records by numeroTrasferta, importo, cid, spesa
    final List<GroupedScarto> groupedList = [];
    for (final r in sortedRecords) {
      final existingGroupIndex = groupedList.indexWhere((g) =>
          g.numeroTrasferta == r.numeroTrasferta &&
          (g.importo - r.importo).abs() < 0.001 &&
          g.cid == r.cid &&
          g.spesa == r.spesa);

      if (existingGroupIndex != -1) {
        groupedList[existingGroupIndex].items.add(r);
      } else {
        groupedList.add(GroupedScarto(
          numeroTrasferta: r.numeroTrasferta,
          importo: r.importo,
          cid: r.cid,
          spesa: r.spesa,
          items: [r],
        ));
      }
    }

    // Determine matching status cache for each group
    final Map<String, bool> groupMatchCache = {};
    for (final group in groupedList) {
      final groupKey = "${group.numeroTrasferta}_${group.importo}_${group.cid}_${group.spesa}";

      // Parse the newest date
      final newestDateStr = group.items.last.dataInvio;
      final parts = newestDateStr.split('/');
      int minPeriod = 0;
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]) ?? 0;
        final month = int.tryParse(parts[1]) ?? 0;
        final year = int.tryParse(parts[2]) ?? 0;
        if (day <= 15) {
          minPeriod = year * 12 + month;
        } else {
          minPeriod = year * 12 + month + 1;
        }
      }

      bool isReinserted = false;
      final scartoCid = group.cid.trim().padLeft(8, '0');
      final scartoTrasferta = group.numeroTrasferta.trim().split('.')[0].replaceAll(RegExp(r'^0+'), '');
      final scartoSpesa = group.spesa.trim().toUpperCase();
      final scartoImporto = group.importo;

      for (final tc in contabileRecords) {
        if (tc.logHistoryId == null) continue;
        final filePeriod = logPeriodMap[tc.logHistoryId];
        if (filePeriod == null || filePeriod < minPeriod) continue;

        // Check CID
        final tcCid = tc.cid.trim().padLeft(8, '0');
        if (tcCid != scartoCid) continue;

        // Check trasferta
        final tcTrasferta = tc.numeroTrasferta.trim().split('.')[0].replaceAll(RegExp(r'^0+'), '');
        if (tcTrasferta != scartoTrasferta) continue;

        // Check spesa
        final tcSpesa = tc.giustificativoSpesa.trim().toUpperCase();
        if (tcSpesa != scartoSpesa) continue;

        // Check importo (sign included)
        final tcImporto = tc.isNegative ? -tc.importo : tc.importo;
        if ((tcImporto - scartoImporto).abs() > 0.005) continue;

        isReinserted = true;
        break;
      }

      groupMatchCache[groupKey] = isReinserted;
    }

    // Filter grouped records based on query and advanced filters
    final filteredGroups = groupedList.where((g) {
      final groupKey = "${g.numeroTrasferta}_${g.importo}_${g.cid}_${g.spesa}";
      final isReinserted = groupMatchCache[groupKey] ?? false;

      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final nominativo = anagraficaMap[g.cid] ?? '';
        final spesaDesc = dictionaryMap[g.spesa.toUpperCase()] ?? '';
        if (!g.numeroTrasferta.toLowerCase().contains(query) &&
            !g.cid.toLowerCase().contains(query) &&
            !nominativo.toLowerCase().contains(query) &&
            !g.spesa.toLowerCase().contains(query) &&
            !spesaDesc.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 2. Stato Reinserimento
      if (_statusFilter == ReinseritoFilter.daReinserire && isReinserted) return false;
      if (_statusFilter == ReinseritoFilter.reinseriti && !isReinserted) return false;

      // 3. Società
      if (_selectedSociete.isNotEmpty) {
        final compCode = anagraficaSocietaMap[g.cid] ?? '';
        if (!_selectedSociete.contains(compCode)) return false;
      }

      // Tipo Dipendente Filter
      if (_selectedTipiDip.isNotEmpty) {
        final dipType = anagraficaTipoDipMap[g.cid] ?? '';
        if (!_selectedTipiDip.contains(dipType)) return false;
      }

      // 4. Tipo Spesa
      if (_selectedSpese.isNotEmpty && !_selectedSpese.contains(g.spesa)) return false;

      // 5. Date Range
      if (_startDate != null || _endDate != null) {
        final date = _parseDate(g.items.last.dataInvio);
        if (_startDate != null && date.isBefore(_startDate!)) return false;
        if (_endDate != null && date.isAfter(_endDate!.add(const Duration(days: 1)))) return false;
      }

      return true;
    }).toList();

    // Stats calculations based on filtered groups (dynamic updates)
    int totalUnmatchedRecords = 0;
    int reinsertedCount = 0;
    int pendingCount = 0;
    double totalAmountFiltered = 0.0;
    double pendingAmount = 0.0;
    double reinsertedAmount = 0.0;

    for (final group in filteredGroups) {
      final groupKey = "${group.numeroTrasferta}_${group.importo}_${group.cid}_${group.spesa}";
      final isReinserted = groupMatchCache[groupKey] ?? false;
      
      totalUnmatchedRecords += group.items.length;
      final groupSum = group.importo;
      totalAmountFiltered += groupSum;
      
      if (isReinserted) {
        reinsertedCount += group.items.length;
        reinsertedAmount += groupSum;
      } else {
        pendingCount += group.items.length;
        pendingAmount += groupSum;
      }
    }

    // Paginate grouped rows
    final totalPages = (filteredGroups.length / _pageSize).ceil();
    final safePage = (_currentPage >= totalPages && totalPages > 0) ? 0 : _currentPage;
    final startIndex = (safePage * _pageSize).clamp(0, filteredGroups.length);
    final endIndex = (startIndex + _pageSize).clamp(0, filteredGroups.length);
    final paginatedGroups = filteredGroups.sublist(startIndex, endIndex);
    final activeFiltersCount = [
      _searchQuery.isNotEmpty,
      _statusFilter != ReinseritoFilter.all,
      _selectedSociete.isNotEmpty,
      _selectedSpese.isNotEmpty,
      _selectedTipiDip.isNotEmpty,
      _startDate != null,
      _endDate != null,
    ].where((e) => e).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(context, availableSpese, availableSocieta, availableTipiDip, dictionaryMap),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          return Column(
            children: [
              // Header & Stats
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(24),
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
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Cerca per trasferta, CID, nominativo o spesa...',
                                      border: InputBorder.none,
                                      isDense: true,
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                    onChanged: (value) {
                                      setState(() {
                                        _searchQuery = value.trim();
                                        _currentPage = 0;
                                      });
                                    },
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                        _currentPage = 0;
                                      });
                                    },
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: activeFiltersCount > 0 ? SkyTheme.timRed : Colors.grey.shade300,
                                  ),
                                  foregroundColor: activeFiltersCount > 0 ? SkyTheme.timRed : Colors.grey.shade700,
                                ),
                              ),
                              if (activeFiltersCount > 0)
                                Positioned(
                                  top: -8,
                                  right: -8,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: SkyTheme.timRed,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$activeFiltersCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () => _exportToExcel(
                            filteredGroups,
                            groupMatchCache,
                            anagraficaMap,
                            anagraficaSocietaMap,
                            anagraficaTipoDipMap,
                            dictionaryMap,
                          ),
                          icon: const Icon(Icons.file_download_outlined, size: 20),
                          label: const Text('Esporta Excel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
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
                            if (_searchQuery.isNotEmpty)
                              _buildActiveFilterChip('Cerca: "$_searchQuery"', () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _currentPage = 0;
                                });
                              }),
                            if (_startDate != null)
                              _buildActiveFilterChip('Dal: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}', () {
                                setState(() {
                                  _startDate = null;
                                  _currentPage = 0;
                                });
                              }),
                            if (_endDate != null)
                              _buildActiveFilterChip('Al: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}', () {
                                setState(() {
                                  _endDate = null;
                                  _currentPage = 0;
                                });
                              }),
                            if (_statusFilter != ReinseritoFilter.all)
                              _buildActiveFilterChip(
                                _statusFilter == ReinseritoFilter.daReinserire
                                    ? 'Stato: Da Reinserire'
                                    : 'Stato: Reinseriti',
                                () {
                                  setState(() {
                                    _statusFilter = ReinseritoFilter.all;
                                    _currentPage = 0;
                                  });
                                },
                              ),
                            ..._selectedSociete.map((soc) {
                              final label = dictionaryMap[soc.toUpperCase()] ?? soc;
                              return _buildActiveFilterChip(
                                label,
                                () {
                                  setState(() {
                                    _selectedSociete.remove(soc);
                                    _currentPage = 0;
                                  });
                                },
                              );
                            }),
                             ..._selectedSpese.map((spesa) {
                              final label = dictionaryMap[spesa.toUpperCase()] ?? spesa;
                              return _buildActiveFilterChip(
                                '$spesa - $label',
                                () {
                                  setState(() {
                                    _selectedSpese.remove(spesa);
                                    _currentPage = 0;
                                  });
                                },
                              );
                            }),
                            ..._selectedTipiDip.map((tipo) {
                              final label = dictionaryMap[tipo.toUpperCase()] ?? tipo;
                              return _buildActiveFilterChip(
                                tipo != label ? '$tipo - $label' : label,
                                () {
                                  setState(() {
                                    _selectedTipiDip.remove(tipo);
                                    _currentPage = 0;
                                  });
                                },
                              );
                            }),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _statusFilter = ReinseritoFilter.all;
                                  _selectedSociete.clear();
                                  _selectedSpese.clear();
                                  _selectedTipiDip.clear();
                                  _startDate = null;
                                  _endDate = null;
                                  _currentPage = 0;
                                });
                              },
                              child: const Text(
                                'Reset tutto',
                                style: TextStyle(fontSize: 12, color: Colors.red, fontFamily: 'TIMSans'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    // Stats cards list
                    isWide
                        ? Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'TOTALE SCARTI FILTRATI',
                                  '$totalUnmatchedRecords record',
                                  'Importo: ${_formatAmount(totalAmountFiltered)}',
                                  Icons.warning_amber_rounded,
                                  SkyTheme.timBlue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'DA REINSERIRE',
                                  '$pendingCount record',
                                  'Importo: ${_formatAmount(pendingAmount)}',
                                  Icons.error_outline_rounded,
                                  SkyTheme.timRed,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'REINSERITI CON SUCCESSO',
                                  '$reinsertedCount record',
                                  'Importo: ${_formatAmount(reinsertedAmount)}',
                                  Icons.check_circle_outline_rounded,
                                  Colors.green.shade700,
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildStatCard(
                                'TOTALE SCARTI FILTRATI',
                                '$totalUnmatchedRecords record',
                                'Importo: ${_formatAmount(totalAmountFiltered)}',
                                Icons.warning_amber_rounded,
                                SkyTheme.timBlue,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                'DA REINSERIRE',
                                '$pendingCount record',
                                'Importo: ${_formatAmount(pendingAmount)}',
                                Icons.error_outline_rounded,
                                SkyTheme.timRed,
                              ),
                              const SizedBox(height: 12),
                              _buildStatCard(
                                'REINSERITI CON SUCCESSO',
                                '$reinsertedCount record',
                                'Importo: ${_formatAmount(reinsertedAmount)}',
                                Icons.check_circle_outline_rounded,
                                Colors.green.shade700,
                              ),
                            ],
                          ),
                  ],
                ),
              ),

              // Main content: table of grouped rows
              Expanded(
                child: allRecords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 64,
                              color: Colors.green.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'NESSUNA TRASFERTA SCARTATA DA ELABORARE',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                                fontFamily: 'TIMSans',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tutti i record scartati sono stati reinseriti o non ci sono dati.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontFamily: 'TIMSans',
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredGroups.isEmpty
                        ? Center(
                            child: Text(
                              'Nessun risultato corrisponde ai filtri selezionati.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontFamily: 'TIMSans',
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(24),
                            child: Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: Colors.grey.shade200),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Scrollbar(
                                      controller: _horizontalScrollController,
                                      thumbVisibility: true,
                                      child: SingleChildScrollView(
                                        controller: _horizontalScrollController,
                                        scrollDirection: Axis.horizontal,
                                        child: SizedBox(
                                          width: 1600,
                                          child: Column(
                                            children: [
                                              // Header Table Row
                                              Container(
                                                height: 48,
                                                color: Colors.grey.shade100,
                                                child: Row(
                                                  children: [
                                                    _buildCell('', 50, isHeader: true), // Chevron col
                                                    _buildCell('CID', 110, isHeader: true),
                                                    _buildCell('NOMINATIVO', 200, isHeader: true),
                                                    _buildCell('SOCIETÀ', 180, isHeader: true),
                                                    _buildCell('TRASFERTA', 140, isHeader: true),
                                                    _buildCell('TIPO SPESA', 220, isHeader: true),
                                                    _buildCell('DATA INVIO (PIÙ VECCHIA)', 180, isHeader: true),
                                                    _buildCell('ULTIMO INVIO', 150, isHeader: true),
                                                    _buildCell('OCCORRENZE', 100, isHeader: true, alignment: Alignment.center),
                                                    _buildCell('REINSERITO', 150, isHeader: true, alignment: Alignment.center),
                                                    _buildCell('IMPORTO', 120, isHeader: true, alignment: Alignment.centerRight),
                                                  ],
                                                ),
                                              ),
                                              // Data rows
                                              Expanded(
                                                child: Scrollbar(
                                                  controller: _scrollController,
                                                  child: ListView.builder(
                                                    controller: _scrollController,
                                                    itemCount: paginatedGroups.length,
                                                    itemBuilder: (context, index) {
                                                      final group = paginatedGroups[index];
                                                      final nominativo = anagraficaMap[group.cid] ?? '-';
                                                      
                                                      final dipType = anagraficaTipoDipMap[group.cid] ?? '';
                                                      final dipTypeDesc = dipType.isNotEmpty
                                                          ? (dictionaryMap[dipType.toUpperCase()] ?? dipType)
                                                          : '';
                                                      final displayDipType = dipType.isNotEmpty
                                                          ? (dipType != dipTypeDesc ? '$dipType - $dipTypeDesc' : dipType)
                                                          : '';
                                                      
                                                      final companyCode = anagraficaSocietaMap[group.cid] ?? '';
                                                      final companyDesc = companyCode.isNotEmpty
                                                          ? (dictionaryMap[companyCode.toUpperCase()] ?? companyCode)
                                                          : '';
                                                      final displayCompany = companyDesc.isNotEmpty
                                                          ? (companyCode != companyDesc ? '$companyCode - $companyDesc' : companyCode)
                                                          : '-';

                                                      final spesaDesc = dictionaryMap[group.spesa.toUpperCase()] ?? '';
                                                      final displaySpesa = spesaDesc.isNotEmpty
                                                          ? '${group.spesa} - $spesaDesc'
                                                          : group.spesa;

                                                      final dateStr = group.items.first.dataInvio;
                                                      final displayDate = dateStr;

                                                      final isEven = index % 2 == 0;
                                                      final amountColor = group.importo < 0 ? SkyTheme.timRed : Colors.green.shade700;

                                                      final groupKey = "${group.numeroTrasferta}_${group.importo}_${group.cid}_${group.spesa}";
                                                      final isExpanded = _expandedGroups.contains(groupKey);
                                                      final isReinserted = groupMatchCache[groupKey] ?? false;

                                                      return Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            height: 52,
                                                            decoration: BoxDecoration(
                                                              color: isEven ? Colors.white : Colors.grey.shade50,
                                                              border: Border(
                                                                bottom: BorderSide(color: Colors.grey.shade100),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                _buildCell(
                                                                  '',
                                                                  50,
                                                                  child: IconButton(
                                                                    icon: Icon(
                                                                      isExpanded
                                                                          ? Icons.keyboard_arrow_down_rounded
                                                                          : Icons.keyboard_arrow_right_rounded,
                                                                      color: SkyTheme.timBlue,
                                                                    ),
                                                                    onPressed: () {
                                                                      setState(() {
                                                                        if (isExpanded) {
                                                                          _expandedGroups.remove(groupKey);
                                                                        } else {
                                                                          _expandedGroups.add(groupKey);
                                                                        }
                                                                      });
                                                                    },
                                                                    padding: EdgeInsets.zero,
                                                                  ),
                                                                ),
                                                                _buildCell(
                                                                  '',
                                                                  110,
                                                                  child: Tooltip(
                                                                    message: 'Clicca per copiare il CID',
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        Clipboard.setData(ClipboardData(text: group.cid));
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text('CID ${group.cid} copiato negli appunti'),
                                                                            duration: const Duration(seconds: 1),
                                                                            backgroundColor: SkyTheme.timBlue,
                                                                          ),
                                                                        );
                                                                      },
                                                                      borderRadius: BorderRadius.circular(4),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Text(
                                                                              group.cid,
                                                                              style: const TextStyle(
                                                                                fontSize: 13,
                                                                                color: Colors.black87,
                                                                                fontFamily: 'TIMSans',
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 4),
                                                                            Icon(Icons.copy_all_rounded, size: 14, color: Colors.grey.shade400),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                _buildCell(
                                                                  '',
                                                                  200,
                                                                  child: Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Text(
                                                                        nominativo,
                                                                        style: const TextStyle(
                                                                          fontSize: 13,
                                                                          fontWeight: FontWeight.w500,
                                                                          color: Colors.black87,
                                                                          fontFamily: 'TIMSans',
                                                                        ),
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                      if (displayDipType.isNotEmpty) ...[
                                                                        const SizedBox(height: 2),
                                                                        Text(
                                                                          displayDipType,
                                                                          style: TextStyle(
                                                                            fontSize: 10,
                                                                            color: Colors.grey.shade600,
                                                                            fontFamily: 'TIMSans',
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                        ),
                                                                      ],
                                                                    ],
                                                                  ),
                                                                ),
                                                                _buildCell(displayCompany, 180),
                                                                _buildCell(
                                                                  '',
                                                                  140,
                                                                  child: Tooltip(
                                                                    message: 'Clicca per copiare il numero trasferta',
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        Clipboard.setData(ClipboardData(text: group.numeroTrasferta));
                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                          SnackBar(
                                                                            content: Text('Trasferta ${group.numeroTrasferta} copiata negli appunti'),
                                                                            duration: const Duration(seconds: 1),
                                                                            backgroundColor: SkyTheme.timBlue,
                                                                          ),
                                                                        );
                                                                      },
                                                                      borderRadius: BorderRadius.circular(4),
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                                        child: Row(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Text(
                                                                              group.numeroTrasferta,
                                                                              style: const TextStyle(
                                                                                fontSize: 13,
                                                                                color: Colors.black87,
                                                                                fontFamily: 'TIMSans',
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 4),
                                                                            Icon(Icons.copy_all_rounded, size: 14, color: Colors.grey.shade400),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                _buildCell(displaySpesa, 220),
                                                                _buildCell(displayDate, 180),
                                                                _buildCell(group.items.last.dataInvio, 150),
                                                                _buildCell(
                                                                  '',
                                                                  100,
                                                                  alignment: Alignment.center,
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                                    decoration: BoxDecoration(
                                                                      color: SkyTheme.timBlue.withAlpha(20),
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    child: Text(
                                                                      '${group.items.length}',
                                                                      style: const TextStyle(
                                                                        fontSize: 11,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: SkyTheme.timBlue,
                                                                        fontFamily: 'TIMSans',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                _buildCell(
                                                                  '',
                                                                  150,
                                                                  alignment: Alignment.center,
                                                                  child: Container(
                                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                                    decoration: BoxDecoration(
                                                                      color: isReinserted
                                                                          ? Colors.green.shade50
                                                                          : Colors.orange.shade50,
                                                                      borderRadius: BorderRadius.circular(8),
                                                                      border: Border.all(
                                                                        color: isReinserted
                                                                            ? Colors.green.shade200
                                                                            : Colors.orange.shade200,
                                                                      ),
                                                                    ),
                                                                    child: Text(
                                                                      isReinserted ? 'REINSERITO' : 'DA REINSERIRE',
                                                                      style: TextStyle(
                                                                        fontSize: 10,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: isReinserted
                                                                            ? Colors.green.shade800
                                                                            : Colors.orange.shade800,
                                                                        fontFamily: 'TIMSans',
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                _buildCell(
                                                                  _formatAmount(group.importo, group.items.first.divisa),
                                                                  120,
                                                                  alignment: Alignment.centerRight,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: amountColor,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          if (isExpanded)
                                                            _buildExpandedSection(group, dictionaryMap, allLogs),
                                                        ],
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

                                  // Pagination bar
                                  if (totalPages > 1)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        border: Border(
                                          top: BorderSide(color: Colors.grey.shade200),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Visualizzati ${startIndex + 1} - $endIndex di ${filteredGroups.length} righe raggruppate',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                              fontFamily: 'TIMSans',
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.chevron_left),
                                                onPressed: safePage > 0
                                                    ? () => setState(() => _currentPage--)
                                                    : null,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Pagina ${safePage + 1} di $totalPages',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'TIMSans',
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: const Icon(Icons.chevron_right),
                                                onPressed: safePage < totalPages - 1
                                                    ? () => setState(() => _currentPage++)
                                                    : null,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HelperFontWeight {
  static const FontWeight normal = FontWeight.normal;
}
