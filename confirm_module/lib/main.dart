import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/datasources/confirm_native_datasource.dart';
import 'data/datasources/confirm_remote_datasource.dart';
import 'data/repositories/confirm_navigator_impl.dart';
import 'data/repositories/confirm_repository_impl.dart';
import 'domain/usecases/complete_confirmation_usecase.dart';
import 'domain/usecases/get_initial_data_usecase.dart';
import 'domain/usecases/submit_confirmation_usecase.dart';
import 'presentation/confirm_screen.dart';
import 'data/datasources/favorites_local_datasource.dart';
import 'data/datasources/itunes_remote_datasource.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'data/repositories/music_search_repository_impl.dart';
import 'domain/usecases/get_favorite_ids_usecase.dart';
import 'domain/usecases/search_tracks_usecase.dart';
import 'domain/usecases/toggle_favorite_usecase.dart';
import 'presentation/music_app.dart';

// ネイティブ側 (Android: ConfirmFlutterActivity, iOS: ConfirmFlutterViewController)
// と1対1で対応するチャンネル名。呼び出し可能なメソッドは2つ:
//   getInitialData -> ネイティブが保持する入力内容を取得
//   goToComplete   -> ネイティブに完了画面への遷移を依頼
// 確認内容の送信(POST)は以前はネイティブに委譲していたが、通信処理は
// Flutter側(ConfirmRemoteDataSource)に寄せたためチャンネルには含まれない。
const MethodChannel _channel = MethodChannel('com.example.legacyapp/confirm');

void main() {
  final ConfirmNativeDataSource nativeDataSource =
      ConfirmNativeDataSource(_channel);
  final ConfirmRemoteDataSource remoteDataSource = ConfirmRemoteDataSource();
  final ConfirmRepositoryImpl repository = ConfirmRepositoryImpl(
    nativeDataSource: nativeDataSource,
    remoteDataSource: remoteDataSource,
  );
  final ConfirmNavigatorImpl navigator = ConfirmNavigatorImpl(nativeDataSource);

  runApp(ConfirmApp(
    getInitialData: GetInitialDataUseCase(repository),
    submitConfirmation: SubmitConfirmationUseCase(repository),
    completeConfirmation: CompleteConfirmationUseCase(navigator),
  ));
}

// Musicタブ用の別エントリポイント。1つのAndroidアプリ/iOSアプリに組み込める
// Flutterモジュールは1つまでという制約(source module/CocoaPods integration
// がともに単一モジュール前提のAPIになっている)があるため、画面ごとに
// モジュールを分けるのではなく、同じモジュール内で複数のDartエントリポイントを
// 使い分ける(docs/MIGRATION_GUIDE.md 9節参照)。
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
  const ConfirmApp({
    super.key,
    required this.getInitialData,
    required this.submitConfirmation,
    required this.completeConfirmation,
  });

  final GetInitialDataUseCase getInitialData;
  final SubmitConfirmationUseCase submitConfirmation;
  final CompleteConfirmationUseCase completeConfirmation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConfirmScreen(
        getInitialData: getInitialData,
        submitConfirmation: submitConfirmation,
        completeConfirmation: completeConfirmation,
      ),
    );
  }
}
