import '../models/game.dart';

abstract final class GamesRegistry {
  static const List<Game> all = [
    Game(
      id: 'txek',
      displayName: 'Txek',
      rulesUrl: 'https://www.txek.fr/txek-faq/',
    ),
  ];

  static Game? game(String id) {
    for (final game in all) {
      if (game.id == id) return game;
    }
    return null;
  }
}
