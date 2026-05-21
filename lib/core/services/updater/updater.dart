import 'updater_interface.dart';
import 'updater_stub.dart' if (dart.library.io) 'updater_desktop.dart';

AppUpdater? _instance;

AppUpdater get appUpdaterInstance {
  _instance ??= getUpdater();
  return _instance!;
}
