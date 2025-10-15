import 'package:flutter/material.dart';

class TabScaffold extends StatelessWidget {
  final String title;
  final IconData icon;

  const TabScaffold({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          backgroundColor: colorScheme.surface,
          title: Row(
            children: <Widget>[
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              '$title Page',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ),
      ],
    );
  }
}
