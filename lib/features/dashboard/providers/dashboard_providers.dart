import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import '../dashboard_view.dart';

final dashboardStatsProvider = Provider((ref) {
  final allRecords = ref.watch(tracciatoContabilesProvider);
  final ecRecords = ref.watch(estrattoContoProvider);
  final selectedYear = ref.watch(dashboardYearProvider);

  // Filtra i record TC per l'anno selezionato
  final records = allRecords.where((r) {
    final parts = r.dataSpesa.split('/');
    if (parts.length == 3) {
      var yearStr = parts[2];
      if (yearStr.length == 2) yearStr = "20$yearStr";
      return yearStr == selectedYear.toString();
    }
    return false;
  }).toList();

  // Filtra i record EC per l'anno selezionato
  final filteredEC = ecRecords.where((r) {
    final parts = r.dataBolla.split('/');
    if (parts.length == 3) {
      var yearStr = parts[2];
      if (yearStr.length == 2) yearStr = "20$yearStr";
      return yearStr == selectedYear.toString();
    }
    return false;
  }).toList();

  final totalTickets = records.length;
  final totalTrasferte = records.map((r) => r.numeroTrasferta).toSet().length;

  double totalAmountTC = 0;
  for (final r in records) {
    totalAmountTC += r.isNegative ? -r.importo : r.importo;
  }

  double totalAmountEC = 0;
  for (final r in filteredEC) {
    totalAmountEC += r.totaleServizioGenerale + r.totaleFee;
  }

  return (
    totalTickets: totalTickets,
    totalTrasferte: totalTrasferte,
    totalAmountTC: totalAmountTC,
    totalAmountEC: totalAmountEC,
  );
});

final dashboardAvailableYearsProvider = Provider((ref) {
  final tcRecords = ref.watch(tracciatoContabilesProvider);
  final ecRecords = ref.watch(estrattoContoProvider);

  final Set<int> years = {};

  for (final r in tcRecords) {
    final parts = r.dataSpesa.split('/');
    if (parts.length == 3) {
      var yearStr = parts[2];
      if (yearStr.length == 2) yearStr = "20$yearStr";
      final y = int.tryParse(yearStr);
      if (y != null) years.add(y);
    }
  }

  for (final r in ecRecords) {
    final parts = r.dataBolla.split('/');
    if (parts.length == 3) {
      var yearStr = parts[2];
      if (yearStr.length == 2) yearStr = "20$yearStr";
      final y = int.tryParse(yearStr);
      if (y != null) years.add(y);
    }
  }

  final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));

  if (!sortedYears.contains(DateTime.now().year)) {
    sortedYears.add(DateTime.now().year);
    sortedYears.sort((a, b) => b.compareTo(a));
  }
  return sortedYears;
});

final dashboardFilteredRecordsProvider = Provider((ref) {
  final records = ref.watch(tracciatoContabilesProvider);
  final year = ref.watch(dashboardYearProvider);

  return records.where((r) {
    final parts = r.dataSpesa.split('/');
    if (parts.length == 3) {
      var yearStr = parts[2];
      if (yearStr.length == 2) yearStr = "20$yearStr";
      return yearStr == year.toString();
    }
    return false;
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

  final sortedEntries =
      cidTrips.entries.map((e) => MapEntry(e.key, e.value.length)).toList()
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
    final tipo = r.tipoDipendente.trim().isEmpty
        ? 'Sconosciuto'
        : r.tipoDipendente;
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
    final tipo = r.tipoDipendente.trim().isEmpty
        ? 'Sconosciuto'
        : r.tipoDipendente;
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

  if (amounts.isEmpty || trips.isEmpty) {
    return (avgByType: <MapEntry<String, double>>[], overallAvg: 0.0);
  }

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
