import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/games_registry.dart';
import '../models/game.dart';
import 'manage_favorites_screen.dart';
import 'session_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _favoriteGameIdsRaw = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _favoriteGameIdsRaw = prefs.getString('favoriteGameIds') ?? '');
  }

  List<Game> get _favoriteGames {
    if (_favoriteGameIdsRaw.isEmpty) return GamesRegistry.all;
    final ids = _favoriteGameIdsRaw.split(',');
    return ids.map(GamesRegistry.game).whereType<Game>().toList();
  }

  Future<void> _openManageFavorites() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ManageFavoritesScreen()),
    );
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final games = _favoriteGames;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de jeux'),
        actions: [
          if (GamesRegistry.all.length > 1)
            IconButton(
              icon: const Icon(Icons.star_outline),
              tooltip: 'Gérer les favoris',
              onPressed: _openManageFavorites,
            ),
        ],
      ),
      body: ListView.separated(
        itemCount: games.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final game = games[index];
          return ListTile(
            title: Text(game.displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text('Suivi des parties'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SessionListScreen(game: game)),
              );
            },
          );
        },
      ),
    );
  }
}
