import '../entities/track.dart';
import '../repositories/music_search_repository.dart';

class SearchTracksUseCase {
  const SearchTracksUseCase(this._repository);

  final MusicSearchRepository _repository;

  Future<List<Track>> call(String term) => _repository.search(term);
}
