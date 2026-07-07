import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/games_registry.dart';
import '../data/session_repository.dart';
import '../models/game.dart';
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
  final Map<String, int?> _remainingValues = {};
  final Map<String, int?> _placedValues = {};

  ScoringMode get _scoringMode =>
      GamesRegistry.game(widget.session.gameId)?.scoringMode ?? ScoringMode.direct;

  @override
  void initState() {
    super.initState();
    for (final p in widget.players) {
      _controllers[p.name] = TextEditingController();
      _remainingValues[p.name] = null;
      _placedValues[p.name] = null;
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int? _ligrettoScore(SessionPlayer player) {
    final remaining = _remainingValues[player.name];
    final placed = _placedValues[player.name];
    if (remaining == null || placed == null) return null;
    return placed - 2 * remaining;
  }

  bool get _allValid {
    if (_scoringMode == ScoringMode.ligrettoCards) {
      return widget.players.every((p) => _ligrettoScore(p) != null);
    }
    return widget.players.every((p) {
      final val = _controllers[p.name]?.text ?? '';
      return val.isNotEmpty && int.tryParse(val) != null;
    });
  }

  Future<void> _save() async {
    final isLigretto = _scoringMode == ScoringMode.ligrettoCards;
    final points = <String, int>{
      for (final p in widget.players)
        p.name: isLigretto
            ? _ligrettoScore(p) ?? 0
            : int.tryParse(_controllers[p.name]?.text ?? '0') ?? 0,
    };
    await context.read<SessionRepository>().addRoundScores(
          sessionId: widget.session.id,
          roundNumber: widget.roundNumber,
          pointsByPlayerName: points,
          remainingCardsByPlayerName: isLigretto ? _remainingValues.map((k, v) => MapEntry(k, v ?? 0)) : null,
          placedCardsByPlayerName: isLigretto ? _placedValues.map((k, v) => MapEntry(k, v ?? 0)) : null,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisir les scores'),
        leadingWidth: 88,
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
            _scoringMode == ScoringMode.ligrettoCards
                ? _LigrettoRow(
                    playerName: player.name,
                    remaining: _remainingValues[player.name],
                    placed: _placedValues[player.name],
                    score: _ligrettoScore(player),
                    onRemainingChanged: (v) => setState(() => _remainingValues[player.name] = v),
                    onPlacedChanged: (v) => setState(() => _placedValues[player.name] = v),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(player.name)),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: _controllers[player.name],
                            keyboardType: const TextInputType.numberWithOptions(signed: true),
                            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*$'))],
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

class _LigrettoRow extends StatelessWidget {
  const _LigrettoRow({
    required this.playerName,
    required this.remaining,
    required this.placed,
    required this.score,
    required this.onRemainingChanged,
    required this.onPlacedChanged,
  });

  final String playerName;
  final int? remaining;
  final int? placed;
  final int? score;
  final ValueChanged<int?> onRemainingChanged;
  final ValueChanged<int?> onPlacedChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(playerName, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(
                score == null ? '—' : '$score pts',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: score == null ? Colors.grey : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: remaining,
                  decoration: const InputDecoration(
                    labelText: 'Cartes restantes',
                    isDense: true,
                  ),
                  items: [
                    for (var i = 0; i <= 10; i++) DropdownMenuItem(value: i, child: Text('$i')),
                  ],
                  onChanged: onRemainingChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: placed,
                  decoration: const InputDecoration(
                    labelText: 'Cartes posées',
                    isDense: true,
                  ),
                  items: [
                    for (var i = 0; i <= 30; i++) DropdownMenuItem(value: i, child: Text('$i')),
                  ],
                  onChanged: onPlacedChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
