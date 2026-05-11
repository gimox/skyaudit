// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_history.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLogHistoryCollection on Isar {
  IsarCollection<LogHistory> get logHistorys => this.collection();
}

const LogHistorySchema = CollectionSchema(
  name: r'LogHistory',
  id: -3283775972220701330,
  properties: {
    r'date': PropertySchema(
      id: 0,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'discardedRecords': PropertySchema(
      id: 1,
      name: r'discardedRecords',
      type: IsarType.long,
    ),
    r'fileName': PropertySchema(
      id: 2,
      name: r'fileName',
      type: IsarType.string,
    ),
    r'insertedRecords': PropertySchema(
      id: 3,
      name: r'insertedRecords',
      type: IsarType.long,
    ),
    r'totalRecords': PropertySchema(
      id: 4,
      name: r'totalRecords',
      type: IsarType.long,
    ),
    r'uniqueCode': PropertySchema(
      id: 5,
      name: r'uniqueCode',
      type: IsarType.string,
    ),
    r'updatedRecords': PropertySchema(
      id: 6,
      name: r'updatedRecords',
      type: IsarType.long,
    )
  },
  estimateSize: _logHistoryEstimateSize,
  serialize: _logHistorySerialize,
  deserialize: _logHistoryDeserialize,
  deserializeProp: _logHistoryDeserializeProp,
  idName: r'id',
  indexes: {
    r'uniqueCode': IndexSchema(
      id: -4227583366094243322,
      name: r'uniqueCode',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'uniqueCode',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _logHistoryGetId,
  getLinks: _logHistoryGetLinks,
  attach: _logHistoryAttach,
  version: '3.1.0+1',
);

int _logHistoryEstimateSize(
  LogHistory object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.fileName.length * 3;
  bytesCount += 3 + object.uniqueCode.length * 3;
  return bytesCount;
}

void _logHistorySerialize(
  LogHistory object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeLong(offsets[1], object.discardedRecords);
  writer.writeString(offsets[2], object.fileName);
  writer.writeLong(offsets[3], object.insertedRecords);
  writer.writeLong(offsets[4], object.totalRecords);
  writer.writeString(offsets[5], object.uniqueCode);
  writer.writeLong(offsets[6], object.updatedRecords);
}

LogHistory _logHistoryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LogHistory(
    date: reader.readDateTime(offsets[0]),
    discardedRecords: reader.readLongOrNull(offsets[1]) ?? 0,
    fileName: reader.readString(offsets[2]),
    insertedRecords: reader.readLongOrNull(offsets[3]) ?? 0,
    totalRecords: reader.readLongOrNull(offsets[4]) ?? 0,
    uniqueCode: reader.readString(offsets[5]),
    updatedRecords: reader.readLongOrNull(offsets[6]) ?? 0,
  );
  object.id = id;
  return object;
}

P _logHistoryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _logHistoryGetId(LogHistory object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _logHistoryGetLinks(LogHistory object) {
  return [];
}

void _logHistoryAttach(IsarCollection<dynamic> col, Id id, LogHistory object) {
  object.id = id;
}

extension LogHistoryByIndex on IsarCollection<LogHistory> {
  Future<LogHistory?> getByUniqueCode(String uniqueCode) {
    return getByIndex(r'uniqueCode', [uniqueCode]);
  }

  LogHistory? getByUniqueCodeSync(String uniqueCode) {
    return getByIndexSync(r'uniqueCode', [uniqueCode]);
  }

  Future<bool> deleteByUniqueCode(String uniqueCode) {
    return deleteByIndex(r'uniqueCode', [uniqueCode]);
  }

  bool deleteByUniqueCodeSync(String uniqueCode) {
    return deleteByIndexSync(r'uniqueCode', [uniqueCode]);
  }

  Future<List<LogHistory?>> getAllByUniqueCode(List<String> uniqueCodeValues) {
    final values = uniqueCodeValues.map((e) => [e]).toList();
    return getAllByIndex(r'uniqueCode', values);
  }

  List<LogHistory?> getAllByUniqueCodeSync(List<String> uniqueCodeValues) {
    final values = uniqueCodeValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'uniqueCode', values);
  }

  Future<int> deleteAllByUniqueCode(List<String> uniqueCodeValues) {
    final values = uniqueCodeValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'uniqueCode', values);
  }

  int deleteAllByUniqueCodeSync(List<String> uniqueCodeValues) {
    final values = uniqueCodeValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'uniqueCode', values);
  }

  Future<Id> putByUniqueCode(LogHistory object) {
    return putByIndex(r'uniqueCode', object);
  }

  Id putByUniqueCodeSync(LogHistory object, {bool saveLinks = true}) {
    return putByIndexSync(r'uniqueCode', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByUniqueCode(List<LogHistory> objects) {
    return putAllByIndex(r'uniqueCode', objects);
  }

  List<Id> putAllByUniqueCodeSync(List<LogHistory> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'uniqueCode', objects, saveLinks: saveLinks);
  }
}

extension LogHistoryQueryWhereSort
    on QueryBuilder<LogHistory, LogHistory, QWhere> {
  QueryBuilder<LogHistory, LogHistory, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LogHistoryQueryWhere
    on QueryBuilder<LogHistory, LogHistory, QWhereClause> {
  QueryBuilder<LogHistory, LogHistory, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LogHistory, LogHistory, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterWhereClause> idBetween(
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

  QueryBuilder<LogHistory, LogHistory, QAfterWhereClause> uniqueCodeEqualTo(
      String uniqueCode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'uniqueCode',
        value: [uniqueCode],
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterWhereClause> uniqueCodeNotEqualTo(
      String uniqueCode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueCode',
              lower: [],
              upper: [uniqueCode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueCode',
              lower: [uniqueCode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueCode',
              lower: [uniqueCode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'uniqueCode',
              lower: [],
              upper: [uniqueCode],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LogHistoryQueryFilter
    on QueryBuilder<LogHistory, LogHistory, QFilterCondition> {
  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      discardedRecordsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discardedRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      discardedRecordsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discardedRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      discardedRecordsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discardedRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      discardedRecordsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discardedRecords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> fileNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      fileNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> fileNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> fileNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fileName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      fileNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> fileNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> fileNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fileName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> fileNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fileName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      fileNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      fileNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fileName',
        value: '',
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      insertedRecordsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'insertedRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      insertedRecordsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'insertedRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      insertedRecordsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'insertedRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      insertedRecordsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'insertedRecords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      totalRecordsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      totalRecordsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      totalRecordsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      totalRecordsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalRecords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> uniqueCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      uniqueCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uniqueCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      uniqueCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uniqueCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> uniqueCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uniqueCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      uniqueCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uniqueCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      uniqueCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uniqueCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      uniqueCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uniqueCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition> uniqueCodeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uniqueCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      uniqueCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uniqueCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      uniqueCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uniqueCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      updatedRecordsEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      updatedRecordsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      updatedRecordsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedRecords',
        value: value,
      ));
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterFilterCondition>
      updatedRecordsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedRecords',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LogHistoryQueryObject
    on QueryBuilder<LogHistory, LogHistory, QFilterCondition> {}

extension LogHistoryQueryLinks
    on QueryBuilder<LogHistory, LogHistory, QFilterCondition> {}

extension LogHistoryQuerySortBy
    on QueryBuilder<LogHistory, LogHistory, QSortBy> {
  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByDiscardedRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discardedRecords', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy>
      sortByDiscardedRecordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discardedRecords', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByInsertedRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insertedRecords', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy>
      sortByInsertedRecordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insertedRecords', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByTotalRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRecords', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByTotalRecordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRecords', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByUniqueCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCode', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByUniqueCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCode', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> sortByUpdatedRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedRecords', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy>
      sortByUpdatedRecordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedRecords', Sort.desc);
    });
  }
}

extension LogHistoryQuerySortThenBy
    on QueryBuilder<LogHistory, LogHistory, QSortThenBy> {
  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByDiscardedRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discardedRecords', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy>
      thenByDiscardedRecordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discardedRecords', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByFileName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByFileNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fileName', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByInsertedRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insertedRecords', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy>
      thenByInsertedRecordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'insertedRecords', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByTotalRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRecords', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByTotalRecordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalRecords', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByUniqueCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCode', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByUniqueCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uniqueCode', Sort.desc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy> thenByUpdatedRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedRecords', Sort.asc);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QAfterSortBy>
      thenByUpdatedRecordsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedRecords', Sort.desc);
    });
  }
}

extension LogHistoryQueryWhereDistinct
    on QueryBuilder<LogHistory, LogHistory, QDistinct> {
  QueryBuilder<LogHistory, LogHistory, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<LogHistory, LogHistory, QDistinct> distinctByDiscardedRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discardedRecords');
    });
  }

  QueryBuilder<LogHistory, LogHistory, QDistinct> distinctByFileName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fileName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QDistinct> distinctByInsertedRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'insertedRecords');
    });
  }

  QueryBuilder<LogHistory, LogHistory, QDistinct> distinctByTotalRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalRecords');
    });
  }

  QueryBuilder<LogHistory, LogHistory, QDistinct> distinctByUniqueCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uniqueCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LogHistory, LogHistory, QDistinct> distinctByUpdatedRecords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedRecords');
    });
  }
}

extension LogHistoryQueryProperty
    on QueryBuilder<LogHistory, LogHistory, QQueryProperty> {
  QueryBuilder<LogHistory, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LogHistory, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<LogHistory, int, QQueryOperations> discardedRecordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discardedRecords');
    });
  }

  QueryBuilder<LogHistory, String, QQueryOperations> fileNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fileName');
    });
  }

  QueryBuilder<LogHistory, int, QQueryOperations> insertedRecordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'insertedRecords');
    });
  }

  QueryBuilder<LogHistory, int, QQueryOperations> totalRecordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalRecords');
    });
  }

  QueryBuilder<LogHistory, String, QQueryOperations> uniqueCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uniqueCode');
    });
  }

  QueryBuilder<LogHistory, int, QQueryOperations> updatedRecordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedRecords');
    });
  }
}
