import 'package:isar/isar.dart';

part 'log_history.g.dart';

@collection
class LogHistory {
  Id id = Isar.autoIncrement;

  final String fileName;
  final DateTime date;
  @Index(unique: true, replace: true)
  final String uniqueCode;

  final int totalRecords;
  final int insertedRecords;
  final int updatedRecords;
  final int discardedRecords;
  final String? sourceType;

  LogHistory({
    required this.fileName,
    required this.date,
    required this.uniqueCode,
    this.totalRecords = 0,
    this.insertedRecords = 0,
    this.updatedRecords = 0,
    this.discardedRecords = 0,
    this.sourceType,
  });
}
