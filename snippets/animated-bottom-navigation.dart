import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedNavDemo(),
    );
  }
}

class AnimatedNavDemo extends StatefulWidget {
  const AnimatedNavDemo({super.key});
  @override
  State<AnimatedNavDemo> createState() => _State();
}

class _State extends State<AnimatedNavDemo> {
  int _index = 0;
  final _items = const [
    (Icons.home_rounded, 'Home'),
    (Icons.search_rounded, 'Search'),
    (Icons.favorite_rounded, 'Favorites'),
    (Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          _items[_index].$2,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
      ),
      bottomNavigationBar: _AnimatedNav(
        items: _items,
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _AnimatedNav extends StatelessWidget {
  final List<(IconData, String)> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _AnimatedNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          items.length,
          (i) => Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: currentIndex == i ? 1.3 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.elasticOut,
                    child: Icon(
                      items[i].$1,
                      color: currentIndex == i
                          ? const Color(0xFF6C63FF)
                          : Colors.white38,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 10,
                      color: currentIndex == i
                          ? const Color(0xFF6C63FF)
                          : Colors.white38,
                    ),
                    child: Text(items[i].$2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}