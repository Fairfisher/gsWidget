// title: Card Swipe Stack
// description: Tinder-style swipeable card stack with drag, rotation, and dismiss animation.
// category: cards
// tags: swipe, drag, tinder, stack, gesture
// author: Nina Petrov
// featured: true
// prompt: Build a Tinder-style swipeable card stack in Flutter with drag gesture detection, card rotation based on drag offset, and dismiss animation.
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
      home: const Scaffold(body: CardSwipeDemo()),
    );
  }
}

const _cards = [
  (Color(0xFFFF5F1F), Icons.bolt_rounded,         'Lightning Fast'),
  (Color(0xFF7C3AED), Icons.auto_awesome_rounded,  'Magical'),
  (Color(0xFF00D4AA), Icons.eco_rounded,           'Fresh & Clean'),
  (Color(0xFF0088FF), Icons.water_drop_rounded,    'Crystal Clear'),
  (Color(0xFFFF3366), Icons.favorite_rounded,      'Made with Love'),
];

class CardSwipeDemo extends StatefulWidget {
  const CardSwipeDemo({super.key});
  @override
  State<CardSwipeDemo> createState() => _CardSwipeDemoState();
}

class _CardSwipeDemoState extends State<CardSwipeDemo> {
  List<int> _indices = List.generate(_cards.length, (i) => i);

  void _dismiss() => setState(() { if (_indices.isNotEmpty) _indices.removeAt(0); });
  void _reset() => setState(() => _indices = List.generate(_cards.length, (i) => i));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 280, height: 340,
            child: _indices.isEmpty
              ? Center(child: TextButton.icon(onPressed: _reset, icon: const Icon(Icons.refresh_rounded), label: const Text('Reset')))
              : Stack(
                  children: List.generate(_indices.length.clamp(0, 3), (i) => Positioned(
                    bottom: i * 10.0, left: i * 6.0, right: i * 6.0,
                    child: i == 0
                      ? _DraggableCard(index: _indices[i], onDismiss: _dismiss)
                      : _CardFace(index: _indices[i]),
                  )).reversed.toList(),
                ),
          ),
          const SizedBox(height: 12),
          Text('${_indices.length} cards left', style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}

class _DraggableCard extends StatefulWidget {
  final int index;
  final VoidCallback onDismiss;
  const _DraggableCard({required this.index, required this.onDismiss});
  @override
  State<_DraggableCard> createState() => _DraggableCardState();
}

class _DraggableCardState extends State<_DraggableCard> {
  Offset _drag = Offset.zero;
  void _onPanUpdate(DragUpdateDetails d) => setState(() => _drag += d.delta);
  void _onPanEnd(DragEndDetails d) {
    if (_drag.dx.abs() > 100) { widget.onDismiss(); } else { setState(() => _drag = Offset.zero); }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform(
        transform: Matrix4.identity()..translate(_drag.dx, _drag.dy)..rotateZ(_drag.dx / 400),
        alignment: Alignment.bottomCenter,
        child: _CardFace(index: widget.index),
      ),
    );
  }
}

class _CardFace extends StatelessWidget {
  final int index;
  const _CardFace({required this.index});
  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _cards[index % _cards.length];
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color, color.withOpacity(0.6)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}