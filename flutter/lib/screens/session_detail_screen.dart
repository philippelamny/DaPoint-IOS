import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/session_repository.dart';
import '../models/game_session.dart';
import '../models/round_score.dart';
import '../models/session_player.dart';
import '../models/session_status.dart';
import 'add_player_screen.dart';
import 'enter_round_scores_screen.dart';

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key, required this.session});

  final GameSession session;

  List<int> _roundNumbers(List<RoundScore> scores) {
    final set = scores.map((s) => s.roundNumber).toSet().toList();
    set.sort();
    return set;
  }

  int? _points(List<RoundScore> scores, SessionPlayer player, int round) {
    for (final s in scores) {
      if (s.playerName == player.name && s.roundNumber == round) return s.points;
    }
    return null;
  }

  int _total(List<RoundScore> scores, SessionPlayer player) {
    return scores.where((s) => s.playerName == player.name).fold(0, (sum, s) => sum + s.points);
  }

  bool _isLeader(List<SessionPlayer> players, List<RoundScore> scores, SessionPlayer player) {
    final rounds = _roundNumbers(scores);
    if (rounds.isEmpty) return false;
    final totals = players.map((p) => _total(scores, p));
    final min = totals.reduce((a, b) => a < b ? a : b);
    return _total(scores, player) == min;
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<SessionRepository>();
    final players = repository.playersForSession(session.id);
    final scores = repository.scoresForSession(session.id);
    final roundNumbers = _roundNumbers(scores);
    final nextRound = (roundNumbers.isEmpty ? 0 : roundNumbers.last) + 1;
    final isOngoing = session.status == SessionStatus.ongoing;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.name),
        actions: isOngoing
            ? [
                IconButton(
                  icon: const Icon(Icons.person_add_alt),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) => AddPlayerScreen(session: session),
                      ),
                    );
                  },
                ),
                if (players.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => EnterRoundScoresScreen(
                            session: session,
                            players: players,
                            roundNumber: nextRound,
                          ),
                        ),
                      );
                    },
                    child: const Text('Ajouter un score'),
                  ),
              ]
            : null,
      ),
      body: players.isEmpty
          ? _EmptyPlayers()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _ScoreTable(
                      players: players,
                      scores: scores,
                      roundNumbers: roundNumbers,
                      total: _total,
                      points: _points,
                      isLeader: (p) => _isLeader(players, scores, p),
                    ),
                  ),
                ),
                if (isOngoing)
                  SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.3))),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(204, 26, 26, 1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => repository.finishSession(session),
                          icon: const Icon(Icons.flag),
                          label: const Text('Terminer la partie'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _EmptyPlayers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('Aucun joueur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Ajoutez des joueurs pour commencer', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _ScoreTable extends StatelessWidget {
  const _ScoreTable({
    required this.players,
    required this.scores,
    required this.roundNumbers,
    required this.total,
    required this.points,
    required this.isLeader,
  });

  final List<SessionPlayer> players;
  final List<RoundScore> scores;
  final List<int> roundNumbers;
  final int Function(List<RoundScore>, SessionPlayer) total;
  final int? Function(List<RoundScore>, SessionPlayer, int) points;
  final bool Function(SessionPlayer) isLeader;

  static const double rowH = 40;
  static const double headH = 34;
  static const double nameW = 112;
  static const double colW = 52;

  @override
  Widget build(BuildContext context) {
    final reversedRounds = roundNumbers.reversed.toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed left column: player names
              SizedBox(
                width: nameW,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: headH),
                    const Divider(height: 1),
                    for (final player in players) ...[
                      Container(
                        height: rowH,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLeader(player)) ...[
                              const Icon(Icons.emoji_events, size: 10, color: Colors.amber),
                              const SizedBox(width: 4),
                            ],
                            Flexible(
                              child: Text(
                                player.name,
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  ],
                ),
              ),
              const VerticalDivider(width: 0.5, thickness: 0.5),
              // Scrollable rounds (most recent first)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final round in reversedRounds)
                        Column(
                          children: [
                            SizedBox(
                              width: colW,
                              height: headH,
                              child: Center(
                                child: Text(
                                  'M$round',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            for (final player in players) ...[
                              SizedBox(
                                width: colW,
                                height: rowH,
                                child: Center(
                                  child: Text(
                                    points(scores, player, round)?.toString() ?? '—',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: points(scores, player, round) == null
                                          ? Colors.grey
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                            ],
                          ],
                        ),
                      if (reversedRounds.isEmpty) SizedBox(width: colW),
                    ],
                  ),
                ),
              ),
              const VerticalDivider(width: 0.5, thickness: 0.5),
              // Fixed right column: total
              SizedBox(
                width: colW + 8,
                child: Column(
                  children: [
                    SizedBox(
                      height: headH,
                      child: Center(
                        child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                    const Divider(height: 1),
                    for (final player in players) ...[
                      SizedBox(
                        height: rowH,
                        child: Center(
                          child: Text(
                            '${total(scores, player)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isLeader(player) ? Colors.green : null,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
