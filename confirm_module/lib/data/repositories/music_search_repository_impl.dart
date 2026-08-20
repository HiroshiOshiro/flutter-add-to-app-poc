import '../../domain/entities/track.dart';
import '../../domain/repositories/music_search_repository.dart';
import '../datasources/itunes_remote_datasource.dart';

class MusicSearchRepositoryImpl implements MusicSearchRepository {
  const MusicSearchRepositoryImpl(this._remoteDataSource);

  final ItunesRemoteDataSource _remoteDataSource;

  @override
  Future<List<Track>> search(String term) => _remoteDataSource.search(term);
}
