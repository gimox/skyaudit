// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trasferte_sap.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTrasferteSapCollection on Isar {
  IsarCollection<TrasferteSap> get trasferteSaps => this.collection();
}

const TrasferteSapSchema = CollectionSchema(
  name: r'TrasferteSap',
  id: -7163586124213164071,
  properties: {
    r'cid': PropertySchema(
      id: 0,
      name: r'cid',
      type: IsarType.string,
    ),
    r'dataFineTrasferta': PropertySchema(
      id: 1,
      name: r'dataFineTrasferta',
      type: IsarType.string,
    ),
    r'dataInizioTrasferta': PropertySchema(
      id: 2,
      name: r'dataInizioTrasferta',
      type: IsarType.string,
    ),
    r'logHistoryId': PropertySchema(
      id: 3,
      name: r'logHistoryId',
      type: IsarType.string,
    ),
    r'numeroTrasferta': PropertySchema(
      id: 4,
      name: r'numeroTrasferta',
      type: IsarType.string,
    ),
    r'oraFineTrasferta': PropertySchema(
      id: 5,
      name: r'oraFineTrasferta',
      type: IsarType.string,
    ),
    r'oraInizioTrasferta': PropertySchema(
      id: 6,
      name: r'oraInizioTrasferta',
      type: IsarType.string,
    )
  },
  estimateSize: _trasferteSapEstimateSize,
  serialize: _trasferteSapSerialize,
  deserialize: _trasferteSapDeserialize,
  deserializeProp: _trasferteSapDeserializeProp,
  idName: r'id',
  indexes: {
    r'numeroTrasferta': IndexSchema(
      id: 388667339200907265,
      name: r'numeroTrasferta',
      unique: true,
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
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _trasferteSapGetId,
  getLinks: _trasferteSapGetLinks,
  attach: _trasferteSapAttach,
  version: '3.1.0+1',
);

int _trasferteSapEstimateSize(
  TrasferteSap object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.dataFineTrasferta.length * 3;
  bytesCount += 3 + object.dataInizioTrasferta.length * 3;
  {
    final value = object.logHistoryId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.numeroTrasferta.length * 3;
  bytesCount += 3 + object.oraFineTrasferta.length * 3;
  bytesCount += 3 + object.oraInizioTrasferta.length * 3;
  return bytesCount;
}

void _trasferteSapSerialize(
  TrasferteSap object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cid);
  writer.writeString(offsets[1], object.dataFineTrasferta);
  writer.writeString(offsets[2], object.dataInizioTrasferta);
  writer.writeString(offsets[3], object.logHistoryId);
  writer.writeString(offsets[4], object.numeroTrasferta);
  writer.writeString(offsets[5], object.oraFineTrasferta);
  writer.writeString(offsets[6], object.oraInizioTrasferta);
}

TrasferteSap _trasferteSapDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TrasferteSap(
    cid: reader.readString(offsets[0]),
    dataFineTrasferta: reader.readString(offsets[1]),
    dataInizioTrasferta: reader.readString(offsets[2]),
    logHistoryId: reader.readStringOrNull(offsets[3]),
    numeroTrasferta: reader.readString(offsets[4]),
    oraFineTrasferta: reader.readString(offsets[5]),
    oraInizioTrasferta: reader.readString(offsets[6]),
  );
  object.id = id;
  return object;
}

P _trasferteSapDeserializeProp<P>(
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
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _trasferteSapGetId(TrasferteSap object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _trasferteSapGetLinks(TrasferteSap object) {
  return [];
}

void _trasferteSapAttach(
    IsarCollection<dynamic> col, Id id, TrasferteSap object) {
  object.id = id;
}

extension TrasferteSapByIndex on IsarCollection<TrasferteSap> {
  Future<TrasferteSap?> getByNumeroTrasferta(String numeroTrasferta) {
    return getByIndex(r'numeroTrasferta', [numeroTrasferta]);
  }

  TrasferteSap? getByNumeroTrasfertaSync(String numeroTrasferta) {
    return getByIndexSync(r'numeroTrasferta', [numeroTrasferta]);
  }

  Future<bool> deleteByNumeroTrasferta(String numeroTrasferta) {
    return deleteByIndex(r'numeroTrasferta', [numeroTrasferta]);
  }

  bool deleteByNumeroTrasfertaSync(String numeroTrasferta) {
    return deleteByIndexSync(r'numeroTrasferta', [numeroTrasferta]);
  }

  Future<List<TrasferteSap?>> getAllByNumeroTrasferta(
      List<String> numeroTrasfertaValues) {
    final values = numeroTrasfertaValues.map((e) => [e]).toList();
    return getAllByIndex(r'numeroTrasferta', values);
  }

  List<TrasferteSap?> getAllByNumeroTrasfertaSync(
      List<String> numeroTrasfertaValues) {
    final values = numeroTrasfertaValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'numeroTrasferta', values);
  }

  Future<int> deleteAllByNumeroTrasferta(List<String> numeroTrasfertaValues) {
    final values = numeroTrasfertaValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'numeroTrasferta', values);
  }

  int deleteAllByNumeroTrasfertaSync(List<String> numeroTrasfertaValues) {
    final values = numeroTrasfertaValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'numeroTrasferta', values);
  }

  Future<Id> putByNumeroTrasferta(TrasferteSap object) {
    return putByIndex(r'numeroTrasferta', object);
  }

  Id putByNumeroTrasfertaSync(TrasferteSap object, {bool saveLinks = true}) {
    return putByIndexSync(r'numeroTrasferta', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNumeroTrasferta(List<TrasferteSap> objects) {
    return putAllByIndex(r'numeroTrasferta', objects);
  }

  List<Id> putAllByNumeroTrasfertaSync(List<TrasferteSap> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'numeroTrasferta', objects, saveLinks: saveLinks);
  }
}

extension TrasferteSapQueryWhereSort
    on QueryBuilder<TrasferteSap, TrasferteSap, QWhere> {
  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TrasferteSapQueryWhere
    on QueryBuilder<TrasferteSap, TrasferteSap, QWhereClause> {
  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhereClause> idBetween(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhereClause>
      numeroTrasfertaEqualTo(String numeroTrasferta) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'numeroTrasferta',
        value: [numeroTrasferta],
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhereClause>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhereClause> cidEqualTo(
      String cid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'cid',
        value: [cid],
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterWhereClause> cidNotEqualTo(
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
}

extension TrasferteSapQueryFilter
    on QueryBuilder<TrasferteSap, TrasferteSap, QFilterCondition> {
  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> cidEqualTo(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> cidLessThan(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> cidBetween(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> cidStartsWith(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> cidEndsWith(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> cidContains(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> cidMatches(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cid',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataFineTrasferta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dataFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dataFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataFineTrasferta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataFineTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataFineTrasfertaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataFineTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dataInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dataInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dataInizioTrasferta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dataInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dataInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dataInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dataInizioTrasferta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dataInizioTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      dataInizioTrasfertaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dataInizioTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition> idBetween(
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      logHistoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'logHistoryId',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      logHistoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'logHistoryId',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      logHistoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'logHistoryId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      logHistoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'logHistoryId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      logHistoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'logHistoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      logHistoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'logHistoryId',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
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

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      numeroTrasfertaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'numeroTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      numeroTrasfertaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'numeroTrasferta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      numeroTrasfertaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numeroTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      numeroTrasfertaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'numeroTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oraFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'oraFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'oraFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'oraFineTrasferta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'oraFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'oraFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'oraFineTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'oraFineTrasferta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oraFineTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraFineTrasfertaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'oraFineTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oraInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'oraInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'oraInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'oraInizioTrasferta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'oraInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'oraInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'oraInizioTrasferta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'oraInizioTrasferta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'oraInizioTrasferta',
        value: '',
      ));
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterFilterCondition>
      oraInizioTrasfertaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'oraInizioTrasferta',
        value: '',
      ));
    });
  }
}

extension TrasferteSapQueryObject
    on QueryBuilder<TrasferteSap, TrasferteSap, QFilterCondition> {}

extension TrasferteSapQueryLinks
    on QueryBuilder<TrasferteSap, TrasferteSap, QFilterCondition> {}

extension TrasferteSapQuerySortBy
    on QueryBuilder<TrasferteSap, TrasferteSap, QSortBy> {
  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy> sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy> sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByDataFineTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataFineTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByDataFineTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataFineTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByDataInizioTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInizioTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByDataInizioTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInizioTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy> sortByLogHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByLogHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByOraFineTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraFineTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByOraFineTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraFineTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByOraInizioTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraInizioTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      sortByOraInizioTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraInizioTrasferta', Sort.desc);
    });
  }
}

extension TrasferteSapQuerySortThenBy
    on QueryBuilder<TrasferteSap, TrasferteSap, QSortThenBy> {
  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy> thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy> thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByDataFineTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataFineTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByDataFineTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataFineTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByDataInizioTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInizioTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByDataInizioTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInizioTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy> thenByLogHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByLogHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByOraFineTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraFineTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByOraFineTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraFineTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByOraInizioTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraInizioTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QAfterSortBy>
      thenByOraInizioTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraInizioTrasferta', Sort.desc);
    });
  }
}

extension TrasferteSapQueryWhereDistinct
    on QueryBuilder<TrasferteSap, TrasferteSap, QDistinct> {
  QueryBuilder<TrasferteSap, TrasferteSap, QDistinct> distinctByCid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QDistinct>
      distinctByDataFineTrasferta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataFineTrasferta',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QDistinct>
      distinctByDataInizioTrasferta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataInizioTrasferta',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QDistinct> distinctByLogHistoryId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logHistoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QDistinct> distinctByNumeroTrasferta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numeroTrasferta',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QDistinct>
      distinctByOraFineTrasferta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oraFineTrasferta',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TrasferteSap, TrasferteSap, QDistinct>
      distinctByOraInizioTrasferta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oraInizioTrasferta',
          caseSensitive: caseSensitive);
    });
  }
}

extension TrasferteSapQueryProperty
    on QueryBuilder<TrasferteSap, TrasferteSap, QQueryProperty> {
  QueryBuilder<TrasferteSap, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TrasferteSap, String, QQueryOperations> cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<TrasferteSap, String, QQueryOperations>
      dataFineTrasfertaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataFineTrasferta');
    });
  }

  QueryBuilder<TrasferteSap, String, QQueryOperations>
      dataInizioTrasfertaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataInizioTrasferta');
    });
  }

  QueryBuilder<TrasferteSap, String?, QQueryOperations> logHistoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logHistoryId');
    });
  }

  QueryBuilder<TrasferteSap, String, QQueryOperations>
      numeroTrasfertaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroTrasferta');
    });
  }

  QueryBuilder<TrasferteSap, String, QQueryOperations>
      oraFineTrasfertaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oraFineTrasferta');
    });
  }

  QueryBuilder<TrasferteSap, String, QQueryOperations>
      oraInizioTrasfertaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oraInizioTrasferta');
    });
  }
}
