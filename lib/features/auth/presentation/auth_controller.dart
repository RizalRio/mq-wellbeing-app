import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../domain/user.dart';

part 'auth_controller.g.dart';

// Controller menggunakan Notifier dari Riverpod untuk mengelola state User secara reaktif
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<User?> build() {
    // State awal adalah null (belum ada user yang login)
    // Di masa depan, kamu bisa menambahkan logika untuk mengecek token yang sudah tersimpan di sini
    return null;
  }

  Future<void> login(String email, String password) async {
    // Set state ke loading agar UI bisa menampilkan indikator putar (spinner)
    state = const AsyncValue.loading();

    // Gunakan AsyncValue.guard untuk menangani try-catch secara otomatis
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.login(email, password);
    });
  }

  Future<void> register(String fullName, String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return await repository.register(fullName, email, password);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
    state = const AsyncValue.data(null); // Kosongkan data user
  }
}
