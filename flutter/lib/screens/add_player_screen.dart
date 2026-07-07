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
  final _nameFocusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _save(Set<String> existingNamesLower) async {
    final trimmed = _nameController.text.trim();
    if (trimmed.isEmpty || existingNamesLower.contains(trimmed.toLowerCase())) return;
    await context.read<SessionRepository>().addPlayer(
          sessionId: widget.session.id,
          name: trimmed,
        );
    if (!mounted) return;
    _nameController.clear();
    setState(() {});
    _nameFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final players = context.watch<SessionRepository>().playersForSession(widget.session.id);
    final existingNamesLower = players.map((p) => p.name.toLowerCase()).toSet();
    final trimmedInput = _nameController.text.trim();
    final isDuplicateInput = trimmedInput.isNotEmpty && existingNamesLower.contains(trimmedInput.toLowerCase());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un joueur'),
        leadingWidth: 88,
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ),
      body: ListView(
        children: [
          for (final player in players)
            ListTile(leading: const Icon(Icons.person), title: Text(player.name)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Nom du joueur',
                      errorText: isDuplicateInput ? 'Ce nom existe déjà' : null,
                    ),
                    autocorrect: false,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _save(existingNamesLower),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: trimmedInput.isEmpty || isDuplicateInput
                      ? null
                      : () => _save(existingNamesLower),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
