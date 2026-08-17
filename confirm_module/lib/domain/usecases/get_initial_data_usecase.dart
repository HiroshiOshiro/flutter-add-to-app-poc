import '../entities/confirm_form_data.dart';
import '../repositories/confirm_repository.dart';

class GetInitialDataUseCase {
  const GetInitialDataUseCase(this._repository);

  final ConfirmRepository _repository;

  Future<ConfirmFormData> call() => _repository.fetchInitialData();
}
