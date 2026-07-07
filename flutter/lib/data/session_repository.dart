import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/game_session.dart';
import '../models/round_score.dart';
import '../models/session_player.dart';
import '../models/session_status.dart';
import 'app_database.dart';

const _uuid = Uuid();

/// Reactive in-memory cache backed by sqlite, mirroring the way SwiftData's
/// @Query keeps SwiftUI views in sync with the store.
class SessionRepository extends ChangeNotifier {
  SessionRepository(this._database);

  final AppDatabase _database;

  final List<GameSession> _sessions = [];
  final List<SessionPlayer> _players = [];
  final List<RoundScore> _scores = [];

  bool _isReady = false;
  bool get isReady => _isReady;

  Future<void> init() async {
    final db = await _database.open();

    final sessionRows = await db.query('sessions');
    _sessions
      ..clear()
      ..addAll(sessionRows.map(_sessionFromRow));

    final playerRows = await db.query('players');
    _players
      ..clear()
      ..addAll(playerRows.map(_playerFromRow));

    final scoreRows = await db.query('scores');
    _scores
      ..clear()
      ..addAll(scoreRows.map(_scoreFromRow));

    _isReady = true;
    notifyListeners();
  }

  List<GameSession> sessionsForGame(String gameId) {
    final result = _sessions.where((s) => s.gameId == gameId).toList();
    result.sort((a, b) => b.startDate.compareTo(a.startDate));
    return result;
  }

  List<SessionPlayer> playersForSession(String sessionId) {
    final result = _players.where((p) => p.sessionId == sessionId).toList();
    result.sort((a, b) => a.order.compareTo(b.order));
    return result;
  }

  List<RoundScore> scoresForSession(String sessionId) {
    final result = _scores.where((s) => s.sessionId == sessionId).toList();
    result.sort((a, b) => a.roundNumber.compareTo(b.roundNumber));
    return result;
  }

  Future<GameSession> createSession({
    required String name,
    required String gameId,
    required List<String> playerNames,
  }) async {
    final db = await _database.open();
    final session = GameSession(
      id: _uuid.v4(),
      name: name,
      gameId: gameId,
      startDate: DateTime.now(),
    );

    final batch = db.batch();
    batch.insert('sessions', _sessionToRow(session));
    final players = <SessionPlayer>[];
    for (var i = 0; i < playerNames.length; i++) {
      final player = SessionPlayer(name: playerNames[i], sessionId: session.id, order: i);
      players.add(player);
      batch.insert('players', _playerToRow(player));
    }
    final results = await batch.commit();

    _sessions.add(session);
    for (var i = 0; i < players.length; i++) {
      final insertedId = results[i + 1] as int;
      _players.add(SessionPlayer(
        id: insertedId,
        name: players[i].name,
        sessionId: players[i].sessionId,
        order: players[i].order,
      ));
    }
    notifyListeners();
    return session;
  }

  Future<void> addPlayer({required String sessionId, required String name}) async {
    final db = await _database.open();
    final order = playersForSession(sessionId).length;
    final player = SessionPlayer(name: name, sessionId: sessionId, order: order);
    final id = await db.insert('players', _playerToRow(player));
    _players.add(SessionPlayer(id: id, name: name, sessionId: sessionId, order: order));
    notifyListeners();
  }

  Future<void> addRoundScores({
    required String sessionId,
    required int roundNumber,
    required Map<String, int> pointsByPlayerName,
    Map<String, int>? remainingCardsByPlayerName,
    Map<String, int>? placedCardsByPlayerName,
  }) async {
    final db = await _database.open();
    final batch = db.batch();
    final entries = <RoundScore>[];
    final createdAt = DateTime.now();
    pointsByPlayerName.forEach((playerName, points) {
      final entry = RoundScore(
        sessionId: sessionId,
        roundNumber: roundNumber,
        playerName: playerName,
        points: points,
        createdAt: createdAt,
        remainingCards: remainingCardsByPlayerName?[playerName],
        placedCards: placedCardsByPlayerName?[playerName],
      );
      entries.add(entry);
      batch.insert('scores', _scoreToRow(entry));
    });
    final results = await batch.commit();
    for (var i = 0; i < entries.length; i++) {
      final id = results[i] as int;
      final e = entries[i];
      _scores.add(RoundScore(
        id: id,
        sessionId: e.sessionId,
        roundNumber: e.roundNumber,
        playerName: e.playerName,
        points: e.points,
        createdAt: e.createdAt,
        remainingCards: e.remainingCards,
        placedCards: e.placedCards,
      ));
    }
    notifyListeners();
  }

  Future<void> finishSession(GameSession session) async {
    final db = await _database.open();
    final endDate = DateTime.now();
    session.status = SessionStatus.finished;
    session.endDate = endDate;
    await db.update(
      'sessions',
      _sessionToRow(session),
      where: 'id = ?',
      whereArgs: [session.id],
    );
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    final db = await _database.open();
    final batch = db.batch();
    batch.delete('players', where: 'sessionId = ?', whereArgs: [sessionId]);
    batch.delete('scores', where: 'sessionId = ?', whereArgs: [sessionId]);
    batch.delete('sessions', where: 'id = ?', whereArgs: [sessionId]);
    await batch.commit(noResult: true);

    _sessions.removeWhere((s) => s.id == sessionId);
    _players.removeWhere((p) => p.sessionId == sessionId);
    _scores.removeWhere((s) => s.sessionId == sessionId);
    notifyListeners();
  }

  Future<void> deleteAllSessions(String gameId) async {
    final db = await _database.open();
    final sessionIds = sessionsForGame(gameId).map((s) => s.id).toList();
    if (sessionIds.isEmpty) return;

    final batch = db.batch();
    for (final sid in sessionIds) {
      batch.delete('players', where: 'sessionId = ?', whereArgs: [sid]);
      batch.delete('scores', where: 'sessionId = ?', whereArgs: [sid]);
      batch.delete('sessions', where: 'id = ?', whereArgs: [sid]);
    }
    await batch.commit(noResult: true);

    _sessions.removeWhere((s) => sessionIds.contains(s.id));
    _players.removeWhere((p) => sessionIds.contains(p.sessionId));
    _scores.removeWhere((s) => sessionIds.contains(s.sessionId));
    notifyListeners();
  }

  // MARK: - Row mapping

  Map<String, Object?> _sessionToRow(GameSession s) => {
        'id': s.id,
        'name': s.name,
        'gameId': s.gameId,
        'startDate': s.startDate.millisecondsSinceEpoch,
        'endDate': s.endDate?.millisecondsSinceEpoch,
        'status': s.status.rawValue,
      };

  GameSession _sessionFromRow(Map<String, Object?> row) => GameSession(
        id: row['id'] as String,
        name: row['name'] as String,
        gameId: row['gameId'] as String,
        startDate: DateTime.fromMillisecondsSinceEpoch(row['startDate'] as int),
        endDate: row['endDate'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row['endDate'] as int),
        status: SessionStatus.fromRawValue(row['status'] as String),
      );

  Map<String, Object?> _playerToRow(SessionPlayer p) => {
        'name': p.name,
        'sessionId': p.sessionId,
        'order': p.order,
      };

  SessionPlayer _playerFromRow(Map<String, Object?> row) => SessionPlayer(
        id: row['id'] as int,
        name: row['name'] as String,
        sessionId: row['sessionId'] as String,
        order: row['order'] as int,
      );

  Map<String, Object?> _scoreToRow(RoundScore s) => {
        'sessionId': s.sessionId,
        'roundNumber': s.roundNumber,
        'playerName': s.playerName,
        'points': s.points,
        'createdAt': s.createdAt.millisecondsSinceEpoch,
        'remainingCards': s.remainingCards,
        'placedCards': s.placedCards,
      };

  RoundScore _scoreFromRow(Map<String, Object?> row) => RoundScore(
        id: row['id'] as int,
        sessionId: row['sessionId'] as String,
        roundNumber: row['roundNumber'] as int,
        playerName: row['playerName'] as String,
        points: row['points'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int? ?? 0),
        remainingCards: row['remainingCards'] as int?,
        placedCards: row['placedCards'] as int?,
      );
}
