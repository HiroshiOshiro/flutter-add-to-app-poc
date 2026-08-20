import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:legacyapp_flutter/domain/entities/track.dart';
import 'package:legacyapp_flutter/domain/repositories/favorites_repository.dart';
import 'package:legacyapp_flutter/domain/repositories/music_search_repository.dart';
import 'package:legacyapp_flutter/domain/usecases/get_favorite_ids_usecase.dart';
import 'package:legacyapp_flutter/domain/usecases/search_tracks_usecase.dart';
import 'package:legacyapp_flutter/domain/usecases/toggle_favorite_usecase.dart';
import 'package:legacyapp_flutter/presentation/music_list_screen.dart';

class _FakeMusicSearchRepository implements MusicSearchRepository {
  _FakeMusicSearchRepository(this.results);

  final List<Track> results;
  final List<String> searchedTerms = [];

  @override
  Future<List<Track>> search(String term) async {
    searchedTerms.add(term);
    return results;
  }
}

class _FailingMusicSearchRepository implements MusicSearchRepository {
  @override
  Future<List<Track>> search(String term) async {
    throw Exception('boom');
  }
}

class _FakeFavoritesRepository implements FavoritesRepository {
  _FakeFavoritesRepository([Set<int>? initial]) : _ids = {...?initial};

  Set<int> _ids;

  @override
  Future<Set<int>> favoriteTrackIds() async => _ids;

  @override
  Future<void> setFavorite(int trackId, bool favorite) async {
    _ids = favorite ? {..._ids, trackId} : ({..._ids}..remove(trackId));
  }
}

const Track _sampleTrack = Track(
  trackId: 1,
  trackName: 'Song A',
  artistName: 'Artist A',
  collectionName: 'Album A',
  primaryGenreName: 'Pop',
  artworkUrl: 'https://example.com/60.jpg',
  artworkUrlLarge: 'https://example.com/100.jpg',
);

Widget _wrap(Widget child) => MaterialApp(home: child);

Future<void> _search(WidgetTester tester, String term) async {
  await tester.enterText(find.byType(TextField), term);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Search'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('typing a term and tapping search shows results', (tester) async {
    final searchRepo = _FakeMusicSearchRepository([_sampleTrack]);
    final favoritesRepo = _FakeFavoritesRepository();

    await tester.pumpWidget(_wrap(MusicListScreen(
      searchTracks: SearchTracksUseCase(searchRepo),
      getFavoriteIds: GetFavoriteIdsUseCase(favoritesRepo),
      toggleFavorite: ToggleFavoriteUseCase(favoritesRepo),
    )));
    await tester.pumpAndSettle();

    await _search(tester, 'taro');

    expect(searchRepo.searchedTerms, ['taro']);
    expect(find.text('Song A'), findsOneWidget);
    expect(find.text('Artist A'), findsOneWidget);
  });

  testWidgets('shows the no-results message for an empty search', (tester) async {
    final searchRepo = _FakeMusicSearchRepository(const []);
    final favoritesRepo = _FakeFavoritesRepository();

    await tester.pumpWidget(_wrap(MusicListScreen(
      searchTracks: SearchTracksUseCase(searchRepo),
      getFavoriteIds: GetFavoriteIdsUseCase(favoritesRepo),
      toggleFavorite: ToggleFavoriteUseCase(favoritesRepo),
    )));
    await tester.pumpAndSettle();

    await _search(tester, 'taro');

    expect(find.text('No results found'), findsOneWidget);
  });

  testWidgets('shows an error message when search fails', (tester) async {
    final favoritesRepo = _FakeFavoritesRepository();

    await tester.pumpWidget(_wrap(MusicListScreen(
      searchTracks: SearchTracksUseCase(_FailingMusicSearchRepository()),
      getFavoriteIds: GetFavoriteIdsUseCase(favoritesRepo),
      toggleFavorite: ToggleFavoriteUseCase(favoritesRepo),
    )));
    await tester.pumpAndSettle();

    await _search(tester, 'taro');

    expect(find.text('Search failed'), findsOneWidget);
  });

  testWidgets('tapping the favorite icon toggles it via the repository',
      (tester) async {
    final searchRepo = _FakeMusicSearchRepository([_sampleTrack]);
    final favoritesRepo = _FakeFavoritesRepository();

    await tester.pumpWidget(_wrap(MusicListScreen(
      searchTracks: SearchTracksUseCase(searchRepo),
      getFavoriteIds: GetFavoriteIdsUseCase(favoritesRepo),
      toggleFavorite: ToggleFavoriteUseCase(favoritesRepo),
    )));
    await tester.pumpAndSettle();
    await _search(tester, 'taro');

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(await favoritesRepo.favoriteTrackIds(), {_sampleTrack.trackId});
  });

  testWidgets('tapping a track opens the detail screen with its info',
      (tester) async {
    final searchRepo = _FakeMusicSearchRepository([_sampleTrack]);
    final favoritesRepo = _FakeFavoritesRepository();

    await tester.pumpWidget(_wrap(MusicListScreen(
      searchTracks: SearchTracksUseCase(searchRepo),
      getFavoriteIds: GetFavoriteIdsUseCase(favoritesRepo),
      toggleFavorite: ToggleFavoriteUseCase(favoritesRepo),
    )));
    await tester.pumpAndSettle();
    await _search(tester, 'taro');

    await tester.tap(find.text('Song A'));
    await tester.pumpAndSettle();

    expect(find.text('Track details'), findsOneWidget);
    expect(find.text('Album A'), findsOneWidget);
  });
}
