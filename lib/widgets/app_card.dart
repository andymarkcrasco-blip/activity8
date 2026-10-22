import 'package:flutter/material.dart';

/// Reusable card (layout widget demo: Scaffold > Column > Card).
class AppCard extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color? color;

  const AppCard({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.info,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: color ?? Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(body),
      ),
    );
  }
}
