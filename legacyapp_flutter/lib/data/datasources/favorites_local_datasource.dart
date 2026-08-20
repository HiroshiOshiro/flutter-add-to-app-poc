import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class FavoritesLocalDataSource {
  static const String databaseFileName = 'music_favorites.db';

  Database? _db;

  Future<Database> _database() async {
    final Database? existing = _db;
    if (existing != null) return existing;

    final String databasesPath = await getDatabasesPath();
    final String path = p.join(databasesPath, databaseFileName);
    final Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) =>
          db.execute('CREATE TABLE favorites (track_id INTEGER PRIMARY KEY)'),
    );
    _db = db;
    return db;
  }

  Future<Set<int>> favoriteTrackIds() async {
    final Database db = await _database();
    final List<Map<String, Object?>> rows =
        await db.query('favorites', columns: ['track_id']);
    return rows.map((row) => row['track_id']! as int).toSet();
  }

  Future<void> setFavorite(int trackId, bool favorite) async {
    final Database db = await _database();
    if (favorite) {
      await db.insert(
        'favorites',
        {'track_id': trackId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await db.delete('favorites', where: 'track_id = ?', whereArgs: [trackId]);
    }
  }
}
