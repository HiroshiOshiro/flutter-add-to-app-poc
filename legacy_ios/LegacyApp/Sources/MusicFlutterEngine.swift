import Flutter
import FlutterPluginRegistrant

// Musicタブは確認画面(ConfirmFlutterViewController)と違い、ネイティブの基底
// クラスが持つ状態を読む必要がなく、検索・お気に入りともDart側で完結する。
// そのためConfirm画面のような「訪問のたびに新規エンジン」ではなく、公式が
// 推奨する「アプリ全体で1つのエンジンを起動して使い回すcached engine」
// パターンを採用できる(docs/MIGRATION_GUIDE.md 5節)。タブを何度切り替えても
// 検索結果やスクロール位置がDart側にそのまま残る。
//
// musicMain()はlib/main.dart(エンジンのルートライブラリ)側に定義されている。
// 別ファイルに置いて@pragma('vm:entry-point')を付けるだけではツリー
// シェイキングからは保護されるが、ライブラリを指定せずに名前だけで
// runWithEntrypoint:を呼ぶとルートライブラリの中しか探索されないため
// 見つからない(詳細はAndroid側 MusicFlutterEngineHolder.kt のコメント参照)。
enum MusicFlutterEngine {
    static let shared: FlutterEngine = {
        let engine = FlutterEngine(name: "music_engine")
        // sqfliteのようなネイティブプラグインはregister(with:)の中で
        // engine.binaryMessenger経由のチャンネルハンドラを登録する。
        // run()より前に登録するとFlutterBinaryMessengerRelay内で
        // 「Setting a message handler before the FlutterEngine has been run」
        // でクラッシュするため、必ずrun()を先に呼ぶ。
        engine.run(withEntrypoint: "musicMain")
        GeneratedPluginRegistrant.register(with: engine)
        return engine
    }()
}
