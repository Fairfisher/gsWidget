// title: Liquid Progress Bar
// description: Animated progress bar with a wave/liquid fill effect using CustomPainter.
// category: loaders
// tags: progress, wave, liquid, animation, custom-paint
// author: Leo Hartmann
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
      theme: ThemeData.dark(),
      home: const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: LiquidProgressDemo(),
          ),
        ),
      ),
    );
  }
}

class LiquidProgressDemo extends StatefulWidget {
  const LiquidProgressDemo({super.key});
  @override
  State<LiquidProgressDemo> createState() => _State();
}

class _State extends State<LiquidProgressDemo> {
  double _p = 0.65;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LiquidProgressBar(progress: _p,        color: const Color(0xFFFF5F1F)),
        const SizedBox(height: 16),
        LiquidProgressBar(progress: _p * 0.7,  color: const Color(0xFF7C3AED)),
        const SizedBox(height: 16),
        LiquidProgressBar(progress: _p * 0.9,  color: const Color(0xFF00D4AA)),
        const SizedBox(height: 32),
        Slider(value: _p, onChanged: (v) => setState(() => _p = v), activeColor: const Color(0xFFFF5F1F)),
      ],
    );
  }
}

class LiquidProgressBar extends StatefulWidget {
  final double progress;
  final Color color;
  const LiquidProgressBar({super.key, required this.progress, required this.color});
  @override
  State<LiquidProgressBar> createState() => _LiquidState();
}

class _LiquidState extends State<LiquidProgressBar> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        size: const Size(double.infinity, 28),
        painter: _LiquidPainter(progress: widget.progress, phase: _ctrl.value * 2 * math.pi, color: widget.color),
      ),
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double progress, phase;
  final Color color;
  const _LiquidPainter({required this.progress, required this.phase, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(14));
    canvas.drawRRect(rrect, Paint()..color = color.withOpacity(0.12));
    final fillW = size.width * progress.clamp(0.0, 1.0);
    final path = Path()..moveTo(0, size.height);
    for (double x = 0; x <= fillW; x++) {
      final y = size.height / 2 + math.sin((x / size.width * 3 * math.pi) + phase) * 3 - (size.height * (progress - 0.5));
      x == 0 ? path.lineTo(0, y) : path.lineTo(x, y);
    }
    path..lineTo(fillW, size.height)..close();
    canvas.save();
    canvas.clipPath(Path()..addRRect(rrect));
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }
  @override
  bool shouldRepaint(_LiquidPainter old) => old.progress != progress || old.phase != phase;
}