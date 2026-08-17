import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:confirm_module/data/datasources/itunes_remote_datasource.dart';

void main() {
  test('search parses the iTunes response into tracks', () async {
    Uri? capturedUri;
    final mockClient = MockClient((request) async {
      capturedUri = request.url;
      return http.Response(
        '''
        {
          "results": [
            {
              "trackId": 42,
              "trackName": "Song A",
              "artistName": "Artist A",
              "collectionName": "Album A",
              "primaryGenreName": "Pop",
              "artworkUrl60": "https://example.com/60.jpg",
              "artworkUrl100": "https://example.com/100.jpg"
            }
          ]
        }
        ''',
        200,
      );
    });
    final dataSource = ItunesRemoteDataSource(client: mockClient);

    final tracks = await dataSource.search('taro');

    expect(capturedUri, isNotNull);
    expect(capturedUri!.host, 'itunes.apple.com');
    expect(capturedUri!.queryParameters['term'], 'taro');
    expect(capturedUri!.queryParameters['media'], 'music');
    expect(tracks, hasLength(1));
    expect(tracks.single.trackId, 42);
    expect(tracks.single.trackName, 'Song A');
    expect(tracks.single.artistName, 'Artist A');
    expect(tracks.single.collectionName, 'Album A');
    expect(tracks.single.primaryGenreName, 'Pop');
    expect(tracks.single.artworkUrl, 'https://example.com/60.jpg');
    expect(tracks.single.artworkUrlLarge, 'https://example.com/100.jpg');
  });

  test('search throws MusicSearchException on a non-2xx response', () async {
    final mockClient = MockClient((request) async => http.Response('', 500));
    final dataSource = ItunesRemoteDataSource(client: mockClient);

    expect(() => dataSource.search('taro'), throwsA(isA<MusicSearchException>()));
  });

  test('search throws MusicSearchException when the request throws', () async {
    final mockClient = MockClient((request) async => throw Exception('boom'));
    final dataSource = ItunesRemoteDataSource(client: mockClient);

    expect(() => dataSource.search('taro'), throwsA(isA<MusicSearchException>()));
  });
}
