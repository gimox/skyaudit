import 'package:isar/isar.dart';

part 'trasferte_sap.g.dart';

@collection
class TrasferteSap {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String numeroTrasferta;

  @Index()
  final String cid;

  final String dataInizioTrasferta;
  final String oraInizioTrasferta;
  final String dataFineTrasferta;
  final String oraFineTrasferta;
  final String? logHistoryId;

  TrasferteSap({
    required this.numeroTrasferta,
    required this.cid,
    required this.dataInizioTrasferta,
    required this.oraInizioTrasferta,
    required this.dataFineTrasferta,
    required this.oraFineTrasferta,
    this.logHistoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numeroTrasferta': numeroTrasferta,
      'cid': cid,
      'dataInizioTrasferta': dataInizioTrasferta,
      'oraInizioTrasferta': oraInizioTrasferta,
      'dataFineTrasferta': dataFineTrasferta,
      'oraFineTrasferta': oraFineTrasferta,
      'logHistoryId': logHistoryId,
    };
  }
}
