import '../../domain/repositories/confirm_navigator.dart';
import '../datasources/confirm_native_datasource.dart';

class ConfirmNavigatorImpl implements ConfirmNavigator {
  const ConfirmNavigatorImpl(this._nativeDataSource);

  final ConfirmNativeDataSource _nativeDataSource;

  @override
  Future<void> goToComplete() => _nativeDataSource.goToComplete();
}
