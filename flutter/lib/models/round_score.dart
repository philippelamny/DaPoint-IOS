class RoundScore {
  final int? id;
  final String sessionId;
  final int roundNumber;
  final String playerName;
  final int points;

  const RoundScore({
    this.id,
    required this.sessionId,
    required this.roundNumber,
    required this.playerName,
    required this.points,
  });
}
