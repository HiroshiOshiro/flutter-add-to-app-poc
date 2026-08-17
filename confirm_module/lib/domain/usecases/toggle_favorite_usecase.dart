import '../repositories/favorites_repository.dart';

class ToggleFavoriteUseCase {
  const ToggleFavoriteUseCase(this._repository);

  final FavoritesRepository _repository;

  Future<void> call(int trackId, bool favorite) =>
      _repository.setFavorite(trackId, favorite);
}
