// title: Wave Loading Animation
// description: Animated wave using CustomPainter and sine wave math — no packages needed.
// category: animations
// tags: wave, loading, custom-paint, sine
// author: Yuki Tanaka
// featured: true
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: WaveAnimation()),
      ),
    );
  }
}

class WaveAnimation extends StatefulWidget {
  const WaveAnimation({super.key});
  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: const Size(300, 100),
        painter: _WavePainter(phase: _ctrl.value * 2 * math.pi),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double phase;
  const _WavePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final paint2 = Paint()
      ..color = const Color(0xFF00BCD4).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    _drawWave(canvas, size, paint1, phase, 20);
    _drawWave(canvas, size, paint2, phase + math.pi / 2, 15);
  }

  void _drawWave(
      Canvas canvas, Size size, Paint paint, double p, double amp) {
    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double x = 0; x <= size.width; x++) {
      final y = size.height / 2 +
          amp * math.sin((x / size.width * 4 * math.pi) + p);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.phase != phase;
}