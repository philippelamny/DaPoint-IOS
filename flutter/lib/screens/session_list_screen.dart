import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/games_registry.dart';
import '../data/session_repository.dart';
import '../models/game.dart';
import '../models/game_session.dart';
import '../models/round_score.dart';
import '../models/session_player.dart';
import '../models/session_status.dart';
import '../theme/brand.dart';
import 'new_session_screen.dart';
import 'rules_screen.dart';
import 'session_detail_screen.dart';

const _medals = ['🥇', '🥈', '🥉'];

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key, required this.game});

  final Game game;

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  bool _filterExpanded = false;
  String _filterName = '';
  SessionStatus? _filterStatus = SessionStatus.ongoing;
  bool _filterStartDateEnabled = false;
  DateTime _filterStartDate = DateTime.now();
  bool _filterEndDateEnabled = false;
  DateTime _filterEndDate = DateTime.now();

  bool get _isFiltering =>
      _filterStatus != null ||
      _filterName.isNotEmpty ||
      _filterStartDateEnabled ||
      _filterEndDateEnabled;

  List<GameSession> _filtered(List<GameSession> sessions) {
    return sessions.where((session) {
      if (_filterStatus != null && session.status != _filterStatus) {
        return false;
      }
      if (_filterName.isNotEmpty &&
          !session.name.toLowerCase().contains(_filterName.toLowerCase())) {
        return false;
      }
      if (_filterStartDateEnabled &&
          session.startDate.isBefore(_filterStartDate)) {
        return false;
      }
      if (_filterEndDateEnabled) {
        final end = session.endDate;
        if (end == null || end.isAfter(_filterEndDate)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser la liste ?'),
        content: const Text(
          'Toutes les parties et leurs scores seront supprimés définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer toutes les parties'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<SessionRepository>().deleteAllSessions(widget.game.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<SessionRepository>();
    final sessions = repository.sessionsForGame(widget.game.id);
    final filteredSessions = _filtered(sessions);
    final rulesUrl = widget.game.rulesUrl;
    final hasLocalRules =
        widget.game.rules != null && widget.game.rules!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.displayName),
        actions: [
          if (hasLocalRules || rulesUrl != null)
            IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Règles',
              onPressed: hasLocalRules
                  ? () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RulesScreen(game: widget.game),
                      ),
                    )
                  : () => launchUrl(
                      Uri.parse(rulesUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
            ),
          if (sessions.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: _confirmReset,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        children: [
          Material(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NewSessionScreen(game: widget.game),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(Icons.add_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Nouvelle partie',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              initiallyExpanded: _filterExpanded,
              onExpansionChanged: (v) => setState(() => _filterExpanded = v),
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              leading: Icon(
                _isFiltering ? Icons.filter_alt : Icons.filter_alt_outlined,
                color: _isFiltering
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
              title: Text(
                'Filtres',
                style: TextStyle(
                  color: _isFiltering
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[700],
                ),
              ),
              children: [_buildFilterSection()],
            ),
          ),
          const SizedBox(height: 12),
          for (final session in filteredSessions) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Dismissible(
                  key: ValueKey(session.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Supprimer cette partie ?'),
                        content: Text(
                          '"${session.name}" et tous ses scores seront supprimés définitivement.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                    return confirmed ?? false;
                  },
                  onDismissed: (_) => context
                      .read<SessionRepository>()
                      .deleteSession(session.id),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SessionDetailScreen(session: session),
                          ),
                        );
                      },
                      child: SessionRowView(session: session),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Nom',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _filterName = v),
          ),
          const SizedBox(height: 12),
          SegmentedButton<SessionStatus?>(
            segments: [
              const ButtonSegment(value: null, label: Text('Tous')),
              ...SessionStatus.values.map(
                (s) => ButtonSegment(value: s, label: Text(s.displayName)),
              ),
            ],
            selected: {_filterStatus},
            onSelectionChanged: (selection) =>
                setState(() => _filterStatus = selection.first),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date de début après le'),
            value: _filterStartDateEnabled,
            onChanged: (v) => setState(() => _filterStartDateEnabled = v),
          ),
          if (_filterStartDateEnabled)
            _DatePickerRow(
              date: _filterStartDate,
              onChanged: (d) => setState(() => _filterStartDate = d),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Date de fin avant le'),
            value: _filterEndDateEnabled,
            onChanged: (v) => setState(() => _filterEndDateEnabled = v),
          ),
          if (_filterEndDateEnabled)
            _DatePickerRow(
              date: _filterEndDate,
              onChanged: (d) => setState(() => _filterEndDate = d),
            ),
        ],
      ),
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({required this.date, required this.onChanged});

  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) onChanged(picked);
        },
        child: Text(DateFormat.yMMMd('fr_FR').format(date)),
      ),
    );
  }
}

// MARK: - Row

class SessionRowView extends StatelessWidget {
  const SessionRowView({super.key, required this.session});

  final GameSession session;

  int _total(List<RoundScore> scores, SessionPlayer player) {
    return scores
        .where((s) => s.playerName == player.name)
        .fold(0, (sum, s) => sum + s.points);
  }

  SessionPlayer? _bestPlayer(
    List<SessionPlayer> players,
    List<RoundScore> scores,
    bool highestWins,
  ) {
    if (players.isEmpty || scores.isEmpty) return null;
    SessionPlayer? best;
    var bestTotal = 0;
    for (final p in players) {
      final t = _total(scores, p);
      if (best == null || (highestWins ? t > bestTotal : t < bestTotal)) {
        best = p;
        bestTotal = t;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<SessionRepository>();
    final players = repository.playersForSession(session.id);
    final scores = repository.scoresForSession(session.id);
    final highestWins =
        GamesRegistry.game(session.gameId)?.highestWins ?? false;
    final best = _bestPlayer(players, scores, highestWins);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      DateFormat.yMMMd('fr_FR').format(session.startDate),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    if (players.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.people, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 2),
                      Text(
                        '${players.length}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                if (best != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 12,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(best.name, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        '· ${_total(scores, best)} pts',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusBadge(status: session.status),
              if (players.isNotEmpty) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => SessionScoreSummarySheet(
                        session: session,
                        players: players,
                        scores: scores,
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// MARK: - Detail sheet

class SessionScoreSummarySheet extends StatelessWidget {
  const SessionScoreSummarySheet({
    super.key,
    required this.session,
    required this.players,
    required this.scores,
  });

  final GameSession session;
  final List<SessionPlayer> players;
  final List<RoundScore> scores;

  int _total(SessionPlayer player) {
    return scores
        .where((s) => s.playerName == player.name)
        .fold(0, (sum, s) => sum + s.points);
  }

  @override
  Widget build(BuildContext context) {
    final highestWins =
        GamesRegistry.game(session.gameId)?.highestWins ?? false;
    final sortedPlayers = [...players]
      ..sort(
        (a, b) => highestWins
            ? _total(b).compareTo(_total(a))
            : _total(a).compareTo(_total(b)),
      );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      session.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: sortedPlayers.length,
                itemBuilder: (context, index) {
                  final player = sortedPlayers[index];
                  final total = _total(player);
                  final isLeader = index == 0 && scores.isNotEmpty;
                  final hasMedal = index < 3 && scores.isNotEmpty;
                  return ListTile(
                    leading: SizedBox(
                      width: 28,
                      child: hasMedal
                          ? Text(
                              _medals[index],
                              style: const TextStyle(fontSize: 20),
                            )
                          : Text(
                              '${index + 1}.',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                    ),
                    title: Text(player.name),
                    trailing: Text(
                      '$total pts',
                      style: TextStyle(
                        fontWeight: isLeader
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isLeader ? Brand.accent : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Status badge

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final SessionStatus status;

  @override
  Widget build(BuildContext context) {
    final isOngoing = status == SessionStatus.ongoing;
    final color = isOngoing ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(fontSize: 12, color: color),
      ),
    );
  }
}
