import 'package:isar/isar.dart';

part 'dictionary.g.dart';

@collection
class Dictionary {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String code;

  late String value;

  late String category; // Es: 'giustificativi_prepagati'

  late DateTime updatedAt;
}
