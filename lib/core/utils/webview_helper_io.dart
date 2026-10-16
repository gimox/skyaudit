import 'package:desktop_webview_window/desktop_webview_window.dart';

/// Intercepts secondary desktop_webview_window titlebar process args on Windows/Linux.
bool runWebViewTitleBar(List<String> args) {
  return runWebViewTitleBarWidget(args);
}
