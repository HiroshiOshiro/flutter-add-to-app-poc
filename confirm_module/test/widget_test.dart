import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:confirm_module/main.dart';

void main() {
  const MethodChannel channel = MethodChannel('com.example.legacyapp/confirm');

  testWidgets('shows the values returned by getInitialData', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      if (call.method == 'getInitialData') {
        return <String, String>{
          'name': 'Taro',
          'email': 'taro@example.com',
          'message': 'Hello',
        };
      }
      return null;
    });

    await tester.pumpWidget(const ConfirmApp());
    await tester.pumpAndSettle();

    expect(find.text('Taro'), findsOneWidget);
    expect(find.text('taro@example.com'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });
}
