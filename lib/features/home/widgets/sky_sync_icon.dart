import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../sync_file/providers/sync_provider.dart';
import '../../sync_file/models/sync_state.dart';
import '../../../core/theme/app_theme.dart';

class SkySyncIcon extends ConsumerStatefulWidget {
  const SkySyncIcon({super.key});

  @override
  ConsumerState<SkySyncIcon> createState() => _SkySyncIconState();
}

class _SkySyncIconState extends ConsumerState<SkySyncIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Gestione stato iniziale se la sincronizzazione è già attiva (es. dopo navigazione)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(syncProvider).isSyncing) {
        _rotationController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _showLoginModal(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.cloud_off_rounded,
            size: 48,
            color: SkyTheme.timRed,
          ),
          title: const Text(
            'Sincronizzazione non Disponibile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: SkyTheme.timBlue,
            ),
          ),
          content: const Text(
            'Per poter eseguire la sincronizzazione automatica dei file tramite SharePoint, è necessario effettuare prima l\'accesso con le credenziali aziendali.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: SkyTheme.timBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).login();
              },
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Accedi ora'),
            ),
          ],
        );
      },
    );
  }

  void _showAlreadySyncingMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'La sincronizzazione globale è già in corso in background.',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: SkyTheme.timBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncProvider);
    final authState = ref.watch(authProvider);

    // Ascolta i cambiamenti per fermare/avviare l'animazione dell'icona
    ref.listen<SyncState>(syncProvider, (previous, next) {
      if (next.isSyncing) {
        if (!_rotationController.isAnimating) {
          _rotationController.repeat();
        }
      } else {
        if (_rotationController.isAnimating) {
          _rotationController.stop();
        }
      }

      // Mostra toast di successo o errore al completamento
      if (previous != null && previous.isSyncing && !next.isSyncing) {
        final hasErrors = next.syncQueue.any((item) => item['status'] == 'error');
        final successCount = next.syncQueue.where((item) => item['status'] == 'completed').length;
        final totalCount = next.syncQueue.length;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  hasErrors ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasErrors
                        ? 'Sincronizzazione completata con alcuni errori.'
                        : 'Sincronizzazione globale completata con successo! Importati ${next.totalRecordsImported} record ($successCount/$totalCount file).',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: hasErrors ? SkyTheme.timRed : Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    final isSyncing = syncState.isSyncing;
    final isAuthenticated = authState.isAuthenticated;

    return Tooltip(
      message: !isAuthenticated
          ? 'Sincronizzazione non disponibile (Accedi)'
          : isSyncing
              ? 'Sincronizzazione in corso...'
              : 'Avvia sincronizzazione globale',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSyncing
              ? Colors.white.withAlpha(40)
              : Colors.transparent,
          border: Border.all(
            color: isSyncing
                ? Colors.white.withAlpha(100)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSyncing
              ? [
                  BoxShadow(
                    color: Colors.white.withAlpha(30),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              if (!isAuthenticated) {
                _showLoginModal(context, ref);
              } else if (isSyncing) {
                _showAlreadySyncingMessage(context);
              } else {
                ref.read(syncProvider.notifier).setSelectedSyncType('all');
                ref.read(syncProvider.notifier).startSynchronization();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: RotationTransition(
                turns: _rotationController,
                child: Icon(
                  isAuthenticated ? Icons.sync : Icons.sync_disabled,
                  color: isAuthenticated
                      ? Colors.white
                      : Colors.white.withAlpha(100),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
