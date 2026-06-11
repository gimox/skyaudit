// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scarti_ec_sap.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScartiEcSapCollection on Isar {
  IsarCollection<ScartiEcSap> get scartiEcSaps => this.collection();
}

const ScartiEcSapSchema = CollectionSchema(
  name: r'ScartiEcSap',
  id: -295590952916692497,
  properties: {
    r'cid': PropertySchema(
      id: 0,
      name: r'cid',
      type: IsarType.string,
    ),
    r'dataInvio': PropertySchema(
      id: 1,
      name: r'dataInvio',
      type: IsarType.string,
    ),
    r'descrizioneScarto': PropertySchema(
      id: 2,
      name: r'descrizioneScarto',
      type: IsarType.string,
    ),
    r'divisa': PropertySchema(
      id: 3,
      name: r'divisa',
      type: IsarType.string,
    ),
    r'importo': PropertySchema(
      id: 4,
      name: r'importo',
      type: IsarType.double,
    ),
    r'isMatched': PropertySchema(
      id: 5,
      name: r'isMatched',
      type: IsarType.bool,
    ),
    r'logHistoryId': PropertySchema(
      id: 6,
      name: r'logHistoryId',
      type: IsarType.string,
    ),
    r'note': PropertySchema(
      id: 7,
      name: r'note',
      type: IsarType.string,
    ),
    r'numeroTrasferta': PropertySchema(
      id: 8,
      name: r'numeroTrasferta',
      type: IsarType.string,
    ),
    r'spesa': PropertySchema(
      id: 9,
      name: r'spesa',
      type: IsarType.string,
    ),
    r'storno': PropertySchema(
      id: 10,
      name: r'storno',
      type: IsarType.string,
    )
  },
  estimateSize: _scartiEcSapEstimateSize,
  serialize: _scartiEcSapSerialize,
  deserialize: _scartiEcSapDeserialize,
  deserializeProp: _scartiEcSapDeserializeProp,
  idName: r'id',
  indexes: {
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
    ),
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
    r'isMatched': IndexSchema(
      id: -6584544857258267416,
      name: r'isMatched',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isMatched',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _scartiEcSapGetId,
  getLinks: _scartiEcSapGetLinks,
  attach: _scartiEcSapAttach,
  version: '3.1.0+1',
);

int _scartiEcSapEstimateSize(
  ScartiEcSap object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.dataInvio.length * 3;
  bytesCount += 3 + object.descrizioneScarto.length * 3;
  bytesCount += 3 + object.divisa.length * 3;
  {
    final value = object.logHistoryId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.note;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.numeroTrasferta.length * 3;
  bytesCount += 3 + object.spesa.length * 3;
  {
    final value = object.storno;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _scartiEcSapSerialize(
  ScartiEcSap object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cid);
  writer.writeString(offsets[1], object.dataInvio);
  writer.writeString(offsets[2], object.descrizioneScarto);
  writer.writeString(offsets[3], object.divisa);
  writer.writeDouble(offsets[4], object.importo);
  writer.writeBool(offsets[5], object.isMatched);
  writer.writeString(offsets[6], object.logHistoryId);
  writer.writeString(offsets[7], object.note);
  writer.writeString(offsets[8], object.numeroTrasferta);
  writer.writeString(offsets[9], object.spesa);
  writer.writeString(offsets[10], object.storno);
}

ScartiEcSap _scartiEcSapDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScartiEcSap(
    cid: reader.readString(offsets[0]),
    dataInvio: reader.readString(offsets[1]),
    descrizioneScarto: reader.readString(offsets[2]),
    divisa: reader.readString(offsets[3]),
    importo: reader.readDouble(offsets[4]),
    isMatched: reader.readBoolOrNull(offsets[5]) ?? false,
    logHistoryId: reader.readStringOrNull(offsets[6]),
    note: reader.readStringOrNull(offsets[7]),
    numeroTrasferta: reader.readString(offsets[8]),
    spesa: reader.readString(offsets[9]),
    storno: reader.readStringOrNull(offsets[10]),
  );
  object.id = id;
  return object;
}

P _scartiEcSapDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _scartiEcSapGetId(ScartiEcSap object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scartiEcSapGetLinks(ScartiEcSap object) {
  return [];
}

void _scartiEcSapAttach(
    IsarCollection<dynamic> col, Id id, ScartiEcSap object) {
  object.id = id;
}

extension ScartiEcSapQueryWhereSort
    on QueryBuilder<ScartiEcSap, ScartiEcSap, QWhere> {
  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhere> anyIsMatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isMatched'),
      );
    });
  }
}

extension ScartiEcSapQueryWhere
    on QueryBuilder<ScartiEcSap, ScartiEcSap, QWhereClause> {
  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause> idBetween(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause>
      numeroTrasfertaEqualTo(String numeroTrasferta) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'numeroTrasferta',
        value: [numeroTrasferta],
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause> cidEqualTo(
      String cid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cid',
        value: [cid],
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause> cidNotEqualTo(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause> isMatchedEqualTo(
      bool isMatched) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isMatched',
        value: [isMatched],
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterWhereClause> isMatchedNotEqualTo(
      bool isMatched) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isMatched',
              lower: [],
              upper: [isMatched],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isMatched',
              lower: [isMatched],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isMatched',
              lower: [isMatched],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isMatched',
              lower: [],
              upper: [isMatched],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ScartiEcSapQueryFilter
    on QueryBuilder<ScartiEcSap, ScartiEcSap, QFilterCondition> {
  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> cidEqualTo(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> cidGreaterThan(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> cidLessThan(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> cidBetween(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> cidStartsWith(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> cidEndsWith(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> cidContains(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> cidMatches(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataInvio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataInvio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataInvio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataInvio',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dataInvio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dataInvio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataInvio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataInvio',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataInvio',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      dataInvioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataInvio',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descrizioneScarto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descrizioneScarto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descrizioneScarto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descrizioneScarto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'descrizioneScarto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'descrizioneScarto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'descrizioneScarto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'descrizioneScarto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descrizioneScarto',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      descrizioneScartoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'descrizioneScarto',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> divisaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'divisa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      divisaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'divisa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> divisaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'divisa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> divisaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'divisa',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      divisaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'divisa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> divisaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'divisa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> divisaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'divisa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> divisaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'divisa',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      divisaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'divisa',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      divisaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'divisa',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> importoEqualTo(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> importoLessThan(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> importoBetween(
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      isMatchedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMatched',
        value: value,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      logHistoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'logHistoryId',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      logHistoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'logHistoryId',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      logHistoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logHistoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      logHistoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logHistoryId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      logHistoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logHistoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      logHistoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logHistoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      noteIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'note',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'note',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'note',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'note',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> noteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      noteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'note',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
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

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      numeroTrasfertaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'numeroTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      numeroTrasfertaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'numeroTrasferta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      numeroTrasfertaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numeroTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      numeroTrasfertaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'numeroTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> spesaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spesa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      spesaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spesa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> spesaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spesa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> spesaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spesa',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> spesaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'spesa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> spesaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'spesa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> spesaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'spesa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> spesaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'spesa',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> spesaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spesa',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      spesaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'spesa',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> stornoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'storno',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      stornoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'storno',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> stornoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storno',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      stornoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'storno',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> stornoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'storno',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> stornoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'storno',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      stornoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'storno',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> stornoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'storno',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> stornoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'storno',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition> stornoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'storno',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      stornoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storno',
        value: '',
      ));
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterFilterCondition>
      stornoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storno',
        value: '',
      ));
    });
  }
}

extension ScartiEcSapQueryObject
    on QueryBuilder<ScartiEcSap, ScartiEcSap, QFilterCondition> {}

extension ScartiEcSapQueryLinks
    on QueryBuilder<ScartiEcSap, ScartiEcSap, QFilterCondition> {}

extension ScartiEcSapQuerySortBy
    on QueryBuilder<ScartiEcSap, ScartiEcSap, QSortBy> {
  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByDataInvio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInvio', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByDataInvioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInvio', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy>
      sortByDescrizioneScarto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneScarto', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy>
      sortByDescrizioneScartoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneScarto', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByDivisa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'divisa', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByDivisaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'divisa', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByImporto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByImportoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByIsMatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMatched', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByIsMatchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMatched', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByLogHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy>
      sortByLogHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy>
      sortByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortBySpesa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spesa', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortBySpesaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spesa', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByStorno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storno', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> sortByStornoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storno', Sort.desc);
    });
  }
}

extension ScartiEcSapQuerySortThenBy
    on QueryBuilder<ScartiEcSap, ScartiEcSap, QSortThenBy> {
  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByDataInvio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInvio', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByDataInvioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInvio', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy>
      thenByDescrizioneScarto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneScarto', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy>
      thenByDescrizioneScartoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descrizioneScarto', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByDivisa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'divisa', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByDivisaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'divisa', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByImporto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByImportoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByIsMatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMatched', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByIsMatchedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMatched', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByLogHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy>
      thenByLogHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByNote() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByNoteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'note', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy>
      thenByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenBySpesa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spesa', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenBySpesaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'spesa', Sort.desc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByStorno() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storno', Sort.asc);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QAfterSortBy> thenByStornoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'storno', Sort.desc);
    });
  }
}

extension ScartiEcSapQueryWhereDistinct
    on QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> {
  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByDataInvio(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataInvio', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByDescrizioneScarto(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descrizioneScarto',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByDivisa(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'divisa', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByImporto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importo');
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByIsMatched() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMatched');
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByLogHistoryId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logHistoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByNote(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'note', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByNumeroTrasferta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numeroTrasferta',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctBySpesa(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spesa', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScartiEcSap, ScartiEcSap, QDistinct> distinctByStorno(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storno', caseSensitive: caseSensitive);
    });
  }
}

extension ScartiEcSapQueryProperty
    on QueryBuilder<ScartiEcSap, ScartiEcSap, QQueryProperty> {
  QueryBuilder<ScartiEcSap, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScartiEcSap, String, QQueryOperations> cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<ScartiEcSap, String, QQueryOperations> dataInvioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataInvio');
    });
  }

  QueryBuilder<ScartiEcSap, String, QQueryOperations>
      descrizioneScartoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descrizioneScarto');
    });
  }

  QueryBuilder<ScartiEcSap, String, QQueryOperations> divisaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'divisa');
    });
  }

  QueryBuilder<ScartiEcSap, double, QQueryOperations> importoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importo');
    });
  }

  QueryBuilder<ScartiEcSap, bool, QQueryOperations> isMatchedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMatched');
    });
  }

  QueryBuilder<ScartiEcSap, String?, QQueryOperations> logHistoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logHistoryId');
    });
  }

  QueryBuilder<ScartiEcSap, String?, QQueryOperations> noteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'note');
    });
  }

  QueryBuilder<ScartiEcSap, String, QQueryOperations>
      numeroTrasfertaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroTrasferta');
    });
  }

  QueryBuilder<ScartiEcSap, String, QQueryOperations> spesaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spesa');
    });
  }

  QueryBuilder<ScartiEcSap, String?, QQueryOperations> stornoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storno');
    });
  }
}
