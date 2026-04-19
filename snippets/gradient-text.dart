// title: Gradient Text
// description: Text with a linear gradient using ShaderMask — pure Flutter, no packages.
// category: typography
// tags: gradient, text, shader, colorful
// author: Aisha Johnson
// featured: false
// likes: 201
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GradientText(
                'Flutter',
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900),
                gradient: LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00BCD4)],
                ),
              ),
              SizedBox(height: 12),
              GradientText(
                'is Beautiful',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
                gradient: LinearGradient(
                  colors: [Color(0xFFFF6584), Color(0xFFFFD93D)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;

  const GradientText(
    this.text, {
    super.key,
    required this.style,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}