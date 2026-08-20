# flutter-add-to-app-poc

大規模な既存モバイルアプリ（iOS: Objective-C / Android: Java、いずれも旧
アーキテクチャ）に、Flutterを画面単位で段階的に導入する「add-to-app」方式の
検証用リポジトリ。

- `legacy_android/` — 移行前を模したAndroidアプリ（Java）。確認画面
  （`ConfirmFlutterActivity.kt`）とMusicタブ（`MusicFlutterEngineHolder.kt`）
  がFlutter化済み
- `legacy_ios/` — 移行前を模したiOSアプリ（Objective-C）。確認画面
  （`ConfirmFlutterViewController.swift`）とMusicタブ
  （`MusicFlutterViewController.swift`）がFlutter化済み
- `legacyapp_flutter/` — 確認画面・Music機能を実装したFlutterモジュール
  （presentation/domain/dataのレイヤードアーキテクチャ、`main()`と
  `musicMain()`の2つのDartエントリポイントを持つ）
- `docs/MIGRATION_GUIDE.md` — 一般化した導入手順・設計判断のまとめ
- `docs/FLUTTER_INTEGRATION_LOG.md` — 実際の作業ログ（つまずいた点の詳細）
- `docs/FLUTTER_LEARNING_GUIDE.md` — Flutter未経験者向けの学習ガイド
  （学習教材・つまずきやすいポイント・本リポジトリの読み方）

## 前提環境

- Flutter SDK（`legacyapp_flutter/.metadata` に記録されているものと同じ
  リビジョン・チャンネルを推奨）
- Android: Android Studio（JDK同梱）、Android SDK、Androidエミュレータ
- iOS: Xcode、CocoaPods、[XcodeGen](https://github.com/yonaskolb/XcodeGen)
- いずれも `flutter` コマンドがPATHで使えること（`flutter doctor` で確認）

## Android（legacy_android）を実行する

1. Flutterモジュールの依存を取得しておく（初回のみ）
   ```bash
   cd legacyapp_flutter
   flutter pub get
   ```
2. `legacy_android` をAndroid Studioで開き、エミュレータ/実機を選んで
   Runする。

コマンドラインでビルドする場合:

```bash
cd legacy_android
# `java` コマンドが見つからない場合は、Android Studio同梱のJDKを指定する
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
./gradlew assembleDebug
```

生成された `app/build/outputs/apk/debug/app-debug.apk` を、起動中の
エミュレータ/実機にインストールして起動する:

```bash
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell am start -n com.example.legacyapp/.MainActivity
```

## iOS（legacy_ios）を実行する

1. Flutterモジュールの依存を取得しておく（初回のみ、Androidと共通）
   ```bash
   cd legacyapp_flutter
   flutter pub get
   ```
2. Xcodeプロジェクトを生成し、CocoaPodsで依存を解決する
   ```bash
   cd legacy_ios
   xcodegen generate
   export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8   # 環境によっては pod install に必要
   pod install
   ```
3. **`LegacyApp.xcworkspace` を開く**（`.xcodeproj` を直接開くと
   CocoaPods経由のFlutter依存が解決されず `Library 'FlutterPluginRegistrant'
   not found` などのビルドエラーになる）
   ```bash
   open LegacyApp.xcworkspace
   ```
4. Xcode上でシミュレータ/実機を選んでRunする。

`project.yml` や `legacy_ios/LegacyApp/Sources` 配下にファイルを追加・削除
した場合は、`xcodegen generate` → `pod install` → ビルド、の順序を毎回
守ること（詳細は [MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md) 4節）。

コマンドラインでビルドする場合:

```bash
cd legacy_ios
xcodebuild -workspace LegacyApp.xcworkspace -scheme LegacyApp \
  -sdk iphonesimulator -configuration Debug \
  -destination "generic/platform=iOS Simulator" build
```

## legacyapp_flutter（Flutterモジュール）単体で確認する

```bash
cd legacyapp_flutter
flutter pub get
flutter analyze
flutter test
```

## 一連の操作フロー

どちらのアプリも「メモ」タブの入力画面から次の流れで確認できる。

1. Name / Email / Message を入力して「次へ」
2. 確認画面（Flutter製）で入力内容を確認し「確定」
   - 送信（POST）はFlutter側（`legacyapp_flutter`）が直接行う
3. 完了画面（ネイティブ）に自動遷移

「Music」タブ（Flutter製）では iTunes Search API を使った楽曲検索・
一覧・詳細表示・お気に入り登録（`sqflite`によるローカルDB保存）を
確認できる。検索結果一覧・詳細画面ともFlutter内の`Navigator`で遷移する。
