abstract class AppUpdater {
  Future<void> initialize();
  Future<void> checkForUpdates();
  void setEventCallback(void Function(String event, {String? message})? callback);
}
