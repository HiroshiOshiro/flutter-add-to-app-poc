import '../entities/track.dart';

abstract class MusicSearchRepository {
  Future<List<Track>> search(String term);
}
