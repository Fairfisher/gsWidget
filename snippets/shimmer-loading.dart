// title: Shimmer Loading Card
// description: Skeleton loading placeholder with shimmer animation — built from scratch, no shimmer package.
// category: loaders
// tags: shimmer, skeleton, loading, placeholder
// author: Priya Sharma
// featured: true
// likes: 634
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerCard(),
              SizedBox(height: 16),
              ShimmerCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatefulWidget {
  const ShimmerCard({super.key});
  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _anim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
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
      builder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                Color(0xFFE0E0E0),
                Color(0xFFF5F5F5),
                Color(0xFFE0E0E0),
              ],
              stops: [
                (_anim.value - 0.3).clamp(0.0, 1.0),
                _anim.value.clamp(0.0, 1.0),
                (_anim.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _Box(width: 48, height: 48, radius: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Box(height: 12, radius: 4),
                          const SizedBox(height: 8),
                          _Box(height: 12, width: 120, radius: 4),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Box(height: 12, radius: 4),
                const SizedBox(height: 8),
                _Box(height: 12, radius: 4),
                const SizedBox(height: 8),
                _Box(height: 12, width: 180, radius: 4),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const _Box({this.width, required this.height, this.radius = 0});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}