import 'package:flutter/material.dart';

class RuleSection {
  final String title;
  final String body;

  const RuleSection({required this.title, required this.body});
}

/// How a round's score is entered and computed.
enum ScoringMode {
  /// A single score value is entered directly.
  direct,

  /// Ligretto: the score is derived from the number of cards placed in the
  /// middle (+1 each) and the number of cards left in the Ligretto pile
  /// (-2 each).
  ligrettoCards,
}

class Game {
  final String id;
  final String displayName;
  final String? rulesUrl;
  final List<RuleSection>? rules;
  final ScoringMode scoringMode;

  /// If true, the player with the highest total wins (e.g. Ligretto).
  /// If false (default), the lowest total wins (e.g. Txek).
  final bool highestWins;

  /// Original in-app pictogram (not the publisher's logo) shown in game lists.
  final IconData icon;

  const Game({
    required this.id,
    required this.displayName,
    this.rulesUrl,
    this.rules,
    this.scoringMode = ScoringMode.direct,
    this.highestWins = false,
    this.icon = Icons.casino,
  });
}
