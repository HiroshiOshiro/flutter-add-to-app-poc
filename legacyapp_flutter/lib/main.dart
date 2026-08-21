import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/confirm_screen.dart';
import 'data/datasources/favorites_local_datasource.dart';
import 'data/datasources/itunes_remote_datasource.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'data/repositories/music_search_repository_impl.dart';
import 'domain/usecases/get_favorite_ids_usecase.dart';
import 'domain/usecases/search_tracks_usecase.dart';
import 'domain/usecases/toggle_favorite_usecase.dart';
import 'presentation/music_app.dart';

// DIの組み立て(ネイティブ連携チャンネル・リポジトリ・UseCaseの配線)は
// presentation/confirm_providers.dart のRiverpod providerに集約している。
void main() {
  runApp(const ProviderScope(child: ConfirmApp()));
}

// Musicタブ用の別エントリポイント。1つのAndroidアプリ/iOSアプリに組み込める
// Flutterモジュールは1つまでという制約(source module/CocoaPods integration
// がともに単一モジュール前提のAPIになっている)があるため、画面ごとに
// モジュールを分けるのではなく、同じモジュール内で複数のDartエントリポイントを
// 使い分ける(docs/MIGRATION_GUIDE.md 6節参照)。
//
// この関数自体は main.dart (エンジンのルートライブラリ) に置く必要がある。
// 別ファイルに置いて @pragma('vm:entry-point') を付けるだけではツリー
// シェイキングからは保護されるが、DartEntrypoint(path, "musicMain") のように
// ライブラリを指定せずに名前だけで呼び出すとルートライブラリの中しか
// 探索されないため「Could not resolve main entrypoint function」で失敗する。
@pragma('vm:entry-point')
void musicMain() {
  final ItunesRemoteDataSource remoteDataSource = ItunesRemoteDataSource();
  final FavoritesLocalDataSource favoritesDataSource = FavoritesLocalDataSource();
  final MusicSearchRepositoryImpl searchRepository =
      MusicSearchRepositoryImpl(remoteDataSource);
  final FavoritesRepositoryImpl favoritesRepository =
      FavoritesRepositoryImpl(favoritesDataSource);

  runApp(MusicApp(
    searchTracks: SearchTracksUseCase(searchRepository),
    getFavoriteIds: GetFavoriteIdsUseCase(favoritesRepository),
    toggleFavorite: ToggleFavoriteUseCase(favoritesRepository),
  ));
}

class ConfirmApp extends StatelessWidget {
  const ConfirmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConfirmScreen(),
    );
  }
}
