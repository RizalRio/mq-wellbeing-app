import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<String> build() async {
    // Memuat profil saat halaman pertama kali dibuka
    final repository = ref.read(authRepositoryProvider);
    return await repository.getMyProfile();
  }

  Future<bool> processLogout() async {
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      return true;
    } catch (e) {
      return false;
    }
  }
}
