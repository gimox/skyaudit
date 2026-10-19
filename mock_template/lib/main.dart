import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

import 'core/db/isar_provider.dart';
import 'core/navigation/app_router.dart';
import 'core/services/proxy_service.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/models/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inizializzazione Finestra Desktop
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1360, 800),
      minimumSize: Size(1000, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // 2. Inizializzazione Database Isar Locale
  final dir = await getApplicationSupportDirectory();
  if (!dir.existsSync()) {
    try {
      dir.createSync(recursive: true);
    } catch (_) {}
  }

  final isar = await Isar.open(
    [AppSettingsSchema],
    directory: dir.path,
    inspector: true,
  );

  // 3. Inizializzazione Proxy Service con le impostazioni persistite
  final settings = await isar.appSettings.get(0) ?? AppSettings();
  if (settings.id == 0 && (await isar.appSettings.count()) == 0) {
    await isar.writeTxn(() async => await isar.appSettings.put(settings));
  }
  await ProxyService.initialize(settings);

  // 4. Avvio dell'Applicazione con Riverpod
  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
      ],
      child: const EnterpriseApp(),
    ),
  );
}

class EnterpriseApp extends ConsumerWidget {
  const EnterpriseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Enterprise App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
