import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/session_repository.dart';
import '../models/game_session.dart';
import '../models/session_player.dart';

class EnterRoundScoresScreen extends StatefulWidget {
  const EnterRoundScoresScreen({
    super.key,
    required this.session,
    required this.players,
    required this.roundNumber,
  });

  final GameSession session;
  final List<SessionPlayer> players;
  final int roundNumber;

  @override
  State<EnterRoundScoresScreen> createState() => _EnterRoundScoresScreenState();
}

class _EnterRoundScoresScreenState extends State<EnterRoundScoresScreen> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (final p in widget.players) {
      _controllers[p.name] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _allValid {
    return widget.players.every((p) {
      final val = _controllers[p.name]?.text ?? '';
      return val.isNotEmpty && int.tryParse(val) != null;
    });
  }

  Future<void> _save() async {
    final points = <String, int>{
      for (final p in widget.players) p.name: int.tryParse(_controllers[p.name]?.text ?? '0') ?? 0,
    };
    await context.read<SessionRepository>().addRoundScores(
          sessionId: widget.session.id,
          roundNumber: widget.roundNumber,
          pointsByPlayerName: points,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisir les scores'),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        actions: [
          TextButton(
            onPressed: _allValid ? _save : null,
            child: const Text('Valider'),
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'MANCHE ${widget.roundNumber} — POINTS PAR JOUEUR',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          for (final player in widget.players)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(player.name)),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _controllers[player.name],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(hintText: '0'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
