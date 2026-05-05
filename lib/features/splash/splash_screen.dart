import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:travel_check/core/config/app_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _setupWindow();
    _initializeVideo();

    // Timer di 3 secondi per garantire il passaggio alla home veloce
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  Future<void> _setupWindow() async {
    if (!kIsWeb &&
        (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
      try {
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
        await windowManager.setSize(const Size(640, 480));
        await windowManager.setResizable(false);
        await windowManager.center();
      } catch (e) {
        debugPrint("Errore configurazione finestra: $e");
      }
    }
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/video/intro.mp4');

    try {
      await _controller.initialize();
      if (mounted) {
        setState(() {});
        _controller.play();

        _controller.addListener(() {
          if (mounted &&
              _controller.value.position >= _controller.value.duration) {
            _navigateToHome();
          }
        });
      }
    } catch (e) {
      debugPrint("Errore caricamento video: $e");
      if (mounted) {
        setState(() {
          _hasError = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _navigateToHome();
        });
      }
    }
  }

  void _navigateToHome() {
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/watermark_video.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _hasError
            ? _buildErrorContent()
            : Stack(
                children: [
                  if (_controller.value.isInitialized)
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    )
                  else
                    _buildLoadingPlaceholder(),

                  _buildOverlayUI(),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Text(
        AppConfig.appName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo in trasparenza invece di uno schermo nero
          Image.asset(
            'assets/images/travel_logo.png',
            width: 140,
            color: Colors.white12,
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              color: Colors.white24,
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayUI() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 60, bottom: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(120),
                  Colors.black.withAlpha(0),
                ],
              ),
            ),
            child: Center(
              child: Text(
                AppConfig.appName.toUpperCase().split('').join(' '),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 4.0,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(bottom: 60, top: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withAlpha(120),
                  Colors.black.withAlpha(0),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "INIZIALIZZAZIONE",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 120,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: const ClipRRect(
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
