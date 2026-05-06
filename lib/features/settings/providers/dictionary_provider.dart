import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import 'package:travel_check/features/settings/models/dictionary.dart';

final dictionaryProvider =
    StateNotifierProvider<DictionaryNotifier, List<Dictionary>>((ref) {
      final isar = ref.watch(isarProvider);
      return DictionaryNotifier(isar);
    });

class DictionaryNotifier extends StateNotifier<List<Dictionary>> {
  final Isar _isar;

  DictionaryNotifier(this._isar) : super([]) {
    _loadDictionaries();
  }

  Future<void> _loadDictionaries() async {
    final dictionaries = await _isar.dictionarys.where().findAll();

    final categories = dictionaries.map((e) => e.category).toSet();
    if (!categories.contains('giustificativi_prepagati') ||
        !categories.contains('tipo_dipendente') ||
        !categories.contains('societa')) {
      await _seedDefaults();
    } else {
      state = dictionaries;
    }
  }

  Future<void> _seedDefaults() async {
    final defaults = [
      Dictionary()
        ..code = 'ALP1'
        ..value = 'Alloggio prepagato'
        ..category = 'giustificativi_prepagati'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'SSP1'
        ..value = 'Visti consolari - pre. Autom.'
        ..category = 'giustificativi_prepagati'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'TAP1'
        ..value = 'Aereo - prepagato Automatico'
        ..category = 'giustificativi_prepagati'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'TGP1'
        ..value = 'Traghetto - prepagato Autom.'
        ..category = 'giustificativi_prepagati'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'TNP1'
        ..value = 'Noleggio auto prep. Autom.'
        ..category = 'giustificativi_prepagati'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'TTP1'
        ..value = 'Treno - prepagato Automatico'
        ..category = 'giustificativi_prepagati'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'QD'
        ..value = 'Quadro'
        ..category = 'tipo_dipendente'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'IM'
        ..value = 'Impiegato'
        ..category = 'tipo_dipendente'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'RS'
        ..value = 'Risorsa Strategica'
        ..category = 'tipo_dipendente'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'DR'
        ..value = 'Dirigente'
        ..category = 'tipo_dipendente'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'C120'
        ..value = 'TIM S.p.A.'
        ..category = 'societa'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'C140'
        ..value = 'Noovle S.p.A'
        ..category = 'societa'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'A710'
        ..value = 'TI Trust Technol. S.r.L.'
        ..category = 'societa'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'A640'
        ..value = 'TI Sparkle S.p.A.'
        ..category = 'societa'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'A200'
        ..value = 'Olivetti S.p.A.'
        ..category = 'societa'
        ..updatedAt = DateTime.now(),
      Dictionary()
        ..code = 'A150'
        ..value = 'Telecontact Center S.p.A'
        ..category = 'societa'
        ..updatedAt = DateTime.now(),
    ];

    await _isar.writeTxn(() async {
      for (final d in defaults) {
        final existing = await _isar.dictionarys
            .filter()
            .codeEqualTo(d.code)
            .and()
            .categoryEqualTo(d.category)
            .findFirst();
        if (existing == null) {
          await _isar.dictionarys.put(d);
        }
      }
    });
    state = await _isar.dictionarys.where().findAll();
  }

  Future<void> addEntry(String code, String value, String category) async {
    final entry = Dictionary()
      ..code = code
      ..value = value
      ..category = category
      ..updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.dictionarys.put(entry);
    });
    state = await _isar.dictionarys.where().findAll();
  }

  Future<void> updateEntry(int id, String code, String value) async {
    final entry = await _isar.dictionarys.get(id);
    if (entry != null) {
      entry.code = code;
      entry.value = value;
      entry.updatedAt = DateTime.now();

      await _isar.writeTxn(() async {
        await _isar.dictionarys.put(entry);
      });
      state = await _isar.dictionarys.where().findAll();
    }
  }

  Future<void> deleteEntry(int id) async {
    await _isar.writeTxn(() async {
      await _isar.dictionarys.delete(id);
    });
    state = await _isar.dictionarys.where().findAll();
  }

  Future<void> clearCategory(String category) async {
    await _isar.writeTxn(() async {
      await _isar.dictionarys.filter().categoryEqualTo(category).deleteAll();
    });
    state = await _isar.dictionarys.where().findAll();
  }
}
