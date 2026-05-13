import 'package:isar/isar.dart';

part 'estratto_amex.g.dart';

@collection
class EstrattoAmex {
  Id id = Isar.autoIncrement;

  // Campi mappati specificamente
  @Index()
  String? cid;
  
  @Index()
  String? numeroTrasferta;
  
  @Index()
  String? bolla; // Bolla trasformata per matching
  
  String? bollaOriginale; // Rif 5 originale

  // Altri campi (A-BL)
  String? numeroConto; // A
  String? conto; // B
  String? identificativoEstrattoConto; // C
  String? dataEstrattoConto; // D
  String? idTransazione; // E
  String? dataTransazione; // F
  String? dataScadenzaPagamento; // G
  String? dataProcessazione; // H
  String? stato; // I
  String? contestata; // J
  String? numeroBollaFattura; // K
  String? fatturaAgenziaViaggio; // L
  String? indicator; // M
  String? nomeViaggiatore; // N
  String? aeroportoDestinazione; // O
  String? aeroportoPartenza; // P
  String? dataPartenza; // Q
  double? importoLordo; // R
  double? importoAllocato; // S
  double? importoNonAllocato; // T
  double? importoNetto; // U
  double? totaleImportoTasse; // V
  String? valuta; // W
  String? riferimentoEstrattoConto; // X
  String? rifPagamentoEstrattoConto; // Y
  String? debitCreditCode; // Z
  String? agenziaViaggi; // AA
  String? ufficioViaggi; // AB
  String? rif1; // AC (Mappato a CID)
  String? rif2; // AD
  String? rif3; // AE (Mappato a numeroTrasferta)
  String? rif4; // AF
  String? rif5; // AG (Mappato a bollaOriginale/bolla)
  String? rif6; // AH
  String? rif7; // AI
  String? pnrNo; // AJ
  String? rifViaggio1; // AK
  String? rifViaggio2; // AL
  String? rifViaggio3; // AM
  String? rifViaggio4; // AN
  String? nomeEsercizio; // AO
  String? tassoCambio; // AP
  String? allocazionePagamento; // AQ
  String? valutaTransazione; // AR
  String? codiceMercato; // AS
  String? rifEstrattoContoCarta; // AT
  String? codiceVettore; // AU
  String? codiceSettore; // AV
  String? inizialiPasseggero; // AW
  String? numeroContoSE; // AX
  String? cittaSE; // AY
  String? codiceSettoreSE; // AZ
  String? numFatturaSEOriginale; // BA
  String? numFatturaSE; // BB
  String? codiceTipoTransazione; // BC
  String? nomeFornitore; // BD
  String? idRegione; // BE
  String? statoRichiesta; // BF
  String? dataAperturaRichiesta; // BG
  String? dataChiusuraRichiesta; // BH
  String? inoltrare; // BI
  String? vettore; // BJ
  String? classeViaggio; // BK
  String? ordine; // BL

  // Campi tecnici
  String? logHistoryId;
  int? sourceFileLine;

  EstrattoAmex();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cid': cid,
      'numeroTrasferta': numeroTrasferta,
      'bolla': bolla,
      'bollaOriginale': bollaOriginale,
      'nomeViaggiatore': nomeViaggiatore,
      'importoLordo': importoLordo,
      'dataTransazione': dataTransazione,
      'fornitore': nomeFornitore,
      // Aggiungi altri campi se necessario per la UI
    };
  }

  factory EstrattoAmex.fromMap(Map<String, dynamic> map) {
    final record = EstrattoAmex();
    record.cid = map['cid'];
    record.numeroTrasferta = map['numeroTrasferta'];
    record.bolla = map['bolla'];
    record.bollaOriginale = map['bollaOriginale'];
    record.numeroConto = map['numeroConto'];
    record.conto = map['conto'];
    record.identificativoEstrattoConto = map['identificativoEstrattoConto'];
    record.dataEstrattoConto = map['dataEstrattoConto'];
    record.idTransazione = map['idTransazione'];
    record.dataTransazione = map['dataTransazione'];
    record.dataScadenzaPagamento = map['dataScadenzaPagamento'];
    record.dataProcessazione = map['dataProcessazione'];
    record.stato = map['stato'];
    record.contestata = map['contestata'];
    record.numeroBollaFattura = map['numeroBollaFattura'];
    record.fatturaAgenziaViaggio = map['fatturaAgenziaViaggio'];
    record.indicator = map['indicator'];
    record.nomeViaggiatore = map['nomeViaggiatore'];
    record.aeroportoDestinazione = map['aeroportoDestinazione'];
    record.aeroportoPartenza = map['aeroportoPartenza'];
    record.dataPartenza = map['dataPartenza'];
    record.importoLordo = map['importoLordo'];
    record.importoAllocato = map['importoAllocato'];
    record.importoNonAllocato = map['importoNonAllocato'];
    record.importoNetto = map['importoNetto'];
    record.totaleImportoTasse = map['totaleImportoTasse'];
    record.valuta = map['valuta'];
    record.riferimentoEstrattoConto = map['riferimentoEstrattoConto'];
    record.rifPagamentoEstrattoConto = map['rifPagamentoEstrattoConto'];
    record.debitCreditCode = map['debitCreditCode'];
    record.agenziaViaggi = map['agenziaViaggi'];
    record.ufficioViaggi = map['ufficioViaggi'];
    record.rif1 = map['rif1'];
    record.rif2 = map['rif2'];
    record.rif3 = map['rif3'];
    record.rif4 = map['rif4'];
    record.rif5 = map['rif5'];
    record.rif6 = map['rif6'];
    record.rif7 = map['rif7'];
    record.pnrNo = map['pnrNo'];
    record.rifViaggio1 = map['rifViaggio1'];
    record.rifViaggio2 = map['rifViaggio2'];
    record.rifViaggio3 = map['rifViaggio3'];
    record.rifViaggio4 = map['rifViaggio4'];
    record.nomeEsercizio = map['nomeEsercizio'];
    record.tassoCambio = map['tassoCambio'];
    record.allocazionePagamento = map['allocazionePagamento'];
    record.valutaTransazione = map['valutaTransazione'];
    record.codiceMercato = map['codiceMercato'];
    record.rifEstrattoContoCarta = map['rifEstrattoContoCarta'];
    record.codiceVettore = map['codiceVettore'];
    record.codiceSettore = map['codiceSettore'];
    record.inizialiPasseggero = map['inizialiPasseggero'];
    record.numeroContoSE = map['numeroContoSE'];
    record.cittaSE = map['cittaSE'];
    record.codiceSettoreSE = map['codiceSettoreSE'];
    record.numFatturaSEOriginale = map['numFatturaSEOriginale'];
    record.numFatturaSE = map['numFatturaSE'];
    record.codiceTipoTransazione = map['codiceTipoTransazione'];
    record.nomeFornitore = map['nomeFornitore'];
    record.idRegione = map['idRegione'];
    record.statoRichiesta = map['statoRichiesta'];
    record.dataAperturaRichiesta = map['dataAperturaRichiesta'];
    record.dataChiusuraRichiesta = map['dataChiusuraRichiesta'];
    record.inoltrare = map['inoltrare'];
    record.vettore = map['vettore'];
    record.classeViaggio = map['classeViaggio'];
    record.ordine = map['ordine'];
    record.logHistoryId = map['logHistoryId'];
    record.sourceFileLine = map['sourceFileLine'];
    return record;
  }
}
