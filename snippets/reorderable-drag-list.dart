// title: Reorderable Drag List
// description: Drag-to-reorder list using Flutter's built-in ReorderableListView.
// category: lists
// tags: drag, reorder, list, interactive
// author: Fatima Al-Rashid
// featured: false
// prompt: Build a drag-to-reorder list in Flutter using ReorderableListView with visible drag handles and smooth reorder animation.
// model: claude-opus-4-7
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ReorderablePage(),
    );
  }
}

class ReorderablePage extends StatefulWidget {
  const ReorderablePage({super.key});
  @override
  State<ReorderablePage> createState() => _State();
}

class _State extends State<ReorderablePage> {
  final List<(String, Color, IconData)> _items = [
    ('Design System', const Color(0xFF6C63FF), Icons.palette),
    ('State Management', const Color(0xFF00BCD4), Icons.storage),
    ('Navigation', const Color(0xFFFF6584), Icons.navigation),
    ('Animations', const Color(0xFFFFD93D), Icons.animation),
    ('Testing', const Color(0xFF55EFC4), Icons.bug_report),
    ('Deployment', const Color(0xFFA29BFE), Icons.rocket_launch),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag to Reorder'),
        centerTitle: true,
      ),
      body: ReorderableListView(
        padding: const EdgeInsets.all(16),
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _items.removeAt(oldIndex);
            _items.insert(newIndex, item);
          });
        },
        children: _items.asMap().entries.map((e) {
          final (label, color, icon) = e.value;
          return Card(
            key: ValueKey(e.key),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 20),
              ),
              title: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          );
        }).toList(),
      ),
    );
  }
}