import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/session_repository.dart';
import '../models/game_session.dart';

class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key, required this.session});

  final GameSession session;

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final trimmed = _nameController.text.trim();
    if (trimmed.isEmpty) return;
    await context.read<SessionRepository>().addPlayer(
          sessionId: widget.session.id,
          name: trimmed,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un joueur'),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        actions: [
          TextButton(
            onPressed: _nameController.text.trim().isEmpty ? null : _save,
            child: const Text('Ajouter'),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Nom du joueur'),
              autocorrect: false,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _save(),
            ),
          ),
        ],
      ),
    );
  }
}
