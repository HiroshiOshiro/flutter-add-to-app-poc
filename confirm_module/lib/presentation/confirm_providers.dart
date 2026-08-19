import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/confirm_native_datasource.dart';
import '../data/datasources/confirm_remote_datasource.dart';
import '../data/repositories/confirm_navigator_impl.dart';
import '../data/repositories/confirm_repository_impl.dart';
import '../domain/entities/confirm_form_data.dart';
import '../domain/repositories/confirm_navigator.dart';
import '../domain/repositories/confirm_repository.dart';
import '../domain/usecases/complete_confirmation_usecase.dart';
import '../domain/usecases/get_initial_data_usecase.dart';
import '../domain/usecases/submit_confirmation_usecase.dart';

// ネイティブ側 (Android: ConfirmFlutterActivity, iOS: ConfirmFlutterViewController)
// と1対1で対応するチャンネル名。呼び出し可能なメソッドは2つ:
//   getInitialData -> ネイティブが保持する入力内容を取得
//   goToComplete   -> ネイティブに完了画面への遷移を依頼
// 確認内容の送信(POST)はFlutter側(ConfirmRemoteDataSource)で完結するため
// チャンネルには含まれない。
final confirmChannelProvider = Provider<MethodChannel>((ref) {
  return const MethodChannel('com.example.legacyapp/confirm');
});

final confirmNativeDataSourceProvider = Provider<ConfirmNativeDataSource>((ref) {
  return ConfirmNativeDataSource(ref.watch(confirmChannelProvider));
});

final confirmRemoteDataSourceProvider = Provider<ConfirmRemoteDataSource>((ref) {
  return ConfirmRemoteDataSource();
});

// 実装(データソースの選択)だけを差し替えられるよう、依存グラフのDIは
// ここで完結させ、presentation層は抽象(ConfirmRepository/ConfirmNavigator)
// だけを参照する。テストではこの2つのproviderをoverrideすればよい。
final confirmRepositoryProvider = Provider<ConfirmRepository>((ref) {
  return ConfirmRepositoryImpl(
    nativeDataSource: ref.watch(confirmNativeDataSourceProvider),
    remoteDataSource: ref.watch(confirmRemoteDataSourceProvider),
  );
});

final confirmNavigatorProvider = Provider<ConfirmNavigator>((ref) {
  return ConfirmNavigatorImpl(ref.watch(confirmNativeDataSourceProvider));
});

final getInitialDataUseCaseProvider = Provider((ref) {
  return GetInitialDataUseCase(ref.watch(confirmRepositoryProvider));
});

final submitConfirmationUseCaseProvider = Provider((ref) {
  return SubmitConfirmationUseCase(ref.watch(confirmRepositoryProvider));
});

final completeConfirmationUseCaseProvider = Provider((ref) {
  return CompleteConfirmationUseCase(ref.watch(confirmNavigatorProvider));
});

class ConfirmState {
  const ConfirmState({
    this.formData = const ConfirmFormData(name: '', email: '', message: ''),
    this.loading = true,
    this.submitting = false,
  });

  final ConfirmFormData formData;
  final bool loading;
  final bool submitting;

  ConfirmState copyWith({
    ConfirmFormData? formData,
    bool? loading,
    bool? submitting,
  }) {
    return ConfirmState(
      formData: formData ?? this.formData,
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
    );
  }
}

class ConfirmController extends Notifier<ConfirmState> {
  // このRiverpodバージョンではref.mountedが使えないため、
  // ref.onDisposeで自前のmountedフラグを管理する
  // (StatefulWidgetのmountedチェックと同じ役割)。
  bool _disposed = false;

  @override
  ConfirmState build() {
    ref.onDispose(() => _disposed = true);
    _loadInitialData();
    return const ConfirmState();
  }

  Future<void> _loadInitialData() async {
    final ConfirmFormData data = await ref.read(getInitialDataUseCaseProvider)();
    if (_disposed) return;
    state = state.copyWith(formData: data, loading: false);
  }

  Future<bool> submit() async {
    state = state.copyWith(submitting: true);
    bool success = false;
    try {
      success =
          await ref.read(submitConfirmationUseCaseProvider)(state.formData);
    } finally {
      if (!_disposed) state = state.copyWith(submitting: false);
    }

    if (success && !_disposed) {
      await ref.read(completeConfirmationUseCaseProvider)();
    }
    return success;
  }
}

final confirmControllerProvider =
    NotifierProvider<ConfirmController, ConfirmState>(ConfirmController.new);
