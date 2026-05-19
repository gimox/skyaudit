import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    mOptions: MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock,
      usesDataProtectionKeychain: true,
    ),
  );

  static const _keyCredentials = 'entra_id_credentials';
  bool _useFallback = false;
  String? _inMemoryFallback;

  Future<File> _getFallbackFile() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/.auth_credentials_fallback.dat');
  }

  Future<void> saveCredentials(String json) async {
    if (_useFallback) {
      await _saveFallback(json);
      return;
    }

    try {
      await _storage.write(key: _keyCredentials, value: json);
    } catch (e) {
      debugPrint('Errore durante la scrittura su Keychain, attivo il fallback su file: $e');
      _useFallback = true;
      await _saveFallback(json);
    }
  }

  Future<String?> readCredentials() async {
    // Se abbiamo già rilevato di dover usare il fallback, lo usiamo subito
    if (_useFallback) {
      return await _readFallback();
    }

    try {
      final value = await _storage.read(key: _keyCredentials);
      return value;
    } catch (e) {
      debugPrint('Errore durante la lettura da Keychain, attivo il fallback su file: $e');
      _useFallback = true;
      return await _readFallback();
    }
  }

  Future<void> clearCredentials() async {
    _inMemoryFallback = null;
    try {
      final file = await _getFallbackFile();
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}

    try {
      await _storage.delete(key: _keyCredentials);
    } catch (_) {}
  }

  Future<void> _saveFallback(String json) async {
    _inMemoryFallback = json;
    try {
      final file = await _getFallbackFile();
      await file.writeAsString(json);
    } catch (e) {
      debugPrint('Impossibile scrivere il file di fallback: $e');
    }
  }

  Future<String?> _readFallback() async {
    if (_inMemoryFallback != null) return _inMemoryFallback;
    try {
      final file = await _getFallbackFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        _inMemoryFallback = content;
        return content;
      }
    } catch (e) {
      debugPrint('Impossibile leggere il file di fallback: $e');
    }
    return null;
  }
}

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
