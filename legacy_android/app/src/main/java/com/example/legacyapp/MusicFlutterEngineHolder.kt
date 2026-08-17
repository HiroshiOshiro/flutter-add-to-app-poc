package com.example.legacyapp

import android.content.Context
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

// Musicタブは確認画面(ConfirmFlutterActivity)と違い、ネイティブの基底クラスが
// 持つ状態を読む必要がなく、検索・お気に入りともDart側で完結する。そのため
// Confirm画面のような「訪問のたびに新規エンジン」ではなく、公式が推奨する
// 「アプリ全体で1つのエンジンを事前に起動して使い回すcached engine」パターンを
// 採用できる(docs/MIGRATION_GUIDE.md 5節)。タブを何度切り替えても検索結果や
// スクロール位置がDart側にそのまま残る。
object MusicFlutterEngineHolder {
    const val ENGINE_ID = "music_engine"

    fun warmUp(context: Context) {
        if (FlutterEngineCache.getInstance().get(ENGINE_ID) != null) {
            return
        }
        val appContext = context.applicationContext

        // FlutterActivity/FlutterFragmentは内部でFlutterLoaderの初期化完了を
        // 待ってからFlutterEngineを作るが、ここでは自前でエンジンを作るため
        // 明示的に初期化を完了させておく必要がある。省略すると
        // findAppBundlePath()や生成後のエンジンの状態が不安定になり、
        // 「Could not resolve main entrypoint function」で起動に失敗することがある。
        val loader = FlutterInjector.instance().flutterLoader()
        if (!loader.initialized()) {
            loader.startInitialization(appContext)
        }
        loader.ensureInitializationComplete(appContext, null)

        // FlutterEngine(Context) のコンストラクタがプラグイン登録まで自動で
        // 行うため、GeneratedPluginRegistrant を明示的に呼ぶ必要はない
        // (呼ぶと "already registered" 警告が出るだけ)。
        val engine = FlutterEngine(appContext)
        val entrypoint = DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "musicMain")
        engine.dartExecutor.executeDartEntrypoint(entrypoint)
        FlutterEngineCache.getInstance().put(ENGINE_ID, engine)
    }
}
