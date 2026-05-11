import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';
import 'package:travel_check/features/upload/providers/log_history_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/features/settings/providers/dictionary_provider.dart';
import 'package:travel_check/features/settings/models/dictionary.dart';
import 'package:travel_check/features/upload/providers/estratto_conto_provider.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/providers/tracciato_sap_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _clearCollection(String collectionName) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Svuota $collectionName',
      content:
          'Sei sicuro di voler eliminare tutti i dati della collection $collectionName? L\'operazione è irreversibile.',
    );

    if (confirmed == true) {
      if (collectionName == 'Tracciato Contabile') {
        await ref.read(tracciatoContabilesProvider.notifier).clear();
      } else if (collectionName == 'Log History') {
        final isar = ref.read(isarProvider);
        await isar.writeTxn(() => isar.logHistorys.clear());
        ref.invalidate(logHistoryProvider);
      } else if (collectionName == 'Dizionari') {
        final isar = ref.read(isarProvider);
        await isar.writeTxn(() => isar.dictionarys.clear());
        ref.invalidate(dictionaryProvider);
      } else if (collectionName == 'Estratto Conto') {
        await ref.read(estrattoContoProvider.notifier).clear();
      } else if (collectionName == 'Tracciato Sap') {
        await ref.read(tracciatoSapProvider.notifier).clear();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Collection $collectionName svuotata con successo'),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }

  Future<void> _clearEntireDatabase() async {
    final isar = ref.read(isarProvider);
    final confirmed = await _showConfirmationDialog(
      title: 'Svuota Intero Database',
      content:
          'ATTENZIONE! Questa operazione eliminerà TUTTI i dati presenti nel database locale. Sei assolutamente sicuro?',
      isDestructive: true,
    );

    if (confirmed == true) {
      await isar.writeTxn(() async {
        await isar.tracciatoContabiles.clear();
        await isar.logHistorys.clear();
        await isar.estrattoContos.clear();
        await isar.tracciatoSaps.clear();
      });
      // Aggiorniamo anche lo stato in memoria per le collection caricate
      ref.invalidate(tracciatoContabilesProvider);
      ref.invalidate(logHistoryProvider);
      ref.invalidate(estrattoContoProvider);
      ref.invalidate(tracciatoSapProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Tutto il database è stato svuotato con successo',
            ),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }

  Future<void> _showEditDictionaryDialog({
    Dictionary? entry,
    String? category,
  }) async {
    _codeController.text = entry?.code ?? '';
    _valueController.text = entry?.value ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry == null ? 'Nuova Voce' : 'Modifica Voce'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Codice',
                hintText: 'Es: ALP1',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Valore',
                hintText: 'Es: Alloggio prepagato',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salva'),
          ),
        ],
      ),
    );

    if (confirmed == true && _codeController.text.isNotEmpty) {
      if (entry == null) {
        await ref
            .read(dictionaryProvider.notifier)
            .addEntry(
              _codeController.text.toUpperCase(),
              _valueController.text,
              category ?? 'giustificativi_prepagati',
            );
      } else {
        await ref
            .read(dictionaryProvider.notifier)
            .updateEntry(
              entry.id,
              _codeController.text.toUpperCase(),
              _valueController.text,
            );
      }
    }
  }

  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: isDestructive ? Colors.red : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? Colors.red.shade600
                  : Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dictionaries = ref.watch(dictionaryProvider);
    final prepagatoEntries = dictionaries
        .where((e) => e.category == 'giustificativi_prepagati')
        .toList();
    final tipoDipendenteEntries = dictionaries
        .where((e) => e.category == 'tipo_dipendente')
        .toList();
    final societaEntries = dictionaries
        .where((e) => e.category == 'societa')
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IMPOSTAZIONI',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w200,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestione configurazioni e manutenzione sistema',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 48),

          // Sezione Dizionari
          _buildSectionHeader(
            context,
            Icons.book_outlined,
            'Dizionari di Decodifica',
            'Configura i valori per la decifrazione automatica dei record.',
          ),
          const SizedBox(height: 24),

          _buildDictionaryCard(
            context,
            'Giustificativi Prepagati',
            'giustificativi_prepagati',
            prepagatoEntries,
          ),

          const SizedBox(height: 24),

          _buildDictionaryCard(
            context,
            'Tipo Dipendente',
            'tipo_dipendente',
            tipoDipendenteEntries,
          ),

          const SizedBox(height: 24),

          _buildDictionaryCard(context, 'Società', 'societa', societaEntries),

          const SizedBox(height: 48),


          // Sezione Database
          _buildSectionHeader(
            context,
            Icons.storage,
            'Gestione Database Locale',
            'Amministrazione dei dati salvati localmente. Attenzione: le cancellazioni sono irreversibili.',
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildCollectionTile(
                  context,
                  Icons.table_chart_outlined,
                  'Collection: Tracciato Contabile',
                  'Elimina solo i record importati del tracciato contabile',
                  () => _clearCollection('Tracciato Contabile'),
                ),
                _buildCollectionTile(
                  context,
                  Icons.history,
                  'Collection: Log History',
                  'Elimina lo storico delle importazioni (file, date, etc.)',
                  () => _clearCollection('Log History'),
                ),
                _buildCollectionTile(
                  context,
                  Icons.account_balance_wallet_outlined,
                  'Collection: Estratto Conto',
                  'Elimina tutti i dati caricati dagli estratti conto',
                  () => _clearCollection('Estratto Conto'),
                ),
                _buildCollectionTile(
                  context,
                  Icons.analytics_outlined,
                  'Collection: Tracciato Sap',
                  'Elimina tutti i dati caricati dal tracciato SAP',
                  () => _clearCollection('Tracciato Sap'),
                ),
                const Divider(height: 32),
                _buildHardResetAction(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: SkyTheme.timBlue),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDictionaryCard(
    BuildContext context,
    String title,
    String category,
    List<Dictionary> entries,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _showEditDictionaryDialog(category: category),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Aggiungi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SkyTheme.timBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('Nessuna voce presente')),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: entries.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: SkyTheme.timBlue.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.code,
                      style: TextStyle(
                        color: SkyTheme.timBlue,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  title: Text(entry.value),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () =>
                            _showEditDictionaryDialog(entry: entry),
                        color: Colors.blue,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () async {
                          final confirmed = await _showConfirmationDialog(
                            title: 'Elimina Voce',
                            content:
                                "Sei sicuro di voler eliminare la voce '${entry.code}'?",
                            isDestructive: true,
                          );
                          if (confirmed == true) {
                            await ref
                                .read(dictionaryProvider.notifier)
                                .deleteEntry(entry.id);
                          }
                        },
                        color: Colors.red,
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCollectionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onPressed,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, color: SkyTheme.timBlue),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: OutlinedButton.icon(
        icon: const Icon(Icons.delete_outline, size: 18),
        label: const Text('Svuota'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange.shade700,
          side: BorderSide(color: Colors.orange.shade200),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildHardResetAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Svuota Intero Database (Hard Reset)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Elimina tutte le collection e formatta il database allo stato di fabbrica.',
                  style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('Formatta DB'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: _clearEntireDatabase,
          ),
        ],
      ),
    );
  }
}
