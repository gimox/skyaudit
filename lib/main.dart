import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/core/navigation/app_router.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:travel_check/core/config/app_config.dart';
import 'package:video_player_win/video_player_win_plugin.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:travel_check/core/db/isar_provider.dart';
import 'package:travel_check/features/upload/models/tracciato_contabile.dart';
import 'package:travel_check/features/upload/models/log_history.dart';
import 'package:travel_check/features/settings/models/dictionary.dart';
import 'package:travel_check/features/settings/models/app_settings.dart';
import 'package:travel_check/features/upload/models/estratto_conto.dart';
import 'package:travel_check/features/upload/models/tracciato_sap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [
      TracciatoContabileSchema,
      LogHistorySchema,
      DictionarySchema,
      AppSettingsSchema,
      EstrattoContoSchema,
      TracciatoSapSchema,
    ],
    directory: dir.path,
    inspector: true, // Assicurati che sia su true
  );

  if (!kIsWeb && Platform.isWindows) {
    WindowsVideoPlayer.registerWith();
  }

  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(1000, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: SkyTheme.light,
      routerConfig: router,
    );
  }
}
