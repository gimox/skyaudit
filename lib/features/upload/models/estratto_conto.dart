import 'package:isar/isar.dart';

part 'estratto_conto.g.dart';

@collection
class EstrattoConto {
  Id id = Isar.autoIncrement;

  final String nrEstrattoConto; // 0
  final String nrBolla; // 1

  @Index(unique: false)
  final String bolla; // Calculated field from index 1

  final String dataBolla; // 2
  final String dataCompetenza; // 3
  final String codiceCliente; // 4
  final String ragioneSociale; // 5
  final String tipoTransazione; // 6
  final String tipoServizio; // 7
  final String descrizioneServizio; //8
  final String itinerario; // 9
  final String fornitore; // 10
  final String codiceViaggio; // 11
  final String nrPax; // 12
  final String nrTktBolla; // 13
  final String nomePasseggero; // 14
  final String metPagamentoServ; // 15
  final String metPagamentoFee; // 16
  final double importoServizio; // 17
  final double tasse; // 18
  final double fee; // 19
  final String codiceIva; // 20
  final double importoIvaServizio; // 21
  final double importoIvaTasse; // 22
  final double importoIvaFee; // 23
  final double totaleServizio; // 24
  final double totaleTasse; // 25
  final double totaleServizioGenerale; // 26
  final double totaleFee; // 27
  final String dataIn; // 28
  final String dataOut; // 29
  final String localitaPartenza; // 30
  final String localitaArrivo; // 31
  final String codiceTrattamento; // 32
  final String codiceSistemazione; // 33
  final String richiedente; // 34
  final String cid; // 35
  final String centroCosto; // 36
  final String numeroTrasferta; // 37
  final String campoStatistico4; // 38
  final String rigaCrm; // 39
  final String sapNoSap; // 40
  final String campoStatistico7; // 41
  final String campoStatistico8; // 42
  final String campoStatistico9; // 43
  final String campoStatistico10; // 44
  final String numeroCCServizio; // 45
  final String numeroCCFee; // 46
  final String numeroDocumServizio; // 47
  final String numeroDocumFee; // 48
  final String nrNotti; // 49
  final String segueFatturaServizi; // 50
  final String servizioDaPagare; // 51
  final double merchantFee; // 52
  final String descrizioneSpedireA; // 53
  final String descrizioneRighePratiche; // 54
  final int? sourceFileLine;

  EstrattoConto({
    required this.nrEstrattoConto,
    required this.nrBolla,
    required this.bolla,
    required this.dataBolla,
    required this.dataCompetenza,
    required this.codiceCliente,
    required this.ragioneSociale,
    required this.tipoTransazione,
    required this.tipoServizio,
    required this.descrizioneServizio,
    required this.itinerario,
    required this.fornitore,
    required this.codiceViaggio,
    required this.nrPax,
    required this.nrTktBolla,
    required this.nomePasseggero,
    required this.metPagamentoServ,
    required this.metPagamentoFee,
    required this.importoServizio,
    required this.tasse,
    required this.fee,
    required this.codiceIva,
    required this.importoIvaServizio,
    required this.importoIvaTasse,
    required this.importoIvaFee,
    required this.totaleServizio,
    required this.totaleTasse,
    required this.totaleServizioGenerale,
    required this.totaleFee,
    required this.dataIn,
    required this.dataOut,
    required this.localitaPartenza,
    required this.localitaArrivo,
    required this.codiceTrattamento,
    required this.codiceSistemazione,
    required this.richiedente,
    required this.cid,
    required this.centroCosto,
    required this.numeroTrasferta,
    required this.campoStatistico4,
    required this.rigaCrm,
    required this.sapNoSap,
    required this.campoStatistico7,
    required this.campoStatistico8,
    required this.campoStatistico9,
    required this.campoStatistico10,
    required this.numeroCCServizio,
    required this.numeroCCFee,
    required this.numeroDocumServizio,
    required this.numeroDocumFee,
    required this.nrNotti,
    required this.segueFatturaServizi,
    required this.servizioDaPagare,
    required this.merchantFee,
    required this.descrizioneSpedireA,
    required this.descrizioneRighePratiche,
    this.sourceFileLine,
  });

  Map<String, dynamic> toMap() {
    return {
      'nrEstrattoConto': nrEstrattoConto,
      'nrBolla': nrBolla,
      'bolla': bolla,
      'dataBolla': dataBolla,
      'dataCompetenza': dataCompetenza,
      'codiceCliente': codiceCliente,
      'ragioneSociale': ragioneSociale,
      'tipoTransazione': tipoTransazione,
      'tipoServizio': tipoServizio,
      'descrizioneServizio': descrizioneServizio,
      'itinerario': itinerario,
      'fornitore': fornitore,
      'codiceViaggio': codiceViaggio,
      'nrPax': nrPax,
      'nrTktBolla': nrTktBolla,
      'nomePasseggero': nomePasseggero,
      'metPagamentoServ': metPagamentoServ,
      'metPagamentoFee': metPagamentoFee,
      'importoServizio': importoServizio,
      'tasse': tasse,
      'fee': fee,
      'codiceIva': codiceIva,
      'importoIvaServizio': importoIvaServizio,
      'importoIvaTasse': importoIvaTasse,
      'importoIvaFee': importoIvaFee,
      'totaleServizio': totaleServizio,
      'totaleTasse': totaleTasse,
      'totaleServizioGenerale': totaleServizioGenerale,
      'totaleFee': totaleFee,
      'dataIn': dataIn,
      'dataOut': dataOut,
      'localitaPartenza': localitaPartenza,
      'localitaArrivo': localitaArrivo,
      'codiceTrattamento': codiceTrattamento,
      'codiceSistemazione': codiceSistemazione,
      'richiedente': richiedente,
      'cid': cid,
      'centroCosto': centroCosto,
      'numeroTrasferta': numeroTrasferta,
      'campoStatistico4': campoStatistico4,
      'rigaCrm': rigaCrm,
      'sapNoSap': sapNoSap,
      'campoStatistico7': campoStatistico7,
      'campoStatistico8': campoStatistico8,
      'campoStatistico9': campoStatistico9,
      'campoStatistico10': campoStatistico10,
      'numeroCCServizio': numeroCCServizio,
      'numeroCCFee': numeroCCFee,
      'numeroDocumServizio': numeroDocumServizio,
      'numeroDocumFee': numeroDocumFee,
      'nrNotti': nrNotti,
      'segueFatturaServizi': segueFatturaServizi,
      'servizioDaPagare': servizioDaPagare,
      'merchantFee': merchantFee,
      'descrizioneSpedireA': descrizioneSpedireA,
      'descrizioneRighePratiche': descrizioneRighePratiche,
      'sourceFileLine': sourceFileLine,
    };
  }

  factory EstrattoConto.fromMap(Map<String, dynamic> map) {
    return EstrattoConto(
      nrEstrattoConto: map['nrEstrattoConto'] ?? '',
      nrBolla: map['nrBolla'] ?? '',
      bolla: map['bolla'] ?? '',
      dataBolla: map['dataBolla'] ?? '',
      dataCompetenza: map['dataCompetenza'] ?? '',
      codiceCliente: map['codiceCliente'] ?? '',
      ragioneSociale: map['ragioneSociale'] ?? '',
      tipoTransazione: map['tipoTransazione'] ?? '',
      tipoServizio: map['tipoServizio'] ?? '',
      descrizioneServizio: map['descrizioneServizio'] ?? '',
      itinerario: map['itinerario'] ?? '',
      fornitore: map['fornitore'] ?? '',
      codiceViaggio: map['codiceViaggio'] ?? '',
      nrPax: map['nrPax'] ?? '',
      nrTktBolla: map['nrTktBolla'] ?? '',
      nomePasseggero: map['nomePasseggero'] ?? '',
      metPagamentoServ: map['metPagamentoServ'] ?? '',
      metPagamentoFee: map['metPagamentoFee'] ?? '',
      importoServizio: (map['importoServizio'] as num?)?.toDouble() ?? 0.0,
      tasse: (map['tasse'] as num?)?.toDouble() ?? 0.0,
      fee: (map['fee'] as num?)?.toDouble() ?? 0.0,
      codiceIva: map['codiceIva'] ?? '',
      importoIvaServizio: (map['importoIvaServizio'] as num?)?.toDouble() ?? 0.0,
      importoIvaTasse: (map['importoIvaTasse'] as num?)?.toDouble() ?? 0.0,
      importoIvaFee: (map['importoIvaFee'] as num?)?.toDouble() ?? 0.0,
      totaleServizio: (map['totaleServizio'] as num?)?.toDouble() ?? 0.0,
      totaleTasse: (map['totaleTasse'] as num?)?.toDouble() ?? 0.0,
      totaleServizioGenerale: (map['totaleServizioGenerale'] as num?)?.toDouble() ?? 0.0,
      totaleFee: (map['totaleFee'] as num?)?.toDouble() ?? 0.0,
      dataIn: map['dataIn'] ?? '',
      dataOut: map['dataOut'] ?? '',
      localitaPartenza: map['localitaPartenza'] ?? '',
      localitaArrivo: map['localitaArrivo'] ?? '',
      codiceTrattamento: map['codiceTrattamento'] ?? '',
      codiceSistemazione: map['codiceSistemazione'] ?? '',
      richiedente: map['richiedente'] ?? '',
      cid: map['cid'] ?? '',
      centroCosto: map['centroCosto'] ?? '',
      numeroTrasferta: map['numeroTrasferta'] ?? '',
      campoStatistico4: map['campoStatistico4'] ?? '',
      rigaCrm: map['rigaCrm'] ?? '',
      sapNoSap: map['sapNoSap'] ?? '',
      campoStatistico7: map['campoStatistico7'] ?? '',
      campoStatistico8: map['campoStatistico8'] ?? '',
      campoStatistico9: map['campoStatistico9'] ?? '',
      campoStatistico10: map['campoStatistico10'] ?? '',
      numeroCCServizio: map['numeroCCServizio'] ?? '',
      numeroCCFee: map['numeroCCFee'] ?? '',
      numeroDocumServizio: map['numeroDocumServizio'] ?? '',
      numeroDocumFee: map['numeroDocumFee'] ?? '',
      nrNotti: map['nrNotti'] ?? '',
      segueFatturaServizi: map['segueFatturaServizi'] ?? '',
      servizioDaPagare: map['servizioDaPagare'] ?? '',
      merchantFee: (map['merchantFee'] as num?)?.toDouble() ?? 0.0,
      descrizioneSpedireA: map['descrizioneSpedireA'] ?? '',
      descrizioneRighePratiche: map['descrizioneRighePratiche'] ?? '',
      sourceFileLine: map['sourceFileLine'] as int?,
    );
  }
}
