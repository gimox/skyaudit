import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/dashboard/providers/dashboard_providers.dart';

final dashboardYearProvider = StateProvider<int>((ref) => DateTime.now().year);

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final _statsScrollController = ScrollController();

  @override
  void dispose() {
    _statsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final allRecords = ref.watch(tracciatoContabilesProvider);
    final selectedYear = ref.watch(dashboardYearProvider);
    final topCidsByTrips = ref.watch(dashboardTopCidByTripsProvider);
    final topCidsByAmount = ref.watch(dashboardTopCidByAmountProvider);
    final amountByType = ref.watch(dashboardAmountByTypeProvider);
    final tripsByType = ref.watch(dashboardTripsByTypeProvider);
    final avgCostByTypeData = ref.watch(dashboardAvgCostByTypeProvider);

    if (allRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(75),
            ),
            const SizedBox(height: 24),
            const Text(
              'NESSUN DATO DISPONIBILE',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Carica un file per visualizzare le statistiche',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final stats = ref.watch(dashboardStatsProvider);
    final filteredRecords = ref.watch(dashboardFilteredRecordsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox.shrink(),
                        const SizedBox(height: 16),
                        _buildYearSelector(context, ref, selectedYear),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox.shrink(),
                        _buildYearSelector(context, ref, selectedYear),
                      ],
                    ),
              const SizedBox(height: 32),

              // Indicatori
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100.withAlpha(120),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final card1 = _buildStatCard(
                      context: context,
                      title: 'TOTALE TRASFERTE',
                      value: stats.totalTrasferte.toString(),
                      icon: Icons.travel_explore,
                      color: SkyTheme.timBlue,
                    );
                    final card2 = _buildStatCard(
                      context: context,
                      title: 'SINGOLI TICKET',
                      value: stats.totalTickets.toString(),
                      icon: Icons.confirmation_number_outlined,
                      color: Colors.orange.shade700,
                    );
                    final card3 = _buildStatCard(
                      context: context,
                      title: 'TOTALE IMPORTI TC',
                      value: '€ ${_formatAmount(stats.totalAmountTC)}',
                      icon: Icons.euro_symbol,
                      color: SkyTheme.timBlue,
                    );
                    final card4 = _buildStatCard(
                      context: context,
                      title: 'TOTALE IMPORTI E.C.',
                      value: '€ ${_formatAmount(stats.totalAmountEC)}',
                      icon: Icons.receipt_long,
                      color: Colors.green.shade700,
                    );

                    if (constraints.maxWidth >= 1100) {
                      return Row(
                        children: [
                          Expanded(child: card1),
                          const SizedBox(width: 16),
                          Expanded(child: card2),
                          const SizedBox(width: 16),
                          Expanded(child: card3),
                          const SizedBox(width: 16),
                          Expanded(child: card4),
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
                                  SizedBox(width: 250, child: card1),
                                  const SizedBox(width: 16),
                                  SizedBox(width: 250, child: card2),
                                  const SizedBox(width: 16),
                                  SizedBox(width: 250, child: card3),
                                  const SizedBox(width: 16),
                                  SizedBox(width: 250, child: card4),
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

              const SizedBox(height: 48),

              // Grafico
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRASFERTE PER MESE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Andamento mensile delle trasferte uniche per l\'anno $selectedYear',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 300,
                      child: _TrasferteLineChart(records: filteredRecords),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Secondo Grafico: Importi
              Container(
                padding: const EdgeInsets.all(24),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IMPORTI TRASFERTE (€)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Somma totale degli importi netti per l\'anno $selectedYear',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 300,
                      child: _ImportiLineChart(records: filteredRecords),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Terzi Grafici: Torte per Tipo Dipendente
              if (isMobile)
                Column(
                  children: [
                    _buildPieChartCard(
                      title: 'N. TRASFERTE PER TIPO DIPENDENTE',
                      subtitle:
                          'Suddivisione del numero di trasferte per tipologia nell\'anno $selectedYear',
                      data: tripsByType,
                      isCurrency: false,
                    ),
                    const SizedBox(height: 32),
                    _buildPieChartCard(
                      title: 'IMPORTI PER TIPO DIPENDENTE (€)',
                      subtitle:
                          'Suddivisione degli importi per tipologia nell\'anno $selectedYear',
                      data: amountByType,
                      isCurrency: true,
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildPieChartCard(
                        title: 'N. TRASFERTE PER TIPO DIPENDENTE',
                        subtitle:
                            'Suddivisione del numero di trasferte per tipologia nell\'anno $selectedYear',
                        data: tripsByType,
                        isCurrency: false,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildPieChartCard(
                        title: 'IMPORTI PER TIPO DIPENDENTE (€)',
                        subtitle:
                            'Suddivisione degli importi per tipologia nell\'anno $selectedYear',
                        data: amountByType,
                        isCurrency: true,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Costo Medio per Tipo Dipendente
              Container(
                padding: const EdgeInsets.all(24),
                height: 450,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: const Text(
                            'COSTO MEDIO PER TIPO DIPENDENTE (€/TRASFERTA)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Media Globale: €${avgCostByTypeData.overallAvg.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rapporto tra importo totale e numero di trasferte per ogni tipologia (Anno $selectedYear)',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: _TopCidBarChart(
                        data: avgCostByTypeData.avgByType,
                        isCurrency: true,
                        multiColor: true,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Grafici Top 20
              if (isMobile)
                Column(
                  children: [
                    _buildTopCidCard(
                      title: 'TOP 20 CID (N. VIAGGI)',
                      subtitle:
                          'I 20 CID con il maggior numero di trasferte uniche',
                      data: topCidsByTrips
                          .map((e) => MapEntry(e.key, e.value.toDouble()))
                          .toList(),
                      isCurrency: false,
                    ),
                    const SizedBox(height: 32),
                    _buildTopCidCard(
                      title: 'TOP 20 CID (IMPORTI €)',
                      subtitle: 'I 20 CID con la spesa complessiva più elevata',
                      data: topCidsByAmount,
                      isCurrency: true,
                      color: SkyTheme.timRed,
                    ),
                  ],
                )
              else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTopCidCard(
                        title: 'TOP 20 CID (N. VIAGGI)',
                        subtitle:
                            'I 20 CID con il maggior numero di trasferte uniche',
                        data: topCidsByTrips
                            .map((e) => MapEntry(e.key, e.value.toDouble()))
                            .toList(),
                        isCurrency: false,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTopCidCard(
                        title: 'TOP 20 CID (IMPORTI €)',
                        subtitle:
                            'I 20 CID con la spesa complessiva più elevata',
                        data: topCidsByAmount,
                        isCurrency: true,
                        color: SkyTheme.timRed,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatAmount(double amount) {
    return NumberFormat.currency(
      locale: 'it_IT',
      symbol: '',
      decimalDigits: 2,
    ).format(amount);
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
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
              color: color.withAlpha(20),
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
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard({
    required String title,
    required String subtitle,
    required List<MapEntry<String, double>> data,
    required bool isCurrency,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 250,
            child: _TipoDipendentePieChart(data: data, isCurrency: isCurrency),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCidCard({
    required String title,
    required String subtitle,
    required List<MapEntry<String, double>> data,
    required bool isCurrency,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: 500,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: _TopCidBarChart(
              data: data,
              isCurrency: isCurrency,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(
    BuildContext context,
    WidgetRef ref,
    int selectedYear,
  ) {
    final availableYears = ref.watch(dashboardAvailableYearsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: selectedYear,
          items: availableYears.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(
                year.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(dashboardYearProvider.notifier).state = value;
            }
          },
        ),
      ),
    );
  }
}

class _TrasferteLineChart extends StatelessWidget {
  final List<TracciatoContabile> records;

  const _TrasferteLineChart({required this.records});

  @override
  Widget build(BuildContext context) {
    // Organizza i dati: Anno -> Mese -> Set di numeroTrasferta
    final Map<int, Map<int, Set<String>>> data = {};

    for (final r in records) {
      final parts = r.dataSpesa.split('/');
      if (parts.length == 3) {
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (month != null && year != null) {
          data.putIfAbsent(year, () => {});
          data[year]!.putIfAbsent(month, () => {});
          data[year]![month]!.add(r.numeroTrasferta);
        }
      }
    }

    final years = data.keys.toList()..sort();
    final List<LineChartBarData> lineBarsData = [];

    // Colori per i diversi anni
    final List<Color> yearColors = [
      SkyTheme.timBlue,
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
    ];

    for (int i = 0; i < years.length; i++) {
      final year = years[i];
      final monthData = data[year]!;
      final List<FlSpot> spots = [];

      for (int m = 1; m <= 12; m++) {
        final count = monthData[m]?.length ?? 0;
        spots.add(FlSpot(m.toDouble(), count.toDouble()));
      }

      lineBarsData.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: yearColors[i % yearColors.length],
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: yearColors[i % yearColors.length].withAlpha(10),
          ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = [
                  'GEN',
                  'FEB',
                  'MAR',
                  'APR',
                  'MAG',
                  'GIU',
                  'LUG',
                  'AGO',
                  'SET',
                  'OTT',
                  'NOV',
                  'DIC',
                ];
                if (value >= 1 && value <= 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[value.toInt() - 1],
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: lineBarsData,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final year = years[spot.barIndex];
                return LineTooltipItem(
                  'Anno $year: ${spot.y.toInt()} trasferte',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

class _ImportiLineChart extends StatelessWidget {
  final List<TracciatoContabile> records;

  const _ImportiLineChart({required this.records});

  @override
  Widget build(BuildContext context) {
    // Organizza i dati: Mese -> Somma Importi
    final Map<int, double> monthData = {};

    for (final r in records) {
      final parts = r.dataSpesa.split('/');
      if (parts.length == 3) {
        final month = int.tryParse(parts[1]);
        if (month != null) {
          final value = r.isNegative ? -r.importo : r.importo;
          monthData[month] = (monthData[month] ?? 0) + value;
        }
      }
    }

    final List<FlSpot> spots = [];
    for (int m = 1; m <= 12; m++) {
      final total = monthData[m] ?? 0.0;
      spots.add(FlSpot(m.toDouble(), total));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const Text(
                    '0 €',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                if (value >= 1000) {
                  return Text(
                    '${(value / 1000).toStringAsFixed(1)}k €',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  );
                }
                return Text(
                  '${value.toInt()} €',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = [
                  'GEN',
                  'FEB',
                  'MAR',
                  'APR',
                  'MAG',
                  'GIU',
                  'LUG',
                  'AGO',
                  'SET',
                  'OTT',
                  'NOV',
                  'DIC',
                ];
                if (value >= 1 && value <= 12) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[value.toInt() - 1],
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.green.shade600,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.shade600.withAlpha(10),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(2)} €',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

class _TopCidBarChart extends StatelessWidget {
  final List<MapEntry<String, double>> data;
  final bool isCurrency;
  final Color? color;
  final bool multiColor;

  const _TopCidBarChart({
    required this.data,
    required this.isCurrency,
    this.color,
    this.multiColor = false,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Nessun dato disponibile',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.isNotEmpty ? (data.first.value * 1.2) : 100,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        data[value.toInt()].key,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        barGroups: List.generate(data.length, (index) {
          final barColor = multiColor
              ? [
                  SkyTheme.timBlue,
                  SkyTheme.timRed,
                  Colors.green.shade600,
                  Colors.orange.shade600,
                  Colors.purple.shade600,
                  Colors.teal.shade600,
                  Colors.pink.shade600,
                ][index % 7]
              : (color ?? SkyTheme.timBlue);

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data[index].value,
                color: barColor,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: data.first.value * 1.2,
                  color: Colors.grey.shade100,
                ),
              ),
            ],
          );
        }),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = data[groupIndex].key;
              final val = data[groupIndex].value;
              return BarTooltipItem(
                '$label\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: isCurrency
                        ? '${val.toStringAsFixed(2)} €'
                        : '${val.toInt()} viaggi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TipoDipendentePieChart extends StatelessWidget {
  final List<MapEntry<String, double>> data;
  final bool isCurrency;

  const _TipoDipendentePieChart({required this.data, this.isCurrency = true});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Nessun dato'));

    final colors = [
      SkyTheme.timBlue,
      SkyTheme.timRed,
      Colors.green.shade600,
      Colors.orange.shade600,
      Colors.purple.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
    ];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: data.asMap().entries.map((entry) {
                final index = entry.key;
                final mapEntry = entry.value;
                final total = data.fold<double>(0, (p, c) => p + c.value);
                final percentage = total > 0
                    ? (mapEntry.value / total * 100)
                    : 0.0;

                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: mapEntry.value,
                  title: '',
                  radius: 60,
                  badgeWidget: _Badge('${percentage.toStringAsFixed(1)}%'),
                  badgePositionPercentageOffset: 1.2,
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.asMap().entries.map((entry) {
              final index = entry.key;
              final mapEntry = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isCurrency
                            ? '${mapEntry.key}: €${mapEntry.value.toStringAsFixed(2)}'
                            : '${mapEntry.key}: ${mapEntry.value.toInt()}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
