import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class AppDatabase {
  static const _dbFileName = 'da_point.db';
  Database? _db;

  Future<Database> open() async {
    final db = _db;
    if (db != null) return db;
    if (kIsWeb) {
      // sqflite has no native web backend: back it with a SQLite build
      // compiled to WebAssembly, persisted in the browser (OPFS/IndexedDB).
      databaseFactory = databaseFactoryFfiWeb;
    }
    final path = kIsWeb ? _dbFileName : join(await getDatabasesPath(), _dbFileName);
    try {
      _db = await _openAt(path);
    } catch (_) {
      // Schéma modifié en développement — on repart sur un store vierge
      await databaseFactory.deleteDatabase(path);
      _db = await _openAt(path);
    }
    return _db!;
  }

  Future<Database> _openAt(String path) {
    return openDatabase(
      path,
      version: 2,
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
            points INTEGER NOT NULL,
            createdAt INTEGER NOT NULL DEFAULT 0,
            remainingCards INTEGER,
            placedCards INTEGER
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE scores ADD COLUMN createdAt INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE scores ADD COLUMN remainingCards INTEGER');
          await db.execute('ALTER TABLE scores ADD COLUMN placedCards INTEGER');
        }
      },
    );
  }
}
