// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracciato_contabile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTracciatoContabileCollection on Isar {
  IsarCollection<TracciatoContabile> get tracciatoContabiles =>
      this.collection();
}

const TracciatoContabileSchema = CollectionSchema(
  name: r'TracciatoContabile',
  id: -6068699107506550185,
  properties: {
    r'cid': PropertySchema(id: 0, name: r'cid', type: IsarType.string),
    r'dataFine': PropertySchema(
      id: 1,
      name: r'dataFine',
      type: IsarType.string,
    ),
    r'dataInizio': PropertySchema(
      id: 2,
      name: r'dataInizio',
      type: IsarType.string,
    ),
    r'dataSpesa': PropertySchema(
      id: 3,
      name: r'dataSpesa',
      type: IsarType.string,
    ),
    r'giustificativoSpesa': PropertySchema(
      id: 4,
      name: r'giustificativoSpesa',
      type: IsarType.string,
    ),
    r'importo': PropertySchema(id: 5, name: r'importo', type: IsarType.double),
    r'isNegative': PropertySchema(
      id: 6,
      name: r'isNegative',
      type: IsarType.bool,
    ),
    r'localita': PropertySchema(
      id: 7,
      name: r'localita',
      type: IsarType.string,
    ),
    r'logHistoryId': PropertySchema(
      id: 8,
      name: r'logHistoryId',
      type: IsarType.string,
    ),
    r'numeroBolla': PropertySchema(
      id: 9,
      name: r'numeroBolla',
      type: IsarType.string,
    ),
    r'numeroTrasferta': PropertySchema(
      id: 10,
      name: r'numeroTrasferta',
      type: IsarType.string,
    ),
    r'oraFine': PropertySchema(id: 11, name: r'oraFine', type: IsarType.string),
    r'oraInizio': PropertySchema(
      id: 12,
      name: r'oraInizio',
      type: IsarType.string,
    ),
    r'progressivo': PropertySchema(
      id: 13,
      name: r'progressivo',
      type: IsarType.string,
    ),
    r'recordType': PropertySchema(
      id: 14,
      name: r'recordType',
      type: IsarType.string,
    ),
    r'societa': PropertySchema(id: 15, name: r'societa', type: IsarType.string),
    r'tipoAttivita': PropertySchema(
      id: 16,
      name: r'tipoAttivita',
      type: IsarType.string,
    ),
    r'tipoDipendente': PropertySchema(
      id: 17,
      name: r'tipoDipendente',
      type: IsarType.string,
    ),
    r'valuta': PropertySchema(id: 18, name: r'valuta', type: IsarType.string),
  },
  estimateSize: _tracciatoContabileEstimateSize,
  serialize: _tracciatoContabileSerialize,
  deserialize: _tracciatoContabileDeserialize,
  deserializeProp: _tracciatoContabileDeserializeProp,
  idName: r'id',
  indexes: {
    r'numeroBolla': IndexSchema(
      id: -7433986064224974417,
      name: r'numeroBolla',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'numeroBolla',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},
  getId: _tracciatoContabileGetId,
  getLinks: _tracciatoContabileGetLinks,
  attach: _tracciatoContabileAttach,
  version: '3.1.0+1',
);

int _tracciatoContabileEstimateSize(
  TracciatoContabile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cid.length * 3;
  bytesCount += 3 + object.dataFine.length * 3;
  bytesCount += 3 + object.dataInizio.length * 3;
  bytesCount += 3 + object.dataSpesa.length * 3;
  bytesCount += 3 + object.giustificativoSpesa.length * 3;
  bytesCount += 3 + object.localita.length * 3;
  {
    final value = object.logHistoryId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.numeroBolla.length * 3;
  bytesCount += 3 + object.numeroTrasferta.length * 3;
  bytesCount += 3 + object.oraFine.length * 3;
  bytesCount += 3 + object.oraInizio.length * 3;
  bytesCount += 3 + object.progressivo.length * 3;
  bytesCount += 3 + object.recordType.length * 3;
  bytesCount += 3 + object.societa.length * 3;
  bytesCount += 3 + object.tipoAttivita.length * 3;
  bytesCount += 3 + object.tipoDipendente.length * 3;
  bytesCount += 3 + object.valuta.length * 3;
  return bytesCount;
}

void _tracciatoContabileSerialize(
  TracciatoContabile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cid);
  writer.writeString(offsets[1], object.dataFine);
  writer.writeString(offsets[2], object.dataInizio);
  writer.writeString(offsets[3], object.dataSpesa);
  writer.writeString(offsets[4], object.giustificativoSpesa);
  writer.writeDouble(offsets[5], object.importo);
  writer.writeBool(offsets[6], object.isNegative);
  writer.writeString(offsets[7], object.localita);
  writer.writeString(offsets[8], object.logHistoryId);
  writer.writeString(offsets[9], object.numeroBolla);
  writer.writeString(offsets[10], object.numeroTrasferta);
  writer.writeString(offsets[11], object.oraFine);
  writer.writeString(offsets[12], object.oraInizio);
  writer.writeString(offsets[13], object.progressivo);
  writer.writeString(offsets[14], object.recordType);
  writer.writeString(offsets[15], object.societa);
  writer.writeString(offsets[16], object.tipoAttivita);
  writer.writeString(offsets[17], object.tipoDipendente);
  writer.writeString(offsets[18], object.valuta);
}

TracciatoContabile _tracciatoContabileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TracciatoContabile(
    cid: reader.readString(offsets[0]),
    dataFine: reader.readString(offsets[1]),
    dataInizio: reader.readString(offsets[2]),
    dataSpesa: reader.readString(offsets[3]),
    giustificativoSpesa: reader.readString(offsets[4]),
    importo: reader.readDouble(offsets[5]),
    isNegative: reader.readBool(offsets[6]),
    localita: reader.readString(offsets[7]),
    logHistoryId: reader.readStringOrNull(offsets[8]),
    numeroBolla: reader.readString(offsets[9]),
    numeroTrasferta: reader.readString(offsets[10]),
    oraFine: reader.readString(offsets[11]),
    oraInizio: reader.readString(offsets[12]),
    progressivo: reader.readString(offsets[13]),
    recordType: reader.readString(offsets[14]),
    societa: reader.readString(offsets[15]),
    tipoAttivita: reader.readString(offsets[16]),
    tipoDipendente: reader.readString(offsets[17]),
    valuta: reader.readString(offsets[18]),
  );
  object.id = id;
  return object;
}

P _tracciatoContabileDeserializeProp<P>(
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
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
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
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _tracciatoContabileGetId(TracciatoContabile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tracciatoContabileGetLinks(
  TracciatoContabile object,
) {
  return [];
}

void _tracciatoContabileAttach(
  IsarCollection<dynamic> col,
  Id id,
  TracciatoContabile object,
) {
  object.id = id;
}

extension TracciatoContabileByIndex on IsarCollection<TracciatoContabile> {
  Future<TracciatoContabile?> getByNumeroBolla(String numeroBolla) {
    return getByIndex(r'numeroBolla', [numeroBolla]);
  }

  TracciatoContabile? getByNumeroBollaSync(String numeroBolla) {
    return getByIndexSync(r'numeroBolla', [numeroBolla]);
  }

  Future<bool> deleteByNumeroBolla(String numeroBolla) {
    return deleteByIndex(r'numeroBolla', [numeroBolla]);
  }

  bool deleteByNumeroBollaSync(String numeroBolla) {
    return deleteByIndexSync(r'numeroBolla', [numeroBolla]);
  }

  Future<List<TracciatoContabile?>> getAllByNumeroBolla(
    List<String> numeroBollaValues,
  ) {
    final values = numeroBollaValues.map((e) => [e]).toList();
    return getAllByIndex(r'numeroBolla', values);
  }

  List<TracciatoContabile?> getAllByNumeroBollaSync(
    List<String> numeroBollaValues,
  ) {
    final values = numeroBollaValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'numeroBolla', values);
  }

  Future<int> deleteAllByNumeroBolla(List<String> numeroBollaValues) {
    final values = numeroBollaValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'numeroBolla', values);
  }

  int deleteAllByNumeroBollaSync(List<String> numeroBollaValues) {
    final values = numeroBollaValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'numeroBolla', values);
  }

  Future<Id> putByNumeroBolla(TracciatoContabile object) {
    return putByIndex(r'numeroBolla', object);
  }

  Id putByNumeroBollaSync(TracciatoContabile object, {bool saveLinks = true}) {
    return putByIndexSync(r'numeroBolla', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNumeroBolla(List<TracciatoContabile> objects) {
    return putAllByIndex(r'numeroBolla', objects);
  }

  List<Id> putAllByNumeroBollaSync(
    List<TracciatoContabile> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'numeroBolla', objects, saveLinks: saveLinks);
  }
}

extension TracciatoContabileQueryWhereSort
    on QueryBuilder<TracciatoContabile, TracciatoContabile, QWhere> {
  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TracciatoContabileQueryWhere
    on QueryBuilder<TracciatoContabile, TracciatoContabile, QWhereClause> {
  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterWhereClause>
  idBetween(
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterWhereClause>
  numeroBollaEqualTo(String numeroBolla) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'numeroBolla',
          value: [numeroBolla],
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterWhereClause>
  numeroBollaNotEqualTo(String numeroBolla) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'numeroBolla',
                lower: [],
                upper: [numeroBolla],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'numeroBolla',
                lower: [numeroBolla],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'numeroBolla',
                lower: [numeroBolla],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'numeroBolla',
                lower: [],
                upper: [numeroBolla],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension TracciatoContabileQueryFilter
    on QueryBuilder<TracciatoContabile, TracciatoContabile, QFilterCondition> {
  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  cidEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  cidLessThan(String value, {bool include = false, bool caseSensitive = true}) {
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  cidBetween(
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  cidEndsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  cidContains(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  cidMatches(String pattern, {bool caseSensitive = true}) {
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  cidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cid', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  cidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cid', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataFine',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataFine',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataFine', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataFineIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataFine', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataInizio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataInizio',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataInizio', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataInizioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataInizio', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'dataSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dataSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dataSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dataSpesa',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'dataSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'dataSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'dataSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'dataSpesa',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dataSpesa', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  dataSpesaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'dataSpesa', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'giustificativoSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'giustificativoSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'giustificativoSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'giustificativoSpesa',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'giustificativoSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'giustificativoSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'giustificativoSpesa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'giustificativoSpesa',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'giustificativoSpesa', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  giustificativoSpesaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'giustificativoSpesa',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  importoEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'importo',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  importoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'importo',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  importoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'importo',
          value: value,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  importoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'importo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  isNegativeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isNegative', value: value),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localita',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localita',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localita', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  localitaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localita', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'logHistoryId'),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'logHistoryId'),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'logHistoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'logHistoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'logHistoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'logHistoryId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'logHistoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'logHistoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'logHistoryId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'logHistoryId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'logHistoryId', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  logHistoryIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'logHistoryId', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'numeroBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'numeroBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'numeroBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'numeroBolla',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'numeroBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'numeroBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'numeroBolla',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'numeroBolla',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numeroBolla', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroBollaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'numeroBolla', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
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

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroTrasfertaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'numeroTrasferta', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  numeroTrasfertaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'numeroTrasferta', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'oraFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'oraFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'oraFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'oraFine',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'oraFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'oraFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'oraFine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'oraFine',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'oraFine', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraFineIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'oraFine', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'oraInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'oraInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'oraInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'oraInizio',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'oraInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'oraInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'oraInizio',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'oraInizio',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'oraInizio', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  oraInizioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'oraInizio', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'progressivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'progressivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'progressivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'progressivo',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'progressivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'progressivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'progressivo',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'progressivo',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'progressivo', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  progressivoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'progressivo', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'recordType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'recordType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'recordType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'recordType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'recordType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'recordType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'recordType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'recordType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'recordType', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  recordTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'recordType', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'societa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'societa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'societa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'societa',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'societa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'societa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'societa',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'societa',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'societa', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  societaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'societa', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tipoAttivita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tipoAttivita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tipoAttivita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tipoAttivita',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tipoAttivita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tipoAttivita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tipoAttivita',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tipoAttivita',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tipoAttivita', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoAttivitaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tipoAttivita', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tipoDipendente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tipoDipendente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tipoDipendente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tipoDipendente',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tipoDipendente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tipoDipendente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tipoDipendente',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tipoDipendente',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tipoDipendente', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  tipoDipendenteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tipoDipendente', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'valuta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'valuta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'valuta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'valuta',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'valuta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'valuta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'valuta',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'valuta',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'valuta', value: ''),
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterFilterCondition>
  valutaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'valuta', value: ''),
      );
    });
  }
}

extension TracciatoContabileQueryObject
    on QueryBuilder<TracciatoContabile, TracciatoContabile, QFilterCondition> {}

extension TracciatoContabileQueryLinks
    on QueryBuilder<TracciatoContabile, TracciatoContabile, QFilterCondition> {}

extension TracciatoContabileQuerySortBy
    on QueryBuilder<TracciatoContabile, TracciatoContabile, QSortBy> {
  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByDataFine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataFine', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByDataFineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataFine', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByDataInizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInizio', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByDataInizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInizio', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByDataSpesa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSpesa', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByDataSpesaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSpesa', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByGiustificativoSpesa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'giustificativoSpesa', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByGiustificativoSpesaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'giustificativoSpesa', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByImporto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByImportoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByIsNegative() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNegative', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByIsNegativeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNegative', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByLocalita() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localita', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByLocalitaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localita', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByLogHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByLogHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByNumeroBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroBolla', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByNumeroBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroBolla', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByOraFine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraFine', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByOraFineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraFine', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByOraInizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraInizio', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByOraInizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraInizio', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByProgressivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressivo', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByProgressivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressivo', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByRecordType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordType', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByRecordTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordType', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortBySocieta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societa', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortBySocietaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societa', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByTipoAttivita() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoAttivita', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByTipoAttivitaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoAttivita', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByTipoDipendente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDipendente', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByTipoDipendenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDipendente', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByValuta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valuta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  sortByValutaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valuta', Sort.desc);
    });
  }
}

extension TracciatoContabileQuerySortThenBy
    on QueryBuilder<TracciatoContabile, TracciatoContabile, QSortThenBy> {
  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByCid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByCidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cid', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByDataFine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataFine', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByDataFineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataFine', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByDataInizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInizio', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByDataInizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataInizio', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByDataSpesa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSpesa', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByDataSpesaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dataSpesa', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByGiustificativoSpesa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'giustificativoSpesa', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByGiustificativoSpesaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'giustificativoSpesa', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByImporto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByImportoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'importo', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByIsNegative() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNegative', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByIsNegativeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isNegative', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByLocalita() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localita', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByLocalitaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localita', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByLogHistoryId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByLogHistoryIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'logHistoryId', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByNumeroBolla() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroBolla', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByNumeroBollaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroBolla', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByNumeroTrasferta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByNumeroTrasfertaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numeroTrasferta', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByOraFine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraFine', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByOraFineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraFine', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByOraInizio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraInizio', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByOraInizioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'oraInizio', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByProgressivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressivo', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByProgressivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progressivo', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByRecordType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordType', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByRecordTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordType', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenBySocieta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societa', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenBySocietaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'societa', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByTipoAttivita() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoAttivita', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByTipoAttivitaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoAttivita', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByTipoDipendente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDipendente', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByTipoDipendenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDipendente', Sort.desc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByValuta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valuta', Sort.asc);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QAfterSortBy>
  thenByValutaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'valuta', Sort.desc);
    });
  }
}

extension TracciatoContabileQueryWhereDistinct
    on QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct> {
  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByCid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByDataFine({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataFine', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByDataInizio({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataInizio', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByDataSpesa({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dataSpesa', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByGiustificativoSpesa({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'giustificativoSpesa',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByImporto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'importo');
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByIsNegative() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isNegative');
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByLocalita({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localita', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByLogHistoryId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'logHistoryId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByNumeroBolla({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numeroBolla', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByNumeroTrasferta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'numeroTrasferta',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByOraFine({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oraFine', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByOraInizio({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'oraInizio', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByProgressivo({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progressivo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByRecordType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctBySocieta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'societa', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByTipoAttivita({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoAttivita', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByTipoDipendente({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'tipoDipendente',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<TracciatoContabile, TracciatoContabile, QDistinct>
  distinctByValuta({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'valuta', caseSensitive: caseSensitive);
    });
  }
}

extension TracciatoContabileQueryProperty
    on QueryBuilder<TracciatoContabile, TracciatoContabile, QQueryProperty> {
  QueryBuilder<TracciatoContabile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations> cidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cid');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  dataFineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataFine');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  dataInizioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataInizio');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  dataSpesaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dataSpesa');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  giustificativoSpesaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'giustificativoSpesa');
    });
  }

  QueryBuilder<TracciatoContabile, double, QQueryOperations> importoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'importo');
    });
  }

  QueryBuilder<TracciatoContabile, bool, QQueryOperations>
  isNegativeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isNegative');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  localitaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localita');
    });
  }

  QueryBuilder<TracciatoContabile, String?, QQueryOperations>
  logHistoryIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'logHistoryId');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  numeroBollaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroBolla');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  numeroTrasfertaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numeroTrasferta');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations> oraFineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oraFine');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  oraInizioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'oraInizio');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  progressivoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progressivo');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  recordTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordType');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations> societaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'societa');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  tipoAttivitaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoAttivita');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations>
  tipoDipendenteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoDipendente');
    });
  }

  QueryBuilder<TracciatoContabile, String, QQueryOperations> valutaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'valuta');
    });
  }
}
