import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/track.dart';

class MusicSearchException implements Exception {
  const MusicSearchException(this.message);

  final String message;

  @override
  String toString() => 'MusicSearchException: $message';
}

class ItunesRemoteDataSource {
  ItunesRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _endpoint = Uri.parse('https://itunes.apple.com/search');

  Future<List<Track>> search(String term) async {
    final Uri uri = _endpoint.replace(queryParameters: {
      'term': term,
      'media': 'music',
      'limit': '25',
    });

    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (e) {
      throw MusicSearchException(e.toString());
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw MusicSearchException('HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw MusicSearchException('invalid response body: $e');
    }
    final List<dynamic> results = json['results'] as List<dynamic>? ?? const [];
    return results.map((dynamic item) {
      final Map<String, dynamic> map = item as Map<String, dynamic>;
      return Track(
        trackId: (map['trackId'] as num?)?.toInt() ?? 0,
        trackName: map['trackName'] as String? ?? '',
        artistName: map['artistName'] as String? ?? '',
        collectionName: map['collectionName'] as String? ?? '',
        primaryGenreName: map['primaryGenreName'] as String? ?? '',
        artworkUrl: map['artworkUrl60'] as String? ?? '',
        artworkUrlLarge: map['artworkUrl100'] as String? ?? '',
      );
    }).toList();
  }
}
