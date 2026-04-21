// title: Toast Notification
// description: Animated slide-in toast notifications with icon, progress bar, and auto-dismiss.
// category: dialogs
// tags: toast, notification, snackbar, animation, slide
// author: Eva Nguyen
// featured: false
// prompt: Build a Flutter toast notification that slides in from the top, displays an icon and message, shows a countdown progress bar, and auto-dismisses.
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
      home: const ToastDemo(),
    );
  }
}

enum ToastType { success, error, warning, info }

class ToastDemo extends StatefulWidget {
  const ToastDemo({super.key});
  @override
  State<ToastDemo> createState() => _ToastDemoState();
}

class _ToastDemoState extends State<ToastDemo> {
  void _show(ToastType type) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) => ToastWidget(type: type, onDone: () => entry.remove()));
    overlay.insert(entry);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Wrap(
          spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
          children: [
            _Btn('Success', const Color(0xFF00D4AA), () => _show(ToastType.success)),
            _Btn('Error',   const Color(0xFFFF3366), () => _show(ToastType.error)),
            _Btn('Warning', const Color(0xFFFFD93D), () => _show(ToastType.warning)),
            _Btn('Info',    const Color(0xFF0088FF), () => _show(ToastType.info)),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap;
  const _Btn(this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class ToastWidget extends StatefulWidget {
  final ToastType type; final VoidCallback onDone;
  const ToastWidget({super.key, required this.type, required this.onDone});
  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  static const _data = {
    ToastType.success: (Icons.check_circle_rounded, Color(0xFF00D4AA), 'Success', 'Action completed!'),
    ToastType.error:   (Icons.error_rounded,         Color(0xFFFF3366), 'Error',   'Something went wrong.'),
    ToastType.warning: (Icons.warning_rounded,        Color(0xFFFFD93D), 'Warning', 'Please review first.'),
    ToastType.info:    (Icons.info_rounded,           Color(0xFF0088FF), 'Info',    'Here is some info.'),
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() { if (mounted) _ctrl.reverse().then((_) => widget.onDone()); }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final (icon, color, title, msg) = _data[widget.type]!;
    return Positioned(
      top: 48, left: 0, right: 0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 340),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withOpacity(0.4)),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 4))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          Icon(icon, color: color, size: 24),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                              Text(msg, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          )),
                        ]),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 0.0),
                        duration: const Duration(seconds: 3),
                        builder: (_, v, __) => LinearProgressIndicator(
                          value: v, minHeight: 3,
                          backgroundColor: color.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}