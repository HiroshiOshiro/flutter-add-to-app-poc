# 大規模モバイルアプリへのFlutter段階導入ガイド

Objective-C/Java製の大規模な既存アプリに対して、Flutterを「add-to-app」方式で
画面単位に段階導入していくための手順・設計判断・注意点をまとめる。特定の
プロジェクト固有の事情は含めず、他プロジェクトでも参照できる形に一般化して
いる。実際の作業ログ（つまずいた点の詳細）は [FLUTTER_INTEGRATION_LOG.md](FLUTTER_INTEGRATION_LOG.md)
を、参考にした一次情報は [REFERENCES.md](REFERENCES.md) を参照。

## 1. 前提と方針

- 大規模アプリを一度に全面Flutter化するのは現実的でないことが多い。
  「1画面ずつFlutterモジュールに置き換え、ネイティブとFlutterが共存する
  期間を経て、最終的に全体をFlutter化する」というstrangler fig
  （絞め殺しの木）パターンを取る。
- 最初に置き換える画面は、次の条件を満たすものを選ぶと検証しやすい。
  - UIが単純で、外部依存（通信・永続化）が明確に切り出せる
  - 前後の画面（ネイティブ）との連携パターン（データの受け渡し・戻り値）を
    一通り確認できる
- 既存の通信・認証基盤をいきなりFlutter側に持ち込まず、**通信は当面ネイティブ
  側に残し、Flutter側はプラットフォームチャンネル経由でネイティブに処理を
  依頼する**方針を取ると、認証ヘッダーや共通エラーハンドリングの二重実装を
  避けられる。ただしこれは「いきなり全部をFlutterに寄せない」ための一時的な
  判断であり、恒久的な設計ではない。1画面での検証が済んだら、その画面が
  担っていた処理(通信など)を実際にFlutter側へ移し、レイヤードアーキテクチャ
  (5節)で置き換え可能な形にしておくと、次にどの処理をFlutter化するかを
  機械的に判断しやすくなる。
- Flutter統合のために新規に書くネイティブ側コード(`FlutterActivity`/
  `FlutterViewController`を継承するクラスや、そのMethodChannelハンドラ)は、
  既存コードの言語に合わせる必要はない。既存コードがJava/Objective-Cであっても、
  新規コードはKotlin/Swiftで書く方が、FlutterのAndroid/iOS embedding APIとの
  親和性が高く、同一モジュール内で既存コードと問題なく共存できる。

## 2. 全体の作業ステップ

1. Flutterモジュールを作成する（`flutter create --template module`）。
2. 対象画面をFlutterのWidgetとして実装する。ネイティブとの通信は
   `MethodChannel` 1本に絞り、必要なメソッドだけを定義する（後述）。
3. モジュール単体で `flutter analyze` / `flutter test` を通し、Dartコードの
   健全性を先に確認してからネイティブへの組み込みに進む。
4. Android側にモジュールを組み込み、対象画面をFlutter製の画面に置き換える。
5. iOS側にモジュールを組み込み、同様に置き換える。
6. 両OSで実機/エミュレータ・シミュレータ上で実際に画面遷移・データ受け渡し・
   通信・エラーハンドリングを操作して確認する。

途中の各ステップでビルドと動作確認を行い、一気に全部作り切ってから動かそうと
しないこと。特にネイティブ側との統合はビルド設定の相性問題が起きやすく、
早い段階で問題を切り分けられた方が原因調査がしやすい。

## 3. Android統合の設計判断

### source module か AAR か

| 方式 | 向いているケース |
|---|---|
| source module（`include_flutter.groovy` を `settings.gradle` から評価） | ローカル開発・PoC。ワンステップで組み込めるが、ビルドする全員のマシンにFlutter SDKが必要 |
| AAR（Flutterモジュールをローカルmavenリポジトリ形式のAARとして出力し依存） | 大規模チーム・CI。Flutterモジュールのビルドとホストアプリのビルドを分離でき、ホスト側の開発者はFlutter SDK不要 |

PoCや検証段階ではsource moduleで素早く確認し、複数チームが関わる本番導入では
AARへの切り替えを検討するとよい。

### ハマりやすい点: 集中管理リポジトリとの衝突

`settings.gradle` で `dependencyResolutionManagement.repositoriesMode` を
`FAIL_ON_PROJECT_REPOS` に設定して依存リポジトリを集中管理しているプロジェクトは、
Flutter Gradleプラグインがプロジェクトレベルで独自にリポジトリを追加しようと
するため、**組み込んだ瞬間にビルドが失敗する**。`PREFER_SETTINGS` に緩和した上で、
Flutterエンジン本体の配布先 `https://storage.googleapis.com/download.flutter.io`
を明示的に `settings.gradle` 側のリポジトリに追加しておく必要がある。

### FlutterActivityのテーマ

`FlutterActivity` はFlutter側の `Scaffold` が自前でAppBarを描画するため、
ホスト側のActionBarと二重表示になりやすい。`Theme.*.NoActionBar` 系のテーマを
専用に用意して割り当てる。

### 新規コードの言語

`FlutterActivity`を継承するActivityなど、Flutter統合のために新規に書く
コードは、既存コードがJavaであってもKotlinで書いてよい。同一Gradleモジュール
内でJavaとKotlinは問題なく共存でき(相互に呼び出せる)、Flutter Android
embeddingのAPIもKotlinから自然に使える。既存コードがまだJavaのみの場合は、
`kotlin-android`プラグインの追加に加えて、`compileOptions`の
`sourceCompatibility`/`targetCompatibility`とKotlinの`jvmTarget`を揃えて
おく必要がある(揃っていないと`compileDebugKotlin`が
`Inconsistent JVM-target compatibility`で失敗する)。

## 4. iOS統合の設計判断

### CocoaPods か 手動フレームワーク埋め込みか

| 方式 | 向いているケース |
|---|---|
| CocoaPods（`podhelper.rb` を `Podfile` から読み込み） | 既にCocoaPodsを使っているプロジェクト。公式のPodfileサンプルにひと手間（`post_install` フックの追加）加えるだけで組み込める |
| 手動フレームワーク埋め込み（`Flutter.xcframework` / `App.xcframework` を直接追加） | CocoaPods非採用のプロジェクト。管理は煩雑になるがCocoaPods導入を強制しない |

### ハマりやすい点1: Podfileの記法

`install_all_flutter_pods(flutter_application_path)` を `target` ブロックに
書くだけでは `pod install` が
`Missing flutter_post_install(installer) in Podfile post_install block`
で失敗する。`post_install do |installer| flutter_post_install(installer) end`
を追記する必要がある。

### ハマりやすい点2: プロジェクト生成ツールとの併用順序

XcodeGenやTuistなどでプロジェクトファイルを生成管理している場合、
プロジェクト構成を変更するたびに再生成が必要になるが、**再生成すると
CocoaPodsが `.pbxproj` に注入した統合設定（ビルドフェーズ等）が失われる**。
以下の順序を毎回徹底すること。

```
project.yml等を変更
  -> プロジェクト生成コマンドを再実行 (xcodegen generate 等)
  -> pod install
  -> ビルド (.xcworkspace を使う。.xcodeproj 直接ビルドは不可)
```

### 新規コードの言語

`FlutterViewController`を継承するクラスなど、Flutter統合のために新規に書く
コードは、既存コードがObjective-CであってもSwiftで書いてよい。ただし
Objective-CとSwiftを混在させる場合、双方向の相互運用設定が必要になる。

- 既存のObjective-C側から新規のSwiftクラスを参照するには、自動生成される
  `<ProductModuleName>-Swift.h`をimportする(個別のヘッダーファイルは不要)。
- 逆にSwift側から既存のObjective-C型を参照するには、Bridging Header
  (`SWIFT_OBJC_BRIDGING_HEADER`)にそれらの型のヘッダーをimportしておく
  必要がある。
- プロジェクトにSwiftファイルを1つでも追加する場合は
  `ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES`を有効にしておく。
- UIKitのdesignated initializer(`init(coder:)`など)をSwiftでオーバーライド
  する際は、元のObjective-C宣言がfailable(`nullable`)かどうかを確認する。
  非failableな宣言を`init?(coder:)`のようにfailableとして上書きすると
  コンパイルエラーになる。

## 5. FlutterEngineのライフサイクル（最も重要な落とし穴）

Flutterの公式ドキュメントでも触れられている通り、`FlutterEngine` は
起動コストが軽くないため、**アプリ全体で1つのエンジンを事前に起動して
使い回す「cached engine」パターン**が推奨されることが多い
（[Load sequence, performance, and memory](https://docs.flutter.dev/add-to-app/performance)）。

ただし、これには重大な制約がある。**Dartの `main()`（およびルートWidgetの
`initState()`）は、そのエンジンの生存期間中に一度しか実行されない。**
そのため、以下のような設計は破綻する。

- アプリ起動時にエンジンを1つ生成してrunする
- 対象画面のWidgetが `initState()` で `MethodChannel` 経由でネイティブから
  初期データを取得する設計にする

この組み合わせだと、1回目にその画面を表示したときのデータのまま
Widgetの状態が固定されてしまい、**2回目以降は同じ画面を開いても
最新の入力内容が反映されない**（もしくはネイティブ側にまだハンドラが
登録されていない起動直後にDartが呼び出しを行い、応答が永久に返ってこず
ローディング状態のまま固まる）。

### 対処方針

- **PoCや、画面遷移のたびに新しいデータを渡す必要がある画面**では、
  対象画面に入るたびに新しい `FlutterEngine` を生成し、
  `run()` → `MethodChannel` のハンドラ登録 → 画面の生成、という順序を
  守る（`run()` 前にチャンネルハンドラを登録したり、runする前に
  `FlutterViewController`/`FlutterActivity` をアタッチしたりすると
  クラッシュする）。起動コストは毎回発生するが、正しく動く。
- **起動速度を優先してエンジンを使い回したい場合**は、`initState()` で
  即座にデータを取得する設計を避け、ネイティブ側から
  `MethodChannel`/`EventChannel` 経由で明示的にデータをpushする、あるいは
  画面が表示されるたびにネイティブから「更新して」という合図を送る設計に
  変更する。

### プラグイン登録はエンジンのrun()より後に行う

Flutterプラグイン（`sqflite`など、ネイティブ側の実装を持つパッケージ）を
1つでも使うようになったら、プラグイン登録(`GeneratedPluginRegistrant`)の
タイミングにも同じ制約が及ぶ。プラグインは登録処理の中でエンジンの
バイナリメッセンジャー経由のチャンネルハンドラを登録することが多く、
**エンジンが`run()`される前にプラグインを登録すると、エンジンをrunする前に
チャンネルハンドラを登録したときと同じ理由でクラッシュする**。
プラグインを1つも使わないうちは登録とrunの順序を気にしなくても動いて
しまうため、後から最初のプラグインを追加したタイミングで初めて表面化する
落とし穴になりやすい。エンジンを手動で構築する場合は、常に
「`run()` → プラグイン登録 → チャンネルハンドラ登録」の順序を守ること。

## 6. 画面数が増えたときの構成: 1モジュール・複数エントリポイント

Android・iOSとも、**1つのホストアプリにsource module/CocoaPods経由で
組み込めるFlutterモジュールは1つまで**という制約がある。Android側の
`include_flutter.groovy`は生成するGradleプロジェクト名を`:flutter`に
固定しており、iOS側の`podhelper.rb`も`Flutter`/`FlutterPluginRegistrant`
という固定のPod名を宣言する。そのため2つ目のFlutterモジュールを同じ方式で
追加しようとすると名前が衝突し、公式にはサポートされていない。

画面が増えてきた場合、**画面ごとに別モジュールを作るのではなく、同じ
モジュール内で複数のDartエントリポイントを使い分ける**のが現実的な対応に
なる（3節・4節で先送りにした「モジュール構成の見直し」の具体的な答え）。

### エントリポイント関数は必ずルートライブラリ(main.dart)に置く

複数エントリポイントを使う際、最も踏みやすい落とし穴は「エントリポイント
関数を別ファイルに定義し、`main.dart`からimportするだけで済ませようとする」
ことである。`@pragma('vm:entry-point')`を付ければツリーシェイキングからは
保護されるが、ネイティブ側から
`DartEntrypoint(pathToBundle, "yourEntrypointName")`のように
**ライブラリを指定せず名前だけで**呼び出す場合、この名前解決は
**ルートライブラリ（`main.dart`自身）の中だけ**を探索する。別ファイルに
定義した関数は、コンパイル済みでツリーシェイキングを免れていても
見つからず、`Could not resolve main entrypoint function`でエンジンの
起動に失敗する。

対処は単純で、**エントリポイント関数そのものを`main.dart`に置く**こと。
関数の中身（呼び出す先の画面・DIの組み立てなど）は他のファイルに
分割したままでよい。`main.dart`は複数のエントリポイント関数を持つ
「起動口の集合」として扱い、実装の詳細は持たせない、という役割分担にすると
見通しがよい。

## 7. ネイティブ⇔Flutter間のデータ受け渡しパターン

1画面あたり1つの `MethodChannel` に絞り、その画面が必要とする操作だけを
メソッドとして定義するとシンプルに保てる。導入初期は次の3種類のメソッドに
分類できることが多い。

- `getInitialData` : ネイティブが保持する状態（フォーム入力内容など）を
  Flutterへ渡す
- `<画面固有のアクション>Submit` : Flutter側のボタン操作の結果、実際に行う
  べき処理（通信など）をネイティブへ依頼する
- `goTo<次の画面>` : 処理が成功したら、次のネイティブ画面への遷移をネイティブに依頼する

この設計のポイントは、**画面遷移の主導権を常にネイティブ側に残す**こと。
Flutter側は「今の画面で何をするか」だけを担当し、「次にどの画面に行くか」は
ネイティブのナビゲーションスタックがそのまま管理する。これにより、
Flutter化されていない前後の画面との接続を素朴に保てる。

このうち`getInitialData`と`goTo<次の画面>`は「ネイティブの基底クラスが持つ
状態」「ネイティブのナビゲーションスタック」という、Flutter側からは本質的に
手が届かない領域を扱っているため、恒久的にネイティブへの依頼として残る。
一方`<画面固有のアクション>Submit`は「その画面固有のビジネスロジック（通信
など）」を担っているだけで、ネイティブである必然性は薄い。1画面での検証が
済み、パターンに確信が持てたら、この部分は次項のレイヤードアーキテクチャに
乗せてFlutter側に処理そのものを移してしまうのが自然な進化になる。

### 処理をFlutter側に寄せる: レイヤードアーキテクチャで受け皿を作る

`<画面固有のアクション>Submit`のような処理をFlutter側に移す際は、Flutter
モジュールの内部をレイヤードアーキテクチャ（presentation / domain / data）
に分けておくと、「何が本質的にネイティブでなければならないか」と「Dartに
移せる処理」を分離しやすい。

- **domain層**: 画面が必要とする操作を抽象インターフェースとして定義する
  （例: 状態取得・送信・完了通知をそれぞれ担う抽象クラス）。この層は
  `MethodChannel`の存在を知らない。
- **data層**: domain層のインターフェースを実装する。ネイティブの基底クラスが
  持つ状態の取得や、次画面への遷移依頼のように、ネイティブでなければ実現
  できない部分だけを`MethodChannel`経由の実装として残し、それ以外（通信など）
  はDart自身（HTTPクライアント等）で完結させた実装に置き換える。
- **presentation層**: UIとその状態管理。domain層のインターフェースだけに
  依存し、実装が`MethodChannel`なのかDartのHTTPクライアントなのかを意識しない。

こうしておくと、画面のUIやビジネスロジックを変更することなく、「ネイティブに
委譲する実装」と「Flutterで完結する実装」を差し替えられる。全面Flutter化の
過程で、ネイティブ委譲の実装をFlutter単体の実装に一つずつ置き換えていく、
という進め方（10節のロードマップ4番目の具体化）がしやすくなる。また
presentation層はdomain層の抽象にしか依存しないため、実装を差し替えても
UIのテストは影響を受けず、data層側もネイティブブリッジ・HTTPクライアント
それぞれを独立して単体テストできる。

### 基底クラスの暗黙の共有状態を橋渡しする

旧アーキテクチャのアプリでは、画面間のデータが基底クラスのstatic変数
（Androidの場合）やクラスプロパティ（iOSの場合）に暗黙的に保持されている
ことがある。Flutter側からはこれらに直接アクセスできないため、
`MethodChannel` の引数として明示的にシリアライズして渡す必要がある。
この「暗黙の状態を明示化する」作業自体が、旧アーキテクチャの技術的負債を
可視化する副産物になる。

## 8. アセット・ローカライズの扱い

Flutterモジュールとホストアプリは別々のビルド成果物になるため、
共通で使う画像などのアセットは重複して持つ必要がある（今回はアイコン画像を
Flutterモジュール側の `assets/` にもコピーした）。ローカライズ文言も同様で、
モジュール単体では `flutter_localizations` を使わず簡易な辞書切り替えで
済ませた。画面数が増えるにつれて重複が無視できなくなってきたら、
共有アセット/文言をパッケージとして切り出すか、ホスト側からロケール・
テーマなどの設定値を `MethodChannel` 経由で渡す設計に見直すとよい。

## 9. 検証方法

- Android: `./gradlew assembleDebug` でビルド確認後、エミュレータ/実機に
  インストールして操作。
- iOS: `xcodebuild -workspace *.xcworkspace -scheme <target> ...`
  （CocoaPods導入後は `.xcodeproj` ではなく必ず `.xcworkspace` を使う）で
  ビルド確認後、シミュレータ/実機で操作。
- 両OSとも、ネイティブ→Flutter→ネイティブと画面をまたいで実際に指で
  操作し、次の3点を目視確認する。
  1. ネイティブの状態がFlutter画面に正しく渡っているか
  2. Flutter画面の操作結果がネイティブに正しく伝わり、想定した処理
     （通信・永続化など）が行われるか
  3. 処理完了後、正しい次のネイティブ画面に遷移するか

## 10. 全面Flutter化に向けたロードマップ（考え方）

1. **画面単位の置き換えを繰り返す。** 依存関係が少ない画面から着手し、
   徐々に依存の多い画面（認証必須の画面、共有状態を多く参照する画面など）へ
   広げる。
2. **モジュール構成を見直すタイミングを決めておく。** 6節の通り1つの
   ホストアプリに組み込めるFlutterモジュールはsource module/CocoaPods
   経由では1つまでという制約があるため、画面が増えてきたら「画面ごとに
   別モジュール」ではなく「1つのFlutterモジュールに複数画面・複数
   エントリポイントを持たせる」方向で構成を見直すことになる。これに
   移行すると、ネイティブ⇔Flutter間の遷移回数が減り、エンジンの使い回しも
   しやすくなる。
3. **ナビゲーションの主導権を段階的にFlutter側へ移す。** 個々の画面の
   置き換えが進んだら、複数のFlutter画面間の遷移はFlutter側のルーターに
   任せ、ネイティブ⇔Flutterの境界を「アプリ全体の入口・出口」だけに
   縮小していく。
4. **共通基盤（通信・永続化・認証）をFlutter側に段階的に寄せる。** 個々の
   画面をFlutter化しただけでは通信層の二重実装（ネイティブに残したまま）が
   残り続ける。7節で説明したレイヤードアーキテクチャの構成であれば、
   ネイティブに委譲していたdata層の実装をDart単体の実装に差し替えるだけで
   段階的に移行できるため、通信層自体をDartの共通パッケージとして再実装し、
   ネイティブ側は薄いブリッジに置き換える判断をする。
5. **全面カットオーバーの判断基準を決めておく。** 「主要画面の◯%が
   Flutter化された」「ネイティブ専用のAPI・SDK依存が解消された」等、
   全面的にFlutterのみのアプリへ切り替える基準を早い段階でチームとして
   合意しておくと、`Add-to-app` 状態がいつまでもデフォルト運用として
   固定化されるのを防げる。
