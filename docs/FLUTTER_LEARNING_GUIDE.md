# Flutter学習ガイド

Flutter未経験のエンジニアが、業務でFlutterコードを読み書きできるように
なるまでの学習教材とポイントをまとめる。前半は他プロジェクトでも通用する
一般的な学習ロードマップ、後半（8節以降）は本リポジトリのコードを実際に
読み進めるための案内になっている。

## 1. 前提: Dartの基礎から始める

FlutterはDart言語の上に成り立っている。Widgetの前にDartの文法でつまずくと
遠回りになるため、最初にDart自体を軽く触っておくと良い。

- Null安全（`?` / `!` / `late`）: 変数がnullになり得るかどうかを型で表現する。
  Flutterのコードには非常に頻出する。
- `async` / `await` / `Future`: JavaScriptのPromiseに近い非同期処理の仕組み。
  本リポジトリのAPI呼び出し・DB操作はほぼ全てこの形。
- 名前付きコンストラクタ引数（`required this.xxx`）: Widgetのコンストラクタで
  多用される。
- `class` / `mixin` / `extends` / `implements`: レイヤードアーキテクチャの
  抽象（インターフェース）と実装の関係を読むのに必要。

これらは [DartPad](https://dartpad.dev/) でブラウザ上のまま試せる。

## 2. 推奨する学習順序

1. **Dartの基礎文法**（[A tour of the Dart language](https://dart.dev/language)）
2. **Flutterの基礎**（公式Codelab [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)）
   - `StatelessWidget` / `StatefulWidget` の違い
   - `build()` が「今の状態からUIを作り直す関数」であるという考え方
     （Reactの仮想DOMに近い宣言的UI）
3. **レイアウトの基本**（[Layout tutorial](https://docs.flutter.dev/ui/layout/tutorial)）
   - `Row` / `Column` / `Expanded` / `Padding` などの組み合わせでUIを作る感覚
4. **非同期処理とUI**（`Future`, `async`/`await`, `FutureBuilder`）
   - 「データ取得中はローディング表示、取得できたら描画」というパターンの書き方
5. **状態管理**（最初は`setState`、次にRiverpodなどの外部状態管理）
   - なぜ`setState`だけでは大きくなると辛くなるのか、を体感してから
     Riverpod等を学ぶと理解が早い
6. **テスト**（[Widget testing](https://docs.flutter.dev/testing/overview)）
7. **プラットフォーム連携**（[Platform channels](https://docs.flutter.dev/platform-integration/platform-channels)）
   - Dart側とネイティブ側（Kotlin/Swift等）がどうやってメッセージを
     やり取りするか

順番に一気通貫でやる必要はなく、実際に手を動かすコード（後述8節）を
読みながら該当箇所だけ深掘りする、という進め方でも十分機能する。

## 3. 公式の学習教材

- [docs.flutter.dev](https://docs.flutter.dev/) — 公式ドキュメントのトップ。
  迷ったらまずここを検索する
- [Flutter Codelabs](https://docs.flutter.dev/codelabs) — 手を動かして学べる
  公式チュートリアル集
- [Flutter widget catalog](https://docs.flutter.dev/ui/widgets) — 各Widgetの
  一覧とサンプル。「こういうUIを作りたい」ときの辞書として使う
- [Dart language tour](https://dart.dev/language) — Dart文法のリファレンス
- [Effective Dart](https://dart.dev/effective-dart) — 命名規則・書き方の
  スタイルガイド。コードレビューで指摘されやすい点の多くがここに書いてある

## 4. 状態管理ライブラリ（Riverpod）

`setState`はWidget内で完結する状態管理には向くが、複数Widget間でのDIや
状態共有が必要になると手作業でのバケツリレーが辛くなる。Riverpodは
Provider経由でDIと状態管理の両方を扱えるライブラリ。

- [riverpod.dev](https://riverpod.dev/) — 公式ドキュメント。まずは
  「Providers」「Notifier」の章を読む
- 覚えておくと良い語彙:
  - `Provider` : 依存関係を解決するだけの、状態を持たないもの（リポジトリなど）
  - `Notifier` / `NotifierProvider` : 状態を持ち、更新できるもの
    （画面の状態管理はここ）
  - `ref.watch` : 値の変化を購読する（build内で使う）
  - `ref.read` : その場で一度だけ値を読む（ボタンのonPressed内など）
  - `ProviderScope` : アプリ全体（または画面）をRiverpodの管理下に置くための
    ルートWidget
  - `overrides` : テストで依存を差し替える仕組み

## 5. テストの考え方

Flutterのテストは主に2種類ある。

- **単体テスト**（`test()`）: クラス・関数単体の振る舞いを検証する。
  Dartのみで完結し、UIは絡まない
- **Widgetテスト**（`testWidgets()`）: Widgetをメモリ上に描画し、
  タップやテキスト入力などの操作をシミュレートして検証する。
  実機・エミュレータは不要で高速に回せる

外部依存（ネイティブとの通信、HTTP、DB）はそのまま呼び出さず、
インターフェース（抽象クラス）に対するfake実装やモックに差し替えてから
テストするのが基本パターン。「本物のネットワーク・DBを叩かずに、
本物と同じインターフェースを満たすダミーに差し替える」という考え方に
最初は戸惑いやすいが、テストの高速化・安定化のために必須のプラクティス。

## 6. つまずきやすいポイント

- **Widgetは「宣言」であって「命令」ではない。** `build()`の中でUIを直接
  書き換えるのではなく、「今の状態を渡したらこういうUIになる」という
  関数として書く。状態が変わったら`build()`が自動的に呼び直される。
- **`BuildContext`の扱い。** 非同期処理（`await`）を挟んだ後に
  `context`を使う場合、その時点でWidgetがまだ画面に存在するかを
  確認する必要がある（`context.mounted`、StatefulWidgetなら`mounted`、
  Riverpodなら`ref.mounted`または`ref.onDispose`での自前管理）。
  確認せずに使うと、既に破棄されたWidgetに対する操作でエラーになる。
- **ホットリロードとホットリスタートの違い。** ホットリロードはコード変更を
  即座に反映するが、既存の状態（変数の値など）は保持される。
  ロジックを変えたのに画面が更新されない/おかしいときは、
  ホットリスタート（状態を初期化して再起動）を試す。
- **`pubspec.yaml`の依存追加後は`flutter pub get`を忘れない。**
  IDEが自動実行してくれない環境もある。
- **Nullable型の`!`は「ここは絶対nullじゃない」という宣言。** 実際にnullが
  来ると実行時エラーになるため、乱用せず`??`（デフォルト値）や
  `if (x != null)`での分岐を優先する。

## 7. 用語集（最低限）

| 用語 | 意味 |
|---|---|
| Widget | 画面を構成する部品。UIそのものというより「UIの設計図」 |
| `BuildContext` | Widgetツリー上での自分の位置を表す情報。`Navigator`や`Theme`の参照に使う |
| `State` | `StatefulWidget`が保持する可変データ。`setState`で更新すると再描画される |
| ホットリロード | コード変更を実行中のアプリへ即座に反映する開発機能 |
| Widgetテスト | UIをメモリ上に描画して検証するテスト（実機不要） |
| MethodChannel | Dart側とネイティブ側（Kotlin/Swift等）でメッセージをやり取りする仕組み |
| Provider（Riverpod） | 依存関係や状態を外部から注入・共有するための仕組み |

---

## 8. 本リポジトリを読み解くための最短ルート

ここからは本リポジトリ固有の案内。上記の基礎を一通り触った前提で、
実際のコードを次の順序で読むと理解しやすい。

1. **`legacyapp_flutter/lib/domain/`** — このアプリが何をするか（エンティティ・
   リポジトリのインターフェース・ユースケース）が、実装に引っ張られず
   一番シンプルに書かれている。最初に読むべき場所。
2. **`legacyapp_flutter/lib/presentation/confirm_screen.dart`** —
   実際の画面（Widget）。`ConsumerWidget`と`ref.watch`の実例。
3. **`legacyapp_flutter/lib/presentation/confirm_providers.dart`** —
   Riverpodの`Provider`/`NotifierProvider`定義。DIの配線と状態管理が
   ここに集約されている。
4. **`legacyapp_flutter/lib/data/`** — domain層のインターフェースを実際に
   満たす実装（ネイティブとの`MethodChannel`通信、HTTP通信など）。
5. **`legacyapp_flutter/test/`** — 各層をどう単体テスト・Widgetテストしているか。
   fakeの作り方、`ProviderScope(overrides: [...])`の使い方の実例。

この5つを読めば、「画面(Widget) → 状態管理(Riverpod) → ユースケース →
リポジトリ → データソース(ネイティブ/HTTP)」という一連の流れが一通り
つかめるはず。

その上で、以下のドキュメントに進むと、この構成に至った経緯・設計判断・
実際にハマった点まで理解できる。

- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) — なぜこのレイヤー構成・
  Flutter統合方式を選んだか、という設計判断のまとめ（他プロジェクトにも
  応用可能な一般化した内容）
- [FLUTTER_INTEGRATION_LOG.md](FLUTTER_INTEGRATION_LOG.md) — 実際の作業で
  発生したエラー・クラッシュとその原因・対処の記録（本リポジトリ固有の
  具体的な内容）
- [REFERENCES.md](REFERENCES.md) — 参考にした一次情報へのリンク集

## 9. 実際に手を動かす練習

読むだけでなく、次のような小さな変更を自分で加えてみると定着が早い。

- `legacyapp_flutter/lib/presentation/confirm_screen.dart`のラベル文言を
  変えてホットリロードで確認する
- `ConfirmState`に新しいフィールドを1つ追加し、画面に表示してみる
- `legacyapp_flutter/test/presentation/confirm_screen_test.dart`に、
  自分で考えたテストケースを1つ追加してみる
- [README.md](../README.md)の手順に沿って、実際にAndroid/iOSアプリを
  ビルドして実機/エミュレータで動かしてみる
