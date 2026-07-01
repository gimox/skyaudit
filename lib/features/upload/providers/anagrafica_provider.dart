import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/anagrafica.dart';
import '../models/log_history.dart';
import 'log_history_provider.dart';

class AnagraficaNotifier extends Notifier<List<Anagrafica>> {
  @override
  List<Anagrafica> build() {
    final isar = ref.watch(isarProvider);
    return isar.anagraficas.where().anyId().findAllSync();
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

      final log = LogHistory(
        fileName: file.name,
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
    
    var sheetName = excel.tables.keys.contains('Anagrafica') ? 'Anagrafica' : excel.tables.keys.first;
    final sheet = excel.tables[sheetName];
    if (sheet == null) {
      throw Exception('Foglio "Anagrafica" non trovato.');
    }
    
    debugPrint('Isolate: Foglio $sheetName trovato. Righe: ${sheet.maxRows}, Colonne: ${sheet.maxColumns}');
    
    final List<Map<String, dynamic>> results = [];
    if (sheet.maxRows <= 1) return results;

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

      // Colonna C è indice 2 (Codice Fiscale)
      final cf = getString(2);
      if (cf.isEmpty) continue;

      final rawCid = getString(0);
      final cid = rawCid.isNotEmpty ? rawCid.padLeft(8, '0') : '';

      results.add({
        'cid': cid,
        'nominativo': getString(1),
        'codiceFiscale': cf,
        'sesso': getString(3),
        'dataNascita': getString(4),
        'luogoNascita': getString(5),
        'dataAssunzione': getString(6),
        'dataAssunzioneGruppo': getString(7),
        'tipoScuola': getString(8),
        'formazione': getString(9),
        'livello': getString(10),
        'tipoDip': getString(11),
        'gradoOccupaz': getString(12),
        'gradoOccupazInSol': getString(13),
        'contrSolidarieta': getString(14),
        'societa': getString(15),
        'societaContabile': getString(16),
        'unitaOrg3': getString(17),
        'unitaOrg3Des': getString(18),
        'unitaOrg4': getString(19),
        'unitaOrg4Des': getString(20),
        'unitaOrg5': getString(21),
        'unitaOrg5Des': getString(22),
        'unitaOrg6': getString(23),
        'unitaOrg6Des': getString(24),
        'unitaOrg7': getString(25),
        'unitaOrg7Des': getString(26),
        'unitaOrg8': getString(27),
        'unitaOrg8Des': getString(28),
        'unitaOrg9': getString(29),
        'unitaOrg9Des': getString(30),
        'unitaOrganizzativa': getString(31),
        'cidResponsabileUO': getString(32),
        'nominativoResponsabileUO': getString(33),
        'mailResponsabileUO': getString(34),
        'paese': getString(35),
        'regione': getString(36),
        'provincia': getString(37),
        'sedeProvincia': getString(38),
        'sedeIndirizzo': getString(39),
        'sedeCap': getString(40),
        'sedeComune': getString(41),
        'tipoContratto': getString(42),
        'partTimeFullTime': getString(43),
        'mansione': getString(44),
        'posizione': getString(45),
        'nuovoSistProfFamiglia': getString(46),
        'nuovoSistProfArea': getString(47),
        'nuovoSistProfAmbito': getString(48),
        'nuovoSistProfJob': getString(49),
        'status': getString(50),
        'utenteCOD': getString(51),
        'utenteRU': getString(52),
        'utenteKA': getString(53),
        'utenteRUBU': getString(54),
        'indirizzoMail': getString(55),
        'cidKeyAccount': getString(56),
        'nominativoKeyAccount': getString(57),
        'mailKeyAccount': getString(58),
        'cidGestore': getString(59),
        'nominativoGestore': getString(60),
        'mailGestore': getString(61),
        'under35': getString(62),
        'responsabileSINO': getString(63),
        'tipologiaResponsabile': getString(64),
        'matricolaAziendaleUID': getString(65),
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
