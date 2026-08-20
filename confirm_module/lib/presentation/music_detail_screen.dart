import 'package:flutter/material.dart';

import '../domain/entities/track.dart';
import '../domain/usecases/toggle_favorite_usecase.dart';
import 'music_strings.dart';

class MusicDetailScreen extends StatefulWidget {
  const MusicDetailScreen({
    super.key,
    required this.track,
    required this.initiallyFavorite,
    required this.toggleFavorite,
  });

  final Track track;
  final bool initiallyFavorite;
  final ToggleFavoriteUseCase toggleFavorite;

  @override
  State<MusicDetailScreen> createState() => _MusicDetailScreenState();
}

class _MusicDetailScreenState extends State<MusicDetailScreen> {
  late bool _isFavorite = widget.initiallyFavorite;

  Future<void> _onFavoriteTapped() async {
    final bool newState = !_isFavorite;
    await widget.toggleFavorite(widget.track.trackId, newState);
    if (!mounted) return;
    setState(() => _isFavorite = newState);
  }

  @override
  Widget build(BuildContext context) {
    final Track track = widget.track;
    return Scaffold(
      appBar: AppBar(title: Text(musicT('detail_title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  track.artworkUrlLarge,
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 200,
                    height: 200,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                track.trackName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                track.artistName,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: _onFavoriteTapped,
                child: Text(musicT(
                  _isFavorite ? 'action_remove_favorite' : 'action_add_favorite',
                )),
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row(musicT('label_album'), track.collectionName),
                    const SizedBox(height: 16),
                    _row(musicT('label_genre'), track.primaryGenreName),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 17)),
      ],
    );
  }
}
