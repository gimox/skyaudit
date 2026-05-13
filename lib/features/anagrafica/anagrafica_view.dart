import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:travel_check/features/upload/providers/anagrafica_provider.dart';
import 'package:travel_check/features/upload/models/anagrafica.dart';
import 'package:travel_check/core/theme/app_theme.dart';

final anagraficaSearchProvider = StateProvider<String?>((ref) => null);
final anagraficaPageProvider = StateProvider<int>((ref) => 0);
final anagraficaSortAscendingProvider = StateProvider<bool>((ref) => true);

// Advanced Filter Providers
final selectedAnagLivelliProvider = StateProvider<List<String>>((ref) => []);
final selectedAnagGradoOccupazProvider = StateProvider<String?>((ref) => null);
final selectedAnagContrSolidarietaProvider = StateProvider<String?>((ref) => null);
final selectedAnagSocietaProvider = StateProvider<String?>((ref) => null);
final selectedAnagSedeComuneProvider = StateProvider<String?>((ref) => null);
final selectedAnagProvinciaProvider = StateProvider<String?>((ref) => null);
final selectedAnagPartFullTimeProvider = StateProvider<String?>((ref) => null);
final selectedAnagResponsabileProvider = StateProvider<String?>((ref) => null);
final selectedAnagGestoreProvider = StateProvider<String?>((ref) => null);

class AnagraficaView extends ConsumerStatefulWidget {
  const AnagraficaView({super.key});

  @override
  ConsumerState<AnagraficaView> createState() => _AnagraficaViewState();
}

class _AnagraficaViewState extends ConsumerState<AnagraficaView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt != null) {
        return DateFormat('dd/MM/yyyy').format(dt);
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _calculateAge(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return '-';
      final now = DateTime.now();
      int age = now.year - dt.year;
      if (now.month < dt.month || (now.month == dt.month && now.day < dt.day)) {
        age--;
      }
      return '$age anni';
    } catch (e) {
      return '-';
    }
  }

  String _calculateSeniority(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final dt = DateTime.tryParse(dateStr);
      if (dt == null) return '-';
      final now = DateTime.now();
      
      int years = now.year - dt.year;
      int months = now.month - dt.month;
      
      if (now.day < dt.day) {
        months--;
      }
      
      if (months < 0) {
        years--;
        months += 12;
      }
      
      return '$years anni e $months mesi';
    } catch (e) {
      return '-';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRecords = ref.watch(anagraficaProvider);
    final searchQuery = ref.watch(anagraficaSearchProvider);
    final currentPage = ref.watch(anagraficaPageProvider);
    final sortAscending = ref.watch(anagraficaSortAscendingProvider);
    const pageSize = 50;

    if (allRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
            ),
            const SizedBox(height: 16),
            Text(
              'NESSUNA ANAGRAFICA CARICATA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w200,
                letterSpacing: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Vai nella sezione "Carica File" per importare i dati.'),
          ],
        ),
      );
    }

    // Watch advanced filters
    final selectedLivelli = ref.watch(selectedAnagLivelliProvider);
    final selectedGrado = ref.watch(selectedAnagGradoOccupazProvider);
    final selectedSolidarieta = ref.watch(selectedAnagContrSolidarietaProvider);
    final selectedSocieta = ref.watch(selectedAnagSocietaProvider);
    final selectedComune = ref.watch(selectedAnagSedeComuneProvider);
    final selectedProvincia = ref.watch(selectedAnagProvinciaProvider);
    final selectedPartFull = ref.watch(selectedAnagPartFullTimeProvider);
    final selectedResponsabile = ref.watch(selectedAnagResponsabileProvider);
    final selectedGestore = ref.watch(selectedAnagGestoreProvider);

    // Estrattori valori unici per i filtri
    final livelliList = allRecords.map((e) => e.livello ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final gradiList = allRecords.map((e) => e.gradoOccupaz ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final solidarietaList = allRecords.map((e) => e.contrSolidarieta ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final societaList = allRecords.map((e) => e.societa ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final comuniList = allRecords.map((e) => e.sedeComune ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final provinceList = allRecords.map((e) => e.provincia ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final partFullList = allRecords.map((e) => e.partTimeFullTime ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final responsabiliList = allRecords.map((e) => e.nominativoResponsabileUO ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();
    final gestoriList = allRecords.map((e) => e.nominativoGestore ?? '').where((e) => e.isNotEmpty).toSet().toList()..sort();

    // Filtra i record
    final filteredRecords = allRecords.where((r) {
      // Ricerca testuale
      bool matchSearch = true;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        matchSearch = (r.cid?.toLowerCase().contains(q) ?? false) ||
                      (r.nominativo?.toLowerCase().contains(q) ?? false) ||
                      (r.codiceFiscale?.toLowerCase().contains(q) ?? false) ||
                      (r.matricolaAziendaleUID?.toLowerCase().contains(q) ?? false);
      }
      if (!matchSearch) return false;

      // Filtri avanzati
      if (selectedLivelli.isNotEmpty && !selectedLivelli.contains(r.livello ?? '')) return false;
      if (selectedGrado != null && r.gradoOccupaz != selectedGrado) return false;
      if (selectedSolidarieta != null && r.contrSolidarieta != selectedSolidarieta) return false;
      if (selectedSocieta != null && r.societa != selectedSocieta) return false;
      if (selectedComune != null && r.sedeComune != selectedComune) return false;
      if (selectedProvincia != null && r.provincia != selectedProvincia) return false;
      if (selectedPartFull != null && r.partTimeFullTime != selectedPartFull) return false;
      if (selectedResponsabile != null && r.nominativoResponsabileUO != selectedResponsabile) return false;
      if (selectedGestore != null && r.nominativoGestore != selectedGestore) return false;

      return true;
    }).toList()..sort((a, b) {
      final nomA = a.nominativo ?? '';
      final nomB = b.nominativo ?? '';
      return sortAscending ? nomA.compareTo(nomB) : nomB.compareTo(nomA);
    });

    final totalPages = (filteredRecords.length / pageSize).ceil();
    final safePage = (currentPage >= totalPages && totalPages > 0) ? 0 : currentPage;
    final startIndex = (safePage * pageSize).clamp(0, filteredRecords.length);
    final endIndex = (startIndex + pageSize).clamp(0, filteredRecords.length);
    final paginatedRecords = filteredRecords.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      endDrawer: _buildFilterDrawer(
        context, 
        ref, 
        livelliList, 
        gradiList, 
        solidarietaList, 
        societaList, 
        comuniList, 
        provinceList, 
        partFullList, 
        responsabiliList, 
        gestoriList
      ),
      body: Column(
        children: [
          // HEADER CON RICERCA
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
                                  hintText: 'Cerca per CID, Nominativo, Codice Fiscale o UID...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (value) {
                                  ref.read(anagraficaSearchProvider.notifier).state = value.isEmpty ? null : value;
                                  ref.read(anagraficaPageProvider.notifier).state = 0;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        ref.read(anagraficaSortAscendingProvider.notifier).state = !sortAscending;
                      },
                      icon: Icon(sortAscending ? Icons.sort_by_alpha : Icons.sort_by_alpha_outlined),
                      tooltip: 'Ordina per Nominativo',
                    ),
                    const SizedBox(width: 8),
                    Builder(
                      builder: (context) => IconButton(
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                        icon: const Icon(Icons.filter_alt_outlined),
                        tooltip: 'Filtri Avanzati',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TABELLA
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Container(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: 1600, // Larghezza fissa per scorrimento orizzontale
                      child: Column(
                        children: [
                          // HEADER FISSO
                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: Row(
                              children: [
                                _buildCell('CID', 100, isHeader: true),
                                _buildCell('UID (MATRICOLA)', 140, isHeader: true),
                                _buildCell('NOMINATIVO', 250, isHeader: true),
                                _buildCell('UNITÀ ORG. 3 DES.', 250, isHeader: true),
                                _buildCell('REGIONE', 150, isHeader: true),
                                _buildCell('SEDE COMUNE', 150, isHeader: true),
                                _buildCell('MANSIONE', 250, isHeader: true),
                                _buildCell('EMAIL', 210, isHeader: true),
                                _buildCell('AZIONI', 100, isHeader: true, alignment: Alignment.center),
                              ],
                            ),
                          ),
                          // BODY
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
                                      border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildCell(record.cid ?? '-', 100, fontWeight: FontWeight.w500),
                                        _buildCell(record.matricolaAziendaleUID ?? '-', 140),
                                        _buildCell(record.nominativo ?? '-', 250, color: SkyTheme.timBlue, fontWeight: FontWeight.bold),
                                        _buildCell(record.unitaOrg3Des ?? '-', 250),
                                        _buildCell(record.regione ?? '-', 150),
                                        _buildCell(record.sedeComune ?? '-', 150),
                                        _buildCell(record.mansione ?? '-', 250),
                                        _buildCell(record.indirizzoMail ?? '-', 210),
                                        _buildCell('', 100, alignment: Alignment.center, child: IconButton(
                                          icon: const Icon(Icons.visibility_outlined, color: Colors.blue, size: 20),
                                          onPressed: () => _showAnagraficaDetails(context, record),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: currentPage > 0 ? () => ref.read(anagraficaPageProvider.notifier).state-- : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text('Pagina ${currentPage + 1} di $totalPages', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: currentPage < totalPages - 1 ? () => ref.read(anagraficaPageProvider.notifier).state++ : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                    const VerticalDivider(),
                    Text('Totale: ${filteredRecords.length}', style: const TextStyle(color: SkyTheme.timBlue, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
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
          letterSpacing: isHeader ? 1.0 : null,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showAnagraficaDetails(BuildContext context, Anagrafica record) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700, maxHeight: 800),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [SkyTheme.timBlue, Color(0xFF0056B3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white.withAlpha(40),
                        child: const Icon(Icons.person, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record.nominativo ?? 'N/D',
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'CID: ${record.cid} | CF: ${record.codiceFiscale}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Dati Personali', Icons.person_outline, Colors.blue, [
                          _buildDetailRow('Sesso', record.sesso ?? '-'),
                          _buildDetailRow('Data Nascita', _formatDate(record.dataNascita)),
                          _buildDetailRow('Età', _calculateAge(record.dataNascita)),
                          _buildDetailRow('Luogo Nascita', record.luogoNascita ?? '-'),
                          _buildDetailRow('Codice Fiscale', record.codiceFiscale ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Formazione', Icons.school_outlined, Colors.teal, [
                          _buildDetailRow('Tipo Scuola', record.tipoScuola ?? '-'),
                          _buildDetailRow('Formazione', record.formazione ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Rapporto di Lavoro', Icons.work_outline, Colors.orange, [
                          _buildDetailRow('CID', record.cid ?? '-'),
                          _buildDetailRow('Matricola', record.matricolaAziendaleUID ?? '-'),
                          _buildDetailRow('Data Assunzione', _formatDate(record.dataAssunzione)),
                          _buildDetailRow('Data Assunzione Gruppo', _formatDate(record.dataAssunzioneGruppo)),
                          _buildDetailRow('Anzianità di servizio', _calculateSeniority(record.dataAssunzioneGruppo)),
                          _buildDetailRow('Tipo Dipendente', record.tipoDip ?? '-'),
                          _buildDetailRow('Livello', record.livello ?? '-'),
                          _buildDetailRow('Mansione', record.mansione ?? '-'),
                          _buildDetailRow('Posizione', record.posizione ?? '-'),
                          _buildDetailRow('Tipo Contratto', record.tipoContratto ?? '-'),
                          _buildDetailRow('Orario', record.partTimeFullTime ?? '-'),
                          _buildDetailRow('Stato', record.status ?? '-'),
                          _buildDetailRow('Responsabilità', record.responsabileSINO ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Organizzazione', Icons.business_outlined, Colors.purple, [
                          _buildDetailRow('Società', record.societa ?? '-'),
                          _buildDetailRow('Unità Org.', record.unitaOrganizzativa ?? '-'),
                          _buildDetailRow('U.O. 3', record.unitaOrg3Des ?? '-'),
                          _buildDetailRow('U.O. 4', record.unitaOrg4Des ?? '-'),
                          _buildDetailRow('U.O. 5', record.unitaOrg5Des ?? '-'),
                          _buildDetailRow('Responsabile', record.nominativoResponsabileUO ?? '-'),
                          _buildDetailRow('Key Account', record.nominativoKeyAccount ?? '-'),
                          _buildDetailRow('Gestore', record.nominativoGestore ?? '-'),
                        ]),
                        const SizedBox(height: 24),
                        _buildDetailSection('Contatti e Sede', Icons.location_on_outlined, Colors.green, [
                          _buildDetailRow('Email', record.indirizzoMail ?? '-'),
                          _buildDetailRow('Sede Comune', record.sedeComune ?? '-'),
                          _buildDetailRow('Sede Indirizzo', record.sedeIndirizzo ?? '-'),
                          _buildDetailRow('Regione', record.regione ?? '-'),
                          _buildDetailRow('Provincia', record.provincia ?? '-'),
                        ]),
                      ],
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

  Widget _buildFilterDrawer(
    BuildContext context, 
    WidgetRef ref, 
    List<String> livelli,
    List<String> gradi,
    List<String> solidarieta,
    List<String> societa,
    List<String> comuni,
    List<String> province,
    List<String> partFull,
    List<String> responsabili,
    List<String> gestori
  ) {
    return Drawer(
      width: 400,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [SkyTheme.timBlue, Color(0xFF0056B3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_outlined, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'FILTRI AVANZATI',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildDrawerSectionTitle('LAVORO'),
                _buildMultiSelectFilter('Livello', ref.watch(selectedAnagLivelliProvider), livelli, (val) {
                  final list = List<String>.from(ref.read(selectedAnagLivelliProvider));
                  if (list.contains(val)) {
                    list.remove(val);
                  } else {
                    list.add(val);
                  }
                  ref.read(selectedAnagLivelliProvider.notifier).state = list;
                }),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Grado Occupazione', ref.watch(selectedAnagGradoOccupazProvider), gradi, (val) => ref.read(selectedAnagGradoOccupazProvider.notifier).state = val, icon: Icons.work_history_outlined),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Contr. Solidarietà', ref.watch(selectedAnagContrSolidarietaProvider), solidarieta, (val) => ref.read(selectedAnagContrSolidarietaProvider.notifier).state = val, icon: Icons.handshake_outlined),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Part-Time / Full-Time', ref.watch(selectedAnagPartFullTimeProvider), partFull, (val) => ref.read(selectedAnagPartFullTimeProvider.notifier).state = val, icon: Icons.timer_outlined),
                
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('SEDE E SOCIETÀ'),
                _buildFilterDropdown<String?>('Società', ref.watch(selectedAnagSocietaProvider), societa, (val) => ref.read(selectedAnagSocietaProvider.notifier).state = val, icon: Icons.business),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Sede Comune', ref.watch(selectedAnagSedeComuneProvider), comuni, (val) => ref.read(selectedAnagSedeComuneProvider.notifier).state = val, icon: Icons.location_city),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Sede Provincia', ref.watch(selectedAnagProvinciaProvider), province, (val) => ref.read(selectedAnagProvinciaProvider.notifier).state = val, icon: Icons.map_outlined),
                
                const SizedBox(height: 32),
                _buildDrawerSectionTitle('GERARCHIA'),
                _buildFilterDropdown<String?>('Responsabile', ref.watch(selectedAnagResponsabileProvider), responsabili, (val) => ref.read(selectedAnagResponsabileProvider.notifier).state = val, icon: Icons.person_outline),
                const SizedBox(height: 16),
                _buildFilterDropdown<String?>('Gestore', ref.watch(selectedAnagGestoreProvider), gestori, (val) => ref.read(selectedAnagGestoreProvider.notifier).state = val, icon: Icons.person_search_outlined),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _resetAllFiltersAnag(ref),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    child: const Text('RESET'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: SkyTheme.timBlue,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFilterDropdown<T>(String label, T value, List<T> items, ValueChanged<T?> onChanged, {IconData? icon, String Function(T)? labelMapper}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          isDense: true,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: [
            DropdownMenuItem<T>(
              value: null, 
              child: Text(
                'Tutti', 
                style: TextStyle(color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...items.map((item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                labelMapper != null ? labelMapper(item) : item.toString(), 
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          selectedItemBuilder: (context) {
            return [
              Text('Tutti', style: TextStyle(color: Colors.grey.shade600, fontSize: 13), overflow: TextOverflow.ellipsis),
              ...items.map((item) => Text(
                labelMapper != null ? labelMapper(item) : item.toString(),
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              )),
            ];
          },
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMultiSelectFilter(String label, List<String> selectedItems, List<String> allItems, Function(String) onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final item = allItems[index];
              final isSelected = selectedItems.contains(item);
              return CheckboxListTile(
                title: Text(item, style: const TextStyle(fontSize: 12)),
                value: isSelected,
                onChanged: (_) => onToggle(item),
                dense: true,
                visualDensity: VisualDensity.compact,
                controlAffinity: ListTileControlAffinity.leading,
              );
            },
          ),
        ),
      ],
    );
  }

  void _resetAllFiltersAnag(WidgetRef ref) {
    ref.read(selectedAnagLivelliProvider.notifier).state = [];
    ref.read(selectedAnagGradoOccupazProvider.notifier).state = null;
    ref.read(selectedAnagContrSolidarietaProvider.notifier).state = null;
    ref.read(selectedAnagSocietaProvider.notifier).state = null;
    ref.read(selectedAnagSedeComuneProvider.notifier).state = null;
    ref.read(selectedAnagProvinciaProvider.notifier).state = null;
    ref.read(selectedAnagPartFullTimeProvider.notifier).state = null;
    ref.read(selectedAnagResponsabileProvider.notifier).state = null;
    ref.read(selectedAnagGestoreProvider.notifier).state = null;
    ref.read(anagraficaSearchProvider.notifier).state = null;
    _searchController.clear();
  }

  Widget _buildDetailSection(String title, IconData icon, Color color, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color, letterSpacing: 1.0)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(flex: 3, child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
