# 参考資料

Flutter add-to-app導入にあたって参照したWeb資料。[MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)
の各節と対応させて分類している。

## 公式ドキュメント（一次情報）

- [Add Flutter to an existing app](https://docs.flutter.dev/add-to-app) —
  add-to-app全体の入口となるページ。Android/iOS双方の統合方法・
  パフォーマンス・プラットフォームチャンネルへのリンクがまとまっている。
- [Integrate a Flutter module into your Android project](https://docs.flutter.dev/add-to-app/android/project-setup) —
  Android統合の公式手順。source module方式とAAR方式の使い分けが説明されている。
- [Add a Flutter screen to an Android app](https://docs.flutter.dev/add-to-app/android/add-flutter-screen) —
  `FlutterActivity`/`FlutterFragment` の使い方と、`FlutterEngineCache` による
  エンジンの使い回しパターンを解説。
- [Integrate a Flutter module into your iOS project](https://docs.flutter.dev/add-to-app/ios/project-setup) —
  iOS統合の公式手順。CocoaPods方式と手動フレームワーク埋め込み方式の
  使い分けが説明されている。
- [Load sequence, performance, and memory](https://docs.flutter.dev/add-to-app/performance) —
  `FlutterEngine` の起動コストと、事前起動して使い回す「cached engine」
  パターンについての公式ガイダンス。本ガイド5節の元ネタ。
- [Multiple Flutter screens or views](https://docs.flutter.dev/add-to-app/multiple-flutters) —
  複数のFlutter画面・複数エンジンを扱う際の設計パターン。
- [Writing custom platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels) —
  `MethodChannel` の基本的な使い方・命名規則・非同期呼び出しのリファレンス。
- [Add Flutter to existing apps (Flutter wiki)](https://github.com/flutter/flutter/wiki/Add-Flutter-to-existing-apps/e1cd3050abcc9e37bcbf4371abb69b8ac1a8f253) —
  add-to-appの背景・設計思想についてのwikiページ。

## 実例・ブログ記事

- [flutter_add_to_app サンプル (GitHub)](https://github.com/shakiz/flutter_add_to_app) —
  Androidネイティブアプリへの組み込みサンプル実装。
- [Adding Flutter to your existing iOS and Android codebases (Medium)](https://medium.com/@ptruiz/adding-flutter-to-your-existing-ios-and-android-codebases-3e2c5a4797c1) —
  既存iOS/Androidコードベースへの導入体験記。
- [How to integrate Flutter into an existing native app: 2 options (funda tech blog)](https://blog.funda.nl/how-to-integrate-flutter-into-an-existing-native-app-two-approaches/) —
  既存ネイティブアプリへの2つの統合方式の比較。
- [Flutter module + Native Android (AAR) and iOS (Podfile) (Codemagic Blog)](https://blog.codemagic.io/integrating-flutter-module-to-your-native-app/) —
  AAR方式(Android)とCocoaPods方式(iOS)を1つのプロジェクトで実演する記事。
  具体的なビルドファイルの記述例が豊富で、公式ドキュメントの補完として有用。
