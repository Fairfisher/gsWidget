// title: Circular Countdown Timer
// description: Animated circular progress timer with custom paint arc and color transitions.
// category: animations
// tags: timer, countdown, circular, custom-paint, animation
// author: Ben Fischer
// featured: false
// likes: 298
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
      home: const Scaffold(body: Center(child: CountdownTimer(seconds: 30))),
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final int seconds;
  const CountdownTimer({super.key, required this.seconds});
  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(seconds: widget.seconds));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    if (_running) { _ctrl.stop(); }
    else if (_ctrl.value >= 1.0) { _ctrl.reset(); _ctrl.forward(); }
    else { _ctrl.forward(); }
    setState(() => _running = !_running);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final remaining = ((1 - _ctrl.value) * widget.seconds).ceil();
        final progress = 1 - _ctrl.value;
        final color = Color.lerp(const Color(0xFF00D4AA), const Color(0xFFFF5F1F), _ctrl.value)!;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200, height: 200,
              child: CustomPaint(
                painter: _ArcPainter(progress: progress, color: color),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$remaining', style: TextStyle(fontSize: 52, fontWeight: FontWeight.w800, color: color)),
                      const Text('seconds', style: TextStyle(fontSize: 12, color: Colors.white38)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _toggle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text(_running ? 'Pause' : (_ctrl.value >= 1.0 ? 'Restart' : 'Start'), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  const _ArcPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;
    canvas.drawCircle(center, radius, Paint()..color = color.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 10);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false,
      Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round);
  }
  @override
  bool shouldRepaint(_ArcPainter old) => old.progress != progress || old.color != color;
}