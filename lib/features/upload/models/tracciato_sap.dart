import 'package:isar/isar.dart';

part 'tracciato_sap.g.dart';

@collection
class TracciatoSap {
  Id id = Isar.autoIncrement;

  @Index()
  final String cid;
  final String nomeDipendente;
  final String societaCodice;
  final String societaDescrizione;
  final String tipoDipendente;
  final String classeRetributiva;
  @Index()
  final String numeroTrasferta;
  final String? progressivoGiustificativo;
  final String tipoSpesaCodice;
  final String tipoSpesaDescrizione;
  final double importo;
  final String valuta;
  final String data;
  final String? riTr;
  final String? cdRichiesta;
  final String? calc;
  final String? codiceStato;
  final String? fi;
  final String? codiceTrasferimentoFi;
  final String? colonnaT; // Indice 19

  final String? logHistoryId;

  TracciatoSap({
    required this.cid,
    required this.nomeDipendente,
    required this.societaCodice,
    required this.societaDescrizione,
    required this.tipoDipendente,
    required this.classeRetributiva,
    required this.numeroTrasferta,
    this.progressivoGiustificativo,
    required this.tipoSpesaCodice,
    required this.tipoSpesaDescrizione,
    required this.importo,
    required this.valuta,
    required this.data,
    this.riTr,
    this.cdRichiesta,
    this.calc,
    this.codiceStato,
    this.fi,
    this.codiceTrasferimentoFi,
    this.colonnaT,
    this.logHistoryId,
  });

  factory TracciatoSap.fromExcelRow(List<dynamic> row, {String? logHistoryId}) {
    // Helper to get string safely
    String getString(int index) {
      if (index >= row.length) return '';
      final val = row[index];
      if (val == null) return '';
      return val.toString().trim();
    }

    // Helper to get double safely
    double getDouble(int index) {
      if (index >= row.length) return 0.0;
      final val = row[index];
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString().replaceAll(',', '.')) ?? 0.0;
    }

    return TracciatoSap(
      cid: getString(0),
      nomeDipendente: getString(1),
      societaCodice: getString(2),
      societaDescrizione: getString(3),
      tipoDipendente: getString(4),
      classeRetributiva: getString(5),
      numeroTrasferta: getString(6),
      progressivoGiustificativo: getString(7),
      tipoSpesaCodice: getString(8),
      tipoSpesaDescrizione: getString(9),
      importo: getDouble(10),
      valuta: getString(11),
      data: getString(12),
      riTr: getString(13),
      cdRichiesta: getString(14),
      calc: getString(15),
      codiceStato: getString(16),
      fi: getString(17),
      codiceTrasferimentoFi: getString(18),
      colonnaT: getString(19),
      logHistoryId: logHistoryId,
    );
  }
}
