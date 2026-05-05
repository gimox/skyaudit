import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import '../dashboard_view.dart';

final dashboardStatsProvider = Provider((ref) {
  final allRecords = ref.watch(tracciatoContabilesProvider);
  final selectedYear = ref.watch(dashboardYearProvider);
  
  // Filtra i record per l'anno selezionato
  final records = allRecords.where((r) {
    final parts = r.dataSpesa.split('/');
    return parts.length == 3 && parts[2] == selectedYear.toString();
  }).toList();

  if (records.isEmpty) return (totalTickets: 0, totalTrasferte: 0, totalAmount: 0.0);

  final totalTickets = records.length;
  final totalTrasferte = records.map((r) => r.numeroTrasferta).toSet().length;
  
  double totalAmount = 0;
  for (final r in records) {
    totalAmount += r.isNegative ? -r.importo : r.importo;
  }

  return (
    totalTickets: totalTickets,
    totalTrasferte: totalTrasferte,
    totalAmount: totalAmount
  );
});

final dashboardAvailableYearsProvider = Provider((ref) {
  final records = ref.watch(tracciatoContabilesProvider);
  final years = records
      .map((r) {
        final parts = r.dataSpesa.split('/');
        return parts.length == 3 ? int.tryParse(parts[2]) : null;
      })
      .whereType<int>()
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  if (!years.contains(DateTime.now().year)) {
    years.add(DateTime.now().year);
    years.sort((a, b) => b.compareTo(a));
  }
  return years;
});

final dashboardFilteredRecordsProvider = Provider((ref) {
  final records = ref.watch(tracciatoContabilesProvider);
  final year = ref.watch(dashboardYearProvider);
  
  return records.where((r) {
    final parts = r.dataSpesa.split('/');
    return parts.length == 3 && parts[2] == year.toString();
  }).toList();
});

final dashboardTopCidByTripsProvider = Provider((ref) {
  final records = ref.watch(dashboardFilteredRecordsProvider);
  if (records.isEmpty) return <MapEntry<String, int>>[];

  // Mappa CID -> Set di numeroTrasferta (per contare viaggi unici)
  final Map<String, Set<String>> cidTrips = {};
  for (final r in records) {
    cidTrips.putIfAbsent(r.cid, () => {});
    cidTrips[r.cid]!.add(r.numeroTrasferta);
  }

  final sortedEntries = cidTrips.entries
      .map((e) => MapEntry(e.key, e.value.length))
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sortedEntries.take(20).toList();
});

final dashboardTopCidByAmountProvider = Provider((ref) {
  final records = ref.watch(dashboardFilteredRecordsProvider);
  if (records.isEmpty) return <MapEntry<String, double>>[];

  // Mappa CID -> Somma Importi
  final Map<String, double> cidAmounts = {};
  for (final r in records) {
    final value = r.isNegative ? -r.importo : r.importo;
    cidAmounts[r.cid] = (cidAmounts[r.cid] ?? 0) + value;
  }

  final sortedEntries = cidAmounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sortedEntries.take(20).toList();
});

final dashboardAmountByTypeProvider = Provider((ref) {
  final records = ref.watch(dashboardFilteredRecordsProvider);
  if (records.isEmpty) return <MapEntry<String, double>>[];

  final Map<String, double> typeAmounts = {};
  for (final r in records) {
    final value = r.isNegative ? -r.importo : r.importo;
    final tipo = r.tipoDipendente.trim().isEmpty ? 'Sconosciuto' : r.tipoDipendente;
    typeAmounts[tipo] = (typeAmounts[tipo] ?? 0) + value;
  }

  return typeAmounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
});

final dashboardTripsByTypeProvider = Provider((ref) {
  final records = ref.watch(dashboardFilteredRecordsProvider);
  if (records.isEmpty) return <MapEntry<String, double>>[];

  final Map<String, Set<String>> typeTrips = {};
  for (final r in records) {
    final tipo = r.tipoDipendente.trim().isEmpty ? 'Sconosciuto' : r.tipoDipendente;
    typeTrips.putIfAbsent(tipo, () => {});
    typeTrips[tipo]!.add(r.numeroTrasferta);
  }

  return typeTrips.entries
      .map((e) => MapEntry(e.key, e.value.length.toDouble()))
      .toList()
    ..sort((a, b) => b.value.compareTo(a.value));
});

final dashboardAvgCostByTypeProvider = Provider((ref) {
  final amounts = ref.watch(dashboardAmountByTypeProvider);
  final trips = ref.watch(dashboardTripsByTypeProvider);
  
  if (amounts.isEmpty || trips.isEmpty) return (avgByType: <MapEntry<String, double>>[], overallAvg: 0.0);

  final tripsMap = Map.fromEntries(trips);
  final avgMap = <String, double>{};
  
  double totalAmount = 0;
  double totalTrips = 0;

  for (final amountEntry in amounts) {
    final type = amountEntry.key;
    final amount = amountEntry.value;
    final tripCount = tripsMap[type] ?? 0;
    
    totalAmount += amount;
    totalTrips += tripCount;
    
    if (tripCount > 0) {
      avgMap[type] = amount / tripCount;
    }
  }

  final sortedEntries = avgMap.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
    
  final overallAvg = totalTrips > 0 ? totalAmount / totalTrips : 0.0;

  return (avgByType: sortedEntries, overallAvg: overallAvg);
});
