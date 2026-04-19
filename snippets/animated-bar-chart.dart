import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: BarChart(),
          ),
        ),
      ),
    );
  }
}

class BarChart extends StatefulWidget {
  const BarChart({super.key});
  @override
  State<BarChart> createState() => _BarChartState();
}

class _BarChartState extends State<BarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  final _data = [
    ('Mon', 0.6, const Color(0xFF6C63FF)),
    ('Tue', 0.8, const Color(0xFF00BCD4)),
    ('Wed', 0.5, const Color(0xFFFF6584)),
    ('Thu', 0.9, const Color(0xFFFFD93D)),
    ('Fri', 0.7, const Color(0xFF55EFC4)),
    ('Sat', 0.4, const Color(0xFFFF6B6B)),
    ('Sun', 0.65, const Color(0xFFA29BFE)),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => CustomPaint(
        size: const Size(double.infinity, 220),
        painter: _BarChartPainter(data: _data, progress: _anim.value),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<(String, double, Color)> data;
  final double progress;

  const _BarChartPainter({required this.data, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final barW = size.width / (data.length * 2);
    final maxH = size.height - 40;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      final (label, value, color) = data[i];
      final x = (i * 2 + 0.5) * barW;
      final barH = value * maxH * progress;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, maxH - barH, barW, barH),
        const Radius.circular(6),
      );

      canvas.drawRRect(rect, Paint()..color = color);

      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(color: Colors.grey, fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barW - textPainter.width) / 2, maxH + 8),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.progress != progress;
}