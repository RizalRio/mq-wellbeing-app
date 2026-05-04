import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'jwt_interceptor.dart';

// PASTIKAN BARIS INI ADA DI SINI
part 'dio_client.g.dart';

@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

@riverpod
Dio dio(DioRef ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  dio.interceptors.add(JwtInterceptor(secureStorage));
  dio.interceptors.add(
    LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ),
  );

  return dio;
}
