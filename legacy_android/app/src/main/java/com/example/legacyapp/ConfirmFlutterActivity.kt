package com.example.legacyapp

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// 確認内容の送信(POST)はFlutter側(confirm_module)に寄せたため、ここで
// 実装するのはBaseActivityが保持する状態の受け渡しと、完了画面への
// 遷移依頼のみ。Flutter統合の新規コードはKotlinで書く方針にしたため、
// 移行前の他のActivity(Java)とは異なりこのクラスだけKotlin。
class ConfirmFlutterActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInitialData" -> result.success(currentFormDataMap())
                    "goToComplete" -> {
                        startActivity(Intent(this, CompleteActivity::class.java))
                        finish()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun currentFormDataMap(): Map<String, String> {
        val data = BaseActivity.sFormData
        return mapOf(
            "name" to data.name,
            "email" to data.email,
            "message" to data.message,
        )
    }

    companion object {
        private const val CHANNEL_NAME = "com.example.legacyapp/confirm"
    }
}
