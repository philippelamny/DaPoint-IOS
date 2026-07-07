import 'package:flutter/material.dart';

import '../models/game.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key, required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final sections = game.rules ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text('Règles — ${game.displayName}')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(section.body, style: const TextStyle(fontSize: 15, height: 1.4)),
            ],
          );
        },
      ),
    );
  }
}
