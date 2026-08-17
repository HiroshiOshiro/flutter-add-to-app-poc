import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:confirm_module/data/datasources/confirm_native_datasource.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.example.legacyapp/confirm');
  final ConfirmNativeDataSource dataSource = ConfirmNativeDataSource(channel);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('getInitialData maps the native response to a ConfirmFormData',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      expect(call.method, 'getInitialData');
      return <String, String>{
        'name': 'Taro',
        'email': 'taro@example.com',
        'message': 'Hello',
      };
    });

    final result = await dataSource.getInitialData();

    expect(result.name, 'Taro');
    expect(result.email, 'taro@example.com');
    expect(result.message, 'Hello');
  });

  test('getInitialData falls back to empty strings for missing fields',
      () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      return <String, String>{};
    });

    final result = await dataSource.getInitialData();

    expect(result.name, '');
    expect(result.email, '');
    expect(result.message, '');
  });

  test('goToComplete invokes the goToComplete method', () async {
    final List<String> calledMethods = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      calledMethods.add(call.method);
      return null;
    });

    await dataSource.goToComplete();

    expect(calledMethods, ['goToComplete']);
  });
}
