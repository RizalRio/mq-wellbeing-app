import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  JwtInterceptor(this.secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Ambil token JWT dari storage yang aman
    final token = await secureStorage.read(key: 'jwt_token');

    // Jika token ada, sisipkan ke header Authorization
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Lanjutkan request
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Future-proofing: Tangani error 401 Unauthorized secara global
    // Misalnya, nantinya kamu bisa trigger logika auto-logout di sini jika token kedaluwarsa
    if (err.response?.statusCode == 401) {
      // TODO: Implementasi logika force logout via Riverpod
    }

    super.onError(err, handler);
  }
}
