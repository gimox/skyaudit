import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class UserAvatarNotifier extends StateNotifier<String?> {
  UserAvatarNotifier() : super(null) {
    loadAvatar();
  }

  Future<void> loadAvatar() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}/user_avatar.png');
      if (await file.exists()) {
        state = file.path;
      } else {
        state = null;
      }
    } catch (e) {
      debugPrint('Errore durante il caricamento dell\'avatar locale: $e');
    }
  }

  Future<void> removeAvatar() async {
    try {
      final dir = await getApplicationSupportDirectory();
      final destinationFile = File('${dir.path}/user_avatar.png');
      if (await destinationFile.exists()) {
        await destinationFile.delete();
      }
      state = null;
    } catch (e) {
      debugPrint('Errore durante la rimozione dell\'avatar: $e');
    }
  }
}

final userAvatarProvider = StateNotifierProvider<UserAvatarNotifier, String?>((ref) {
  return UserAvatarNotifier();
});
