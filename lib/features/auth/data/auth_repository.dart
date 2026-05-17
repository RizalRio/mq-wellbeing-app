import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/dio_client.dart';
import '../domain/user.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthRepository(this._dio, this._secureStorage);

  Future<User> register(String fullName, String email, String password) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {'full_name': fullName, 'email': email, 'password': password},
      );
      return User.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Terjadi kesalahan saat registrasi';
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      final responseData = response.data['data'];

      // Simpan JWT Token ke Secure Storage
      final token = responseData['token'];
      await _secureStorage.write(key: 'jwt_token', value: token);

      return User.fromJson(responseData['user']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ??
          'Gagal login, periksa kembali email dan password';
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
  }
}

// Provider untuk AuthRepository agar mudah dipanggil oleh Controller
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthRepository(dio, secureStorage);
}

extension ProfileExtension on AuthRepository {
  // Menggunakan extension agar tidak merusak kode yang ada

  // Fungsi untuk mengambil data profil singkat
  Future<String> getMyProfile() async {
    try {
      // Endpoint /me dari Golang
      final response = await _dio.get('/me');
      // Mengambil user_id dari respons {"data": {"user_id": "..."}}
      final userId =
          response.data['data']['user_id'] ?? 'User ID tidak diketahui';
      return userId;
    } catch (e) {
      throw 'Gagal mengambil data profil';
    }
  }

  // Fungsi untuk Logout (menghapus token lokal)
  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    // Menghapus kunci token JWT dari perangkat secara permanen
    await storage.delete(key: 'jwt_token');
  }
}
