import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/models/auth_state.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/providers/user_avatar_provider.dart';
import 'sky_sync_icon.dart';

class SkyTopBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final bool showMenuIcon;

  const SkyTopBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.showMenuIcon = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final avatarPath = ref.watch(userAvatarProvider);

    return AppBar(
      leading: showMenuIcon
          ? IconButton(icon: const Icon(Icons.menu), onPressed: onMenuPressed)
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/travel_logo.png', height: 28),
          const SizedBox(width: 12),
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
      actions: [
        const SkySyncIcon(),
        const SizedBox(width: 8),
        _buildUserActions(context, ref, authState, avatarPath),
        const SizedBox(width: 16),
      ],
      elevation: 0,
      centerTitle: false,
    );
  }

  Widget _buildUserActions(BuildContext context, WidgetRef ref, AuthState authState, String? avatarPath) {
    if (authState.isChecking || authState.isAuthenticating) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(SkyTheme.timRed),
          ),
        ),
      );
    }

    final isConnected = authState.isAuthenticated;
    final userName = authState.userName;

    if (!isConnected) {
      return OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          await ref.read(authProvider.notifier).login();
        },
        icon: const Icon(Icons.login, size: 18, color: Colors.white),
        label: const Text(
          'ACCEDI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontSize: 13,
          ),
        ),
      );
    }

    return PopupMenuButton<int>(
      tooltip: 'Profilo Utente',
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 6,
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: SkyTheme.timBlue.withAlpha(76),
            width: 1.5,
          ),
        ),
        child: _buildAvatarWidget(avatarPath, userName, size: 32),
      ),
      onSelected: (value) async {
        if (value == 2) {
          await ref.read(authProvider.notifier).logout();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildAvatarWidget(avatarPath, userName, size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          userName ?? 'Utente',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: SkyTheme.timBlue,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authState.userEmail ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
            ],
          ),
        ),
        const PopupMenuItem<int>(
          value: 2,
          child: Row(
            children: [
              Icon(Icons.logout, size: 16, color: SkyTheme.timRed),
              SizedBox(width: 8),
              Text(
                'Disconnetti',
                style: TextStyle(
                  color: SkyTheme.timRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWidget(String? avatarPath, String? userName, {double size = 32}) {
    if (avatarPath != null && avatarPath.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.file(
            File(avatarPath),
            fit: BoxFit.cover,
            key: ValueKey('$avatarPath-${DateTime.now().millisecondsSinceEpoch}'), // Risolve il caching di Flutter
            errorBuilder: (context, error, stackTrace) => _buildInitialsOrIcon(userName, size),
          ),
        ),
      );
    }
    return _buildInitialsOrIcon(userName, size);
  }

  Widget _buildInitialsOrIcon(String? userName, double size) {
    if (userName != null && userName.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: SkyTheme.timBlue,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _getInitials(userName),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: size * 0.38,
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.person,
        color: Colors.grey.shade600,
        size: size * 0.6,
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
