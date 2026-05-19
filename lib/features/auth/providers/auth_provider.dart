import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/config/auth_config.dart';
import '../models/auth_state.dart';
import 'secure_storage_service.dart';
import 'user_avatar_provider.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._secureStorage, this._ref) : super(AuthState.checking()) {
    _tryAutoLogin();
  }

  final SecureStorageService _secureStorage;
  final Ref _ref;
  oauth2.Client? _oauthClient;

  String? get accessToken => _oauthClient?.credentials.accessToken;

  Future<String?> getValidAccessToken() async {
    if (_oauthClient == null) return null;
    var credentials = _oauthClient!.credentials;
    if (credentials.isExpired && credentials.canRefresh) {
      try {
        credentials = await credentials.refresh(
          identifier: AuthConfig.clientId,
          secret: null,
        );
        _oauthClient = oauth2.Client(
          credentials,
          identifier: AuthConfig.clientId,
          secret: null,
        );
        await _secureStorage.saveCredentials(credentials.toJson());
      } catch (e) {
        debugPrint('Rinnovo automatico token fallito: $e');
        return null;
      }
    }
    return _oauthClient?.credentials.accessToken;
  }

  // Verifiche all'avvio in background (Non-bloccante)
  Future<void> _tryAutoLogin() async {
    try {
      final savedJson = await _secureStorage.readCredentials();
      if (savedJson != null) {
        var credentials = oauth2.Credentials.fromJson(savedJson);

        // Esegue il refresh preventivo in background se scaduto o in scadenza
        if (credentials.isExpired && credentials.canRefresh) {
          credentials = await credentials.refresh(
            identifier: AuthConfig.clientId,
            secret: null,
          );
          await _secureStorage.saveCredentials(credentials.toJson());
        }

        // Inizializza il client OAuth2.
        _oauthClient = oauth2.Client(
          credentials,
          identifier: AuthConfig.clientId,
          secret: null,
        );

        final idToken = _oauthClient!.credentials.idToken;
        final decoded = _decodeJwt(idToken);
        final name = decoded?['name'] as String? ?? 'Dipendente TIM';
        final email = decoded?['preferred_username'] as String? ?? decoded?['email'] as String? ?? 'utente@tim.it';

        state = AuthState.authenticated(userName: name, userEmail: email);

        // Se non c'è la foto profilo in locale, prova a riscaricarla da Microsoft Graph in background
        final dir = await getApplicationSupportDirectory();
        final avatarFile = File('${dir.path}/user_avatar.png');
        if (!avatarFile.existsSync()) {
          _fetchAndSaveMicrosoftGraphPhoto(credentials.accessToken);
        }
        return;
      }
    } catch (e) {
      // Ignora l'errore del login automatico per rimanere in Sola Lettura senza interrompere l'utente
      debugPrint('AutoLogin Entra ID fallito o token scaduto non rinnovabile: $e');
    }
    state = AuthState.unauthenticated();
  }

  // Flusso di Login Attivo (PKCE)
  Future<void> login() async {
    state = AuthState.authenticating();
    try {
      final authEndpoint = Uri.parse(AuthConfig.authorizationEndpoint);
      final tokenEndpoint = Uri.parse(AuthConfig.tokenEndpoint);

      // Crea la richiesta di concessione del codice con PKCE (Proof Key for Code Exchange)
      final grant = oauth2.AuthorizationCodeGrant(
        AuthConfig.clientId,
        authEndpoint,
        tokenEndpoint,
      );

      final redirectUriStr = kIsWeb ? AuthConfig.webRedirectUrl : AuthConfig.desktopRedirectUrl;
      final redirectUri = Uri.parse(redirectUriStr);

      final authorizationUrl = grant.getAuthorizationUrl(
        redirectUri,
        scopes: AuthConfig.scopes,
      );

      // Definisce lo schema di callback richiesto da flutter_web_auth_2
      final callbackScheme = kIsWeb ? 'http' : AuthConfig.desktopCallbackScheme;

      // Apre il browser di sistema o popup web
      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl.toString(),
        callbackUrlScheme: callbackScheme,
      );

      // Riceve il codice di reindirizzamento e finalizza lo scambio
      final responseUri = Uri.parse(result);
      _oauthClient = await grant.handleAuthorizationResponse(responseUri.queryParameters);

      // Salva le nuove credenziali in modo permanente e sicuro
      await _secureStorage.saveCredentials(_oauthClient!.credentials.toJson());

      // Estrae le informazioni utente
      final idToken = _oauthClient!.credentials.idToken;
      final decoded = _decodeJwt(idToken);
      final name = decoded?['name'] as String? ?? 'Dipendente TIM';
      final email = decoded?['preferred_username'] as String? ?? decoded?['email'] as String? ?? 'utente@tim.it';

      // Scarica ed imposta la foto profilo dall'API Microsoft Graph
      await _fetchAndSaveMicrosoftGraphPhoto(_oauthClient!.credentials.accessToken);

      state = AuthState.authenticated(userName: name, userEmail: email);
    } catch (e) {
      state = AuthState.error(e.toString());
      // Rimane scollegato in caso di errore
      Future.delayed(const Duration(seconds: 4), () {
        if (state.status == AuthStatus.error) {
          state = AuthState.unauthenticated();
        }
      });
    }
  }

  // Disconnessione
  Future<void> logout() async {
    try {
      await _secureStorage.clearCredentials();
      _oauthClient = null;
      // Rimuove l'avatar e notifica lo stato
      await _ref.read(userAvatarProvider.notifier).removeAvatar();
    } catch (_) {}
    state = AuthState.unauthenticated();
  }

  // Scarica la foto profilo in formato nativo utilizzando HttpClient di dart:io
  Future<void> _fetchAndSaveMicrosoftGraphPhoto(String accessToken) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://graph.microsoft.com/v1.0/me/photo/\$value'));
      request.headers.set('Authorization', 'Bearer $accessToken');
      
      final response = await request.close();
      if (response.statusCode == 200) {
        final dir = await getApplicationSupportDirectory();
        final destinationFile = File('${dir.path}/user_avatar.png');
        
        if (destinationFile.existsSync()) {
          destinationFile.deleteSync();
        }
        
        final bytes = await response.fold<List<int>>([], (prev, elem) => prev..addAll(elem));
        await destinationFile.writeAsBytes(bytes);
        
        // Notifica il caricamento del nuovo avatar al provider
        await _ref.read(userAvatarProvider.notifier).loadAvatar();
        debugPrint('Foto profilo Microsoft caricata con successo!');
      } else {
        debugPrint('Microsoft Graph Foto Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Errore durante il download dell\'avatar Microsoft Graph: $e');
    }
  }

  // Helper per decodificare in sicurezza il token JWT OIDC
  Map<String, dynamic>? _decodeJwt(String? token) {
    if (token == null) return null;
    final parts = token.split('.');
    if (parts.length != 3) return null;
    try {
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      return json.decode(resp) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

// Provider Riverpod globale per l'autenticazione
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthNotifier(secureStorage, ref);
});
