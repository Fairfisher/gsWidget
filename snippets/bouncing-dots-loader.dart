// title: Bouncing Dots Loader
// description: Three dots that bounce sequentially using staggered animations.
// category: loaders
// tags: dots, bounce, loading, animated
// author: Tom Baker
// featured: false
// likes: 156
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: BouncingDots()),
      ),
    );
  }
}

class BouncingDots extends StatefulWidget {
  const BouncingDots({super.key});
  @override
  State<BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<BouncingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
    _anims = List.generate(3, (i) {
      final start = i / 4;
      final end = start + 0.5;
      return Tween<double>(begin: 0, end: -20).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start.clamp(0, 1), end.clamp(0, 1),
              curve: Curves.easeInOut),
        ),
      );
    });
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
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          3,
          (i) => Transform.translate(
            offset: Offset(0, _anims[i].value),
            child: Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}