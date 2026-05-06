import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cross_file/cross_file.dart';
import 'package:isar/isar.dart';
import 'package:excel/excel.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import '../models/estratto_conto.dart';

class EstrattoContoNotifier extends Notifier<List<EstrattoConto>> {
  @override
  List<EstrattoConto> build() {
    final isar = ref.watch(isarProvider);
    return isar.estrattoContos.where().anyId().findAllSync();
  }

  Future<Map<String, int>> loadFromFile(XFile file) async {
    final isar = ref.read(isarProvider);
    final bytes = File(file.path).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final List<EstrattoConto> newRecords = [];

    String? documentSheetName;
    for (var name in excel.tables.keys) {
      if (name.toLowerCase() == 'document') {
        documentSheetName = name;
        break;
      }
    }

    if (documentSheetName == null) {
      throw Exception('Foglio "Document" non trovato.');
    }

    final sheet = excel.tables[documentSheetName]!;

    for (var i = 1; i < sheet.maxRows; i++) {
      final row = sheet.rows[i];
      if (row.isEmpty) continue;

      String val(int index) {
        if (index >= row.length) return '';
        final cell = row[index];
        if (cell == null || cell.value == null) return '';
        final v = cell.value;
        if (v is TextCellValue) return v.value.toString().trim();
        return v.toString().trim();
      }

      double dVal(int index) {
        if (index >= row.length) return 0.0;
        final cell = row[index];
        if (cell == null || cell.value == null) return 0.0;
        final v = cell.value;
        if (v is DoubleCellValue) return v.value;
        if (v is IntCellValue) return v.value.toDouble();
        if (v is TextCellValue) {
          return double.tryParse(v.value.toString().replaceAll(',', '.')) ??
              0.0;
        }
        return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0.0;
      }

      final nrBollaRaw = val(1);
      String bollaCalc = '';
      if (nrBollaRaw.isNotEmpty) {
        bollaCalc = nrBollaRaw;
        if (bollaCalc.length >= 3 && bollaCalc[2] == '/') {
          bollaCalc = '${bollaCalc.substring(0, 2)}0${bollaCalc.substring(3)}';
        }
        bollaCalc = bollaCalc.padRight(12, '0');
      }

      final record = EstrattoConto(
        nrEstrattoConto: val(0),
        nrBolla: nrBollaRaw,
        bolla: bollaCalc,
        dataBolla: val(2),
        dataCompetenza: val(3),
        codiceCliente: val(4),
        ragioneSociale: val(5),
        tipoTransazione: val(6),
        tipoServizio: val(7),
        descrizioneServizio: val(8),
        itinerario: val(9),
        fornitore: val(10),
        codiceViaggio: val(11),
        nrPax: val(12),
        nrTktBolla: val(13),
        nomePasseggero: val(14),
        metPagamentoServ: val(15),
        metPagamentoFee: val(16),
        importoServizio: dVal(17),
        tasse: dVal(18),
        fee: dVal(19),
        codiceIva: val(20),
        importoIvaServizio: dVal(21),
        importoIvaTasse: dVal(22),
        importoIvaFee: dVal(23),
        totaleServizio: dVal(24),
        totaleTasse: dVal(25),
        totaleServizioGenerale: dVal(26),
        totaleFee: dVal(27),
        dataIn: val(28),
        dataOut: val(29),
        localitaPartenza: val(30),
        localitaArrivo: val(31),
        codiceTrattamento: val(32),
        codiceSistemazione: val(33),
        richiedente: val(34),
        cid: val(35),
        centroCosto: val(36),
        numeroTrasferta: val(37),
        campoStatistico4: val(38),
        rigaCrm: val(39),
        sapNoSap: val(40),
        campoStatistico7: val(41),
        campoStatistico8: val(42),
        campoStatistico9: val(43),
        campoStatistico10: val(44),
        numeroCCServizio: val(45),
        numeroCCFee: val(46),
        numeroDocumServizio: val(47),
        numeroDocumFee: val(48),
        nrNotti: val(49),
        segueFatturaServizi: val(50),
        servizioDaPagare: val(51),
        merchantFee: dVal(52),
        descrizioneSpedireA: val(53),
        descrizioneRighePratiche: val(54),
      );
      newRecords.add(record);
    }

    if (newRecords.isEmpty) {
      throw Exception('Nessun dato trovato.');
    }

    int insertedCount = 0;
    await isar.writeTxn(() async {
      await isar.estrattoContos.putAll(newRecords);
      insertedCount = newRecords.length;
    });

    state = isar.estrattoContos.where().anyId().findAllSync();

    return {'inserted': insertedCount, 'total': newRecords.length};
  }

  Future<void> clear() async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.estrattoContos.clear());
    state = [];
  }

  Future<void> deleteRecord(Id id) async {
    final isar = ref.read(isarProvider);
    await isar.writeTxn(() => isar.estrattoContos.delete(id));
    state = isar.estrattoContos.where().anyId().findAllSync();
  }
}

final estrattoContoProvider =
    NotifierProvider<EstrattoContoNotifier, List<EstrattoConto>>(() {
      return EstrattoContoNotifier();
    });
