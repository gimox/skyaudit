import 'dart:io';
import 'package:flutter/foundation.dart';

class AuthConfig {
  // Configured via compile-time environment variables or using standard placeholders.
  static const String tenantId = String.fromEnvironment(
    'AZURE_TENANT_ID',
    defaultValue: 'YOUR_TENANT_ID',
  );

  static const String clientId = String.fromEnvironment(
    'AZURE_CLIENT_ID',
    defaultValue: 'YOUR_CLIENT_ID',
  );

  static String get authorizationEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/authorize';

  static String get tokenEndpoint =>
      'https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token';

  // Desktop configuration (macOS & Windows loopback)
  static const int desktopPort = 3000;
  
  static String get desktopRedirectUrl {
    if (!kIsWeb && Platform.isMacOS) {
      return 'sky-audit://callback';
    }
    return 'http://localhost:$desktopPort/callback';
  }

  static String get desktopCallbackScheme {
    if (!kIsWeb && Platform.isMacOS) {
      return 'sky-audit';
    }
    return 'http';
  }

  // Web configuration (Single-page app redirect callback page)
  static const String webRedirectUrl = String.fromEnvironment(
    'AZURE_WEB_REDIRECT_URL',
    defaultValue: 'YOUR_WEB_REDIRECT_URL',
  );

  // Scopes requested (offline_access is critical to retrieve the refresh_token for session persistence)
  static const List<String> scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
    'User.Read',
    'Sites.Read.All',
    'Files.Read.All',
  ];
}
