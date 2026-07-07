import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/games_registry.dart';
import '../models/game.dart';
import '../theme/brand.dart';
import 'manage_favorites_screen.dart';
import 'session_list_screen.dart';

const _gameColors = [Brand.start, Brand.end, Brand.accent];

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
    setState(
      () => _favoriteGameIdsRaw = prefs.getString('favoriteGameIds') ?? '',
    );
  }

  List<Game> get _favoriteGames {
    if (_favoriteGameIdsRaw.isEmpty) return GamesRegistry.all;
    final ids = _favoriteGameIdsRaw.split(',');
    return ids.map(GamesRegistry.game).whereType<Game>().toList();
  }

  Future<void> _openManageFavorites() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ManageFavoritesScreen()));
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final games = _favoriteGames;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _Header(onManageFavorites: _openManageFavorites),
          ),
          if (games.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Aucun jeu favori')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              sliver: SliverList.separated(
                itemCount: games.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final game = games[index];
                  final color = _gameColors[index % _gameColors.length];
                  return _GameCard(
                    game: game,
                    color: color,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SessionListScreen(game: game),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onManageFavorites});

  final VoidCallback onManageFavorites;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: Brand.gradient),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        16,
        24,
      ),
      child: Row(
        children: [
          const LogoMark(size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DaPoint',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Suivi de jeux',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          if (GamesRegistry.all.length > 1)
            IconButton(
              icon: const Icon(Icons.star_outline, color: Colors.white),
              tooltip: 'Gérer les favoris',
              onPressed: onManageFavorites,
            ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.color,
    required this.onTap,
  });

  final Game game;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(game.icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Suivi des parties',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
