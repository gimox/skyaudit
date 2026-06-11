import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Scarti matching helper logic tests', () {
    String cleanTrasferta(String t) {
      String s = t.trim().split('.')[0];
      s = s.replaceAll(RegExp(r'^0+'), '');
      return s;
    }

    String padCid(String cid) {
      return cid.trim().padLeft(8, '0');
    }

    bool sameImporto(double a, double b) {
      return (a - b).abs() < 0.005;
    }

    test('cleanTrasferta removes leading zeros and decimals', () {
      expect(cleanTrasferta('00012345.0'), '12345');
      expect(cleanTrasferta('12345'), '12345');
      expect(cleanTrasferta('000000'), '');
    });

    test('padCid pads CID with leading zeros to 8 digits', () {
      expect(padCid('12345'), '00012345');
      expect(padCid('00012345'), '00012345');
      expect(padCid('  99  '), '00000099');
    });

    test('sameImporto handles floating point discrepancies within 0.01', () {
      expect(sameImporto(24.12, 24.12000001), true);
      expect(sameImporto(24.12, 24.129), false);
      expect(sameImporto(-24.12, -24.12), true);
    });

    test('1-to-1 matching simulation', () {
      // Mock scarti records
      final scarti = [
        {'cid': '123', 'trasferta': '0001', 'importo': 50.0},
        {'cid': '123', 'trasferta': '0001', 'importo': 50.0}, // Duplicate scarto
      ];

      // Mock contabile records
      final contabile = [
        {'id': 1, 'cid': '00000123', 'numeroTrasferta': '1.0', 'importo': 50.0, 'isNegative': false, 'isScarto': false},
        {'id': 2, 'cid': '00000123', 'numeroTrasferta': '1.0', 'importo': 50.0, 'isNegative': false, 'isScarto': false},
        {'id': 3, 'cid': '00000123', 'numeroTrasferta': '1.0', 'importo': 50.0, 'isNegative': false, 'isScarto': false},
      ];

      final matchedIds = <int>{};
      final updatedContabile = <int, bool>{};

      for (final sc in scarti) {
        final scCid = padCid(sc['cid'] as String);
        final scTrasf = cleanTrasferta(sc['trasferta'] as String);
        final scImp = sc['importo'] as double;

        Map<String, dynamic>? bestMatch;
        for (final cand in contabile) {
          if (matchedIds.contains(cand['id'] as int)) continue;

          final candCid = padCid(cand['cid'] as String);
          final candTrasf = cleanTrasferta(cand['numeroTrasferta'] as String);
          final candImp = (cand['isNegative'] as bool) ? -(cand['importo'] as double) : (cand['importo'] as double);

          if (scCid == candCid && scTrasf == candTrasf && sameImporto(scImp, candImp)) {
            bestMatch = cand;
            break;
          }
        }

        if (bestMatch != null) {
          matchedIds.add(bestMatch['id'] as int);
          updatedContabile[bestMatch['id'] as int] = true;
        }
      }

      // Check that only 2 records are marked as Scarto (since we only had 2 scarti)
      expect(matchedIds.length, 2);
      expect(updatedContabile[1], true);
      expect(updatedContabile[2], true);
      expect(updatedContabile[3], isNull); // 3rd contabile record remains untouched
    });
   group('Importo sign matching tests', () {
      test('Matches positive and negative importo correctly', () {
        final scartoStorno = -50.0;
        final tcStornoNegative = true;
        final tcStornoImporto = 50.0;
        final tcSignedImporto = tcStornoNegative ? -tcStornoImporto : tcStornoImporto;

        expect((scartoStorno - tcSignedImporto).abs() < 0.01, true);
      });
    });
  });
}
