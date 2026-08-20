import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/confirm_form_data.dart';

/// 確認内容の送信先API。以前はネイティブ側の既存通信スタック
/// (Android: HttpURLConnection, iOS: NSURLSession)に委譲していたが、
/// このモジュールが確認画面の処理を一手に引き受ける方針に合わせて
/// Flutter側で直接POSTするようにしている。
class ConfirmRemoteDataSource {
  ConfirmRemoteDataSource({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _endpoint =
      Uri.parse('https://jsonplaceholder.typicode.com/posts');

  Future<bool> submit(ConfirmFormData data) async {
    try {
      final http.Response response = await _client.post(
        _endpoint,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': data.name,
          'email': data.email,
          'message': data.message,
        }),
      );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
