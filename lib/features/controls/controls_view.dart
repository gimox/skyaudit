import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';

final controlsMonthProvider = StateProvider<Set<String>>((ref) => {});
final controlsYearProvider = StateProvider<String?>((ref) => null);
final controlsSearchProvider = StateProvider<String>((ref) => '');
final controlsSocietaProvider = StateProvider<Set<String>>((ref) => {});
final controlsCidProvider = StateProvider<String>((ref) => '');

class ControlsView extends ConsumerStatefulWidget {
  const ControlsView({super.key});

  @override
  ConsumerState<ControlsView> createState() => _ControlsViewState();
}

class _ControlsViewState extends ConsumerState<ControlsView> {
  final _searchController = TextEditingController();
  final _cidController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _cidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(tracciatoContabilesProvider);

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
    final searchCid = ref.watch(controlsCidProvider);

    final availableYears = allRecords.map((r) {
      final parts = r.dataFine.split('/');
      return parts.length == 3 ? parts[2] : '';
    }).where((y) => y.isNotEmpty).toSet().toList()..sort();

    final availableSocieta = allRecords.map((r) => r.societa).where((s) => s.isNotEmpty).toSet().toList()..sort();

    const monthNames = {
      '01': 'Gennaio', '02': 'Febbraio', '03': 'Marzo',
      '04': 'Aprile', '05': 'Maggio', '06': 'Giugno',
      '07': 'Luglio', '08': 'Agosto', '09': 'Settembre',
      '10': 'Ottobre', '11': 'Novembre', '12': 'Dicembre',
    };

    final Map<String, List<TracciatoContabile>> groupedRecords = {};
    for (final record in allRecords) {
      groupedRecords.putIfAbsent(record.numeroTrasferta, () => []).add(record);
    }

    var trasferte = groupedRecords.keys.toList();

    if (searchQuery.isNotEmpty) {
      trasferte = trasferte.where((t) => t.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }

    if (searchCid.isNotEmpty) {
      trasferte = trasferte.where((t) => groupedRecords[t]!.first.cid.contains(searchCid)).toList();
    }

    if (selectedMonth.isNotEmpty || selectedYear != null || selectedSocieta.isNotEmpty) {
      trasferte = trasferte.where((t) {
        final firstRecord = groupedRecords[t]!.first;
        
        if (selectedSocieta.isNotEmpty && !selectedSocieta.contains(firstRecord.societa)) return false;

        if (selectedMonth.isNotEmpty || selectedYear != null) {
          final parts = firstRecord.dataFine.split('/');
          if (parts.length != 3) return false;
          
          final m = parts[1];
          final y = parts[2];

          if (selectedMonth.isNotEmpty && !selectedMonth.contains(m)) return false;
          if (selectedYear != null && selectedYear != y) return false;
        }

        return true;
      }).toList();
    }

    trasferte.sort();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'CONTROLLI TRASFERTE',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const Spacer(),
              Chip(
                label: Text('${trasferte.length} Trasferte'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ],
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      const DropdownMenuItem(value: null, child: Text('Tutti gli Anni')),
                      ...availableYears.map((y) => DropdownMenuItem(value: y, child: Text(y))),
                    ],
                    onChanged: (value) => ref.read(controlsYearProvider.notifier).state = value,
                  ),
                ),
              ),
              // Filtro Società (Multi-select Dialog)
              InkWell(
                onTap: () => _showMultiSelectSocieta(context, availableSocieta),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (value) => ref.read(controlsSearchProvider.notifier).state = value,
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (value) => ref.read(controlsCidProvider.notifier).state = value,
                ),
              ),
              // Reset Filtri
              if (selectedMonth.isNotEmpty || selectedYear != null || selectedSocieta.isNotEmpty || searchQuery.isNotEmpty || searchCid.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    ref.read(controlsMonthProvider.notifier).state = <String>{};
                    ref.read(controlsYearProvider.notifier).state = null;
                    ref.read(controlsSocietaProvider.notifier).state = <String>{};
                    ref.read(controlsSearchProvider.notifier).state = '';
                    ref.read(controlsCidProvider.notifier).state = '';
                    _searchController.clear();
                    _cidController.clear();
                  },
                  icon: const Icon(Icons.filter_alt_off),
                  label: const Text('Reset Filtri'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: trasferte.length,
              itemBuilder: (context, index) {
                final numeroTrasferta = trasferte[index];
                final recordsTrasferta = groupedRecords[numeroTrasferta]!;
                final firstRecord = recordsTrasferta.first;
                
                double totaleTrasferta = 0.0;
                for(var r in recordsTrasferta) {
                  totaleTrasferta += r.isNegative ? -r.importo : r.importo;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ExpansionTile(
                    title: Text(
                      'Trasferta: $numeroTrasferta',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${recordsTrasferta.length} record • Dal ${firstRecord.dataInizio} al ${firstRecord.dataFine} • Totale: ${totaleTrasferta.toStringAsFixed(2)} EUR • Società: ${firstRecord.societa} • Tipo: ${firstRecord.tipoDipendente}'),
                    leading: const Icon(Icons.flight_takeoff),
                    children: recordsTrasferta.asMap().entries.map((entry) {
                      final index = entry.key;
                      final record = entry.value;
                      final isEven = index % 2 == 0;

                      return Container(
                        color: isEven ? Colors.transparent : Colors.grey.shade50,
                        child: ListTile(
                          title: Text(record.localita.isEmpty ? 'Località non specificata' : record.localita),
                          subtitle: Text('Bolla: ${record.numeroBolla} • Giustificativo: ${record.giustificativoSpesa}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: record.isNegative ? Colors.red.shade700 : Colors.green.shade800,
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.visibility_outlined, color: Colors.blue),
                                onPressed: () => _showRecordDetails(context, record),
                                tooltip: 'Visualizza Dettagli',
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, TracciatoContabile record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Dettaglio Record - ${record.numeroBolla}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  _buildDetailRow('Società', record.societa),
                  _buildDetailRow('Tipo Dipendente', record.tipoDipendente),
                  _buildDetailRow('Giustificativo', record.giustificativoSpesa),
                  _buildDetailRow('Numero Bolla', record.numeroBolla),
                  _buildDetailRow('Data Spesa', record.dataSpesa),
                  _buildDetailRow('Località', record.localita),
                  _buildDetailRow('Inizio', '${record.dataInizio} ${record.oraInizio}'),
                  _buildDetailRow('Fine', '${record.dataFine} ${record.oraFine}'),
                  _buildDetailRow('Tipo Attività', record.tipoAttivita),
                  _buildDetailRow('Importo', '${record.isNegative ? "-" : ""}${record.importo.toStringAsFixed(2)} ${record.valuta}', isHighlight: true),
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

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
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

  void _showMultiSelectSocieta(BuildContext context, List<String> availableSocieta) {
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
                          final notifier = ref.read(controlsSocietaProvider.notifier);
                          if (value == true) {
                            notifier.state = {...selectedSocieta, s};
                          } else {
                            notifier.state = {...selectedSocieta}..remove(s);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => ref.read(controlsSocietaProvider.notifier).state = <String>{},
                  child: const Text('Cancella Filtro'),
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

  void _showMultiSelectMesi(BuildContext context, Map<String, String> monthNames) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final selectedMesi = ref.watch(controlsMonthProvider);
            return AlertDialog(
              title: const Text('Seleziona Mesi'),
              content: SizedBox(
                width: 350,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: monthNames.entries.map((e) {
                      final mId = e.key;
                      final mName = e.value;
                      final isSelected = selectedMesi.contains(mId);
                      return CheckboxListTile(
                        title: Text(mName),
                        value: isSelected,
                        onChanged: (bool? value) {
                          final notifier = ref.read(controlsMonthProvider.notifier);
                          if (value == true) {
                            notifier.state = {...selectedMesi, mId};
                          } else {
                            notifier.state = {...selectedMesi}..remove(mId);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => ref.read(controlsMonthProvider.notifier).state = <String>{},
                  child: const Text('Cancella Filtro'),
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
