# Flutter組み込み作業ログ

`confirm_module`（確認画面のFlutterモジュール）の作成と、`legacy_android`
`legacy_ios` への組み込み作業の記録。実施した作業内容と、作業中に発生した
想定外の問題・その対処を時系列で残す。

## 1. confirm_module（Flutterモジュール単体）作成

### 作業内容
- `flutter create --template module --org com.example confirm_module` でモジュールを作成。
- 確認画面 (`lib/main.dart`) を実装。ネイティブとは `MethodChannel`
  (`com.example.legacyapp/confirm`) 1本で通信し、以下3メソッドのみを使う設計にした。
  - `getInitialData` : ネイティブが保持する入力内容 (name/email/message) を取得
  - `confirmSubmit` : 「確定」操作をネイティブへ依頼し、ネイティブの既存通信スタック
    (HttpURLConnection / NSURLSession) で送信、成否をFlutterへ返す
  - `goToComplete` : 送信成功後、ネイティブに完了画面への遷移を依頼
  - この設計により、認証ヘッダーや共通処理を含む既存の通信基盤をFlutter側に
    複製せず温存できる（大規模アプリでのadd-to-appの典型パターン）。
- バナー画像 (`profile_banner.png`) はモジュール自身の `assets/` にコピーして
  `pubspec.yaml` に登録。ネイティブ側アセットとは別ファイルとして重複保持する
  形になる（モジュール境界を越えたアセット共有の仕組みは用意していないため。
  実プロジェクトでは共有アセットパッケージを別途切り出すのが一般的）。
- 日英ローカライズは `flutter_localizations` は使わず、ネイティブの
  `strings.xml` / `Localizable.strings` と同じキーを持つ簡易な
  `Map<String, String>` をDart側に直接持たせ、`PlatformDispatcher.locale` で
  切り替える方式にした（モジュール単体としての依存を増やさないための簡略化。
  本格導入時は `flutter_localizations` + ARB管理に置き換えるのが望ましい）。

### 単体確認
- `flutter pub get` / `flutter analyze` が通ることを確認（No issues found）。
- `test/widget_test.dart` を、生成テンプレートのカウンターテストから
  「`getInitialData` の戻り値がそのまま画面に表示されること」を検証する
  ウィジェットテストに書き換え、`flutter test` が通ることを確認。

### 想定外だったこと
- `flutter create` で生成される `test/widget_test.dart` はテンプレートの
  カウンターアプリ (`MyApp`) を前提にしたテストのままで、`lib/main.dart` を
  書き換えた時点で `flutter analyze` がコンパイルエラーになった。
  生成直後のテストファイルはそのままでは使えないため、実装に合わせて
  書き換える前提で見ておく必要がある。

---

## 2. Android統合（confirm_moduleをlegacy_androidへ組み込み）

### 作業内容
- `settings.gradle` に `confirm_module/.android/include_flutter.groovy` を
  `evaluate` する形でsourceモジュールとして取り込み、`app/build.gradle` に
  `implementation project(':flutter')` を追加。
- `ConfirmFlutterActivity`（`io.flutter.embedding.android.FlutterActivity`
  のサブクラス）を追加し、`configureFlutterEngine` で
  `MethodChannel("com.example.legacyapp/confirm")` にハンドラを登録:
  - `getInitialData` → `BaseActivity.sFormData` の内容をMapで返す
  - `confirmSubmit` → 別スレッドで旧`ConfirmActivity`にあった
    `HttpURLConnection`によるPOST処理をそのまま実行し、成否を返す
  - `goToComplete` → `CompleteActivity` を起動してこの画面を`finish()`
- `FlutterActivity`はScaffoldで自前のAppBarを描画するため、ネイティブの
  ActionBarと二重にならないよう `Theme.MaterialComponents.Light.NoActionBar`
  ベースの専用テーマ(`FlutterActivityTheme`)をManifestで指定。
- `MemoFragment` の遷移先を `ConfirmActivity` → `ConfirmFlutterActivity` に
  変更し、旧 `ConfirmActivity.java` / `activity_confirm.xml` を削除。

### 想定外だったこと（重要）
1. **`dependencyResolutionManagement` の `FAIL_ON_PROJECT_REPOS` と衝突。**
   `legacy_android/settings.gradle` は最初から
   `repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)` を設定していたが、
   Flutter Gradleプラグイン (`confirm_module/.android/Flutter/build.gradle`)
   がプロジェクトレベルで独自にmavenリポジトリを追加しようとするため、
   ```
   Build was configured to prefer settings repositories over project repositories
   but repository 'maven' was added by plugin 'dev.flutter.flutter-gradle-plugin'
   ```
   で即失敗した。`RepositoriesMode.PREFER_SETTINGS` に緩和して解決。
2. **リポジトリを緩和しただけではFlutterエンジン本体が見つからない。**
   `PREFER_SETTINGS`にすると、プロジェクト側が独自にリポジトリを宣言している
   場合はそちらを無視してsettings側のリポジトリのみで解決しようとする挙動に
   なるため、`google()`/`mavenCentral()`だけでは
   `io.flutter:flutter_embedding_debug` 等のFlutterエンジンAARが見つからず
   `Could not resolve...` で失敗した。Flutterエンジンの配布元
   `https://storage.googleapis.com/download.flutter.io` を
   `settings.gradle` の `dependencyResolutionManagement.repositories` に
   明示的に追加して解決。
   → **教訓**: 「集中管理リポジトリ (`dependencyResolutionManagement`) を
   厳格運用しているAndroidプロジェクトにadd-to-appでFlutterモジュールを
   足す場合、settings.gradle側にFlutterのmavenリポジトリを明示追加する
   必要がある」ことは公式ドキュメントには明記されておらず、素朴に
   `include_flutter.groovy` を読み込むだけでは失敗する。

### 起動確認
- `./gradlew assembleDebug` が成功することを確認。
- エミュレータで実際に Input(ネイティブ) → 次へ → Confirm(**Flutter**) →
  Confirm(**ネイティブHTTP送信**) → Complete(ネイティブ) という一連の流れを
  操作して確認。Flutter画面にネイティブ入力値(`getInitialData`)が正しく
  渡り、送信後は自動でネイティブのComplete画面に遷移することを確認した。
  ActionBarの二重表示も発生していない。

---

## 3. iOS統合（confirm_moduleをlegacy_iosへ組み込み）

### 作業内容
- `legacy_ios/Podfile` を作成し、`confirm_module/.ios/Flutter/podhelper.rb` を
  `load` して `install_all_flutter_pods` で組み込み。`pod install` で
  `LegacyApp.xcworkspace` を生成。
- `ConfirmFlutterViewController`（`FlutterViewController` のサブクラス）を
  追加し、`FlutterMethodChannel("com.example.legacyapp/confirm")` に
  `getInitialData` / `confirmSubmit` / `goToComplete` のハンドラを実装
  (Android版のConfirmFlutterActivityと対称的な設計)。
- `InputViewController` の遷移先を `ConfirmViewController`(ネイティブ) →
  `ConfirmFlutterViewController` に変更し、旧 `ConfirmViewController.h/.m`
  を削除。

### 想定外だったこと（重要、3段階でハマった）
1. **`pod install` がPodfileの記法不足でエラー。**
   `install_all_flutter_pods` だけでは
   `Missing flutter_post_install(installer) in Podfile post_install block`
   でエラーになった。`post_install do |installer| flutter_post_install(installer) end`
   をPodfileに追記して解決。公式のPodfileサンプルをそのまま貼るだけでは
   足りず、`podhelper.rb` が要求するpost_installフックの追加が別途必要。
2. **`xcodegen generate` を再実行するとCocoaPods統合が消える。**
   新規ソースファイル追加のために `xcodegen generate` で `.xcodeproj` を
   再生成すると、CocoaPodsが `project.pbxproj` に注入した設定
   (Pods統合のビルドフェーズ等)が失われ、`pod install` をやり直すまで
   ビルドが壊れる。**「project.ymlやソース構成を変更する → `xcodegen generate`
   → `pod install` → ビルド」の順序を毎回徹底する必要がある。**
   xcodegenのみでプロジェクトを管理していたAndroid/iOS双方の運用に、
   CocoaPods導入後は一手間増える。
3. **`FlutterEngine` を「アプリ起動時に1回だけrunして使い回す」設計にしたら
   Confirm画面が永久にローディングのまま止まった。**
   Dartの`main()`（＝`ConfirmScreen.initState()`内の`getInitialData`呼び出し）は
   エンジンの生存期間中に**一度しか実行されない**。アプリ起動時にエンジンを
   runすると、そのタイミングではまだ`MethodChannel`のハンドラを登録して
   いない（ユーザーがまだConfirm画面を開いていないため）ので、
   `getInitialData`が永久に解決されないまま`ConfirmScreen`が
   ローディング状態に固まった。
   - 1回目の対処(ハンドラをrunの前に登録)は
     `-[FlutterEngine setMessageHandlerOnChannel:...]`が
     `FlutterBinaryMessengerRelay`内で `EXC_CRASH`(NSException)を起こした
     （エンジンがrunされる前は`engine.binaryMessenger`経由のハンドラ登録が
     使えない）。
   - 2回目の対処(`initWithEngine:`を先に呼ぶ)は、エンジンがrunされる前に
     プラットフォームビューへアタッチしようとして
     `EXC_BAD_ACCESS`(SIGSEGV)でクラッシュした。
   - **最終的な解決策**: 「アプリ全体で1つの温存エンジンを使い回す」設計を
     やめ、**Confirm画面を開くたびに新しい`FlutterEngine`を生成してrunする**
     方式に変更。`run()` → `initWithEngine:`(ここでアタッチ、runは済んでいる
     ので安全) → `MethodChannel`のハンドラ登録、という順序を守れば
     クラッシュもハングも起きない。Dartの初回フレーム(および
     `getInitialData`呼び出し)は、ビュー実体がロードされる少し後の
     タイミングで発生するため、`init`内の同期処理が先に完了していれば
     間に合う。
   - トレードオフとして毎回エンジンを起動し直すため、温存エンジンに比べて
     起動が数百ms程度遅くなる。本番アプリで温存エンジンの高速起動を
     活かしたい場合は、`initState`で即座にデータ取得する設計ではなく、
     ネイティブ側から明示的にデータをpushする(あるいは`initialRoute`/
     エンジン再利用時の再初期化フックを使う)設計に変更する必要がある。

### 起動確認
- `xcodebuild -workspace LegacyApp.xcworkspace -scheme LegacyApp ...` が
  成功することを確認。
- シミュレータで実際に Input(ネイティブ) → 次へ → Confirm(**Flutter**) →
  Confirm(**ネイティブNSURLSession送信**) → Complete(ネイティブ) という
  一連の流れを操作して確認。Flutter画面にネイティブ入力値
  (`getInitialData`)が正しく渡り、送信後は自動でネイティブのComplete画面に
  遷移することを確認した。

---
