import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const _dbFileName = 'da_point.db';
  Database? _db;

  Future<Database> open() async {
    final db = _db;
    if (db != null) return db;
    final dir = await getDatabasesPath();
    final path = join(dir, _dbFileName);
    try {
      _db = await _openAt(path);
    } catch (_) {
      // Schéma modifié en développement — on repart sur un store vierge
      await _deleteStoreFiles(path);
      _db = await _openAt(path);
    }
    return _db!;
  }

  Future<Database> _openAt(String path) {
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sessions (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            gameId TEXT NOT NULL,
            startDate INTEGER NOT NULL,
            endDate INTEGER,
            status TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE players (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            sessionId TEXT NOT NULL,
            "order" INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE scores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionId TEXT NOT NULL,
            roundNumber INTEGER NOT NULL,
            playerName TEXT NOT NULL,
            points INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> _deleteStoreFiles(String path) async {
    for (final suffix in ['', '-wal', '-shm', '-journal']) {
      final f = File('$path$suffix');
      if (await f.exists()) {
        await f.delete();
      }
    }
  }
}
