import 'package:isar/isar.dart';

part 'scarti_ec_sap.g.dart';

@collection
class ScartiEcSap {
  Id id = Isar.autoIncrement;

  @Index()
  final String numeroTrasferta; // Col 0 (A): TRASFERTA

  @Index()
  final String cid; // Col 1 (B): CID (with 8-digit padding: left padded with zeros)

  final String descrizioneScarto; // Col 2 (C): DESCRIZIONE SCARTO

  final String spesa; // Col 3 (D): SPESA

  final double importo; // Col 4 (E): IMPORTO

  final String divisa; // Col 5 (F): DIVISA

  final String? storno; // Col 6 (G): STORNO?

  final String dataInvio; // Col 7 (H): DATA_INVIO (converted from dd.MM.yyyy to dd/MM/yyyy)

  final String? note; // Col 8 (I): NOTE

  final String? logHistoryId;

  ScartiEcSap({
    required this.numeroTrasferta,
    required this.cid,
    required this.descrizioneScarto,
    required this.spesa,
    required this.importo,
    required this.divisa,
    this.storno,
    required this.dataInvio,
    this.note,
    this.logHistoryId,
  });
}
