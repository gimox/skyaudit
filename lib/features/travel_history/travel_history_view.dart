import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/features/upload/models/anagrafica.dart';

// Mappa semplificata delle città italiane per geocoding statico
final Map<String, LatLng> italianCitiesCoords = {
  'ROMA': const LatLng(41.9028, 12.4964),
  'MILANO': const LatLng(45.4642, 9.1900),
  'TORINO': const LatLng(45.0703, 7.6869),
  'NAPOLI': const LatLng(40.8518, 14.2681),
  'FIRENZE': const LatLng(43.7696, 11.2558),
  'BOLOGNA': const LatLng(44.4949, 11.3426),
  'VENEZIA': const LatLng(45.4408, 12.3155),
  'PALERMO': const LatLng(38.1157, 13.3615),
  'GENOVA': const LatLng(44.4056, 8.9463),
  'BARI': const LatLng(41.1171, 16.8719),
  'CATANZARO': const LatLng(38.9098, 16.5877),
  'CAGLIARI': const LatLng(39.2238, 9.1217),
  'PERUGIA': const LatLng(43.1107, 12.3908),
  'ANCONA': const LatLng(43.6158, 13.5189),
  'POTENZA': const LatLng(40.6404, 15.8056),
  'CAMPOBASSO': const LatLng(41.5603, 14.6596),
  'AOSTA': const LatLng(45.7349, 7.3130),
  'TRENTO': const LatLng(46.0748, 11.1217),
  'TRIESTE': const LatLng(45.6495, 13.7768),
  'L\'AQUILA': const LatLng(42.3489, 13.3980),
  'VERONA': const LatLng(45.4384, 10.9916),
  'PADOVA': const LatLng(45.4064, 11.8768),
  'BRESCIA': const LatLng(45.5398, 10.2181),
  'TARANTO': const LatLng(40.4677, 17.2470),
  'REGGIO CALABRIA': const LatLng(38.1144, 15.6500),
  'MESSINA': const LatLng(38.1938, 15.5540),
  'MODENA': const LatLng(44.6471, 10.9252),
  'PARMA': const LatLng(44.8015, 10.3279),
  'LIVORNO': const LatLng(43.5485, 10.3106),
  'FOGGIA': const LatLng(41.4622, 15.5446),
  'SALERNO': const LatLng(40.6780, 14.7591),
  'FERRARA': const LatLng(44.8381, 11.6198),
  'LATINA': const LatLng(41.4676, 12.9037),
  'SASSARI': const LatLng(40.7272, 8.5595),
  'MONZA': const LatLng(45.5845, 9.2744),
  'SIRACUSA': const LatLng(37.0755, 15.2866),
  'PESCARA': const LatLng(42.4618, 14.2142),
  'BERGAMO': const LatLng(45.6983, 9.6773),
  'VICENZA': const LatLng(45.5467, 11.5475),
  'FORLÌ': const LatLng(44.2227, 12.0407),
  'BOLZANO': const LatLng(46.4981, 11.3548),
  'BRINDISI': const LatLng(40.6327, 17.9417),
  'STOCKHOLM': const LatLng(59.3293, 18.0686),
  'FIUMICINO': const LatLng(41.7733, 12.2391),
  'STOCCOLMA': const LatLng(59.3293, 18.0686),
};

final travelHistoryCidProvider = StateProvider<String>((ref) => '');

class TravelHistoryView extends ConsumerStatefulWidget {
  const TravelHistoryView({super.key});

  @override
  ConsumerState<TravelHistoryView> createState() => _TravelHistoryViewState();
}

class _TravelHistoryViewState extends ConsumerState<TravelHistoryView> {
  final TextEditingController _cidController = TextEditingController();
  final MapController _mapController = MapController();
  int _selectedLayerIndex = 0;

  final List<Map<String, String>> _layers = [
    {
      'name': 'Voyager',
      'url': 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
      'icon': 'map',
    },
    {
      'name': 'Light',
      'url': 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
      'icon': 'light_mode',
    },
    {
      'name': 'Dark',
      'url': 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      'icon': 'dark_mode',
    },
    {
      'name': 'Terrain',
      'url': 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
      'icon': 'terrain',
    },
  ];

  @override
  void dispose() {
    _cidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracciato = ref.watch(tracciatoContabilesProvider);
    final selectedCid = ref.watch(travelHistoryCidProvider);
    final anagrafica = ref.watch(anagraficaProvider);
    final selectedEmployee = anagrafica.where((e) => e.cid == selectedCid).firstOrNull;

    // Filtra record per CID e raggruppa per trasferta
    final userRecords = tracciato.where((r) => r.cid == selectedCid).toList();
    
    final Map<String, List<TracciatoContabile>> trips = {};
    for (var r in userRecords) {
      if (!trips.containsKey(r.numeroTrasferta)) {
        trips[r.numeroTrasferta] = [];
      }
      trips[r.numeroTrasferta]!.add(r);
    }

    final sortedTripIds = trips.keys.toList()
      ..sort((a, b) {
        final dateA = _parseDate(trips[a]!.first.dataInizio);
        final dateB = _parseDate(trips[b]!.first.dataInizio);
        return dateB.compareTo(dateA); // Ordine decrescente
      });

    // Calcolo totale complessivo
    double grandTotal = 0;
    for (var tripRecords in trips.values) {
      for (var r in tripRecords) {
        grandTotal += r.isNegative ? -r.importo : r.importo;
      }
    }

    // Punti per la linea del percorso (dal più vecchio al più recente)
    final List<LatLng> pathPoints = [];
    final List<Marker> markers = [];
    
    final chronoTripIds = sortedTripIds.reversed.toList();
    
    for (int i = 0; i < chronoTripIds.length; i++) {
      final tripId = chronoTripIds[i];
      final firstRecord = trips[tripId]!.first;
      final city = firstRecord.localita.toUpperCase();
      
      if (italianCitiesCoords.containsKey(city)) {
        final point = italianCitiesCoords[city]!;
        pathPoints.add(point);
        
        markers.add(
          Marker(
            point: point,
            width: 60,
            height: 60,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF003399).withAlpha(100),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        i == chronoTripIds.length - 1 ? Icons.location_on : Icons.circle,
                        color: i == chronoTripIds.length - 1 ? Colors.red : const Color(0xFF003399),
                        size: 20,
                      ),
                    ),
                    Text(
                      '${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF003399),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    // Frecce direzionali lungo il percorso
    final List<Marker> directionMarkers = [];
    for (int i = 0; i < pathPoints.length - 1; i++) {
      final p1 = pathPoints[i];
      final p2 = pathPoints[i + 1];
      
      // Calcola il punto intermedio
      final midLat = (p1.latitude + p2.latitude) / 2;
      final midLng = (p1.longitude + p2.longitude) / 2;
      final midpoint = LatLng(midLat, midLng);
      
      // Calcola l'angolo per la freccia
      final angle = atan2(p2.latitude - p1.latitude, p2.longitude - p1.longitude);
      
      directionMarkers.add(
        Marker(
          point: midpoint,
          width: 24,
          height: 24,
          child: Transform.rotate(
            angle: -angle + (pi / 2),
            child: Icon(
              Icons.flight,
              size: 14,
              color: const Color(0xFF003399).withAlpha(200),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header con ricerca
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(200),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Autocomplete<Anagrafica>(
                      displayStringForOption: (e) => '${e.cid ?? ""} - ${e.nominativo ?? ""}',
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Anagrafica>.empty();
                        }
                        return anagrafica.where((e) =>
                          (e.cid?.toLowerCase().contains(textEditingValue.text.toLowerCase()) ?? false) ||
                          (e.nominativo?.toLowerCase().contains(textEditingValue.text.toLowerCase()) ?? false)
                        ).take(10); // Limita suggerimenti per performance
                      },
                      onSelected: (e) {
                        ref.read(travelHistoryCidProvider.notifier).state = e.cid ?? '';
                        _cidController.text = e.cid ?? '';
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Inserisci CID o Nominativo...',
                            prefixIcon: const Icon(Icons.person_search_outlined),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          ),
                          onSubmitted: (value) {
                            ref.read(travelHistoryCidProvider.notifier).state = value;
                          },
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(option.nominativo ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('CID: ${option.cid ?? ""} • ${option.societa ?? ""}'),
                                    leading: const Icon(Icons.person_outline, color: Color(0xFF003399)),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (selectedEmployee != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedEmployee.nominativo ?? '-',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003399),
                        ),
                      ),
                      Text(
                        'CID: ${selectedEmployee.cid} • ${selectedEmployee.societa}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                ],
                ElevatedButton(
                  onPressed: () {
                    // La ricerca è gestita dall'autocomplete o dall'invio manuale
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003399),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('CERCA'),
                ),
                if (selectedCid.isNotEmpty) ...[
                  const SizedBox(width: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003399).withAlpha(15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF003399).withAlpha(30)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'TOTALE STORICO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003399),
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${grandTotal.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003399),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          Expanded(
            child: selectedCid.isEmpty
                ? _buildEmptyState()
                : Row(
                    children: [
                      // Elenco Trasferte
                      Expanded(
                        flex: 4,
                        child: _buildTripsList(sortedTripIds, trips),
                      ),
                      // Mappa
                      Expanded(
                        flex: 6,
                        child: Container(
                          margin: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: markers.any((m) => m.point.latitude > 50) 
                                    ? const LatLng(50.0, 15.0) // Centro Europa se c'è Stoccolma
                                    : const LatLng(41.8719, 12.5674), // Centro Italia
                                  initialZoom: markers.any((m) => m.point.latitude > 50) ? 4 : 6,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: _layers[_selectedLayerIndex]['url']!,
                                    subdomains: const ['a', 'b', 'c', 'd'],
                                    userAgentPackageName: 'com.skyaudit.app',
                                  ),
                                  PolylineLayer(
                                    polylines: pathPoints.isEmpty ? <Polyline<Object>>[] : [
                                      Polyline<Object>(
                                        points: pathPoints,
                                        color: const Color(0xFF003399).withAlpha(120),
                                        strokeWidth: 4,
                                      ),
                                    ],
                                  ),
                                  MarkerLayer(markers: [...markers, ...directionMarkers]),
                                ],
                              ),
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FloatingActionButton.small(
                                      heroTag: 'change_layer',
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF003399),
                                      onPressed: () {
                                        setState(() {
                                          _selectedLayerIndex = (_selectedLayerIndex + 1) % _layers.length;
                                        });
                                      },
                                      tooltip: 'Cambia stile mappa',
                                      child: Icon(_getLayerIcon(_layers[_selectedLayerIndex]['icon']!)),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(20),
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              final currentZoom = _mapController.camera.zoom;
                                              _mapController.move(_mapController.camera.center, currentZoom + 1);
                                            },
                                            icon: const Icon(Icons.add, color: Color(0xFF003399)),
                                            tooltip: 'Zoom In',
                                          ),
                                          const Divider(height: 1, indent: 8, endIndent: 8),
                                          IconButton(
                                            onPressed: () {
                                              final currentZoom = _mapController.camera.zoom;
                                              _mapController.move(_mapController.camera.center, currentZoom - 1);
                                            },
                                            icon: const Icon(Icons.remove, color: Color(0xFF003399)),
                                            tooltip: 'Zoom Out',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 24),
          Text(
            'Inserisci un CID per iniziare l\'esplorazione',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(List<String> tripIds, Map<String, List<TracciatoContabile>> trips) {
    if (tripIds.isEmpty) {
      return const Center(child: Text('Nessuna trasferta trovata per questo CID'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: tripIds.length,
      itemBuilder: (context, index) {
        final tripId = tripIds[index];
        final records = trips[tripId]!;
        final first = records.first;
        
        double totalCost = 0;
        for (var r in records) {
          totalCost += r.isNegative ? -r.importo : r.importo;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(220),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF003399).withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flight_takeoff, color: Color(0xFF003399)),
            ),
            title: Text(
              first.localita,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Dal ${first.dataInizio} al ${first.dataFine}'),
                const SizedBox(height: 2),
                Text('Trasferta: $tripId', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${totalCost.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF003399),
                  ),
                ),
                const Text('Totale Costi', style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            onTap: () {
              final city = first.localita.toUpperCase();
              if (italianCitiesCoords.containsKey(city)) {
                _mapController.move(italianCitiesCoords[city]!, 10);
              }
              _showTripDetails(tripId, records);
            },
          ),
        );
      },
    );
  }
  void _showTripDetails(String tripId, List<TracciatoContabile> records) {
    final first = records.first;
    double totalCost = 0;
    for (var r in records) {
      totalCost += r.isNegative ? -r.importo : r.importo;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                children: [
                  // Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                first.localita,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF003399),
                                ),
                              ),
                              Text(
                                'Trasferta n. $tripId • ${first.dataInizio} - ${first.dataFine}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003399).withAlpha(15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${totalCost.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF003399),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  
                  // Elenco Giustificativi
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      padding: const EdgeInsets.all(24),
                      itemCount: records.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final r = records[index];
                        final importoEffettivo = r.isNegative ? -r.importo : r.importo;
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getGiustificativoIcon(r.giustificativoSpesa),
                                  color: const Color(0xFF003399),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.giustificativoSpesa,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Bolla: ${r.numeroBolla} • Data: ${r.dataSpesa}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${importoEffettivo.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: r.isNegative ? Colors.red : Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _getGiustificativoIcon(String code) {
    if (code.contains('ALP')) return Icons.hotel;
    if (code.contains('TAP')) return Icons.flight;
    if (code.contains('TNP')) return Icons.directions_car;
    if (code.contains('TTP')) return Icons.train;
    if (code.contains('SSP')) return Icons.description;
    return Icons.receipt_long;
  }


  IconData _getLayerIcon(String iconName) {
    switch (iconName) {
      case 'light_mode':
        return Icons.light_mode;
      case 'dark_mode':
        return Icons.dark_mode;
      case 'terrain':
        return Icons.terrain;
      default:
        return Icons.map;
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (_) {
      return DateTime(1970);
    }
  }
}
