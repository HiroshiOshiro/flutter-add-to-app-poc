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
