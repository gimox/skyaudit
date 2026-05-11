// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracciato_sap.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTracciatoSapCollection on Isar {
  IsarCollection<TracciatoSap> get tracciatoSaps => this.collection();
}

const TracciatoSapSchema = CollectionSchema(
  name: r'TracciatoSap',
  id: -6296813604166429681,
  properties: {
    r'calc': PropertySchema(
      id: 0,
      name: r'calc',
      type: IsarType.string,
    ),
    r'cdRichiesta': PropertySchema(
      id: 1,
      name: r'cdRichiesta',
      type: IsarType.string,
    ),
    r'cid': PropertySchema(
      id: 2,
      name: r'cid',
      type: IsarType.string,
    ),
    r'classeRetributiva': PropertySchema(
      id: 3,
      name: r'classeRetributiva',
      type: IsarType.string,
    ),
    r'codiceStato': PropertySchema(
      id: 4,
      name: r'codiceStato',
      type: IsarType.string,
    ),
    r'codiceTrasferimentoFi': PropertySchema(
      id: 5,
      name: r'codiceTrasferimentoFi',
      type: IsarType.string,
    ),
    r'colonnaT': PropertySchema(
      id: 6,
      name: r'colonnaT',
      type: IsarType.string,
    ),
    r'data': PropertySchema(
      id: 7,
      name: r'data',
      type: IsarType.string,
    ),
    r'fi': PropertySchema(
      id: 8,
      name: r'fi',
      type: IsarType.string,
    ),
    r'importo': PropertySchema(
      id: 9,
      name: r'importo',
      type: IsarType.double,
    ),
    r'logHistoryId': PropertySchema(
      id: 10,
      name: r'logHistoryId',
      type: IsarType.string,
    ),
    r'nomeDipendente': PropertySchema(
      id: 11,
      name: r'nomeDipendente',
      type: IsarType.string,
    ),
    r'numeroTrasferta': PropertySchema(
      id: 12,
      name: r'numeroTrasferta',
      type: IsarType.string,
    ),
    r'progressivoGiustificativo': PropertySchema(
      id: 13,
      name: r'progressivoGiustificativo',
      type: IsarType.string,
    ),
    r'riTr': PropertySchema(
      id: 14,
      name: r'riTr',
      type: IsarType.string,
    ),
    r'societaCodice': PropertySchema(
      id: 15,
      name: r'societaCodice',
      type: IsarType.string,
    ),
    r'societaDescrizione': PropertySchema(
      id: 16,
      name: r'societaDescrizione',
      type: IsarType.string,
    ),
    r'tipoDipendente': PropertySchema(
      id: 17,
      name: r'tipoDipendente',
      type: IsarType.string,
    ),
    r'tipoSpesaCodice': PropertySchema(
      id: 18,
      name: r'tipoSpesaCodice',
      type: IsarType.string,
    ),
    r'tipoSpesaDescrizione': PropertySchema(
      id: 19,
      name: r'tipoSpesaDescrizione',
      type: IsarType.string,
    ),
    r'valuta': PropertySchema(
      id: 20,
      name: r'valuta',
      type: IsarType.string,
    )
  },
  estimateSize: _tracciatoSapEstimateSize,
  serialize: _tracciatoSapSerialize,
  deserialize: _tracciatoSapDeserialize,
  deserializeProp: _tracciatoSapDeserializeProp,
  idName: r'id',
  indexes: {
    r'cid': IndexSchema(
      id: 2203098626925536187,
      name: r'cid',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'cid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'numeroTrasferta': IndexSchema(
      id: 388667339200907265,
      name: r'numeroTrasferta',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'numeroTrasferta',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _tracciatoSapGetId,
  getLinks: _tracciatoSapGetLinks,
  attach: _tracciatoSapAttach,
  version: '3.1.0+1',
);

int _tracciatoSapEstimateSize(
  TracciatoSap object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.calc;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cdRichiesta;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.classeRetributiva.length * 3;
  {
    final value = object.codiceStato;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.codiceTrasferimentoFi;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.colonnaT;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.data.length * 3;
  {
    final value = object.fi;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.logHistoryId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nomeDipendente.length * 3;
  bytesCount += 3 + object.numeroTrasferta.length * 3;
  {
    final value = object.progressivoGiustificativo;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.riTr;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.societaCodice.length * 3;
  bytesCount += 3 + object.societaDescrizione.length * 3;
  bytesCount += 3 + object.tipoDipendente.length * 3;
  bytesCount += 3 + object.tipoSpesaCodice.length * 3;
  bytesCount += 3 + object.tipoSpesaDescrizione.length * 3;
  bytesCount += 3 + object.valuta.length * 3;
  return bytesCount;
}

void _tracciatoSapSerialize(
  TracciatoSap object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.calc);
  writer.writeString(offsets[1], object.cdRichiesta);
  writer.writeString(offsets[2], object.cid);
  writer.writeString(offsets[3], object.classeRetributiva);
  writer.writeString(offsets[4], object.codiceStato);
  writer.writeString(offsets[5], object.codiceTrasferimentoFi);
  writer.writeString(offsets[6], object.colonnaT);
  writer.writeString(offsets[7], object.data);
  writer.writeString(offsets[8], object.fi);
  writer.writeDouble(offsets[9], object.importo);
  writer.writeString(offsets[10], object.logHistoryId);
  writer.writeString(offsets[11], object.nomeDipendente);
  writer.writeString(offsets[12], object.numeroTrasferta);
  writer.writeString(offsets[13], object.progressivoGiustificativo);
  writer.writeString(offsets[14], object.riTr);
  writer.writeString(offsets[15], object.societaCodice);
  writer.writeString(offsets[16], object.societaDescrizione);
  writer.writeString(offsets[17], object.tipoDipendente);
  writer.writeString(offsets[18], object.tipoSpesaCodice);
  writer.writeString(offsets[19], object.tipoSpesaDescrizione);
  writer.writeString(offsets[20], object.valuta);
}

TracciatoSap _tracciatoSapDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TracciatoSap(
    calc: reader.readStringOrNull(offsets[0]),
    cdRichiesta: reader.readStringOrNull(offsets[1]),
    cid: reader.readString(offsets[2]),
    classeRetributiva: reader.readString(offsets[3]),
    codiceStato: reader.readStringOrNull(offsets[4]),
    codiceTrasferimentoFi: reader.readStringOrNull(offsets[5]),
    colonnaT: reader.readStringOrNull(offsets[6]),
    data: reader.readString(offsets[7]),
    fi: reader.readStringOrNull(offsets[8]),
    importo: reader.readDouble(offsets[9]),
    logHistoryId: reader.readStringOrNull(offsets[10]),
    nomeDipendente: reader.readString(offsets[11]),
    numeroTrasferta: reader.readString(offsets[12]),
    progressivoGiustificativo: reader.readStringOrNull(offsets[13]),
    riTr: reader.readStringOrNull(offsets[14]),
    societaCodice: reader.readString(offsets[15]),
    societaDescrizione: reader.readString(offsets[16]),
    tipoDipendente: reader.readString(offsets[17]),
    tipoSpesaCodice: reader.readString(offsets[18]),
    tipoSpesaDescrizione: reader.readString(offsets[19]),
    valuta: reader.readString(offsets[20]),
  );
  object.id = id;
  return object;
}

P _tracciatoSapDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
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
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tracciatoSapGetId(TracciatoSap object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tracciatoSapGetLinks(TracciatoSap object) {
  return [];
}

void _tracciatoSapAttach(
    IsarCollection<dynamic> col, Id id, TracciatoSap object) {
  object.id = id;
}

extension TracciatoSapQueryWhereSort
    on QueryBuilder<TracciatoSap, TracciatoSap, QWhere> {
  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TracciatoSapQueryWhere
    on QueryBuilder<TracciatoSap, TracciatoSap, QWhereClause> {
  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhereClause> cidEqualTo(
      String cid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cid',
        value: [cid],
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhereClause> cidNotEqualTo(
      String cid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cid',
              lower: [],
              upper: [cid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cid',
              lower: [cid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cid',
              lower: [cid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'cid',
              lower: [],
              upper: [cid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhereClause>
      numeroTrasfertaEqualTo(String numeroTrasferta) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'numeroTrasferta',
        value: [numeroTrasferta],
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterWhereClause>
      numeroTrasfertaNotEqualTo(String numeroTrasferta) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'numeroTrasferta',
              lower: [],
              upper: [numeroTrasferta],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'numeroTrasferta',
              lower: [numeroTrasferta],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'numeroTrasferta',
              lower: [numeroTrasferta],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'numeroTrasferta',
              lower: [],
              upper: [numeroTrasferta],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TracciatoSapQueryFilter
    on QueryBuilder<TracciatoSap, TracciatoSap, QFilterCondition> {
  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> calcIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'calc',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      calcIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'calc',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> calcEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      calcGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> calcLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> calcBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      calcStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'calc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> calcEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'calc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> calcContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'calc',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> calcMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'calc',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      calcIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calc',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      calcIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'calc',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cdRichiesta',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cdRichiesta',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cdRichiesta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cdRichiesta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cdRichiesta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cdRichiesta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cdRichiesta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cdRichiesta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cdRichiesta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cdRichiesta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cdRichiesta',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cdRichiestaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cdRichiesta',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> cidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> cidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> cidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> cidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> cidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> cidContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> cidMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classeRetributiva',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'classeRetributiva',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'classeRetributiva',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'classeRetributiva',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'classeRetributiva',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'classeRetributiva',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'classeRetributiva',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'classeRetributiva',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'classeRetributiva',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      classeRetributivaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'classeRetributiva',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'codiceStato',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'codiceStato',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codiceStato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codiceStato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codiceStato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codiceStato',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codiceStato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codiceStato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codiceStato',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codiceStato',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codiceStato',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceStatoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codiceStato',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'codiceTrasferimentoFi',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'codiceTrasferimentoFi',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codiceTrasferimentoFi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codiceTrasferimentoFi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codiceTrasferimentoFi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codiceTrasferimentoFi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codiceTrasferimentoFi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codiceTrasferimentoFi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codiceTrasferimentoFi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codiceTrasferimentoFi',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codiceTrasferimentoFi',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      codiceTrasferimentoFiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codiceTrasferimentoFi',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'colonnaT',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'colonnaT',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colonnaT',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'colonnaT',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'colonnaT',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'colonnaT',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'colonnaT',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'colonnaT',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'colonnaT',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'colonnaT',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'colonnaT',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      colonnaTIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'colonnaT',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> dataEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      dataGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> dataLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> dataBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'data',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      dataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> dataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> dataContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'data',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> dataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'data',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      dataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      dataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'data',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fi',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      fiIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fi',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fi',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fi',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fi',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> fiIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fi',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      fiIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fi',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      importoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'importo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      importoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'importo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      importoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'importo',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      importoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'importo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'logHistoryId',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'logHistoryId',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logHistoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'logHistoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'logHistoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'logHistoryId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'logHistoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'logHistoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logHistoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logHistoryId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logHistoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      logHistoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logHistoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nomeDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nomeDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nomeDipendente',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nomeDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nomeDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nomeDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nomeDipendente',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nomeDipendente',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      nomeDipendenteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nomeDipendente',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numeroTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numeroTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numeroTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numeroTrasferta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'numeroTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'numeroTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'numeroTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'numeroTrasferta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numeroTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      numeroTrasfertaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'numeroTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'progressivoGiustificativo',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'progressivoGiustificativo',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progressivoGiustificativo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progressivoGiustificativo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progressivoGiustificativo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progressivoGiustificativo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'progressivoGiustificativo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'progressivoGiustificativo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'progressivoGiustificativo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'progressivoGiustificativo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progressivoGiustificativo',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      progressivoGiustificativoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'progressivoGiustificativo',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> riTrIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'riTr',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      riTrIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'riTr',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> riTrEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'riTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      riTrGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'riTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> riTrLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'riTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> riTrBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'riTr',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      riTrStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'riTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> riTrEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'riTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> riTrContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'riTr',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> riTrMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'riTr',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      riTrIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'riTr',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      riTrIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'riTr',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'societaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'societaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'societaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'societaCodice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'societaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'societaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'societaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'societaCodice',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'societaCodice',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaCodiceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'societaCodice',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'societaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'societaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'societaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'societaDescrizione',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'societaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'societaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'societaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'societaDescrizione',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'societaDescrizione',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      societaDescrizioneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'societaDescrizione',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoDipendente',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoDipendente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoDipendente',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoDipendente',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoDipendenteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoDipendente',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoSpesaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoSpesaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoSpesaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoSpesaCodice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoSpesaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoSpesaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoSpesaCodice',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoSpesaCodice',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoSpesaCodice',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaCodiceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoSpesaCodice',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoSpesaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoSpesaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoSpesaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoSpesaDescrizione',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoSpesaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoSpesaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoSpesaDescrizione',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoSpesaDescrizione',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoSpesaDescrizione',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      tipoSpesaDescrizioneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoSpesaDescrizione',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> valutaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'valuta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      valutaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'valuta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      valutaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'valuta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> valutaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'valuta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      valutaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'valuta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      valutaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'valuta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      valutaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'valuta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition> valutaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'valuta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      valutaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'valuta',
        value: '',
      ));
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterFilterCondition>
      valutaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'valuta',
        value: '',
      ));
    });
  }
}

extension TracciatoSapQueryObject
    on QueryBuilder<TracciatoSap, TracciatoSap, QFilterCondition> {}

extension TracciatoSapQueryLinks
    on QueryBuilder<TracciatoSap, TracciatoSap, QFilterCondition> {}

extension TracciatoSapQuerySortBy
    on QueryBuilder<TracciatoSap, TracciatoSap, QSortBy> {
  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByCalc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calc', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByCalcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calc', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByCdRichiesta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cdRichiesta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByCdRichiestaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cdRichiesta', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByClasseRetributiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classeRetributiva', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByClasseRetributivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classeRetributiva', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByCodiceStato() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceStato', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByCodiceStatoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceStato', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByCodiceTrasferimentoFi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceTrasferimentoFi', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByCodiceTrasferimentoFiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceTrasferimentoFi', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByColonnaT() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colonnaT', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByColonnaTDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colonnaT', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByFi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fi', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByFiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fi', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByImporto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByImportoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByLogHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByLogHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByNomeDipendente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeDipendente', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByNomeDipendenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeDipendente', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByProgressivoGiustificativo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressivoGiustificativo', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByProgressivoGiustificativoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressivoGiustificativo', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByRiTr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riTr', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByRiTrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riTr', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortBySocietaCodice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societaCodice', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortBySocietaCodiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societaCodice', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortBySocietaDescrizione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societaDescrizione', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortBySocietaDescrizioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societaDescrizione', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByTipoDipendente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDipendente', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByTipoDipendenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDipendente', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByTipoSpesaCodice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoSpesaCodice', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByTipoSpesaCodiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoSpesaCodice', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByTipoSpesaDescrizione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoSpesaDescrizione', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      sortByTipoSpesaDescrizioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoSpesaDescrizione', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByValuta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valuta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> sortByValutaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valuta', Sort.desc);
    });
  }
}

extension TracciatoSapQuerySortThenBy
    on QueryBuilder<TracciatoSap, TracciatoSap, QSortThenBy> {
  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByCalc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calc', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByCalcDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calc', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByCdRichiesta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cdRichiesta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByCdRichiestaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cdRichiesta', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByClasseRetributiva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classeRetributiva', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByClasseRetributivaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'classeRetributiva', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByCodiceStato() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceStato', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByCodiceStatoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceStato', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByCodiceTrasferimentoFi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceTrasferimentoFi', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByCodiceTrasferimentoFiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codiceTrasferimentoFi', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByColonnaT() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colonnaT', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByColonnaTDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'colonnaT', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'data', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByFi() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fi', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByFiDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fi', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByImporto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByImportoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByLogHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByLogHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByNomeDipendente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeDipendente', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByNomeDipendenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nomeDipendente', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByProgressivoGiustificativo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressivoGiustificativo', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByProgressivoGiustificativoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressivoGiustificativo', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByRiTr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riTr', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByRiTrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'riTr', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenBySocietaCodice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societaCodice', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenBySocietaCodiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societaCodice', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenBySocietaDescrizione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societaDescrizione', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenBySocietaDescrizioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societaDescrizione', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByTipoDipendente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDipendente', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByTipoDipendenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDipendente', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByTipoSpesaCodice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoSpesaCodice', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByTipoSpesaCodiceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoSpesaCodice', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByTipoSpesaDescrizione() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoSpesaDescrizione', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy>
      thenByTipoSpesaDescrizioneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoSpesaDescrizione', Sort.desc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByValuta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valuta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QAfterSortBy> thenByValutaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valuta', Sort.desc);
    });
  }
}

extension TracciatoSapQueryWhereDistinct
    on QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> {
  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByCalc(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calc', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByCdRichiesta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cdRichiesta', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct>
      distinctByClasseRetributiva({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'classeRetributiva',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByCodiceStato(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codiceStato', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct>
      distinctByCodiceTrasferimentoFi({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codiceTrasferimentoFi',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByColonnaT(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'colonnaT', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'data', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByFi(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fi', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByImporto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importo');
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByLogHistoryId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logHistoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByNomeDipendente(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nomeDipendente',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByNumeroTrasferta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numeroTrasferta',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct>
      distinctByProgressivoGiustificativo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progressivoGiustificativo',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByRiTr(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'riTr', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctBySocietaCodice(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'societaCodice',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct>
      distinctBySocietaDescrizione({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'societaDescrizione',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByTipoDipendente(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoDipendente',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByTipoSpesaCodice(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoSpesaCodice',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct>
      distinctByTipoSpesaDescrizione({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoSpesaDescrizione',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoSap, TracciatoSap, QDistinct> distinctByValuta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valuta', caseSensitive: caseSensitive);
    });
  }
}

extension TracciatoSapQueryProperty
    on QueryBuilder<TracciatoSap, TracciatoSap, QQueryProperty> {
  QueryBuilder<TracciatoSap, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TracciatoSap, String?, QQueryOperations> calcProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calc');
    });
  }

  QueryBuilder<TracciatoSap, String?, QQueryOperations> cdRichiestaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cdRichiesta');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations> cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations>
      classeRetributivaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'classeRetributiva');
    });
  }

  QueryBuilder<TracciatoSap, String?, QQueryOperations> codiceStatoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codiceStato');
    });
  }

  QueryBuilder<TracciatoSap, String?, QQueryOperations>
      codiceTrasferimentoFiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codiceTrasferimentoFi');
    });
  }

  QueryBuilder<TracciatoSap, String?, QQueryOperations> colonnaTProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'colonnaT');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations> dataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'data');
    });
  }

  QueryBuilder<TracciatoSap, String?, QQueryOperations> fiProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fi');
    });
  }

  QueryBuilder<TracciatoSap, double, QQueryOperations> importoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importo');
    });
  }

  QueryBuilder<TracciatoSap, String?, QQueryOperations> logHistoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logHistoryId');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations>
      nomeDipendenteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nomeDipendente');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations>
      numeroTrasfertaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroTrasferta');
    });
  }

  QueryBuilder<TracciatoSap, String?, QQueryOperations>
      progressivoGiustificativoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progressivoGiustificativo');
    });
  }

  QueryBuilder<TracciatoSap, String?, QQueryOperations> riTrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'riTr');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations> societaCodiceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'societaCodice');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations>
      societaDescrizioneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'societaDescrizione');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations>
      tipoDipendenteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoDipendente');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations>
      tipoSpesaCodiceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoSpesaCodice');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations>
      tipoSpesaDescrizioneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoSpesaDescrizione');
    });
  }

  QueryBuilder<TracciatoSap, String, QQueryOperations> valutaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valuta');
    });
  }
}
