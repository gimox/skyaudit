import 'updater_interface.dart';

class AppUpdaterImpl implements AppUpdater {
  @override
  Future<void> initialize() async {
    // No-op on Web/other platforms
  }

  @override
  Future<void> checkForUpdates() async {
    // No-op on Web/other platforms
  }

  @override
  void setEventCallback(void Function(String event, {String? message})? callback) {
    // No-op on Web/other platforms
  }
}

AppUpdater getUpdater() => AppUpdaterImpl();
