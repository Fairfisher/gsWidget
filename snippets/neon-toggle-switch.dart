// title: Neon Toggle Switch
// description: Custom toggle switch with electric neon glow effect and smooth thumb animation.
// category: inputs
// tags: toggle, switch, neon, glow, custom
// author: Mia Torres
// featured: true
// prompt: Build a custom Flutter toggle switch with an electric neon glow effect and smooth animated thumb transition on toggle.
// model: claude-opus-4-7
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(body: Center(child: NeonToggleDemo())),
    );
  }
}

class NeonToggleDemo extends StatefulWidget {
  const NeonToggleDemo({super.key});
  @override
  State<NeonToggleDemo> createState() => _NeonToggleDemoState();
}

class _NeonToggleDemoState extends State<NeonToggleDemo> {
  bool _on = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        NeonToggle(value: _on, onChanged: (v) => setState(() => _on = v), activeColor: const Color(0xFFFF5F1F)),
        const SizedBox(height: 24),
        NeonToggle(value: !_on, onChanged: (v) => setState(() => _on = !v), activeColor: const Color(0xFF7C3AED)),
        const SizedBox(height: 24),
        NeonToggle(value: _on, onChanged: (v) => setState(() => _on = v), activeColor: const Color(0xFF00D4AA)),
      ],
    );
  }
}

class NeonToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  const NeonToggle({super.key, required this.value, required this.onChanged, this.activeColor = const Color(0xFFFF5F1F)});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 64, height: 34,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17),
          color: value ? activeColor.withOpacity(0.15) : const Color(0xFF1A1A2E),
          border: Border.all(color: value ? activeColor : const Color(0xFF333355), width: 1.5),
          boxShadow: value ? [BoxShadow(color: activeColor.withOpacity(0.4), blurRadius: 12, spreadRadius: 1)] : [],
        ),
        child: Stack(children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? activeColor : const Color(0xFF555577),
                  boxShadow: value ? [BoxShadow(color: activeColor.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)] : [],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}