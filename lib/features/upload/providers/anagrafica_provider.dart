import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar_community/isar.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/anagrafica.dart';
import '../models/log_history.dart';
import 'log_history_provider.dart';

class AnagraficaNotifier extends Notifier<List<Anagrafica>> {
  @override
  List<Anagrafica> build() {
    final isar = ref.watch(isarProvider);
    _loadInitialData(isar);
    return [];
  }

  Future<void> _loadInitialData(Isar isar) async {
    final records = await isar.anagraficas.where().anyId().findAll();
    state = records;
  }

  Future<Map<String, dynamic>> loadFromFile(XFile file) async {
    final isar = ref.read(isarProvider);
    final uniqueCode = DateTime.now().millisecondsSinceEpoch.toString();

    debugPrint('Caricamento Anagrafica: ${file.path}');

    // Parsing in isolate per non bloccare la UI
    final List<Map<String, dynamic>> results = await compute(_parseAnagraficaIsolate, {
      'filePath': file.path,
      'uniqueCode': uniqueCode,
    });

    if (results.isEmpty) {
      throw Exception('Nessun record valido trovato nel file Anagrafica.');
    }

    int insertedCount = 0;
    int updatedCount = 0;
    int discardedCount = 0;

    await isar.writeTxn(() async {
      debugPrint('Provder: Recupero CF esistenti...');
      // Otteniamo solo ID e CF per risparmiare memoria
      final existingData = await isar.anagraficas.where().exportJson();
      final Map<String, int> cfMap = {};
      for (var item in existingData) {
        final cf = item['codiceFiscale'] as String?;
        final id = item['id'] as int?;
        if (cf != null && id != null) {
          cfMap[cf] = id;
        }
      }
      debugPrint('Provider: CF mappati: ${cfMap.length}');

      final List<Anagrafica> recordsToSave = [];

      for (var m in results) {
        final cf = m['codiceFiscale'] as String?;
        if (cf == null || cf.isEmpty) {
          discardedCount++;
          continue;
        }

        final record = Anagrafica()
          ..codiceFiscale = cf
          ..cid = m['cid']
          ..nominativo = m['nominativo']
          ..sesso = m['sesso']
          ..dataNascita = m['dataNascita']
          ..luogoNascita = m['luogoNascita']
          ..dataAssunzione = m['dataAssunzione']
          ..dataAssunzioneGruppo = m['dataAssunzioneGruppo']
          ..tipoScuola = m['tipoScuola']
          ..formazione = m['formazione']
          ..livello = m['livello']
          ..areaFascia = m['areaFascia']
          ..tipoDip = m['tipoDip']
          ..gradoOccupaz = m['gradoOccupaz']
          ..gradoOccupazInSol = m['gradoOccupazInSol']
          ..contrSolidarieta = m['contrSolidarieta']
          ..societa = m['societa']
          ..societaContabile = m['societaContabile']
          ..unitaOrg3 = m['unitaOrg3']
          ..unitaOrg3Des = m['unitaOrg3Des']
          ..unitaOrg4 = m['unitaOrg4']
          ..unitaOrg4Des = m['unitaOrg4Des']
          ..unitaOrg5 = m['unitaOrg5']
          ..unitaOrg5Des = m['unitaOrg5Des']
          ..unitaOrg6 = m['unitaOrg6']
          ..unitaOrg6Des = m['unitaOrg6Des']
          ..unitaOrg7 = m['unitaOrg7']
          ..unitaOrg7Des = m['unitaOrg7Des']
          ..unitaOrg8 = m['unitaOrg8']
          ..unitaOrg8Des = m['unitaOrg8Des']
          ..unitaOrg9 = m['unitaOrg9']
          ..unitaOrg9Des = m['unitaOrg9Des']
          ..unitaOrganizzativa = m['unitaOrganizzativa']
          ..cidResponsabileUO = m['cidResponsabileUO']
          ..nominativoResponsabileUO = m['nominativoResponsabileUO']
          ..mailResponsabileUO = m['mailResponsabileUO']
          ..paese = m['paese']
          ..regione = m['regione']
          ..provincia = m['provincia']
          ..sedeProvincia = m['sedeProvincia']
          ..sedeIndirizzo = m['sedeIndirizzo']
          ..sedeCap = m['sedeCap']
          ..sedeComune = m['sedeComune']
          ..tipoContratto = m['tipoContratto']
          ..partTimeFullTime = m['partTimeFullTime']
          ..mansione = m['mansione']
          ..posizione = m['posizione']
          ..nuovoSistProfFamiglia = m['nuovoSistProfFamiglia']
          ..nuovoSistProfArea = m['nuovoSistProfArea']
          ..nuovoSistProfAmbito = m['nuovoSistProfAmbito']
          ..nuovoSistProfJob = m['nuovoSistProfJob']
          ..status = m['status']
          ..utenteCOD = m['utenteCOD']
          ..utenteRU = m['utenteRU']
          ..utenteKA = m['utenteKA']
          ..utenteRUBU = m['utenteRUBU']
          ..indirizzoMail = m['indirizzoMail']
          ..cidKeyAccount = m['cidKeyAccount']
          ..nominativoKeyAccount = m['nominativoKeyAccount']
          ..mailKeyAccount = m['mailKeyAccount']
          ..cidGestore = m['cidGestore']
          ..nominativoGestore = m['nominativoGestore']
          ..mailGestore = m['mailGestore']
          ..under35 = m['under35']
          ..responsabileSINO = m['responsabileSINO']
          ..tipologiaResponsabile = m['tipologiaResponsabile']
          ..matricolaAziendaleUID = m['matricolaAziendaleUID']
          ..lastUpdate = DateTime.now()
          ..importBatch = uniqueCode;

        if (cfMap.containsKey(cf)) {
          record.id = cfMap[cf]!;
          updatedCount++;
        } else {
          insertedCount++;
        }
        
        recordsToSave.add(record);
      }

      await isar.anagraficas.putAll(recordsToSave);

      final cleanFileName = file.name.split(RegExp(r'[/\\]')).last.trim();
      final log = LogHistory(
        fileName: cleanFileName,
        date: DateTime.now(),
        uniqueCode: uniqueCode,
        totalRecords: results.length,
        insertedRecords: insertedCount,
        updatedRecords: updatedCount,
        discardedRecords: discardedCount,
        sourceType: 'Anagrafica',
      );
      await isar.logHistorys.put(log);
    });

    state = await isar.anagraficas.where().anyId().findAll();
    ref.invalidate(logHistoryProvider);

    return {
      'inserted': insertedCount,
      'updated': updatedCount,
      'discarded': discardedCount,
      'total': results.length,
      'uniqueCode': uniqueCode,
    };
  }

  Future<void> clear() async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.anagraficas.clear());
    state = [];
  }
}

Future<List<Map<String, dynamic>>> _parseAnagraficaIsolate(Map<String, dynamic> params) async {
  final String filePath = params['filePath'];
  
  try {
    debugPrint('Isolate: Inizio lettura bytes file...');
    final bytes = File(filePath).readAsBytesSync();
    debugPrint('Isolate: Decodifica Excel...');
    final excel = Excel.decodeBytes(bytes);
    
    // Ricerca foglio case-insensitive: cerca foglio "anagrafica" o scarta fogli tipo "pivot"
    String? selectedSheetName;
    for (final key in excel.tables.keys) {
      final cleanKey = key.trim().toLowerCase();
      if (cleanKey == 'anagrafica') {
        selectedSheetName = key;
        break;
      }
    }

    if (selectedSheetName == null) {
      for (final key in excel.tables.keys) {
        final cleanKey = key.trim().toLowerCase();
        if (cleanKey.contains('anagrafica')) {
          selectedSheetName = key;
          break;
        }
      }
    }

    if (selectedSheetName == null) {
      // Seleziona il foglio con più righe escludendo pivot/riepilogo
      int maxRows = -1;
      for (final entry in excel.tables.entries) {
        final lower = entry.key.toLowerCase();
        if (lower.contains('pivot') || lower.contains('riepilogo')) continue;
        if (entry.value.maxRows > maxRows) {
          maxRows = entry.value.maxRows;
          selectedSheetName = entry.key;
        }
      }
    }

    selectedSheetName ??= excel.tables.keys.first;
    final sheet = excel.tables[selectedSheetName];
    if (sheet == null) {
      throw Exception('Foglio Anagrafica non trovato.');
    }
    
    debugPrint('Isolate: Foglio "$selectedSheetName" selezionato. Righe: ${sheet.maxRows}, Colonne: ${sheet.maxColumns}');
    
    final List<Map<String, dynamic>> results = [];
    if (sheet.maxRows <= 1) return results;

    String normalize(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

    // Mappatura dinamica degli header per gestire variazioni di colonne (es. AREA/FASCIA)
    final Map<String, int> colMap = {};
    final headerRow = sheet.rows.first;
    for (int i = 0; i < headerRow.length; i++) {
      final cell = headerRow[i];
      if (cell != null && cell.value != null) {
        final key = normalize(cell.value.toString());
        if (key.isNotEmpty && !colMap.containsKey(key)) {
          colMap[key] = i;
        }
      }
    }

    int findCol(List<String> candidates, int fallbackIndex) {
      for (final c in candidates) {
        final norm = normalize(c);
        if (colMap.containsKey(norm)) {
          return colMap[norm]!;
        }
      }
      return fallbackIndex;
    }

    final int idxCid = findCol(['cid'], 0);
    final int idxNominativo = findCol(['nominativo'], 1);
    final int idxCodiceFiscale = findCol(['codicefiscale', 'cf'], 2);
    final int idxSesso = findCol(['sesso'], 3);
    final int idxDataNascita = findCol(['datadinascita', 'datanascita'], 4);
    final int idxLuogoNascita = findCol(['luogodinascita', 'luogonascita'], 5);
    final int idxDataAssunzione = findCol(['datadiassunzione', 'dataassunzione'], 6);
    final int idxDataAssunzioneGruppo = findCol(['datadiassunzionegruppo', 'dataassunzionegruppo'], 7);
    final int idxTipoScuola = findCol(['tiposcuola'], 8);
    final int idxFormazione = findCol(['formazione'], 9);
    final int idxLivello = findCol(['livello'], 10);
    final int idxAreaFascia = findCol(['areafascia', 'area', 'fascia'], -1);
    final int idxTipoDip = findCol(['tipodip', 'tipodipendente'], 11);
    final int idxGradoOccupaz = findCol(['gradooccupaz', 'gradooccupazione'], 12);
    final int idxGradoOccupazInSol = findCol(['gradooccupazinsol'], 13);
    final int idxContrSolidarieta = findCol(['contrsolidarieta'], 14);
    final int idxSocieta = findCol(['societa'], 15);
    final int idxSocietaContabile = findCol(['societacontabile'], 16);
    final int idxUnitaOrg3 = findCol(['unitaorg3'], 17);
    final int idxUnitaOrg3Des = findCol(['unitaorg3des', 'unitaorg3descrizione'], 18);
    final int idxUnitaOrg4 = findCol(['unitaorg4'], 19);
    final int idxUnitaOrg4Des = findCol(['unitaorg4des', 'unitaorg4descrizione'], 20);
    final int idxUnitaOrg5 = findCol(['unitaorg5'], 21);
    final int idxUnitaOrg5Des = findCol(['unitaorg5des', 'unitaorg5descrizione'], 22);
    final int idxUnitaOrg6 = findCol(['unitaorg6'], 23);
    final int idxUnitaOrg6Des = findCol(['unitaorg6des', 'unitaorg6descrizione'], 24);
    final int idxUnitaOrg7 = findCol(['unitaorg7'], 25);
    final int idxUnitaOrg7Des = findCol(['unitaorg7des', 'unitaorg7descrizione'], 26);
    final int idxUnitaOrg8 = findCol(['unitaorg8'], 27);
    final int idxUnitaOrg8Des = findCol(['unitaorg8des', 'unitaorg8descrizione'], 28);
    final int idxUnitaOrg9 = findCol(['unitaorg9'], 29);
    final int idxUnitaOrg9Des = findCol(['unitaorg9des', 'unitaorg9descrizione'], 30);
    final int idxUnitaOrganizzativa = findCol(['unitaorganizzativa'], 31);
    final int idxCidResponsabileUO = findCol(['cidresponsabileuo'], 32);
    final int idxNominativoResponsabileUO = findCol(['nominativoresponsabileuo'], 33);
    final int idxMailResponsabileUO = findCol(['mailresponsabileuo'], 34);
    final int idxPaese = findCol(['paese'], 35);
    final int idxRegione = findCol(['regione'], 36);
    final int idxProvincia = findCol(['provincia'], 37);
    final int idxSedeProvincia = findCol(['sedeprovincia'], 38);
    final int idxSedeIndirizzo = findCol(['sedeindirizzo'], 39);
    final int idxSedeCap = findCol(['sedecap'], 40);
    final int idxSedeComune = findCol(['sedecomune'], 41);
    final int idxTipoContratto = findCol(['tipocontratto'], 42);
    final int idxPartTimeFullTime = findCol(['parttimefulltime'], 43);
    final int idxMansione = findCol(['mansione'], 44);
    final int idxPosizione = findCol(['posizione'], 45);
    final int idxNuovoSistProfFamiglia = findCol(['nuovosistproffamiglia'], 46);
    final int idxNuovoSistProfArea = findCol(['nuovosistprofarea'], 47);
    final int idxNuovoSistProfAmbito = findCol(['nuovosistprofambito'], 48);
    final int idxNuovoSistProfJob = findCol(['nuovosistprofjob'], 49);
    final int idxStatus = findCol(['status'], 50);
    final int idxUtenteCOD = findCol(['utentecod'], 51);
    final int idxUtenteRU = findCol(['utenteru'], 52);
    final int idxUtenteKA = findCol(['utenteka'], 53);
    final int idxUtenteRUBU = findCol(['utenterubu'], 54);
    final int idxIndirizzoMail = findCol(['indirizzomail'], 55);
    final int idxCidKeyAccount = findCol(['cidkeyaccount'], 56);
    final int idxNominativoKeyAccount = findCol(['nominativokeyaccount'], 57);
    final int idxMailKeyAccount = findCol(['mailkeyaccount'], 58);
    final int idxCidGestore = findCol(['cidgestore'], 59);
    final int idxNominativoGestore = findCol(['nominativogestore'], 60);
    final int idxMailGestore = findCol(['mailgestore'], 61);
    final int idxUnder35 = findCol(['under35'], 62);
    final int idxResponsabileSINO = findCol(['responsabilesino'], 63);
    final int idxTipologiaResponsabile = findCol(['tipologiaresponsabile'], 64);
    final int idxMatricolaAziendaleUID = findCol(['matricolaaziendaleuid'], 65);

    int rowIndex = 0;
    for (final row in sheet.rows) {
      rowIndex++;
      if (rowIndex == 1) continue; // Salta intestazione

      if (row.isEmpty) continue;

      String getString(int index) {
        if (index < 0 || index >= row.length) return '';
        final cell = row[index];
        if (cell == null || cell.value == null) return '';
        return cell.value.toString().trim();
      }

      final cf = getString(idxCodiceFiscale);
      if (cf.isEmpty) continue;

      final rawCid = getString(idxCid);
      final cid = rawCid.isNotEmpty ? rawCid.padLeft(8, '0') : '';

      results.add({
        'cid': cid,
        'nominativo': getString(idxNominativo),
        'codiceFiscale': cf,
        'sesso': getString(idxSesso),
        'dataNascita': getString(idxDataNascita),
        'luogoNascita': getString(idxLuogoNascita),
        'dataAssunzione': getString(idxDataAssunzione),
        'dataAssunzioneGruppo': getString(idxDataAssunzioneGruppo),
        'tipoScuola': getString(idxTipoScuola),
        'formazione': getString(idxFormazione),
        'livello': getString(idxLivello),
        'areaFascia': idxAreaFascia >= 0 ? getString(idxAreaFascia) : null,
        'tipoDip': getString(idxTipoDip),
        'gradoOccupaz': getString(idxGradoOccupaz),
        'gradoOccupazInSol': getString(idxGradoOccupazInSol),
        'contrSolidarieta': getString(idxContrSolidarieta),
        'societa': getString(idxSocieta),
        'societaContabile': getString(idxSocietaContabile),
        'unitaOrg3': getString(idxUnitaOrg3),
        'unitaOrg3Des': getString(idxUnitaOrg3Des),
        'unitaOrg4': getString(idxUnitaOrg4),
        'unitaOrg4Des': getString(idxUnitaOrg4Des),
        'unitaOrg5': getString(idxUnitaOrg5),
        'unitaOrg5Des': getString(idxUnitaOrg5Des),
        'unitaOrg6': getString(idxUnitaOrg6),
        'unitaOrg6Des': getString(idxUnitaOrg6Des),
        'unitaOrg7': getString(idxUnitaOrg7),
        'unitaOrg7Des': getString(idxUnitaOrg7Des),
        'unitaOrg8': getString(idxUnitaOrg8),
        'unitaOrg8Des': getString(idxUnitaOrg8Des),
        'unitaOrg9': getString(idxUnitaOrg9),
        'unitaOrg9Des': getString(idxUnitaOrg9Des),
        'unitaOrganizzativa': getString(idxUnitaOrganizzativa),
        'cidResponsabileUO': getString(idxCidResponsabileUO),
        'nominativoResponsabileUO': getString(idxNominativoResponsabileUO),
        'mailResponsabileUO': getString(idxMailResponsabileUO),
        'paese': getString(idxPaese),
        'regione': getString(idxRegione),
        'provincia': getString(idxProvincia),
        'sedeProvincia': getString(idxSedeProvincia),
        'sedeIndirizzo': getString(idxSedeIndirizzo),
        'sedeCap': getString(idxSedeCap),
        'sedeComune': getString(idxSedeComune),
        'tipoContratto': getString(idxTipoContratto),
        'partTimeFullTime': getString(idxPartTimeFullTime),
        'mansione': getString(idxMansione),
        'posizione': getString(idxPosizione),
        'nuovoSistProfFamiglia': getString(idxNuovoSistProfFamiglia),
        'nuovoSistProfArea': getString(idxNuovoSistProfArea),
        'nuovoSistProfAmbito': getString(idxNuovoSistProfAmbito),
        'nuovoSistProfJob': getString(idxNuovoSistProfJob),
        'status': getString(idxStatus),
        'utenteCOD': getString(idxUtenteCOD),
        'utenteRU': getString(idxUtenteRU),
        'utenteKA': getString(idxUtenteKA),
        'utenteRUBU': getString(idxUtenteRUBU),
        'indirizzoMail': getString(idxIndirizzoMail),
        'cidKeyAccount': getString(idxCidKeyAccount),
        'nominativoKeyAccount': getString(idxNominativoKeyAccount),
        'mailKeyAccount': getString(idxMailKeyAccount),
        'cidGestore': getString(idxCidGestore),
        'nominativoGestore': getString(idxNominativoGestore),
        'mailGestore': getString(idxMailGestore),
        'under35': getString(idxUnder35),
        'responsabileSINO': getString(idxResponsabileSINO),
        'tipologiaResponsabile': getString(idxTipologiaResponsabile),
        'matricolaAziendaleUID': getString(idxMatricolaAziendaleUID),
      });

      if (rowIndex % 1000 == 0) {
        debugPrint('Isolate: Elaborate $rowIndex righe...');
      }
    }
    
    debugPrint('Isolate: Parsing completato. Record validi: ${results.length}');
    return results;
  } catch (e, stack) {
    debugPrint('Isolate ERROR: $e');
    debugPrint('Stack: $stack');
    rethrow;
  }
}

final anagraficaProvider = NotifierProvider<AnagraficaNotifier, List<Anagrafica>>(() {
  return AnagraficaNotifier();
});
