import '../repositories/confirm_navigator.dart';

class CompleteConfirmationUseCase {
  const CompleteConfirmationUseCase(this._navigator);

  final ConfirmNavigator _navigator;

  Future<void> call() => _navigator.goToComplete();
}
