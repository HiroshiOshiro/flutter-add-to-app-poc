import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:confirm_module/domain/entities/confirm_form_data.dart';
import 'package:confirm_module/domain/repositories/confirm_navigator.dart';
import 'package:confirm_module/domain/repositories/confirm_repository.dart';
import 'package:confirm_module/presentation/confirm_providers.dart';
import 'package:confirm_module/presentation/confirm_screen.dart';

class _FakeConfirmRepository implements ConfirmRepository {
  _FakeConfirmRepository({
    required this.initialData,
    this.submitResult = true,
  });

  final ConfirmFormData initialData;
  final bool submitResult;
  final List<ConfirmFormData> submittedData = [];

  @override
  Future<ConfirmFormData> fetchInitialData() async => initialData;

  @override
  Future<bool> submit(ConfirmFormData data) async {
    submittedData.add(data);
    return submitResult;
  }
}

class _FakeConfirmNavigator implements ConfirmNavigator {
  bool completeCalled = false;

  @override
  Future<void> goToComplete() async {
    completeCalled = true;
  }
}

Widget _wrap(ConfirmRepository repository, ConfirmNavigator navigator) {
  return ProviderScope(
    overrides: [
      confirmRepositoryProvider.overrideWithValue(repository),
      confirmNavigatorProvider.overrideWithValue(navigator),
    ],
    child: const MaterialApp(home: ConfirmScreen()),
  );
}

void main() {
  const ConfirmFormData sampleData = ConfirmFormData(
    name: 'Taro',
    email: 'taro@example.com',
    message: 'Hello',
  );

  testWidgets('shows the values returned by the repository', (tester) async {
    final repository = _FakeConfirmRepository(initialData: sampleData);
    final navigator = _FakeConfirmNavigator();

    await tester.pumpWidget(_wrap(repository, navigator));
    await tester.pumpAndSettle();

    expect(find.text('Taro'), findsOneWidget);
    expect(find.text('taro@example.com'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('shows a loading indicator until the initial data resolves',
      (tester) async {
    final repository = _DelayedFakeConfirmRepository(initialData: sampleData);
    final navigator = _FakeConfirmNavigator();

    await tester.pumpWidget(_wrap(repository, navigator));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Confirm your details'), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Confirm your details'), findsOneWidget);
  });

  testWidgets(
      'tapping confirm submits via the repository then navigates to complete',
      (tester) async {
    final repository = _FakeConfirmRepository(initialData: sampleData);
    final navigator = _FakeConfirmNavigator();

    await tester.pumpWidget(_wrap(repository, navigator));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(repository.submittedData, [sampleData]);
    expect(navigator.completeCalled, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('shows an error dialog when submission fails and does not '
      'navigate away', (tester) async {
    final repository =
        _FakeConfirmRepository(initialData: sampleData, submitResult: false);
    final navigator = _FakeConfirmNavigator();

    await tester.pumpWidget(_wrap(repository, navigator));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
    await tester.pumpAndSettle();

    expect(repository.submittedData, [sampleData]);
    expect(navigator.completeCalled, isFalse);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Failed to submit'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('disables the confirm button while a submission is in flight',
      (tester) async {
    final repository = _DelayedSubmitFakeConfirmRepository(
      initialData: sampleData,
    );
    final navigator = _FakeConfirmNavigator();

    await tester.pumpWidget(_wrap(repository, navigator));
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

class _DelayedFakeConfirmRepository extends _FakeConfirmRepository {
  _DelayedFakeConfirmRepository({required super.initialData});

  @override
  Future<ConfirmFormData> fetchInitialData() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return initialData;
  }
}

class _DelayedSubmitFakeConfirmRepository extends _FakeConfirmRepository {
  _DelayedSubmitFakeConfirmRepository({required super.initialData});

  @override
  Future<bool> submit(ConfirmFormData data) async {
    submittedData.add(data);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return true;
  }
}
