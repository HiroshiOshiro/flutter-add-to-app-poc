import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:legacyapp_flutter/data/datasources/favorites_local_datasource.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final String databasesPath = await databaseFactory.getDatabasesPath();
    await databaseFactory.deleteDatabase(
      p.join(databasesPath, FavoritesLocalDataSource.databaseFileName),
    );
  });

  test('favoriteTrackIds reflects setFavorite calls', () async {
    final dataSource = FavoritesLocalDataSource();

    expect(await dataSource.favoriteTrackIds(), isEmpty);

    await dataSource.setFavorite(1, true);
    await dataSource.setFavorite(2, true);
    expect(await dataSource.favoriteTrackIds(), {1, 2});

    await dataSource.setFavorite(1, false);
    expect(await dataSource.favoriteTrackIds(), {2});
  });

  test('setFavorite(id, true) twice does not duplicate the row', () async {
    final dataSource = FavoritesLocalDataSource();

    await dataSource.setFavorite(5, true);
    await dataSource.setFavorite(5, true);

    expect(await dataSource.favoriteTrackIds(), {5});
  });
}
