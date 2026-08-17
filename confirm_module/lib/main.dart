import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/datasources/confirm_native_datasource.dart';
import 'data/datasources/confirm_remote_datasource.dart';
import 'data/repositories/confirm_navigator_impl.dart';
import 'data/repositories/confirm_repository_impl.dart';
import 'domain/usecases/complete_confirmation_usecase.dart';
import 'domain/usecases/get_initial_data_usecase.dart';
import 'domain/usecases/submit_confirmation_usecase.dart';
import 'presentation/confirm_screen.dart';

// ネイティブ側 (Android: ConfirmFlutterActivity, iOS: ConfirmFlutterViewController)
// と1対1で対応するチャンネル名。呼び出し可能なメソッドは2つ:
//   getInitialData -> ネイティブが保持する入力内容を取得
//   goToComplete   -> ネイティブに完了画面への遷移を依頼
// 確認内容の送信(POST)は以前はネイティブに委譲していたが、通信処理は
// Flutter側(ConfirmRemoteDataSource)に寄せたためチャンネルには含まれない。
const MethodChannel _channel = MethodChannel('com.example.legacyapp/confirm');

void main() {
  final ConfirmNativeDataSource nativeDataSource =
      ConfirmNativeDataSource(_channel);
  final ConfirmRemoteDataSource remoteDataSource = ConfirmRemoteDataSource();
  final ConfirmRepositoryImpl repository = ConfirmRepositoryImpl(
    nativeDataSource: nativeDataSource,
    remoteDataSource: remoteDataSource,
  );
  final ConfirmNavigatorImpl navigator = ConfirmNavigatorImpl(nativeDataSource);

  runApp(ConfirmApp(
    getInitialData: GetInitialDataUseCase(repository),
    submitConfirmation: SubmitConfirmationUseCase(repository),
    completeConfirmation: CompleteConfirmationUseCase(navigator),
  ));
}

class ConfirmApp extends StatelessWidget {
  const ConfirmApp({
    super.key,
    required this.getInitialData,
    required this.submitConfirmation,
    required this.completeConfirmation,
  });

  final GetInitialDataUseCase getInitialData;
  final SubmitConfirmationUseCase submitConfirmation;
  final CompleteConfirmationUseCase completeConfirmation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ConfirmScreen(
        getInitialData: getInitialData,
        submitConfirmation: submitConfirmation,
        completeConfirmation: completeConfirmation,
      ),
    );
  }
}
