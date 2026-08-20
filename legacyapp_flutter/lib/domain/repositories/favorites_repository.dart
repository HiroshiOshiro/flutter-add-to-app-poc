abstract class FavoritesRepository {
  Future<Set<int>> favoriteTrackIds();

  Future<void> setFavorite(int trackId, bool favorite);
}
