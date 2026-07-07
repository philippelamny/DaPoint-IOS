import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/games_registry.dart';
import '../models/game.dart';

class ManageFavoritesScreen extends StatefulWidget {
  const ManageFavoritesScreen({super.key});

  @override
  State<ManageFavoritesScreen> createState() => _ManageFavoritesScreenState();
}

class _ManageFavoritesScreenState extends State<ManageFavoritesScreen> {
  String _favoriteGameIdsRaw = '';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _favoriteGameIdsRaw = prefs.getString('favoriteGameIds') ?? '';
      _loaded = true;
    });
  }

  Set<String> get _favoriteIds => _favoriteGameIdsRaw.isEmpty
      ? GamesRegistry.all.map((g) => g.id).toSet()
      : _favoriteGameIdsRaw.split(',').toSet();

  bool _isFavorite(Game game) => _favoriteIds.contains(game.id);

  Future<void> _toggleFavorite(Game game) async {
    final ids = _favoriteIds;
    if (ids.contains(game.id)) {
      ids.remove(game.id);
    } else {
      ids.add(game.id);
    }
    final raw = ids.join(',');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favoriteGameIds', raw);
    if (!mounted) return;
    setState(() => _favoriteGameIdsRaw = raw);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Gérer les favoris')),
      body: ListView.separated(
        itemCount: GamesRegistry.all.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final game = GamesRegistry.all[index];
          final isFav = _isFavorite(game);
          return ListTile(
            title: Text(game.displayName),
            trailing: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav ? Colors.amber : Colors.grey,
            ),
            onTap: () => _toggleFavorite(game),
          );
        },
      ),
    );
  }
}
