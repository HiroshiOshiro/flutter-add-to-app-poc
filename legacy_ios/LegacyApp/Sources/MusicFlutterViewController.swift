import Flutter

class MusicFlutterViewController: FlutterViewController {
    init() {
        super.init(engine: MusicFlutterEngine.shared, nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
