import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/core/navigation/app_router.dart';
import 'package:travel_check/core/theme/app_theme.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:travel_check/core/config/app_config.dart';
import 'package:travel_check/core/services/updater/updater.dart';
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
import 'package:travel_check/features/upload/models/estratto_amex.dart';
import 'package:travel_check/features/upload/models/anagrafica.dart';
import 'package:travel_check/features/upload/models/scarti_ec_sap.dart';
import 'package:travel_check/features/upload/models/trasferte_sap.dart';
import 'package:travel_check/core/services/proxy_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione Isar con pulizia una tantum per migrazione schema
  final dir = await getApplicationDocumentsDirectory();
  final resetFile = File('${dir.path}/.isar_reset_v3');
  if (!resetFile.existsSync()) {
    final files = [
      File('${dir.path}/default.isar'),
      File('${dir.path}/default.isar.lock'),
    ];
    for (final f in files) {
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (e) {
          debugPrint('Errore rimozione file isar per migrazione: $e');
        }
      }
    }
    try {
      resetFile.createSync();
    } catch (_) {}
  }

  final isar = await Isar.open(
    [
      TracciatoContabileSchema,
      LogHistorySchema,
      DictionarySchema,
      AppSettingsSchema,
      EstrattoContoSchema,
      TracciatoSapSchema,
      EstrattoAmexSchema,
      AnagraficaSchema,
      ScartiEcSapSchema,
      TrasferteSapSchema,
    ],
    directory: dir.path,
    inspector: true, // Assicurati che sia su true
  );

  // Inizializza la rilevazione e l'override del proxy leggendo i parametri da Isar
  final settings = isar.appSettings.getSync(0) ?? AppSettings();
  if (settings.clearBeforeSync) {
    settings.clearBeforeSync = false;
    await isar.writeTxn(() async {
      await isar.appSettings.put(settings);
    });
  }
  await ProxyService.initialize(settings);

  if (!kIsWeb && Platform.isWindows) {
    WindowsVideoPlayer.registerWith();
  }

  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    await appUpdaterInstance.initialize();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(1000, 700),
      center: true,
      backgroundColor: Colors.white,
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
