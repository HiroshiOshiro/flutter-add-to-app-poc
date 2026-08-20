import '../entities/confirm_form_data.dart';

abstract class ConfirmRepository {
  Future<ConfirmFormData> fetchInitialData();

  Future<bool> submit(ConfirmFormData data);
}
