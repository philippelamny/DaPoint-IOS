import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/session_repository.dart';
import '../models/game.dart';
import 'session_detail_screen.dart';

class NewSessionScreen extends StatefulWidget {
  const NewSessionScreen({super.key, required this.game});

  final Game game;

  @override
  State<NewSessionScreen> createState() => _NewSessionScreenState();
}

class _NewSessionScreenState extends State<NewSessionScreen> {
  final _sessionNameController = TextEditingController();
  final _newPlayerController = TextEditingController();
  final _newPlayerFocusNode = FocusNode();
  final List<String> _playerNames = [];

  bool get _canCreate => _sessionNameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _sessionNameController.dispose();
    _newPlayerController.dispose();
    _newPlayerFocusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    final trimmed = _newPlayerController.text.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _playerNames.add(trimmed);
      _newPlayerController.clear();
    });
    _newPlayerFocusNode.requestFocus();
  }

  Future<void> _create() async {
    final repository = context.read<SessionRepository>();
    final session = await repository.createSession(
      name: _sessionNameController.text.trim(),
      gameId: widget.game.id,
      playerNames: _playerNames,
    );
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SessionDetailScreen(session: session)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle partie'),
        actions: [
          TextButton(
            onPressed: _canCreate ? _create : null,
            child: const Text('Créer'),
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text('PARTIE', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _sessionNameController,
              decoration: const InputDecoration(hintText: 'Nom de la partie'),
              autocorrect: false,
              onChanged: (_) => setState(() {}),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 4),
            child: Text('JOUEURS', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          for (final name in _playerNames)
            Dismissible(
              key: ValueKey('$name-${_playerNames.indexOf(name)}'),
              onDismissed: (_) => setState(() => _playerNames.remove(name)),
              background: Container(color: Colors.red),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(name),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newPlayerController,
                    focusNode: _newPlayerFocusNode,
                    decoration: const InputDecoration(hintText: 'Ajouter un joueur'),
                    autocorrect: false,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _addPlayer(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle),
                  onPressed: _newPlayerController.text.trim().isEmpty ? null : _addPlayer,
                ),
              ],
            ),
          ),
          if (_playerNames.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Text(
                'Tu pourras aussi ajouter des joueurs depuis la page des scores.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
