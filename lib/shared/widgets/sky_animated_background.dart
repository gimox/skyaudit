import 'package:flutter/material.dart';
import 'dart:math' as math;

class SkyAnimatedBackground extends StatefulWidget {
  const SkyAnimatedBackground({super.key});

  @override
  State<SkyAnimatedBackground> createState() => _SkyAnimatedBackgroundState();
}

class _SkyAnimatedBackgroundState extends State<SkyAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 40),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: TravelPatternPainter(progress: _controller.value),
          child: Container(),
        );
      },
    );
  }
}

class TravelPatternPainter extends CustomPainter {
  final double progress;
  TravelPatternPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final icons = [
      Icons.flight_takeoff,
      Icons.description_outlined,
      Icons.analytics_outlined,
      Icons.public,
      Icons.receipt_long_outlined,
      Icons.map_outlined,
    ];

    final random = math.Random(42); // Seed fisso per pattern costante

    for (int i = 0; i < 15; i++) {
      final double xBase = random.nextDouble() * size.width;
      final double yBase = random.nextDouble() * size.height;
      
      // Calcolo del movimento lento in base al progress
      final double x = (xBase + (progress * 50 * (i % 2 == 0 ? 1 : -1))) % size.width;
      final double y = (yBase + (progress * 30)) % size.height;
      
      final icon = icons[i % icons.length];
      
      TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 40 + (random.nextDouble() * 40),
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.blue.withAlpha(8),
        ),
      );
      textPainter.layout();
      
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 0.1 * (i % 2 == 0 ? 1 : -1));
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(TravelPatternPainter oldDelegate) => true;
}
