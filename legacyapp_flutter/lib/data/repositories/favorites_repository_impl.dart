import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_datasource.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl(this._localDataSource);

  final FavoritesLocalDataSource _localDataSource;

  @override
  Future<Set<int>> favoriteTrackIds() => _localDataSource.favoriteTrackIds();

  @override
  Future<void> setFavorite(int trackId, bool favorite) =>
      _localDataSource.setFavorite(trackId, favorite);
}
