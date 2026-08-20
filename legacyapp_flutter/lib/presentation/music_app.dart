import 'package:flutter/material.dart';

import '../domain/usecases/get_favorite_ids_usecase.dart';
import '../domain/usecases/search_tracks_usecase.dart';
import '../domain/usecases/toggle_favorite_usecase.dart';
import 'music_list_screen.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({
    super.key,
    required this.searchTracks,
    required this.getFavoriteIds,
    required this.toggleFavorite,
  });

  final SearchTracksUseCase searchTracks;
  final GetFavoriteIdsUseCase getFavoriteIds;
  final ToggleFavoriteUseCase toggleFavorite;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MusicListScreen(
        searchTracks: searchTracks,
        getFavoriteIds: getFavoriteIds,
        toggleFavorite: toggleFavorite,
      ),
    );
  }
}
