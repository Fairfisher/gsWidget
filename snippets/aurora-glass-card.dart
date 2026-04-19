// title: Aurora Glass Card
// description: Floating glass card with animated aurora blobs in purple, cyan and pink. BackdropFilter blur over morphing radial gradients.
// category: cards
// tags: glass, aurora, blur, animation, gradient, dark
// author: gsWidget
// featured: true
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFF060612),
        body: Center(child: AuroraGlassCard()),
      ),
    );
  }
}

class AuroraGlassCard extends StatefulWidget {
  const AuroraGlassCard({super.key});
  @override
  State<AuroraGlassCard> createState() => _AuroraGlassCardState();
}

class _AuroraGlassCardState extends State<AuroraGlassCard>
    with TickerProviderStateMixin {
  late final AnimationController _a =
      AnimationController(vsync: this, duration: const Duration(seconds: 9))
        ..repeat(reverse: true);
  late final AnimationController _b =
      AnimationController(vsync: this, duration: const Duration(seconds: 13))
        ..repeat(reverse: true);
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 7))
        ..repeat(reverse: true);
  late final AnimationController _float =
      AnimationController(vsync: this, duration: const Duration(seconds: 5))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _c.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_a, _b, _c, _float]),
      builder: (context, _) {
        final dy = -14.0 * sin(_float.value * pi);
        return Transform.translate(
          offset: Offset(0, dy),
          child: SizedBox(
            width: 360,
            height: 220,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _blob(
                  left: -50 + 100 * _a.value,
                  top: -40 + 70 * sin(_a.value * pi),
                  size: 200,
                  color: const Color(0xFF7C3AED),
                  opacity: 0.55,
                  blur: 70,
                ),
                _blob(
                  right: -30 + 80 * (1 - _b.value),
                  bottom: -30 + 60 * _b.value,
                  size: 170,
                  color: const Color(0xFF06B6D4),
                  opacity: 0.5,
                  blur: 65,
                ),
                _blob(
                  left: 90 + 50 * sin(_c.value * pi),
                  top: -50 + 40 * _c.value,
                  size: 140,
                  color: const Color(0xFFEC4899),
                  opacity: 0.4,
                  blur: 60,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _avatar(),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Aurora Glass Card',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.92),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Glassmorphism · Flutter',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.35),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              _chip('Blur'),
                              const SizedBox(width: 6),
                              _chip('Animate'),
                              const SizedBox(width: 6),
                              _chip('Glass'),
                              const Spacer(),
                              _copyBtn(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _blob({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
    required double opacity,
    required double blur,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(opacity),
              blurRadius: blur,
              spreadRadius: size * 0.25,
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar() {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
        ),
      ),
      child: const Icon(Icons.auto_awesome_rounded,
          color: Colors.white, size: 20),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _copyBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Text(
        'Use it',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
