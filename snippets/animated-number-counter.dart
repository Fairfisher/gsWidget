import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(body: Center(child: CounterDemo())),
    );
  }
}

class CounterDemo extends StatefulWidget {
  const CounterDemo({super.key});
  @override
  State<CounterDemo> createState() => _CounterDemoState();
}

class _CounterDemoState extends State<CounterDemo> {
  int _count = 0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RollingCounter(value: _count, style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w800, color: Color(0xFFFF5F1F))),
        const SizedBox(height: 40),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Btn(icon: Icons.remove_rounded, onTap: () => setState(() => _count--)),
            const SizedBox(width: 16),
            _Btn(icon: Icons.add_rounded, onTap: () => setState(() => _count++)),
          ],
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFFF5F1F).withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFF5F1F).withOpacity(0.4)),
        ),
        child: Icon(icon, color: const Color(0xFFFF5F1F)),
      ),
    );
  }
}

class RollingCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  const RollingCounter({super.key, required this.value, this.style});
  @override
  State<RollingCounter> createState() => _RollingCounterState();
}

class _RollingCounterState extends State<RollingCounter> {
  int _prev = 0;
  @override
  void didUpdateWidget(RollingCounter old) { super.didUpdateWidget(old); _prev = old.value; }
  @override
  Widget build(BuildContext context) {
    final digits = widget.value.abs().toString().padLeft(3, '0').split('');
    final prevDigits = _prev.abs().toString().padLeft(3, '0').split('');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.value < 0) Text('-', style: widget.style),
        for (int i = 0; i < digits.length; i++)
          _RollingDigit(digit: int.parse(digits[i]), prevDigit: int.parse(prevDigits[i]), style: widget.style, goingUp: widget.value > _prev),
      ],
    );
  }
}

class _RollingDigit extends StatelessWidget {
  final int digit, prevDigit;
  final TextStyle? style;
  final bool goingUp;
  const _RollingDigit({required this.digit, required this.prevDigit, required this.goingUp, this.style});
  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: TweenAnimationBuilder<double>(
        key: ValueKey(digit),
        tween: Tween(begin: goingUp ? 1.0 : -1.0, end: 0.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (_, v, __) => Transform.translate(
          offset: Offset(0, v * (style?.fontSize ?? 40)),
          child: Text('$digit', style: style),
        ),
      ),
    );
  }
}