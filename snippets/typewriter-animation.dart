// title: Typewriter Animation
// description: Typewriter effect with blinking cursor using AnimationController.
// category: animations
// tags: typewriter, text, animation, cursor
// author: Emma Wilson
// featured: false
// prompt: Build a Flutter typewriter text animation with a blinking cursor using AnimationController and character-by-character string reveal.
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
        body: Center(
          child: TypewriterText(
            text: 'Hello, Flutter World!',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDelay;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDelay = const Duration(milliseconds: 80),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText>
    with TickerProviderStateMixin {
  late final AnimationController _cursorCtrl;
  int _charCount = 0;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _typeNext();
  }

  void _typeNext() {
    if (_charCount >= widget.text.length) {
      setState(() => _done = true);
      return;
    }
    Future.delayed(widget.charDelay, () {
      if (!mounted) return;
      setState(() => _charCount++);
      _typeNext();
    });
  }

  @override
  void dispose() {
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.text.substring(0, _charCount),
          style: widget.style,
        ),
        AnimatedBuilder(
          animation: _cursorCtrl,
          builder: (_, __) => Opacity(
            opacity: _cursorCtrl.value,
            child: Container(
              width: 2,
              height: (widget.style?.fontSize ?? 16) + 4,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}