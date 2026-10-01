import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/providers/trasferte_sap_provider.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
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

  final totalTickets = records.where((r) => !r.isNegative && r.importo > 0.001).length;
  final Map<String, List<TracciatoContabile>> recordsByTrasferta = {};
  for (final r in records) {
    recordsByTrasferta.putIfAbsent(r.numeroTrasferta, () => []).add(r);
  }
  final totalTrasferte = recordsByTrasferta.values.where((list) {
    final regularRecords = list.where((r) => !r.isScarto);
    if (regularRecords.isEmpty) return false;

    final totalSum = list.fold<double>(0.0, (acc, r) => acc + (r.isNegative ? -r.importo : r.importo));
    if (totalSum.abs() < 0.001) return false;

    final regularSum = regularRecords.fold<double>(0.0, (acc, r) => acc + (r.isNegative ? -r.importo : r.importo));
    if (regularSum.abs() < 0.001) return false;

    return true;
  }).length;

  double totalAmountTC = 0;
  for (final r in records) {
    if (!r.isScarto && !r.isBonificato) {
      totalAmountTC += r.isNegative ? -r.importo : r.importo;
    }
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
  final tsRecords = ref.watch(trasferteSapProvider);
  final sapRecords = ref.watch(tracciatoSapProvider);

  final Set<int> years = {};

  int? parseYear(String dateStr) {
    if (dateStr.isEmpty) return null;
    final partsSlash = dateStr.split('/');
    if (partsSlash.length == 3) {
      var y = partsSlash[2].trim();
      if (y.length == 2) y = "20$y";
      return int.tryParse(y);
    }
    final partsDash = dateStr.split('-');
    if (partsDash.length == 3) {
      if (partsDash[0].length == 4) return int.tryParse(partsDash[0]);
      if (partsDash[2].length == 4) return int.tryParse(partsDash[2]);
    }
    return null;
  }

  for (final r in tcRecords) {
    final y = parseYear(r.dataSpesa);
    if (y != null) years.add(y);
  }

  for (final r in ecRecords) {
    final y = parseYear(r.dataBolla);
    if (y != null) years.add(y);
  }

  for (final r in tsRecords) {
    final y = parseYear(r.dataInizioTrasferta);
    if (y != null) years.add(y);
  }

  for (final r in sapRecords) {
    final y = parseYear(r.data);
    if (y != null) years.add(y);
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

class DashboardSapStats {
  final int totalTrasferteSap;
  final double totalAmountSap;
  final int okCount;
  final int koCount;
  final int uniqueCids;
  final bool hasData;

  const DashboardSapStats({
    required this.totalTrasferteSap,
    required this.totalAmountSap,
    required this.okCount,
    required this.koCount,
    required this.uniqueCids,
    required this.hasData,
  });
}

DateTime? _parseFlexibleDate(String dateStr) {
  if (dateStr.trim().isEmpty) return null;
  var s = dateStr.trim();
  // Rimuovi eventuale orario dopo lo spazio o 'T'
  if (s.contains(' ')) {
    s = s.split(' ').first.trim();
  }
  if (s.contains('T')) {
    s = s.split('T').first.trim();
  }
  if (s.isEmpty) return null;

  // 1. Prova DateTime.tryParse (ISO: YYYY-MM-DD)
  final iso = DateTime.tryParse(s);
  if (iso != null) return iso;

  // 2. Se contiene separatori /, ., -
  final separators = RegExp(r'[./\-]');
  if (s.contains(separators)) {
    final parts = s.split(separators);
    if (parts.length == 3) {
      final p0 = int.tryParse(parts[0].trim());
      final p1 = int.tryParse(parts[1].trim());
      var p2Str = parts[2].trim();
      if (p2Str.length == 2) p2Str = "20$p2Str";
      final p2 = int.tryParse(p2Str);

      if (p0 != null && p1 != null && p2 != null) {
        // Se p0 ha 4 cifre: YYYY-MM-DD
        if (parts[0].trim().length == 4) {
          if (p1 >= 1 && p1 <= 12 && p2 >= 1 && p2 <= 31) {
            return DateTime(p0, p1, p2);
          }
        }
        // Se p2 ha 4 cifre: DD/MM/YYYY
        if (p2 >= 1900 && p2 <= 2100) {
          if (p1 >= 1 && p1 <= 12 && p0 >= 1 && p0 <= 31) {
            return DateTime(p2, p1, p0);
          }
        }
      }
    }
  }

  // 3. Se stringa numerica di 8 cifre (YYYYMMDD o DDMMYYYY)
  if (s.length == 8 && RegExp(r'^\d{8}$').hasMatch(s)) {
    if (s.startsWith('20') || s.startsWith('19')) {
      final y = int.tryParse(s.substring(0, 4));
      final m = int.tryParse(s.substring(4, 6));
      final d = int.tryParse(s.substring(6, 8));
      if (y != null && m != null && d != null && m >= 1 && m <= 12) {
        return DateTime(y, m, d);
      }
    } else {
      final d = int.tryParse(s.substring(0, 2));
      final m = int.tryParse(s.substring(2, 4));
      final y = int.tryParse(s.substring(4, 8));
      if (y != null && m != null && d != null && m >= 1 && m <= 12) {
        return DateTime(y, m, d);
      }
    }
  }

  // 4. Se numero seriale di Excel (es. 45321)
  final serial = int.tryParse(s);
  if (serial != null && serial > 30000 && serial < 60000) {
    return DateTime(1899, 12, 30).add(Duration(days: serial));
  }

  return null;
}

int? _extractYearFromString(String dateStr) {
  final dt = _parseFlexibleDate(dateStr);
  return dt?.year;
}

int? _extractMonthFromString(String dateStr) {
  final dt = _parseFlexibleDate(dateStr);
  return dt?.month;
}

final dashboardSapStatsProvider = Provider<DashboardSapStats>((ref) {
  final trasferteSapList = ref.watch(trasferteSapProvider);
  final tracciatoSapList = ref.watch(tracciatoSapProvider);
  final contabileRecords = ref.watch(tracciatoContabilesProvider);
  final selectedYear = ref.watch(dashboardYearProvider);

  // Pre-indicizzazione contabile per O(1) constant time lookup
  final contabileTrasferte = <String>{};
  final Map<String, String> contabileDates = {};
  for (final tc in contabileRecords) {
    final t = tc.numeroTrasferta.trim();
    if (t.isNotEmpty) {
      contabileTrasferte.add(t);
      if (tc.dataSpesa.trim().isNotEmpty) {
        contabileDates.putIfAbsent(t, () => tc.dataSpesa.trim());
      }
    }
  }

  final Map<String, String> sapDates = {};
  for (final s in tracciatoSapList) {
    if (s.data.trim().isNotEmpty) {
      sapDates.putIfAbsent(s.numeroTrasferta.trim(), () => s.data.trim());
    }
  }

  final tsFiltered = trasferteSapList.where((ts) {
    var d = ts.dataInizioTrasferta.trim();
    if (d.isEmpty) {
      d = sapDates[ts.numeroTrasferta.trim()] ?? contabileDates[ts.numeroTrasferta.trim()] ?? '';
    }
    return _extractYearFromString(d) == selectedYear;
  }).toList();

  final sapFiltered = tracciatoSapList
      .where((s) => _extractYearFromString(s.data) == selectedYear)
      .toList();

  final hasData = tsFiltered.isNotEmpty || sapFiltered.isNotEmpty;
  if (!hasData) {
    return const DashboardSapStats(
      totalTrasferteSap: 0,
      totalAmountSap: 0.0,
      okCount: 0,
      koCount: 0,
      uniqueCids: 0,
      hasData: false,
    );
  }

  // Importo totale dalle spese SAP
  double totalAmount = 0.0;
  for (final s in sapFiltered) {
    totalAmount += s.importo;
  }

  final Set<String> sapTrasferteNumbers = {};
  final Set<String> uniqueCidSet = {};

  if (tsFiltered.isNotEmpty) {
    for (final ts in tsFiltered) {
      final num = ts.numeroTrasferta.trim();
      if (num.isNotEmpty) sapTrasferteNumbers.add(num);
      final c = ts.cid.trim();
      if (c.isNotEmpty) uniqueCidSet.add(c);
    }
  } else {
    for (final s in sapFiltered) {
      final num = s.numeroTrasferta.trim();
      if (num.isNotEmpty) sapTrasferteNumbers.add(num);
      final c = s.cid.trim();
      if (c.isNotEmpty) uniqueCidSet.add(c);
    }
  }

  // Se non presenti importi in TracciatoSap, recupera dai record contabili associati
  if (totalAmount == 0.0 && sapTrasferteNumbers.isNotEmpty) {
    for (final tc in contabileRecords) {
      if (sapTrasferteNumbers.contains(tc.numeroTrasferta.trim()) && !tc.isScarto && !tc.isBonificato) {
        totalAmount += tc.isNegative ? -tc.importo : tc.importo;
      }
    }
  }

  final totalTs = sapTrasferteNumbers.length;
  int okCount = 0;
  for (final num in sapTrasferteNumbers) {
    if (contabileTrasferte.contains(num)) {
      okCount++;
    }
  }
  final koCount = totalTs - okCount;

  return DashboardSapStats(
    totalTrasferteSap: totalTs,
    totalAmountSap: totalAmount,
    okCount: okCount,
    koCount: koCount,
    uniqueCids: uniqueCidSet.length,
    hasData: true,
  );
});

final dashboardSapMonthlyProvider = Provider<List<MapEntry<String, int>>>((ref) {
  final trasferteSapList = ref.watch(trasferteSapProvider);
  final tracciatoSapList = ref.watch(tracciatoSapProvider);
  final contabileRecords = ref.watch(tracciatoContabilesProvider);
  final selectedYear = ref.watch(dashboardYearProvider);

  // Mappa di date fallback da TracciatoSap o Contabile
  final Map<String, String> fallbackDates = {};
  for (final s in tracciatoSapList) {
    if (s.data.trim().isNotEmpty) {
      fallbackDates.putIfAbsent(s.numeroTrasferta.trim(), () => s.data.trim());
    }
  }
  for (final tc in contabileRecords) {
    if (tc.dataSpesa.trim().isNotEmpty) {
      fallbackDates.putIfAbsent(tc.numeroTrasferta.trim(), () => tc.dataSpesa.trim());
    }
  }

  final monthlyCounts = List<int>.filled(12, 0);
  final List<Set<String>> monthlyUniqueTrasferte = List.generate(12, (_) => <String>{});

  // 1. Scansiona trasferteSapList
  if (trasferteSapList.isNotEmpty) {
    for (final ts in trasferteSapList) {
      var dateStr = ts.dataInizioTrasferta.trim();
      if (dateStr.isEmpty) {
        dateStr = fallbackDates[ts.numeroTrasferta.trim()] ?? '';
      }
      final y = _extractYearFromString(dateStr);
      if (y == selectedYear) {
        final m = _extractMonthFromString(dateStr);
        if (m != null && m >= 1 && m <= 12) {
          monthlyUniqueTrasferte[m - 1].add(ts.numeroTrasferta.trim());
        }
      }
    }
  }

  // 2. Se non abbiamo trasferte dall'anno in trasferteSapList, proviamo con tracciatoSapList
  final totalFromTs = monthlyUniqueTrasferte.fold<int>(0, (sum, set) => sum + set.length);
  if (totalFromTs == 0 && tracciatoSapList.isNotEmpty) {
    for (final s in tracciatoSapList) {
      final y = _extractYearFromString(s.data);
      if (y == selectedYear) {
        final m = _extractMonthFromString(s.data);
        if (m != null && m >= 1 && m <= 12) {
          monthlyUniqueTrasferte[m - 1].add(s.numeroTrasferta.trim());
        }
      }
    }
  }

  for (int i = 0; i < 12; i++) {
    monthlyCounts[i] = monthlyUniqueTrasferte[i].length;
  }

  const months = ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic'];
  return List.generate(12, (i) => MapEntry(months[i], monthlyCounts[i]));
});

final dashboardSapTopCidsProvider = Provider<List<MapEntry<String, int>>>((ref) {
  final trasferteSapList = ref.watch(trasferteSapProvider);
  final tracciatoSapList = ref.watch(tracciatoSapProvider);
  final selectedYear = ref.watch(dashboardYearProvider);

  final Map<String, Set<String>> cidTrips = {};

  if (trasferteSapList.isNotEmpty) {
    for (final ts in trasferteSapList) {
      if (_extractYearFromString(ts.dataInizioTrasferta) == selectedYear) {
        final cid = ts.cid.trim();
        if (cid.isNotEmpty) {
          cidTrips.putIfAbsent(cid, () => {}).add(ts.numeroTrasferta.trim());
        }
      }
    }
  } else {
    for (final s in tracciatoSapList) {
      if (_extractYearFromString(s.data) == selectedYear) {
        final cid = s.cid.trim();
        if (cid.isNotEmpty) {
          cidTrips.putIfAbsent(cid, () => {}).add(s.numeroTrasferta.trim());
        }
      }
    }
  }

  final sorted = cidTrips.entries.map((e) => MapEntry(e.key, e.value.length)).toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted.take(15).toList();
});

