import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:legacyapp_flutter/data/datasources/confirm_remote_datasource.dart';
import 'package:legacyapp_flutter/domain/entities/confirm_form_data.dart';

void main() {
  const ConfirmFormData sampleData = ConfirmFormData(
    name: 'Taro',
    email: 'taro@example.com',
    message: 'Hello',
  );

  test('submit returns true on a 2xx response and sends the form as JSON',
      () async {
    http.Request? capturedRequest;
    final mockClient = MockClient((request) async {
      capturedRequest = request;
      return http.Response('', 201);
    });
    final dataSource = ConfirmRemoteDataSource(client: mockClient);

    final result = await dataSource.submit(sampleData);

    expect(result, isTrue);
    expect(capturedRequest, isNotNull);
    expect(
      capturedRequest!.url,
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );
    expect(
      jsonDecode(capturedRequest!.body),
      {
        'name': 'Taro',
        'email': 'taro@example.com',
        'message': 'Hello',
      },
    );
  });

  test('submit returns false on a non-2xx response', () async {
    final mockClient = MockClient((request) async => http.Response('', 500));
    final dataSource = ConfirmRemoteDataSource(client: mockClient);

    final result = await dataSource.submit(sampleData);

    expect(result, isFalse);
  });

  test('submit returns false when the request throws', () async {
    final mockClient = MockClient((request) async {
      throw const SocketExceptionStub();
    });
    final dataSource = ConfirmRemoteDataSource(client: mockClient);

    final result = await dataSource.submit(sampleData);

    expect(result, isFalse);
  });
}

class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
