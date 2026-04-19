// title: Morphing FAB
// description: Floating action button that morphs into an expanded action panel with smooth animation.
// category: buttons
// tags: fab, morph, expand, animation, spring
// author: Chloe Dubois
// featured: true
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(body: MorphingFabDemo()),
    );
  }
}

class MorphingFabDemo extends StatefulWidget {
  const MorphingFabDemo({super.key});
  @override
  State<MorphingFabDemo> createState() => _MorphingFabDemoState();
}

class _MorphingFabDemoState extends State<MorphingFabDemo> with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutCubic);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    const actions = [(Icons.camera_alt_rounded, 'Photo'), (Icons.link_rounded, 'Link'), (Icons.file_copy_rounded, 'File')];
    return Center(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final w = 64 + _anim.value * 196;
          final h = 64 + _anim.value * 140;
          return GestureDetector(
            onTap: _toggle,
            child: Container(
              width: w, height: h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [Color(0xFFFF5F1F), Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(32 - _anim.value * 16),
                boxShadow: [BoxShadow(color: const Color(0xFFFF5F1F).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: _anim.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        ...actions.map((a) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(a.$1, color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Text(a.$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          ]),
                        )),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0, end: 0.625).animate(_ctrl),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}