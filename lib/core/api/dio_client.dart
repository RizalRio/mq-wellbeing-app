import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Diperlukan untuk mendeteksi kIsWeb
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'jwt_interceptor.dart';

part 'dio_client.g.dart';

@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  return const FlutterSecureStorage();
}

@riverpod
Dio dio(DioRef ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  // Menentukan BaseURL secara dinamis
  String getBaseUrl() {
    if (kIsWeb) {
      // Jika berjalan di Web (Chrome/Edge)
      return 'http://localhost:8080/api/v1';
    } else if (Platform.isAndroid) {
      // Jika berjalan di Emulator Android
      return 'http://10.0.2.2:8080/api/v1';
    } else {
      // Jika berjalan di iOS Simulator atau Desktop
      return 'http://localhost:8080/api/v1';
    }
  }

  final dio = Dio(
    BaseOptions(
      baseUrl: getBaseUrl(),
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
