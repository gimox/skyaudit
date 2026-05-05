import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_check/features/splash/splash_screen.dart';
import 'package:travel_check/features/home/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final bool isDesktop =
      !kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux);

  return GoRouter(
    initialLocation: isDesktop ? '/' : '/home',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
  );
});
