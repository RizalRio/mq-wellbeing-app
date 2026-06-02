import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user.dart'; // WAJIB: Tambahkan import model User ini

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  // PERBAIKAN: Ubah FutureOr<String> menjadi FutureOr<User>
  FutureOr<User> build() async {
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
