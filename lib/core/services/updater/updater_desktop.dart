import 'dart:io';
import 'package:auto_updater/auto_updater.dart';
import 'updater_interface.dart';

class AppUpdaterImpl implements AppUpdater {
  @override
  Future<void> initialize() async {
    if (Platform.isWindows || Platform.isMacOS) {
      // Define the update feed URL (appcast.xml on GitHub repository)
      const String feedURL = 'https://raw.githubusercontent.com/gimox/skyaudit/main/appcast.xml';
      await autoUpdater.setFeedURL(feedURL);
      await autoUpdater.setScheduledCheckInterval(86400); // Check once a day automatically
    }
  }

  @override
  Future<void> checkForUpdates() async {
    if (Platform.isWindows || Platform.isMacOS) {
      // Triggers the native update check UI (Sparkle / WinSparkle)
      await autoUpdater.checkForUpdates();
    }
  }
}

AppUpdater getUpdater() => AppUpdaterImpl();
