import 'dart:io';
import 'package:auto_updater/auto_updater.dart';
import 'updater_interface.dart';

class AppUpdaterImpl implements AppUpdater, UpdaterListener {
  void Function(String event, {String? message})? _callback;

  @override
  Future<void> initialize() async {
    if (Platform.isWindows || Platform.isMacOS) {
      // Define the update feed URL (appcast.xml on GitHub repository)
      const String feedURL = 'https://raw.githubusercontent.com/gimox/skyaudit/main/appcast.xml';
      await autoUpdater.setFeedURL(feedURL);
      await autoUpdater.setScheduledCheckInterval(86400); // Check once a day automatically
      autoUpdater.addListener(this);
    }
  }

  @override
  Future<void> checkForUpdates() async {
    if (Platform.isWindows || Platform.isMacOS) {
      // Triggers the native update check UI (Sparkle / WinSparkle)
      await autoUpdater.checkForUpdates();
    }
  }

  @override
  void setEventCallback(void Function(String event, {String? message})? callback) {
    _callback = callback;
  }

  @override
  void onUpdaterError(UpdaterError? error) {
    _callback?.call('error', message: error?.message);
  }

  @override
  void onUpdaterCheckingForUpdate(Appcast? appcast) {
    _callback?.call('checkingForUpdate');
  }

  @override
  void onUpdaterUpdateAvailable(AppcastItem? appcastItem) {
    _callback?.call('updateAvailable', message: appcastItem?.versionString);
  }

  @override
  void onUpdaterUpdateNotAvailable(UpdaterError? error) {
    _callback?.call('updateNotAvailable', message: error?.message);
  }

  @override
  void onUpdaterUpdateDownloaded(AppcastItem? appcastItem) {
    _callback?.call('updateDownloaded', message: appcastItem?.versionString);
  }

  @override
  void onUpdaterBeforeQuitForUpdate(AppcastItem? appcastItem) {
    _callback?.call('beforeQuitForUpdate');
  }
}

AppUpdater getUpdater() => AppUpdaterImpl();
