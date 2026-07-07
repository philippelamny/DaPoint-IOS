class RoundScore {
  final int? id;
  final String sessionId;
  final int roundNumber;
  final String playerName;
  final int points;
  final DateTime createdAt;

  /// Ligretto only: number of cards left in the Ligretto pile for this round.
  final int? remainingCards;

  /// Ligretto only: number of cards placed in the middle for this round.
  final int? placedCards;

  const RoundScore({
    this.id,
    required this.sessionId,
    required this.roundNumber,
    required this.playerName,
    required this.points,
    required this.createdAt,
    this.remainingCards,
    this.placedCards,
  });
}
