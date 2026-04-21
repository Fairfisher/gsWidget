// title: Neon Border Card
// description: Card with an animated rotating neon gradient border using CustomPainter.
// category: cards
// tags: neon, border, gradient, animation, glow
// author: Sam Rivera
// featured: true
// prompt: Build a Flutter card with an animated rotating neon gradient border using CustomPainter. Glowing neon effect on a dark background.
// model: claude-opus-4-7
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
      home: const Scaffold(body: Center(child: NeonBorderCard())),
    );
  }
}

class NeonBorderCard extends StatefulWidget {
  const NeonBorderCard({super.key});
  @override
  State<NeonBorderCard> createState() => _NeonBorderCardState();
}

class _NeonBorderCardState extends State<NeonBorderCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _NeonBorderPainter(angle: _ctrl.value * 2 * math.pi),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(28),
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: const Color(0xFF0F0F1E), borderRadius: BorderRadius.circular(18)),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bolt_rounded, color: Color(0xFFFF5F1F), size: 32),
              SizedBox(height: 12),
              Text('Neon Card', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              SizedBox(height: 6),
              Text('Animated gradient border using CustomPainter with a rotating sweep gradient.', style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeonBorderPainter extends CustomPainter {
  final double angle;
  const _NeonBorderPainter({required this.angle});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(21));
    final gradient = SweepGradient(startAngle: angle, endAngle: angle + 2 * math.pi,
      colors: const [Color(0xFFFF5F1F), Color(0xFF7C3AED), Color(0xFF00D4AA), Color(0xFFFF5F1F)]);
    canvas.drawRRect(rrect, Paint()..shader = gradient.createShader(rect)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    canvas.drawRRect(rrect, Paint()..shader = gradient.createShader(rect)..style = PaintingStyle.stroke..strokeWidth = 6.5..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
  }
  @override
  bool shouldRepaint(_NeonBorderPainter old) => old.angle != angle;
}