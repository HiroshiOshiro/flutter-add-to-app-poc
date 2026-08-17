import '../entities/confirm_form_data.dart';
import '../repositories/confirm_repository.dart';

class SubmitConfirmationUseCase {
  const SubmitConfirmationUseCase(this._repository);

  final ConfirmRepository _repository;

  Future<bool> call(ConfirmFormData data) => _repository.submit(data);
}
