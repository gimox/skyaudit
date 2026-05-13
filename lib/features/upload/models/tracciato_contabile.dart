import 'package:isar/isar.dart';

part 'tracciato_contabile.g.dart';

@collection
class TracciatoContabile {
  Id id = Isar.autoIncrement;

  final String recordType;
  final String cid;
  final String numeroTrasferta;
  final String progressivo;
  final String societa;
  final String tipoDipendente;
  final String giustificativoSpesa;
  @Index(unique: false)
  final String numeroBolla;
  final String dataSpesa;
  final String localita;
  final String dataInizio;
  final String oraInizio;
  final String dataFine;
  final String oraFine;
  final String tipoAttivita;
  final double importo;
  final String valuta;
  final bool isNegative;
  final String? logHistoryId;
  final int? sourceFileLine;

  TracciatoContabile({
    required this.recordType,
    required this.cid,
    required this.numeroTrasferta,
    required this.progressivo,
    required this.societa,
    required this.tipoDipendente,
    required this.giustificativoSpesa,
    required this.numeroBolla,
    required this.dataSpesa,
    required this.localita,
    required this.dataInizio,
    required this.oraInizio,
    required this.dataFine,
    required this.oraFine,
    required this.tipoAttivita,
    required this.importo,
    required this.valuta,
    required this.isNegative,
    this.logHistoryId,
    this.sourceFileLine,
  });

  static String _formatDate(String yyyymmdd) {
    if (yyyymmdd.length != 8) return yyyymmdd;
    final year = yyyymmdd.substring(0, 4);
    final month = yyyymmdd.substring(4, 6);
    final day = yyyymmdd.substring(6, 8);
    return '$day/$month/$year';
  }

  static String _formatTime(String hhmmss) {
    if (hhmmss.length != 6) return hhmmss;
    final hh = hhmmss.substring(0, 2);
    final mm = hhmmss.substring(2, 4);
    final ss = hhmmss.substring(4, 6);
    return '$hh:$mm:$ss';
  }

  factory TracciatoContabile.fromString(
    String line, {
    String? logHistoryId,
    int? sourceFileLine,
  }) {
    // Pad line to ensure we can reach position 166 without FormatException
    if (line.length < 166) {
      line = line.padRight(166, ' ');
    }

    final rawImporto = line.substring(140, 160).trim();
    final parsedImporto = double.tryParse(rawImporto) ?? 0.0;

    return TracciatoContabile(
      recordType: line.substring(0, 1),
      cid: line.substring(1, 9).trim().isNotEmpty ? line.substring(1, 9).trim().padLeft(8, '0') : '',
      numeroTrasferta: line.substring(9, 19).trim(),
      progressivo: line.substring(19, 22).trim(),
      societa: line.substring(22, 26).trim(),
      tipoDipendente: line.substring(26, 28).trim(),
      giustificativoSpesa: line.substring(28, 32).trim(),
      numeroBolla: line.substring(32, 44).trim(),
      dataSpesa: _formatDate(line.substring(44, 52).trim()),
      localita: line.substring(52, 111).trim(),
      dataInizio: _formatDate(line.substring(111, 119).trim()),
      oraInizio: _formatTime(line.substring(119, 125).trim()),
      dataFine: _formatDate(line.substring(125, 133).trim()),
      oraFine: _formatTime(line.substring(133, 139).trim()),
      tipoAttivita: line.substring(139, 140).trim(),
      importo: parsedImporto,
      valuta: line.substring(160, 163).trim(),
      isNegative: line.substring(165, 166) == 'R',
      logHistoryId: logHistoryId,
      sourceFileLine: sourceFileLine,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recordType': recordType,
      'cid': cid,
      'numeroTrasferta': numeroTrasferta,
      'progressivo': progressivo,
      'societa': societa,
      'tipoDipendente': tipoDipendente,
      'giustificativoSpesa': giustificativoSpesa,
      'numeroBolla': numeroBolla,
      'dataSpesa': dataSpesa,
      'localita': localita,
      'dataInizio': dataInizio,
      'oraInizio': oraInizio,
      'dataFine': dataFine,
      'oraFine': oraFine,
      'tipoAttivita': tipoAttivita,
      'importo': importo,
      'valuta': valuta,
      'isNegative': isNegative,
      'logHistoryId': logHistoryId,
      'sourceFileLine': sourceFileLine,
    };
  }

  factory TracciatoContabile.fromMap(Map<String, dynamic> map) {
    return TracciatoContabile(
      recordType: map['recordType'] ?? '',
      cid: map['cid'] ?? '',
      numeroTrasferta: map['numeroTrasferta'] ?? '',
      progressivo: map['progressivo'] ?? '',
      societa: map['societa'] ?? '',
      tipoDipendente: map['tipoDipendente'] ?? '',
      giustificativoSpesa: map['giustificativoSpesa'] ?? '',
      numeroBolla: map['numeroBolla'] ?? '',
      dataSpesa: map['dataSpesa'] ?? '',
      localita: map['localita'] ?? '',
      dataInizio: map['dataInizio'] ?? '',
      oraInizio: map['oraInizio'] ?? '',
      dataFine: map['dataFine'] ?? '',
      oraFine: map['oraFine'] ?? '',
      tipoAttivita: map['tipoAttivita'] ?? '',
      importo: (map['importo'] as num?)?.toDouble() ?? 0.0,
      valuta: map['valuta'] ?? '',
      isNegative: map['isNegative'] ?? false,
      logHistoryId: map['logHistoryId'],
      sourceFileLine: map['sourceFileLine'] as int?,
    );
  }
}
