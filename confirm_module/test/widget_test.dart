import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:confirm_module/main.dart';

void main() {
  const MethodChannel channel = MethodChannel('com.example.legacyapp/confirm');

  Future<Map<String, String>> defaultInitialData() async => <String, String>{
        'name': 'Taro',
        'email': 'taro@example.com',
        'message': 'Hello',
      };

  void setHandler(
    Future<Object?> Function(MethodCall call) handler,
  ) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, handler);
  }

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('shows the values returned by getInitialData', (tester) async {
    setHandler((call) async {
      if (call.method == 'getInitialData') return defaultInitialData();
      return null;
    });

    await tester.pumpWidget(const ConfirmApp());
    await tester.pumpAndSettle();

    expect(find.text('Taro'), findsOneWidget);
    expect(find.text('taro@example.com'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('shows a loading indicator until getInitialData resolves',
      (tester) async {
    setHandler((call) async {
      if (call.method == 'getInitialData') {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return defaultInitialData();
      }
      return null;
    });

    await tester.pumpWidget(const ConfirmApp());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Confirm your details'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Confirm your details'), findsOneWidget);
  });

  testWidgets(
      'tapping confirm calls confirmSubmit then goToComplete on success',
      (tester) async {
    final List<String> calledMethods = [];
    setHandler((call) async {
      calledMethods.add(call.method);
      switch (call.method) {
        case 'getInitialData':
          return defaultInitialData();
        case 'confirmSubmit':
          return true;
        case 'goToComplete':
          return null;
      }
      return null;
    });

    await tester.pumpWidget(const ConfirmApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(
      calledMethods,
      ['getInitialData', 'confirmSubmit', 'goToComplete'],
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('shows an error dialog when confirmSubmit fails and does not '
      'navigate away', (tester) async {
    final List<String> calledMethods = [];
    setHandler((call) async {
      calledMethods.add(call.method);
      switch (call.method) {
        case 'getInitialData':
          return defaultInitialData();
        case 'confirmSubmit':
          return false;
      }
      return null;
    });

    await tester.pumpWidget(const ConfirmApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(calledMethods, ['getInitialData', 'confirmSubmit']);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Failed to submit'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('disables the confirm button while a submission is in flight',
      (tester) async {
    setHandler((call) async {
      switch (call.method) {
        case 'getInitialData':
          return defaultInitialData();
        case 'confirmSubmit':
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return true;
        case 'goToComplete':
          return null;
      }
      return null;
    });

    await tester.pumpWidget(const ConfirmApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
    await tester.pump();

    final ElevatedButton button =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
  });
}
