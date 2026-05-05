import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:travel_check/features/upload/providers/tracciato_contabile_provider.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  Future<void> _clearCollection(String collectionName) async {
    final confirmed = await _showConfirmationDialog(
      title: 'Svuota $collectionName',
      content: 'Sei sicuro di voler eliminare tutti i dati della collection $collectionName? L\'operazione è irreversibile.',
    );

    if (confirmed == true) {
      if (collectionName == 'Tracciato Contabile') {
        await ref.read(tracciatoContabilesProvider.notifier).clear();
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
      content: 'ATTENZIONE! Questa operazione eliminerà TUTTI i dati presenti nel database locale. Sei assolutamente sicuro?',
      isDestructive: true,
    );

    if (confirmed == true) {
      await isar.writeTxn(() async {
        await isar.clear();
      });
      // Aggiorniamo anche lo stato in memoria per le collection caricate
      ref.invalidate(tracciatoContabilesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tutto il database è stato svuotato con successo'),
            backgroundColor: Colors.green.shade600,
          ),
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
              backgroundColor: isDestructive ? Colors.red.shade600 : Colors.orange.shade600,
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
    return Padding(
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

          // Sezione Database
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.storage, color: SkyTheme.timBlue),
                    const SizedBox(width: 12),
                    const Text(
                      'Gestione Database Locale',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Amministrazione dei dati salvati localmente. Attenzione: le cancellazioni sono irreversibili.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 24),
                
                // Singole Collection
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: Icon(Icons.table_chart_outlined, color: SkyTheme.timBlue),
                  ),
                  title: const Text('Collection: Tracciato Contabile'),
                  subtitle: const Text('Elimina solo i record importati del tracciato contabile'),
                  trailing: OutlinedButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Svuota'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade200),
                    ),
                    onPressed: () => _clearCollection('Tracciato Contabile'),
                  ),
                ),
                
                const Divider(height: 32),
                
                // Tutto il DB
                Container(
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
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                              ),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
