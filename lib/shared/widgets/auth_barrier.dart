import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/auth/providers/auth_provider.dart';

class AuthBarrier {
  /// Controlla lo stato di autenticazione dell'utente.
  /// Se già autenticato, esegue immediatamente la callback [onAuthenticated].
  /// Altrimenti, mostra una modale elegante in stile TIM per invitare all'accesso Entra ID.
  static void check(BuildContext context, WidgetRef ref, VoidCallback onAuthenticated) {
    final authState = ref.read(authProvider);
    if (authState.isAuthenticated) {
      onAuthenticated();
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AuthBarrierDismiss',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Consumer(
                  builder: (context, ref, _) {
                    final currentAuth = ref.watch(authProvider);

                    // Se l'utente si è autenticato con successo tramite il browser aperto in background,
                    // chiude automaticamente la modale ed esegue l'operazione protetta!
                    if (currentAuth.isAuthenticated) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pop(context);
                        onAuthenticated();
                      });
                    }

                    final bool isLoading = currentAuth.isAuthenticating || currentAuth.isChecking;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icona Lucchetto TIM
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: SkyTheme.timBlue.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: SkyTheme.timBlue.withOpacity(0.15),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_person_outlined,
                            color: SkyTheme.timBlue,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Autenticazione Richiesta',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: SkyTheme.timBlue,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Questa è un\'area protetta riservata agli auditor autorizzati. Per procedere, effettua l\'accesso sicuro tramite Microsoft Entra ID con il tuo account aziendale TIM.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        
                        if (currentAuth.isError) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: SkyTheme.timRed.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SkyTheme.timRed.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: SkyTheme.timRed, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    currentAuth.errorMessage ?? 'Errore di autenticazione',
                                    style: const TextStyle(
                                      color: SkyTheme.timRed,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: isLoading ? null : () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  'ANNULLA',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => ref.read(authProvider.notifier).login(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SkyTheme.timRed,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  shadowColor: Colors.transparent,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'ACCEDI CON TIM',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
