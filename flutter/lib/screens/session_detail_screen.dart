import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/games_registry.dart';
import '../data/session_repository.dart';
import '../models/game_session.dart';
import '../models/round_score.dart';
import '../models/session_player.dart';
import '../models/session_status.dart';
import '../theme/brand.dart';
import 'add_player_screen.dart';
import 'enter_round_scores_screen.dart';

const _medals = ['🥇', '🥈', '🥉'];

class SessionDetailScreen extends StatelessWidget {
  const SessionDetailScreen({super.key, required this.session});

  final GameSession session;

  List<int> _roundNumbers(List<RoundScore> scores) {
    final set = scores.map((s) => s.roundNumber).toSet().toList();
    set.sort();
    return set;
  }

  int? _points(List<RoundScore> scores, SessionPlayer player, int round) {
    return _entry(scores, player, round)?.points;
  }

  RoundScore? _entry(List<RoundScore> scores, SessionPlayer player, int round) {
    for (final s in scores) {
      if (s.playerName == player.name && s.roundNumber == round) return s;
    }
    return null;
  }

  void _showRoundDetail(BuildContext context, SessionPlayer player, int round, RoundScore entry) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${player.name} — Manche $round',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat("d MMM yyyy 'à' HH:mm", 'fr_FR').format(entry.createdAt),
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              if (entry.remainingCards != null)
                _DetailRow(label: 'Cartes restantes', value: '${entry.remainingCards}'),
              if (entry.placedCards != null)
                _DetailRow(label: 'Cartes posées', value: '${entry.placedCards}'),
              _DetailRow(label: 'Score', value: '${entry.points} pts', bold: true),
            ],
          ),
        ),
      ),
    );
  }

  int _total(List<RoundScore> scores, SessionPlayer player) {
    return scores.where((s) => s.playerName == player.name).fold(0, (sum, s) => sum + s.points);
  }

  List<SessionPlayer> _ranked(List<SessionPlayer> players, List<RoundScore> scores, bool highestWins) {
    return [...players]..sort((a, b) => highestWins
        ? _total(scores, b).compareTo(_total(scores, a))
        : _total(scores, a).compareTo(_total(scores, b)));
  }

  int? _rank(List<SessionPlayer> ranked, List<RoundScore> scores, SessionPlayer player) {
    if (scores.isEmpty) return null;
    final index = ranked.indexOf(player);
    return index < 3 ? index : null;
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<SessionRepository>();
    final players = repository.playersForSession(session.id);
    final scores = repository.scoresForSession(session.id);
    final roundNumbers = _roundNumbers(scores);
    final nextRound = (roundNumbers.isEmpty ? 0 : roundNumbers.last) + 1;
    final isOngoing = session.status == SessionStatus.ongoing;
    final highestWins = GamesRegistry.game(session.gameId)?.highestWins ?? false;
    final ranked = _ranked(players, scores, highestWins);

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
                      rank: (p) => _rank(ranked, scores, p),
                      onTapScore: (player, round) {
                        final entry = _entry(scores, player, round);
                        if (entry != null) _showRoundDetail(context, player, round, entry);
                      },
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
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
    required this.rank,
    required this.onTapScore,
  });

  final List<SessionPlayer> players;
  final List<RoundScore> scores;
  final List<int> roundNumbers;
  final int Function(List<RoundScore>, SessionPlayer) total;
  final int? Function(List<RoundScore>, SessionPlayer, int) points;
  final int? Function(SessionPlayer) rank;
  final void Function(SessionPlayer player, int round) onTapScore;

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
                            if (rank(player) != null) ...[
                              Text(_medals[rank(player)!], style: const TextStyle(fontSize: 12)),
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
                                child: InkWell(
                                  onTap: () => onTapScore(player, round),
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
                              color: rank(player) == 0 ? Brand.accent : null,
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
