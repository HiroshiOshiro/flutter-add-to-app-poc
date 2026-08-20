import 'package:flutter/services.dart';

import '../../domain/entities/confirm_form_data.dart';

/// ネイティブ側(Android: ConfirmFlutterActivity, iOS: ConfirmFlutterViewController)
/// と1対1で対応するMethodChannelのラッパー。通信処理(POST)はFlutter側に
/// 移したため、ここで扱うのは「ネイティブの基底クラスが保持する状態の取得」と
/// 「次のネイティブ画面への遷移依頼」の2つだけに絞っている。
class ConfirmNativeDataSource {
  const ConfirmNativeDataSource(this._channel);

  final MethodChannel _channel;

  Future<ConfirmFormData> getInitialData() async {
    final Map<Object?, Object?> data = await _channel
        .invokeMethod('getInitialData') as Map<Object?, Object?>;
    return ConfirmFormData(
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      message: (data['message'] as String?) ?? '',
    );
  }

  Future<void> goToComplete() => _channel.invokeMethod('goToComplete');
}
