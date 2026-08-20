import Flutter
import FlutterPluginRegistrant
import UIKit

// 確認内容の送信(POST)はFlutter側(legacyapp_flutter)に寄せたため、ここで
// 実装するのはBaseViewControllerが保持する状態の受け渡しと、完了画面への
// 遷移依頼のみ。Flutter統合の新規コードはSwiftで書く方針にしたため、
// 移行前の他のViewController(Objective-C)とは異なりこのクラスだけSwift。
//
// エンジンは訪問のたびに新規生成する(アプリ全体で使い回さない)。Dartの
// main()/initState()はエンジンの生存期間中に一度しか実行されないため、
// 使い回すと2回目以降の訪問で最新の入力内容が反映されなくなる
// (詳細はdocs/MIGRATION_GUIDE.md 5節を参照)。
class ConfirmFlutterViewController: FlutterViewController {

    private static let channelName = "com.example.legacyapp/confirm"

    private let ownedEngine: FlutterEngine
    private var channel: FlutterMethodChannel!

    init() {
        let engine = FlutterEngine(name: "confirm_engine")
        // engine.binaryMessenger はエンジンがrunした後でないと使えないため、
        // run()を先に済ませてからsuper.init(engine:)でアタッチする。
        // sqfliteのようなネイティブプラグインはregister(with:)の中でも
        // engine.binaryMessenger経由のチャンネル登録を行うため、
        // GeneratedPluginRegistrant.register(with:)もrun()より後に呼ぶ
        // 必要がある(先に呼ぶと「Setting a message handler before the
        // FlutterEngine has been run」でクラッシュする)。
        engine.run()
        GeneratedPluginRegistrant.register(with: engine)

        ownedEngine = engine
        super.init(engine: engine, nibName: nil, bundle: nil)

        channel = FlutterMethodChannel(
            name: Self.channelName,
            binaryMessenger: engine.binaryMessenger
        )
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self else { return }
            switch call.method {
            case "getInitialData":
                let data = BaseViewController.sharedFormData
                result(["name": data.name, "email": data.email, "message": data.message])
            case "goToComplete":
                let completeVC = CompleteViewController()
                self.navigationController?.pushViewController(completeVC, animated: true)
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
