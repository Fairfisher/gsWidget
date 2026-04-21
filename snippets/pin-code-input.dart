// title: Pin Code Input
// description: OTP/PIN input with 6 boxes and auto-advance focus.
// category: inputs
// tags: otp, pin, verification, input
// author: Marco Rossi
// featured: true
// prompt: Build an OTP/PIN input widget in Flutter with 6 individual digit boxes, auto-advance focus on input, and backspace support.
// model: claude-opus-4-7
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: PinCodeInput()),
      ),
    );
  }
}

class PinCodeInput extends StatefulWidget {
  const PinCodeInput({super.key});
  @override
  State<PinCodeInput> createState() => _PinCodeInputState();
}

class _PinCodeInputState extends State<PinCodeInput> {
  static const int _length = 6;
  final List<TextEditingController> _controllers =
      List.generate(_length, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _pin =>
      _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Enter OTP',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'We sent a code to your phone',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _length,
            (i) => Container(
              width: 48,
              height: 56,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF6C63FF), width: 2),
                  ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (v) {
                  if (v.isNotEmpty && i < _length - 1) {
                    _focusNodes[i + 1].requestFocus();
                  } else if (v.isEmpty && i > 0) {
                    _focusNodes[i - 1].requestFocus();
                  }
                  setState(() {});
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _pin.length == _length
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PIN: $_pin')),
                  )
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            padding: const EdgeInsets.symmetric(
                horizontal: 48, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text(
            'Verify',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ],
    );
  }
}