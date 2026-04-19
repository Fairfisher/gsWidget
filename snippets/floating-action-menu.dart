import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const FloatingMenuDemo(),
    );
  }
}

const _actions = [
  (Icons.camera_alt_rounded,  'Camera',  Color(0xFF00D4AA)),
  (Icons.image_rounded,        'Gallery', Color(0xFF7C3AED)),
  (Icons.mic_rounded,          'Audio',   Color(0xFF0088FF)),
  (Icons.attach_file_rounded,  'File',    Color(0xFFFFD93D)),
];

class FloatingMenuDemo extends StatefulWidget {
  const FloatingMenuDemo({super.key});
  @override
  State<FloatingMenuDemo> createState() => _FloatingMenuDemoState();
}

class _FloatingMenuDemoState extends State<FloatingMenuDemo> with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('Tap the + button', style: TextStyle(color: Colors.white38))),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ..._actions.asMap().entries.map((e) {
            final delay = e.key / _actions.length;
            final anim = CurvedAnimation(
              parent: _ctrl,
              curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0), curve: Curves.elasticOut),
            );
            return AnimatedBuilder(
              animation: anim,
              builder: (_, __) => Transform.scale(
                scale: anim.value,
                alignment: Alignment.centerRight,
                child: Opacity(
                  opacity: anim.value.clamp(0.0, 1.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: e.value.$3.withOpacity(0.3)),
                          ),
                          child: Text(e.value.$2, style: TextStyle(color: e.value.$3, fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 10),
                        FloatingActionButton.small(
                          heroTag: 'fab_${e.key}',
                          onPressed: _toggle,
                          backgroundColor: e.value.$3,
                          child: Icon(e.value.$1, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          FloatingActionButton(
            heroTag: 'fab_main',
            onPressed: _toggle,
            backgroundColor: const Color(0xFFFF5F1F),
            child: AnimatedRotation(
              turns: _open ? 0.125 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.add_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}