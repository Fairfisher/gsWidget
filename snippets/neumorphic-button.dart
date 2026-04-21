// title: Neumorphic Button
// description: Soft UI button with light and dark shadows creating a pressed-in depth effect.
// category: buttons
// tags: neumorphism, soft-ui, shadow, 3d
// author: Sara Kim
// featured: false
// prompt: Build a neumorphic button in Flutter with soft UI inner and outer shadows creating a pressed-in depth illusion on a neutral background.
// model: claude-opus-4-7
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFE0E5EC),
        body: Center(child: NeumorphicButton()),
      ),
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  const NeumorphicButton({super.key});
  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E5EC),
          borderRadius: BorderRadius.circular(16),
          boxShadow: _pressed
              ? [
                  const BoxShadow(
                    color: Color(0xFFBEC8D9),
                    offset: Offset(4, 4),
                    blurRadius: 10,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-4, -4),
                    blurRadius: 10,
                  ),
                ]
              : [
                  const BoxShadow(
                    color: Color(0xFFBEC8D9),
                    offset: Offset(8, 8),
                    blurRadius: 20,
                  ),
                  const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-8, -8),
                    blurRadius: 20,
                  ),
                ],
        ),
        child: Text(
          'Neu Button',
          style: TextStyle(
            color: _pressed
                ? const Color(0xFF6C63FF)
                : const Color(0xFF4A5568),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}