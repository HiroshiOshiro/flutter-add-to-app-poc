import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:legacyapp_flutter/domain/entities/track.dart';
import 'package:legacyapp_flutter/domain/repositories/favorites_repository.dart';
import 'package:legacyapp_flutter/domain/usecases/toggle_favorite_usecase.dart';
import 'package:legacyapp_flutter/presentation/music_detail_screen.dart';

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
  trackId: 7,
  trackName: 'Song B',
  artistName: 'Artist B',
  collectionName: 'Album B',
  primaryGenreName: 'Rock',
  artworkUrl: 'https://example.com/60.jpg',
  artworkUrlLarge: 'https://example.com/100.jpg',
);

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('shows track info and the add-favorite label initially',
      (tester) async {
    final favoritesRepo = _FakeFavoritesRepository();

    await tester.pumpWidget(_wrap(MusicDetailScreen(
      track: _sampleTrack,
      initiallyFavorite: false,
      toggleFavorite: ToggleFavoriteUseCase(favoritesRepo),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Song B'), findsOneWidget);
    expect(find.text('Artist B'), findsOneWidget);
    expect(find.text('Album B'), findsOneWidget);
    expect(find.text('Rock'), findsOneWidget);
    expect(find.text('Add to favorites'), findsOneWidget);
  });

  testWidgets('tapping the favorite button toggles the label and persists it',
      (tester) async {
    final favoritesRepo = _FakeFavoritesRepository();

    await tester.pumpWidget(_wrap(MusicDetailScreen(
      track: _sampleTrack,
      initiallyFavorite: false,
      toggleFavorite: ToggleFavoriteUseCase(favoritesRepo),
    )));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to favorites'));
    await tester.pumpAndSettle();

    expect(find.text('Remove from favorites'), findsOneWidget);
    expect(await favoritesRepo.favoriteTrackIds(), {_sampleTrack.trackId});
  });

  testWidgets('starts with the remove-favorite label when already a favorite',
      (tester) async {
    final favoritesRepo = _FakeFavoritesRepository({_sampleTrack.trackId});

    await tester.pumpWidget(_wrap(MusicDetailScreen(
      track: _sampleTrack,
      initiallyFavorite: true,
      toggleFavorite: ToggleFavoriteUseCase(favoritesRepo),
    )));
    await tester.pumpAndSettle();

    expect(find.text('Remove from favorites'), findsOneWidget);
  });
}
