// title: Animated Stepper
// description: Custom horizontal stepper with animated progress line, step icons, and labels.
// category: navigation
// tags: stepper, progress, steps, animation, custom
// author: Yuki Tanaka
// featured: false
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const Scaffold(body: Center(child: StepperDemo())),
    );
  }
}

const _steps = [
  (Icons.person_rounded,      'Account'),
  (Icons.location_on_rounded,  'Address'),
  (Icons.payment_rounded,      'Payment'),
  (Icons.check_rounded,        'Done'),
];

class StepperDemo extends StatefulWidget {
  const StepperDemo({super.key});
  @override
  State<StepperDemo> createState() => _StepperDemoState();
}

class _StepperDemoState extends State<StepperDemo> {
  int _current = 0;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedStepper(steps: _steps, currentStep: _current),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_current > 0) ...[
                _StepBtn(label: 'Back', icon: Icons.arrow_back_rounded, onTap: () => setState(() => _current--), outline: true),
                const SizedBox(width: 12),
              ],
              if (_current < _steps.length - 1)
                _StepBtn(label: 'Next', icon: Icons.arrow_forward_rounded, onTap: () => setState(() => _current++)),
              if (_current == _steps.length - 1)
                _StepBtn(label: 'Restart', icon: Icons.refresh_rounded, onTap: () => setState(() => _current = 0)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap; final bool outline;
  const _StepBtn({required this.label, required this.icon, required this.onTap, this.outline = false});
  @override
  Widget build(BuildContext context) {
    const c = Color(0xFFFF5F1F);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: outline ? Colors.transparent : c,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: outline ? c : Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: outline ? c : Colors.white, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class AnimatedStepper extends StatelessWidget {
  final List<(IconData, String)> steps;
  final int currentStep;
  const AnimatedStepper({super.key, required this.steps, required this.currentStep});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _StepCircle(
            icon: steps[i].$1, label: steps[i].$2,
            state: i < currentStep ? _SS.done : i == currentStep ? _SS.active : _SS.idle,
          ),
          if (i < steps.length - 1) Expanded(child: _StepLine(filled: i < currentStep)),
        ],
      ],
    );
  }
}

enum _SS { idle, active, done }

class _StepCircle extends StatelessWidget {
  final IconData icon; final String label; final _SS state;
  const _StepCircle({required this.icon, required this.label, required this.state});
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF5F1F);
    final bg = state == _SS.idle ? const Color(0xFF1A1A2E) : primary.withOpacity(state == _SS.active ? 0.15 : 1.0);
    final border = state == _SS.idle ? const Color(0xFF333355) : primary;
    final iconColor = state == _SS.idle ? Colors.white38 : state == _SS.active ? primary : Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: bg, shape: BoxShape.circle,
            border: Border.all(color: border, width: 2),
            boxShadow: state != _SS.idle ? [BoxShadow(color: primary.withOpacity(0.3), blurRadius: 12, spreadRadius: 1)] : [],
          ),
          child: Icon(state == _SS.done ? Icons.check_rounded : icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 11, color: state == _SS.idle ? Colors.white38 : primary,
          fontWeight: state != _SS.idle ? FontWeight.w600 : FontWeight.w400)),
      ],
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool filled;
  const _StepLine({required this.filled});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 2,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFFF5F1F) : const Color(0xFF333355),
          borderRadius: BorderRadius.circular(1),
          boxShadow: filled ? [const BoxShadow(color: Color(0x66FF5F1F), blurRadius: 6)] : [],
        ),
      ),
    );
  }
}