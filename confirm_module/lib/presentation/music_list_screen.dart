import 'package:flutter/material.dart';

import '../domain/entities/track.dart';
import '../domain/usecases/get_favorite_ids_usecase.dart';
import '../domain/usecases/search_tracks_usecase.dart';
import '../domain/usecases/toggle_favorite_usecase.dart';
import 'music_detail_screen.dart';
import 'music_strings.dart';

class MusicListScreen extends StatefulWidget {
  const MusicListScreen({
    super.key,
    required this.searchTracks,
    required this.getFavoriteIds,
    required this.toggleFavorite,
  });

  final SearchTracksUseCase searchTracks;
  final GetFavoriteIdsUseCase getFavoriteIds;
  final ToggleFavoriteUseCase toggleFavorite;

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Track> _tracks = const [];
  Set<int> _favoriteIds = const {};
  bool _loading = false;
  bool _searched = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final Set<int> ids = await widget.getFavoriteIds();
    if (!mounted) return;
    setState(() => _favoriteIds = ids);
  }

  Future<void> _performSearch() async {
    final String term = _searchController.text.trim();
    if (term.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      final List<Track> results = await widget.searchTracks(term);
      if (!mounted) return;
      setState(() {
        _tracks = results;
        _searched = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleFavorite(Track track) async {
    final bool newState = !_favoriteIds.contains(track.trackId);
    await widget.toggleFavorite(track.trackId, newState);
    if (!mounted) return;
    setState(() {
      _favoriteIds = newState
          ? {..._favoriteIds, track.trackId}
          : ({..._favoriteIds}..remove(track.trackId));
    });
  }

  Future<void> _openDetail(Track track) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => MusicDetailScreen(
        track: track,
        initiallyFavorite: _favoriteIds.contains(track.trackId),
        toggleFavorite: widget.toggleFavorite,
      ),
    ));
    // 詳細画面でお気に入りが変更されている可能性があるため再取得する。
    _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _performSearch(),
                      decoration: InputDecoration(
                        hintText: musicT('search_hint'),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _performSearch,
                    child: Text(musicT('search_button')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error) {
      return Center(child: Text(musicT('search_error')));
    }
    if (_searched && _tracks.isEmpty) {
      return Center(child: Text(musicT('no_results')));
    }
    return ListView.builder(
      itemCount: _tracks.length,
      itemBuilder: (context, index) {
        final Track track = _tracks[index];
        final bool isFavorite = _favoriteIds.contains(track.trackId);
        return ListTile(
          onTap: () => _openDetail(track),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              track.artworkUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 56,
                height: 56,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          title: Text(track.trackName, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(track.artistName, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: () => _toggleFavorite(track),
          ),
        );
      },
    );
  }
}
