// title: Animated Gradient Button
// description: Button with a continuously shifting gradient background animation.
// category: buttons
// tags: gradient, animation, custom
// author: Liam Torres
// featured: true
// likes: 274
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: AnimatedGradientButton()),
      ),
    );
  }
}

class AnimatedGradientButton extends StatefulWidget {
  const AnimatedGradientButton({super.key});
  @override
  State<AnimatedGradientButton> createState() => _State();
}

class _State extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.lerp(
                Alignment.topLeft,
                Alignment.bottomLeft,
                _anim.value,
              )!,
              end: Alignment.lerp(
                Alignment.bottomRight,
                Alignment.topRight,
                _anim.value,
              )!,
              colors: const [
                Color(0xFF6C63FF),
                Color(0xFFFF6584),
                Color(0xFF00BCD4),
              ],
            ),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 40, vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: const Text(
              'Gradient Button',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}