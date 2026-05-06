// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'estratto_conto.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEstrattoContoCollection on Isar {
  IsarCollection<EstrattoConto> get estrattoContos => this.collection();
}

const EstrattoContoSchema = CollectionSchema(
  name: r'EstrattoConto',
  id: -6768238905630775642,
  properties: {
    r'bolla': PropertySchema(id: 0, name: r'bolla', type: IsarType.string),
    r'campoStatistico10': PropertySchema(
      id: 1,
      name: r'campoStatistico10',
      type: IsarType.string,
    ),
    r'campoStatistico4': PropertySchema(
      id: 2,
      name: r'campoStatistico4',
      type: IsarType.string,
    ),
    r'campoStatistico7': PropertySchema(
      id: 3,
      name: r'campoStatistico7',
      type: IsarType.string,
    ),
    r'campoStatistico8': PropertySchema(
      id: 4,
      name: r'campoStatistico8',
      type: IsarType.string,
    ),
    r'campoStatistico9': PropertySchema(
      id: 5,
      name: r'campoStatistico9',
      type: IsarType.string,
    ),
    r'centroCosto': PropertySchema(
      id: 6,
      name: r'centroCosto',
      type: IsarType.string,
    ),
    r'cid': PropertySchema(id: 7, name: r'cid', type: IsarType.string),
    r'codiceCliente': PropertySchema(
      id: 8,
      name: r'codiceCliente',
      type: IsarType.string,
    ),
    r'codiceIva': PropertySchema(
      id: 9,
      name: r'codiceIva',
      type: IsarType.string,
    ),
    r'codiceSistemazione': PropertySchema(
      id: 10,
      name: r'codiceSistemazione',
      type: IsarType.string,
    ),
    r'codiceTrattamento': PropertySchema(
      id: 11,
      name: r'codiceTrattamento',
      type: IsarType.string,
    ),
    r'codiceViaggio': PropertySchema(
      id: 12,
      name: r'codiceViaggio',
      type: IsarType.string,
    ),
    r'dataBolla': PropertySchema(
      id: 13,
      name: r'dataBolla',
      type: IsarType.string,
    ),
    r'dataCompetenza': PropertySchema(
      id: 14,
      name: r'dataCompetenza',
      type: IsarType.string,
    ),
    r'dataIn': PropertySchema(id: 15, name: r'dataIn', type: IsarType.string),
    r'dataOut': PropertySchema(id: 16, name: r'dataOut', type: IsarType.string),
    r'descrizioneRighePratiche': PropertySchema(
      id: 17,
      name: r'descrizioneRighePratiche',
      type: IsarType.string,
    ),
    r'descrizioneServizio': PropertySchema(
      id: 18,
      name: r'descrizioneServizio',
      type: IsarType.string,
    ),
    r'descrizioneSpedireA': PropertySchema(
      id: 19,
      name: r'descrizioneSpedireA',
      type: IsarType.string,
    ),
    r'fee': PropertySchema(id: 20, name: r'fee', type: IsarType.double),
    r'fornitore': PropertySchema(
      id: 21,
      name: r'fornitore',
      type: IsarType.string,
    ),
    r'importoIvaFee': PropertySchema(
      id: 22,
      name: r'importoIvaFee',
      type: IsarType.double,
    ),
    r'importoIvaServizio': PropertySchema(
      id: 23,
      name: r'importoIvaServizio',
      type: IsarType.double,
    ),
    r'importoIvaTasse': PropertySchema(
      id: 24,
      name: r'importoIvaTasse',
      type: IsarType.double,
    ),
    r'importoServizio': PropertySchema(
      id: 25,
      name: r'importoServizio',
      type: IsarType.double,
    ),
    r'itinerario': PropertySchema(
      id: 26,
      name: r'itinerario',
      type: IsarType.string,
    ),
    r'localitaArrivo': PropertySchema(
      id: 27,
      name: r'localitaArrivo',
      type: IsarType.string,
    ),
    r'localitaPartenza': PropertySchema(
      id: 28,
      name: r'localitaPartenza',
      type: IsarType.string,
    ),
    r'merchantFee': PropertySchema(
      id: 29,
      name: r'merchantFee',
      type: IsarType.double,
    ),
    r'metPagamentoFee': PropertySchema(
      id: 30,
      name: r'metPagamentoFee',
      type: IsarType.string,
    ),
    r'metPagamentoServ': PropertySchema(
      id: 31,
      name: r'metPagamentoServ',
      type: IsarType.string,
    ),
    r'nomePasseggero': PropertySchema(
      id: 32,
      name: r'nomePasseggero',
      type: IsarType.string,
    ),
    r'nrBolla': PropertySchema(id: 33, name: r'nrBolla', type: IsarType.string),
    r'nrEstrattoConto': PropertySchema(
      id: 34,
      name: r'nrEstrattoConto',
      type: IsarType.string,
    ),
    r'nrNotti': PropertySchema(id: 35, name: r'nrNotti', type: IsarType.string),
    r'nrPax': PropertySchema(id: 36, name: r'nrPax', type: IsarType.string),
    r'nrTktBolla': PropertySchema(
      id: 37,
      name: r'nrTktBolla',
      type: IsarType.string,
    ),
    r'numeroCCFee': PropertySchema(
      id: 38,
      name: r'numeroCCFee',
      type: IsarType.string,
    ),
    r'numeroCCServizio': PropertySchema(
      id: 39,
      name: r'numeroCCServizio',
      type: IsarType.string,
    ),
    r'numeroDocumFee': PropertySchema(
      id: 40,
      name: r'numeroDocumFee',
      type: IsarType.string,
    ),
    r'numeroDocumServizio': PropertySchema(
      id: 41,
      name: r'numeroDocumServizio',
      type: IsarType.string,
    ),
    r'numeroTrasferta': PropertySchema(
      id: 42,
      name: r'numeroTrasferta',
      type: IsarType.string,
    ),
    r'ragioneSociale': PropertySchema(
      id: 43,
      name: r'ragioneSociale',
      type: IsarType.string,
    ),
    r'richiedente': PropertySchema(
      id: 44,
      name: r'richiedente',
      type: IsarType.string,
    ),
    r'rigaCrm': PropertySchema(id: 45, name: r'rigaCrm', type: IsarType.string),
    r'sapNoSap': PropertySchema(
      id: 46,
      name: r'sapNoSap',
      type: IsarType.string,
    ),
    r'segueFatturaServizi': PropertySchema(
      id: 47,
      name: r'segueFatturaServizi',
      type: IsarType.string,
    ),
    r'servizioDaPagare': PropertySchema(
      id: 48,
      name: r'servizioDaPagare',
      type: IsarType.string,
    ),
    r'tasse': PropertySchema(id: 49, name: r'tasse', type: IsarType.double),
    r'tipoServizio': PropertySchema(
      id: 50,
      name: r'tipoServizio',
      type: IsarType.string,
    ),
    r'tipoTransazione': PropertySchema(
      id: 51,
      name: r'tipoTransazione',
      type: IsarType.string,
    ),
    r'totaleFee': PropertySchema(
      id: 52,
      name: r'totaleFee',
      type: IsarType.double,
    ),
    r'totaleServizio': PropertySchema(
      id: 53,
      name: r'totaleServizio',
      type: IsarType.double,
    ),
    r'totaleServizioGenerale': PropertySchema(
      id: 54,
      name: r'totaleServizioGenerale',
      type: IsarType.double,
    ),
    r'totaleTasse': PropertySchema(
      id: 55,
      name: r'totaleTasse',
      type: IsarType.double,
    ),
  },
  estimateSize: _estrattoContoEstimateSize,
  serialize: _estrattoContoSerialize,
  deserialize: _estrattoContoDeserialize,
  deserializeProp: _estrattoContoDeserializeProp,
  idName: r'id',
  indexes: {
    r'bolla': IndexSchema(
      id: -5698054717680728322,
      name: r'bolla',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'bolla',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _estrattoContoGetId,
  getLinks: _estrattoContoGetLinks,
  attach: _estrattoContoAttach,
  version: '3.1.0+1',
);

int _estrattoContoEstimateSize(
  EstrattoConto object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bolla.length * 3;
  bytesCount += 3 + object.campoStatistico10.length * 3;
  bytesCount += 3 + object.campoStatistico4.length * 3;
  bytesCount += 3 + object.campoStatistico7.length * 3;
  bytesCount += 3 + object.campoStatistico8.length * 3;
  bytesCount += 3 + object.campoStatistico9.length * 3;
  bytesCount += 3 + object.centroCosto.length * 3;
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.codiceCliente.length * 3;
  bytesCount += 3 + object.codiceIva.length * 3;
  bytesCount += 3 + object.codiceSistemazione.length * 3;
  bytesCount += 3 + object.codiceTrattamento.length * 3;
  bytesCount += 3 + object.codiceViaggio.length * 3;
  bytesCount += 3 + object.dataBolla.length * 3;
  bytesCount += 3 + object.dataCompetenza.length * 3;
  bytesCount += 3 + object.dataIn.length * 3;
  bytesCount += 3 + object.dataOut.length * 3;
  bytesCount += 3 + object.descrizioneRighePratiche.length * 3;
  bytesCount += 3 + object.descrizioneServizio.length * 3;
  bytesCount += 3 + object.descrizioneSpedireA.length * 3;
  bytesCount += 3 + object.fornitore.length * 3;
  bytesCount += 3 + object.itinerario.length * 3;
  bytesCount += 3 + object.localitaArrivo.length * 3;
  bytesCount += 3 + object.localitaPartenza.length * 3;
  bytesCount += 3 + object.metPagamentoFee.length * 3;
  bytesCount += 3 + object.metPagamentoServ.length * 3;
  bytesCount += 3 + object.nomePasseggero.length * 3;
  bytesCount += 3 + object.nrBolla.length * 3;
  bytesCount += 3 + object.nrEstrattoConto.length * 3;
  bytesCount += 3 + object.nrNotti.length * 3;
  bytesCount += 3 + object.nrPax.length * 3;
  bytesCount += 3 + object.nrTktBolla.length * 3;
  bytesCount += 3 + object.numeroCCFee.length * 3;
  bytesCount += 3 + object.numeroCCServizio.length * 3;
  bytesCount += 3 + object.numeroDocumFee.length * 3;
  bytesCount += 3 + object.numeroDocumServizio.length * 3;
  bytesCount += 3 + object.numeroTrasferta.length * 3;
  bytesCount += 3 + object.ragioneSociale.length * 3;
  bytesCount += 3 + object.richiedente.length * 3;
  bytesCount += 3 + object.rigaCrm.length * 3;
  bytesCount += 3 + object.sapNoSap.length * 3;
  bytesCount += 3 + object.segueFatturaServizi.length * 3;
  bytesCount += 3 + object.servizioDaPagare.length * 3;
  bytesCount += 3 + object.tipoServizio.length * 3;
  bytesCount += 3 + object.tipoTransazione.length * 3;
  return bytesCount;
}

void _estrattoContoSerialize(
  EstrattoConto object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bolla);
  writer.writeString(offsets[1], object.campoStatistico10);
  writer.writeString(offsets[2], object.campoStatistico4);
  writer.writeString(offsets[3], object.campoStatistico7);
  writer.writeString(offsets[4], object.campoStatistico8);
  writer.writeString(offsets[5], object.campoStatistico9);
  writer.writeString(offsets[6], object.centroCosto);
  writer.writeString(offsets[7], object.cid);
  writer.writeString(offsets[8], object.codiceCliente);
  writer.writeString(offsets[9], object.codiceIva);
  writer.writeString(offsets[10], object.codiceSistemazione);
  writer.writeString(offsets[11], object.codiceTrattamento);
  writer.writeString(offsets[12], object.codiceViaggio);
  writer.writeString(offsets[13], object.dataBolla);
  writer.writeString(offsets[14], object.dataCompetenza);
  writer.writeString(offsets[15], object.dataIn);
  writer.writeString(offsets[16], object.dataOut);
  writer.writeString(offsets[17], object.descrizioneRighePratiche);
  writer.writeString(offsets[18], object.descrizioneServizio);
  writer.writeString(offsets[19], object.descrizioneSpedireA);
  writer.writeDouble(offsets[20], object.fee);
  writer.writeString(offsets[21], object.fornitore);
  writer.writeDouble(offsets[22], object.importoIvaFee);
  writer.writeDouble(offsets[23], object.importoIvaServizio);
  writer.writeDouble(offsets[24], object.importoIvaTasse);
  writer.writeDouble(offsets[25], object.importoServizio);
  writer.writeString(offsets[26], object.itinerario);
  writer.writeString(offsets[27], object.localitaArrivo);
  writer.writeString(offsets[28], object.localitaPartenza);
  writer.writeDouble(offsets[29], object.merchantFee);
  writer.writeString(offsets[30], object.metPagamentoFee);
  writer.writeString(offsets[31], object.metPagamentoServ);
  writer.writeString(offsets[32], object.nomePasseggero);
  writer.writeString(offsets[33], object.nrBolla);
  writer.writeString(offsets[34], object.nrEstrattoConto);
  writer.writeString(offsets[35], object.nrNotti);
  writer.writeString(offsets[36], object.nrPax);
  writer.writeString(offsets[37], object.nrTktBolla);
  writer.writeString(offsets[38], object.numeroCCFee);
  writer.writeString(offsets[39], object.numeroCCServizio);
  writer.writeString(offsets[40], object.numeroDocumFee);
  writer.writeString(offsets[41], object.numeroDocumServizio);
  writer.writeString(offsets[42], object.numeroTrasferta);
  writer.writeString(offsets[43], object.ragioneSociale);
  writer.writeString(offsets[44], object.richiedente);
  writer.writeString(offsets[45], object.rigaCrm);
  writer.writeString(offsets[46], object.sapNoSap);
  writer.writeString(offsets[47], object.segueFatturaServizi);
  writer.writeString(offsets[48], object.servizioDaPagare);
  writer.writeDouble(offsets[49], object.tasse);
  writer.writeString(offsets[50], object.tipoServizio);
  writer.writeString(offsets[51], object.tipoTransazione);
  writer.writeDouble(offsets[52], object.totaleFee);
  writer.writeDouble(offsets[53], object.totaleServizio);
  writer.writeDouble(offsets[54], object.totaleServizioGenerale);
  writer.writeDouble(offsets[55], object.totaleTasse);
}

EstrattoConto _estrattoContoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EstrattoConto(
    bolla: reader.readString(offsets[0]),
    campoStatistico10: reader.readString(offsets[1]),
    campoStatistico4: reader.readString(offsets[2]),
    campoStatistico7: reader.readString(offsets[3]),
    campoStatistico8: reader.readString(offsets[4]),
    campoStatistico9: reader.readString(offsets[5]),
    centroCosto: reader.readString(offsets[6]),
    cid: reader.readString(offsets[7]),
    codiceCliente: reader.readString(offsets[8]),
    codiceIva: reader.readString(offsets[9]),
    codiceSistemazione: reader.readString(offsets[10]),
    codiceTrattamento: reader.readString(offsets[11]),
    codiceViaggio: reader.readString(offsets[12]),
    dataBolla: reader.readString(offsets[13]),
    dataCompetenza: reader.readString(offsets[14]),
    dataIn: reader.readString(offsets[15]),
    dataOut: reader.readString(offsets[16]),
    descrizioneRighePratiche: reader.readString(offsets[17]),
    descrizioneServizio: reader.readString(offsets[18]),
    descrizioneSpedireA: reader.readString(offsets[19]),
    fee: reader.readDouble(offsets[20]),
    fornitore: reader.readString(offsets[21]),
    importoIvaFee: reader.readDouble(offsets[22]),
    importoIvaServizio: reader.readDouble(offsets[23]),
    importoIvaTasse: reader.readDouble(offsets[24]),
    importoServizio: reader.readDouble(offsets[25]),
    itinerario: reader.readString(offsets[26]),
    localitaArrivo: reader.readString(offsets[27]),
    localitaPartenza: reader.readString(offsets[28]),
    merchantFee: reader.readDouble(offsets[29]),
    metPagamentoFee: reader.readString(offsets[30]),
    metPagamentoServ: reader.readString(offsets[31]),
    nomePasseggero: reader.readString(offsets[32]),
    nrBolla: reader.readString(offsets[33]),
    nrEstrattoConto: reader.readString(offsets[34]),
    nrNotti: reader.readString(offsets[35]),
    nrPax: reader.readString(offsets[36]),
    nrTktBolla: reader.readString(offsets[37]),
    numeroCCFee: reader.readString(offsets[38]),
    numeroCCServizio: reader.readString(offsets[39]),
    numeroDocumFee: reader.readString(offsets[40]),
    numeroDocumServizio: reader.readString(offsets[41]),
    numeroTrasferta: reader.readString(offsets[42]),
    ragioneSociale: reader.readString(offsets[43]),
    richiedente: reader.readString(offsets[44]),
    rigaCrm: reader.readString(offsets[45]),
    sapNoSap: reader.readString(offsets[46]),
    segueFatturaServizi: reader.readString(offsets[47]),
    servizioDaPagare: reader.readString(offsets[48]),
    tasse: reader.readDouble(offsets[49]),
    tipoServizio: reader.readString(offsets[50]),
    tipoTransazione: reader.readString(offsets[51]),
    totaleFee: reader.readDouble(offsets[52]),
    totaleServizio: reader.readDouble(offsets[53]),
    totaleServizioGenerale: reader.readDouble(offsets[54]),
    totaleTasse: reader.readDouble(offsets[55]),
  );
  object.id = id;
  return object;
}

P _estrattoContoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readDouble(offset)) as P;
    case 21:
      return (reader.readString(offset)) as P;
    case 22:
      return (reader.readDouble(offset)) as P;
    case 23:
      return (reader.readDouble(offset)) as P;
    case 24:
      return (reader.readDouble(offset)) as P;
    case 25:
      return (reader.readDouble(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readDouble(offset)) as P;
    case 30:
      return (reader.readString(offset)) as P;
    case 31:
      return (reader.readString(offset)) as P;
    case 32:
      return (reader.readString(offset)) as P;
    case 33:
      return (reader.readString(offset)) as P;
    case 34:
      return (reader.readString(offset)) as P;
    case 35:
      return (reader.readString(offset)) as P;
    case 36:
      return (reader.readString(offset)) as P;
    case 37:
      return (reader.readString(offset)) as P;
    case 38:
      return (reader.readString(offset)) as P;
    case 39:
      return (reader.readString(offset)) as P;
    case 40:
      return (reader.readString(offset)) as P;
    case 41:
      return (reader.readString(offset)) as P;
    case 42:
      return (reader.readString(offset)) as P;
    case 43:
      return (reader.readString(offset)) as P;
    case 44:
      return (reader.readString(offset)) as P;
    case 45:
      return (reader.readString(offset)) as P;
    case 46:
      return (reader.readString(offset)) as P;
    case 47:
      return (reader.readString(offset)) as P;
    case 48:
      return (reader.readString(offset)) as P;
    case 49:
      return (reader.readDouble(offset)) as P;
    case 50:
      return (reader.readString(offset)) as P;
    case 51:
      return (reader.readString(offset)) as P;
    case 52:
      return (reader.readDouble(offset)) as P;
    case 53:
      return (reader.readDouble(offset)) as P;
    case 54:
      return (reader.readDouble(offset)) as P;
    case 55:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _estrattoContoGetId(EstrattoConto object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _estrattoContoGetLinks(EstrattoConto object) {
  return [];
}

void _estrattoContoAttach(
  IsarCollection<dynamic> col,
  Id id,
  EstrattoConto object,
) {
  object.id = id;
}

extension EstrattoContoQueryWhereSort
    on QueryBuilder<EstrattoConto, EstrattoConto, QWhere> {
  QueryBuilder<EstrattoConto, EstrattoConto, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension EstrattoContoQueryWhere
    on QueryBuilder<EstrattoConto, EstrattoConto, QWhereClause> {
  QueryBuilder<EstrattoConto, EstrattoConto, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterWhereClause> bollaEqualTo(
    String bolla,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'bolla', value: [bolla]),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterWhereClause> bollaNotEqualTo(
    String bolla,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'bolla',
                lower: [],
                upper: [bolla],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'bolla',
                lower: [bolla],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'bolla',
                lower: [bolla],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'bolla',
                lower: [],
                upper: [bolla],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension EstrattoContoQueryFilter
    on QueryBuilder<EstrattoConto, EstrattoConto, QFilterCondition> {
  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'bolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'bolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'bolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'bolla',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'bolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'bolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'bolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'bolla',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'bolla', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  bollaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'bolla', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10EqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'campoStatistico10',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'campoStatistico10',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'campoStatistico10',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'campoStatistico10',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'campoStatistico10',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'campoStatistico10',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'campoStatistico10',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'campoStatistico10',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'campoStatistico10', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico10IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'campoStatistico10', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4EqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'campoStatistico4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'campoStatistico4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'campoStatistico4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'campoStatistico4',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'campoStatistico4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'campoStatistico4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'campoStatistico4',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'campoStatistico4',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'campoStatistico4', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico4IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'campoStatistico4', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7EqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'campoStatistico7',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'campoStatistico7',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'campoStatistico7',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'campoStatistico7',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'campoStatistico7',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'campoStatistico7',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'campoStatistico7',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'campoStatistico7',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'campoStatistico7', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico7IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'campoStatistico7', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8EqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'campoStatistico8',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'campoStatistico8',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'campoStatistico8',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'campoStatistico8',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'campoStatistico8',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'campoStatistico8',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'campoStatistico8',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'campoStatistico8',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'campoStatistico8', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico8IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'campoStatistico8', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9EqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'campoStatistico9',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9GreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'campoStatistico9',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9LessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'campoStatistico9',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9Between(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'campoStatistico9',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9StartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'campoStatistico9',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9EndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'campoStatistico9',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9Contains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'campoStatistico9',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9Matches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'campoStatistico9',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9IsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'campoStatistico9', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  campoStatistico9IsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'campoStatistico9', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'centroCosto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'centroCosto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'centroCosto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'centroCosto',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'centroCosto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'centroCosto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'centroCosto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'centroCosto',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'centroCosto', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  centroCostoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'centroCosto', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> cidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  cidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> cidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> cidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cid',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  cidStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> cidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> cidContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cid',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> cidMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cid',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cid', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cid', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'codiceCliente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'codiceCliente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'codiceCliente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'codiceCliente',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'codiceCliente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'codiceCliente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'codiceCliente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'codiceCliente',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'codiceCliente', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceClienteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'codiceCliente', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'codiceIva',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'codiceIva',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'codiceIva',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'codiceIva',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'codiceIva',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'codiceIva',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'codiceIva',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'codiceIva',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'codiceIva', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceIvaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'codiceIva', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'codiceSistemazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'codiceSistemazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'codiceSistemazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'codiceSistemazione',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'codiceSistemazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'codiceSistemazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'codiceSistemazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'codiceSistemazione',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'codiceSistemazione', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceSistemazioneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'codiceSistemazione', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'codiceTrattamento',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'codiceTrattamento',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'codiceTrattamento',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'codiceTrattamento',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'codiceTrattamento',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'codiceTrattamento',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'codiceTrattamento',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'codiceTrattamento',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'codiceTrattamento', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceTrattamentoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'codiceTrattamento', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'codiceViaggio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'codiceViaggio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'codiceViaggio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'codiceViaggio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'codiceViaggio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'codiceViaggio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'codiceViaggio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'codiceViaggio',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'codiceViaggio', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  codiceViaggioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'codiceViaggio', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataBolla',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataBolla',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataBolla', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataBollaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataBolla', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataCompetenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataCompetenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataCompetenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataCompetenza',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataCompetenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataCompetenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataCompetenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataCompetenza',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataCompetenza', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataCompetenzaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataCompetenza', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataIn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataIn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataIn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataIn',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataIn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataIn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataIn',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataIn',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataIn', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataInIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataIn', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataOut',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataOut',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataOut',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataOut',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataOut',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataOut',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataOut',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataOut',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataOut', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  dataOutIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataOut', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'descrizioneRighePratiche',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'descrizioneRighePratiche',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'descrizioneRighePratiche',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'descrizioneRighePratiche',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'descrizioneRighePratiche',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'descrizioneRighePratiche',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'descrizioneRighePratiche',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'descrizioneRighePratiche',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'descrizioneRighePratiche',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneRighePraticheIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'descrizioneRighePratiche',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'descrizioneServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'descrizioneServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'descrizioneServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'descrizioneServizio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'descrizioneServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'descrizioneServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'descrizioneServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'descrizioneServizio',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'descrizioneServizio', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneServizioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'descrizioneServizio',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireAEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'descrizioneSpedireA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireAGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'descrizioneSpedireA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireALessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'descrizioneSpedireA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireABetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'descrizioneSpedireA',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireAStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'descrizioneSpedireA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireAEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'descrizioneSpedireA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireAContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'descrizioneSpedireA',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireAMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'descrizioneSpedireA',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireAIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'descrizioneSpedireA', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  descrizioneSpedireAIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'descrizioneSpedireA',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> feeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  feeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> feeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> feeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fee',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'fornitore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fornitore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fornitore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fornitore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'fornitore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'fornitore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'fornitore',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'fornitore',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fornitore', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  fornitoreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'fornitore', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaFeeEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'importoIvaFee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaFeeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importoIvaFee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaFeeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importoIvaFee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaFeeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importoIvaFee',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaServizioEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'importoIvaServizio',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaServizioGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importoIvaServizio',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaServizioLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importoIvaServizio',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaServizioBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importoIvaServizio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaTasseEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'importoIvaTasse',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaTasseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importoIvaTasse',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaTasseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importoIvaTasse',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoIvaTasseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importoIvaTasse',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoServizioEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'importoServizio',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoServizioGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importoServizio',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoServizioLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importoServizio',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  importoServizioBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importoServizio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'itinerario',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'itinerario',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'itinerario',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'itinerario',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'itinerario',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'itinerario',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'itinerario',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'itinerario',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'itinerario', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  itinerarioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'itinerario', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localitaArrivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localitaArrivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localitaArrivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localitaArrivo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localitaArrivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localitaArrivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localitaArrivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localitaArrivo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localitaArrivo', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaArrivoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localitaArrivo', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localitaPartenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localitaPartenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localitaPartenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localitaPartenza',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localitaPartenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localitaPartenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localitaPartenza',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localitaPartenza',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localitaPartenza', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  localitaPartenzaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localitaPartenza', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  merchantFeeEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'merchantFee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  merchantFeeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'merchantFee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  merchantFeeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'merchantFee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  merchantFeeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'merchantFee',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'metPagamentoFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'metPagamentoFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'metPagamentoFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'metPagamentoFee',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'metPagamentoFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'metPagamentoFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'metPagamentoFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'metPagamentoFee',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'metPagamentoFee', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoFeeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'metPagamentoFee', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'metPagamentoServ',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'metPagamentoServ',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'metPagamentoServ',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'metPagamentoServ',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'metPagamentoServ',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'metPagamentoServ',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'metPagamentoServ',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'metPagamentoServ',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'metPagamentoServ', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  metPagamentoServIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'metPagamentoServ', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nomePasseggero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nomePasseggero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nomePasseggero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nomePasseggero',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nomePasseggero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nomePasseggero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nomePasseggero',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nomePasseggero',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nomePasseggero', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nomePasseggeroIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nomePasseggero', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nrBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nrBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nrBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nrBolla',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nrBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nrBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nrBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nrBolla',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nrBolla', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrBollaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nrBolla', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nrEstrattoConto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nrEstrattoConto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nrEstrattoConto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nrEstrattoConto',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nrEstrattoConto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nrEstrattoConto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nrEstrattoConto',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nrEstrattoConto',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nrEstrattoConto', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrEstrattoContoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nrEstrattoConto', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nrNotti',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nrNotti',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nrNotti',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nrNotti',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nrNotti',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nrNotti',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nrNotti',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nrNotti',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nrNotti', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrNottiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nrNotti', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nrPax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nrPax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nrPax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nrPax',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nrPax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nrPax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nrPax',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nrPax',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nrPax', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrPaxIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nrPax', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'nrTktBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'nrTktBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'nrTktBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'nrTktBolla',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'nrTktBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'nrTktBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'nrTktBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'nrTktBolla',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'nrTktBolla', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  nrTktBollaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'nrTktBolla', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'numeroCCFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numeroCCFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numeroCCFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numeroCCFee',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'numeroCCFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'numeroCCFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'numeroCCFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'numeroCCFee',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numeroCCFee', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCFeeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'numeroCCFee', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'numeroCCServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numeroCCServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numeroCCServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numeroCCServizio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'numeroCCServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'numeroCCServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'numeroCCServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'numeroCCServizio',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numeroCCServizio', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroCCServizioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'numeroCCServizio', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'numeroDocumFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numeroDocumFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numeroDocumFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numeroDocumFee',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'numeroDocumFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'numeroDocumFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'numeroDocumFee',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'numeroDocumFee',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numeroDocumFee', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumFeeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'numeroDocumFee', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'numeroDocumServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numeroDocumServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numeroDocumServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numeroDocumServizio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'numeroDocumServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'numeroDocumServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'numeroDocumServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'numeroDocumServizio',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numeroDocumServizio', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroDocumServizioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'numeroDocumServizio',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'numeroTrasferta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numeroTrasferta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numeroTrasferta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numeroTrasferta',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'numeroTrasferta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'numeroTrasferta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'numeroTrasferta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'numeroTrasferta',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numeroTrasferta', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  numeroTrasfertaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'numeroTrasferta', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ragioneSociale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ragioneSociale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ragioneSociale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ragioneSociale',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ragioneSociale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ragioneSociale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ragioneSociale',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ragioneSociale',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ragioneSociale', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  ragioneSocialeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ragioneSociale', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'richiedente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'richiedente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'richiedente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'richiedente',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'richiedente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'richiedente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'richiedente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'richiedente',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'richiedente', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  richiedenteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'richiedente', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'rigaCrm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'rigaCrm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'rigaCrm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'rigaCrm',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'rigaCrm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'rigaCrm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'rigaCrm',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'rigaCrm',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'rigaCrm', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  rigaCrmIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'rigaCrm', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sapNoSap',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sapNoSap',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sapNoSap',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sapNoSap',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sapNoSap',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sapNoSap',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sapNoSap',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sapNoSap',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sapNoSap', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  sapNoSapIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'sapNoSap', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'segueFatturaServizi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'segueFatturaServizi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'segueFatturaServizi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'segueFatturaServizi',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'segueFatturaServizi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'segueFatturaServizi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'segueFatturaServizi',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'segueFatturaServizi',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'segueFatturaServizi', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  segueFatturaServiziIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'segueFatturaServizi',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'servizioDaPagare',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'servizioDaPagare',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'servizioDaPagare',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'servizioDaPagare',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'servizioDaPagare',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'servizioDaPagare',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'servizioDaPagare',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'servizioDaPagare',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'servizioDaPagare', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  servizioDaPagareIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'servizioDaPagare', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tasseEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tasse',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tasseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tasse',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tasseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tasse',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tasseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tasse',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tipoServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tipoServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tipoServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tipoServizio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tipoServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tipoServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tipoServizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tipoServizio',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tipoServizio', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoServizioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tipoServizio', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tipoTransazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tipoTransazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tipoTransazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tipoTransazione',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tipoTransazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tipoTransazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tipoTransazione',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tipoTransazione',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tipoTransazione', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  tipoTransazioneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tipoTransazione', value: ''),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleFeeEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totaleFee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleFeeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totaleFee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleFeeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totaleFee',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleFeeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totaleFee',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleServizioEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totaleServizio',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleServizioGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totaleServizio',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleServizioLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totaleServizio',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleServizioBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totaleServizio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleServizioGeneraleEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totaleServizioGenerale',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleServizioGeneraleGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totaleServizioGenerale',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleServizioGeneraleLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totaleServizioGenerale',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleServizioGeneraleBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totaleServizioGenerale',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleTasseEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'totaleTasse',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleTasseGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totaleTasse',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleTasseLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totaleTasse',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterFilterCondition>
  totaleTasseBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totaleTasse',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }
}

extension EstrattoContoQueryObject
    on QueryBuilder<EstrattoConto, EstrattoConto, QFilterCondition> {}

extension EstrattoContoQueryLinks
    on QueryBuilder<EstrattoConto, EstrattoConto, QFilterCondition> {}

extension EstrattoContoQuerySortBy
    on QueryBuilder<EstrattoConto, EstrattoConto, QSortBy> {
  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bolla', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bolla', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico10() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico10', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico10Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico10', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico4() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico4', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico4Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico4', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico7() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico7', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico7Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico7', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico8() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico8', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico8Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico8', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico9() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico9', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCampoStatistico9Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico9', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByCentroCosto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centroCosto', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCentroCostoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centroCosto', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCodiceCliente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceCliente', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCodiceClienteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceCliente', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByCodiceIva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceIva', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCodiceIvaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceIva', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCodiceSistemazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceSistemazione', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCodiceSistemazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceSistemazione', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCodiceTrattamento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceTrattamento', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCodiceTrattamentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceTrattamento', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCodiceViaggio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceViaggio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByCodiceViaggioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceViaggio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByDataBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBolla', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByDataBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBolla', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByDataCompetenza() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCompetenza', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByDataCompetenzaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCompetenza', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByDataIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataIn', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByDataInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataIn', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByDataOut() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataOut', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByDataOutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataOut', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByDescrizioneRighePratiche() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneRighePratiche', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByDescrizioneRighePraticheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneRighePratiche', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByDescrizioneServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByDescrizioneServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByDescrizioneSpedireA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneSpedireA', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByDescrizioneSpedireADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneSpedireA', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByFornitore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fornitore', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByFornitoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fornitore', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByImportoIvaFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByImportoIvaFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByImportoIvaServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByImportoIvaServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByImportoIvaTasse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaTasse', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByImportoIvaTasseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaTasse', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByImportoServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByImportoServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByItinerario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itinerario', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByItinerarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itinerario', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByLocalitaArrivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localitaArrivo', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByLocalitaArrivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localitaArrivo', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByLocalitaPartenza() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localitaPartenza', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByLocalitaPartenzaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localitaPartenza', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByMerchantFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByMerchantFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByMetPagamentoFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metPagamentoFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByMetPagamentoFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metPagamentoFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByMetPagamentoServ() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metPagamentoServ', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByMetPagamentoServDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metPagamentoServ', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNomePasseggero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomePasseggero', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNomePasseggeroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomePasseggero', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByNrBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrBolla', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByNrBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrBolla', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNrEstrattoConto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrEstrattoConto', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNrEstrattoContoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrEstrattoConto', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByNrNotti() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrNotti', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByNrNottiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrNotti', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByNrPax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrPax', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByNrPaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrPax', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByNrTktBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrTktBolla', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNrTktBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrTktBolla', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByNumeroCCFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCCFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNumeroCCFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCCFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNumeroCCServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCCServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNumeroCCServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCCServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNumeroDocumFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroDocumFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNumeroDocumFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroDocumFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNumeroDocumServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroDocumServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNumeroDocumServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroDocumServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByRagioneSociale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ragioneSociale', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByRagioneSocialeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ragioneSociale', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByRichiedente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'richiedente', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByRichiedenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'richiedente', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByRigaCrm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rigaCrm', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByRigaCrmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rigaCrm', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortBySapNoSap() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sapNoSap', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortBySapNoSapDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sapNoSap', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortBySegueFatturaServizi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segueFatturaServizi', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortBySegueFatturaServiziDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segueFatturaServizi', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByServizioDaPagare() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servizioDaPagare', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByServizioDaPagareDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servizioDaPagare', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByTasse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasse', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByTasseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasse', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTipoServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTipoServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTipoTransazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoTransazione', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTipoTransazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoTransazione', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByTotaleFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTotaleFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTotaleServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTotaleServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTotaleServizioGenerale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleServizioGenerale', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTotaleServizioGeneraleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleServizioGenerale', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> sortByTotaleTasse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleTasse', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  sortByTotaleTasseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleTasse', Sort.desc);
    });
  }
}

extension EstrattoContoQuerySortThenBy
    on QueryBuilder<EstrattoConto, EstrattoConto, QSortThenBy> {
  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bolla', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bolla', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico10() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico10', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico10Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico10', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico4() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico4', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico4Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico4', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico7() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico7', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico7Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico7', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico8() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico8', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico8Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico8', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico9() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico9', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCampoStatistico9Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'campoStatistico9', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByCentroCosto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centroCosto', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCentroCostoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'centroCosto', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCodiceCliente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceCliente', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCodiceClienteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceCliente', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByCodiceIva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceIva', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCodiceIvaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceIva', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCodiceSistemazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceSistemazione', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCodiceSistemazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceSistemazione', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCodiceTrattamento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceTrattamento', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCodiceTrattamentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceTrattamento', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCodiceViaggio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceViaggio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByCodiceViaggioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceViaggio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByDataBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBolla', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByDataBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataBolla', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByDataCompetenza() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCompetenza', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByDataCompetenzaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataCompetenza', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByDataIn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataIn', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByDataInDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataIn', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByDataOut() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataOut', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByDataOutDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataOut', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByDescrizioneRighePratiche() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneRighePratiche', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByDescrizioneRighePraticheDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneRighePratiche', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByDescrizioneServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByDescrizioneServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByDescrizioneSpedireA() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneSpedireA', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByDescrizioneSpedireADesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneSpedireA', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByFornitore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fornitore', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByFornitoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fornitore', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByImportoIvaFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByImportoIvaFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByImportoIvaServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByImportoIvaServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByImportoIvaTasse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaTasse', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByImportoIvaTasseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoIvaTasse', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByImportoServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByImportoServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importoServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByItinerario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itinerario', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByItinerarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itinerario', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByLocalitaArrivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localitaArrivo', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByLocalitaArrivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localitaArrivo', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByLocalitaPartenza() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localitaPartenza', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByLocalitaPartenzaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localitaPartenza', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByMerchantFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByMerchantFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'merchantFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByMetPagamentoFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metPagamentoFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByMetPagamentoFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metPagamentoFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByMetPagamentoServ() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metPagamentoServ', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByMetPagamentoServDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metPagamentoServ', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNomePasseggero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomePasseggero', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNomePasseggeroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomePasseggero', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByNrBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrBolla', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByNrBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrBolla', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNrEstrattoConto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrEstrattoConto', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNrEstrattoContoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrEstrattoConto', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByNrNotti() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrNotti', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByNrNottiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrNotti', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByNrPax() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrPax', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByNrPaxDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrPax', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByNrTktBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrTktBolla', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNrTktBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nrTktBolla', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByNumeroCCFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCCFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNumeroCCFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCCFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNumeroCCServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCCServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNumeroCCServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroCCServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNumeroDocumFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroDocumFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNumeroDocumFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroDocumFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNumeroDocumServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroDocumServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNumeroDocumServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroDocumServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByRagioneSociale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ragioneSociale', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByRagioneSocialeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ragioneSociale', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByRichiedente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'richiedente', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByRichiedenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'richiedente', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByRigaCrm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rigaCrm', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByRigaCrmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rigaCrm', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenBySapNoSap() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sapNoSap', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenBySapNoSapDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sapNoSap', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenBySegueFatturaServizi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segueFatturaServizi', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenBySegueFatturaServiziDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'segueFatturaServizi', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByServizioDaPagare() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servizioDaPagare', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByServizioDaPagareDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'servizioDaPagare', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByTasse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasse', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByTasseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasse', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTipoServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTipoServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTipoTransazione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoTransazione', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTipoTransazioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoTransazione', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByTotaleFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleFee', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTotaleFeeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleFee', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTotaleServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleServizio', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTotaleServizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleServizio', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTotaleServizioGenerale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleServizioGenerale', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTotaleServizioGeneraleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleServizioGenerale', Sort.desc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy> thenByTotaleTasse() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleTasse', Sort.asc);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QAfterSortBy>
  thenByTotaleTasseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totaleTasse', Sort.desc);
    });
  }
}

extension EstrattoContoQueryWhereDistinct
    on QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> {
  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByBolla({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bolla', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByCampoStatistico10({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'campoStatistico10',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByCampoStatistico4({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'campoStatistico4',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByCampoStatistico7({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'campoStatistico7',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByCampoStatistico8({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'campoStatistico8',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByCampoStatistico9({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'campoStatistico9',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByCentroCosto({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'centroCosto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByCid({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByCodiceCliente({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'codiceCliente',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByCodiceIva({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codiceIva', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByCodiceSistemazione({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'codiceSistemazione',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByCodiceTrattamento({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'codiceTrattamento',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByCodiceViaggio({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'codiceViaggio',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByDataBolla({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataBolla', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByDataCompetenza({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'dataCompetenza',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByDataIn({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataIn', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByDataOut({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataOut', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByDescrizioneRighePratiche({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'descrizioneRighePratiche',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByDescrizioneServizio({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'descrizioneServizio',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByDescrizioneSpedireA({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'descrizioneSpedireA',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fee');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByFornitore({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fornitore', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByImportoIvaFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importoIvaFee');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByImportoIvaServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importoIvaServizio');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByImportoIvaTasse() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importoIvaTasse');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByImportoServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importoServizio');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByItinerario({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itinerario', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByLocalitaArrivo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'localitaArrivo',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByLocalitaPartenza({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'localitaPartenza',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByMerchantFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'merchantFee');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByMetPagamentoFee({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'metPagamentoFee',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByMetPagamentoServ({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'metPagamentoServ',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByNomePasseggero({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'nomePasseggero',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByNrBolla({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nrBolla', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByNrEstrattoConto({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'nrEstrattoConto',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByNrNotti({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nrNotti', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByNrPax({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nrPax', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByNrTktBolla({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nrTktBolla', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByNumeroCCFee({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numeroCCFee', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByNumeroCCServizio({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'numeroCCServizio',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByNumeroDocumFee({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'numeroDocumFee',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByNumeroDocumServizio({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'numeroDocumServizio',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByNumeroTrasferta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'numeroTrasferta',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByRagioneSociale({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'ragioneSociale',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByRichiedente({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'richiedente', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByRigaCrm({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rigaCrm', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctBySapNoSap({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sapNoSap', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctBySegueFatturaServizi({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'segueFatturaServizi',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByServizioDaPagare({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'servizioDaPagare',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByTasse() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasse');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByTipoServizio({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoServizio', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByTipoTransazione({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'tipoTransazione',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct> distinctByTotaleFee() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totaleFee');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByTotaleServizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totaleServizio');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByTotaleServizioGenerale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totaleServizioGenerale');
    });
  }

  QueryBuilder<EstrattoConto, EstrattoConto, QDistinct>
  distinctByTotaleTasse() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totaleTasse');
    });
  }
}

extension EstrattoContoQueryProperty
    on QueryBuilder<EstrattoConto, EstrattoConto, QQueryProperty> {
  QueryBuilder<EstrattoConto, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> bollaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bolla');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  campoStatistico10Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campoStatistico10');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  campoStatistico4Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campoStatistico4');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  campoStatistico7Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campoStatistico7');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  campoStatistico8Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campoStatistico8');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  campoStatistico9Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'campoStatistico9');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> centroCostoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'centroCosto');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  codiceClienteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codiceCliente');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> codiceIvaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codiceIva');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  codiceSistemazioneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codiceSistemazione');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  codiceTrattamentoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codiceTrattamento');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  codiceViaggioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codiceViaggio');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> dataBollaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataBolla');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  dataCompetenzaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataCompetenza');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> dataInProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataIn');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> dataOutProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataOut');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  descrizioneRighePraticheProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descrizioneRighePratiche');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  descrizioneServizioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descrizioneServizio');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  descrizioneSpedireAProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descrizioneSpedireA');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations> feeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fee');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> fornitoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fornitore');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations>
  importoIvaFeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importoIvaFee');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations>
  importoIvaServizioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importoIvaServizio');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations>
  importoIvaTasseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importoIvaTasse');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations>
  importoServizioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importoServizio');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> itinerarioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itinerario');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  localitaArrivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localitaArrivo');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  localitaPartenzaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localitaPartenza');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations> merchantFeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'merchantFee');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  metPagamentoFeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metPagamentoFee');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  metPagamentoServProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metPagamentoServ');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  nomePasseggeroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nomePasseggero');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> nrBollaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nrBolla');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  nrEstrattoContoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nrEstrattoConto');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> nrNottiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nrNotti');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> nrPaxProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nrPax');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> nrTktBollaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nrTktBolla');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> numeroCCFeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroCCFee');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  numeroCCServizioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroCCServizio');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  numeroDocumFeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroDocumFee');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  numeroDocumServizioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroDocumServizio');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  numeroTrasfertaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroTrasferta');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  ragioneSocialeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ragioneSociale');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> richiedenteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'richiedente');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> rigaCrmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rigaCrm');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> sapNoSapProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sapNoSap');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  segueFatturaServiziProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'segueFatturaServizi');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  servizioDaPagareProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'servizioDaPagare');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations> tasseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasse');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations> tipoServizioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoServizio');
    });
  }

  QueryBuilder<EstrattoConto, String, QQueryOperations>
  tipoTransazioneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoTransazione');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations> totaleFeeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totaleFee');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations>
  totaleServizioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totaleServizio');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations>
  totaleServizioGeneraleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totaleServizioGenerale');
    });
  }

  QueryBuilder<EstrattoConto, double, QQueryOperations> totaleTasseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totaleTasse');
    });
  }
}
