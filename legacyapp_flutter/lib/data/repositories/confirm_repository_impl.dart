import '../../domain/entities/confirm_form_data.dart';
import '../../domain/repositories/confirm_repository.dart';
import '../datasources/confirm_native_datasource.dart';
import '../datasources/confirm_remote_datasource.dart';

class ConfirmRepositoryImpl implements ConfirmRepository {
  const ConfirmRepositoryImpl({
    required ConfirmNativeDataSource nativeDataSource,
    required ConfirmRemoteDataSource remoteDataSource,
  })  : _nativeDataSource = nativeDataSource,
        _remoteDataSource = remoteDataSource;

  final ConfirmNativeDataSource _nativeDataSource;
  final ConfirmRemoteDataSource _remoteDataSource;

  @override
  Future<ConfirmFormData> fetchInitialData() =>
      _nativeDataSource.getInitialData();

  @override
  Future<bool> submit(ConfirmFormData data) => _remoteDataSource.submit(data);
}
