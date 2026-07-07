import 'session_status.dart';

class GameSession {
  final String id;
  String name;
  final String gameId;
  final DateTime startDate;
  DateTime? endDate;
  SessionStatus status;

  GameSession({
    required this.id,
    required this.name,
    required this.gameId,
    required this.startDate,
    this.endDate,
    this.status = SessionStatus.ongoing,
  });
}
