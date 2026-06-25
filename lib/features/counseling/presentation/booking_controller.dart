import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/counseling_repository.dart';

part 'booking_controller.g.dart';

@riverpod
class BookingController extends _$BookingController {
  @override
  FutureOr<void> build() {
    // Status awal kosong
  }

  Future<bool> checkout(String scheduleId) async {
    state = const AsyncLoading(); // Memicu UI untuk menampilkan indikator putar
    try {
      final repo = ref.read(counselingRepositoryProvider);
      await repo.checkoutSchedule(scheduleId);

      state = const AsyncData(null); // Sukses
      return true;
    } catch (e, st) {
      state = AsyncError(e, st); // Gagal, simpan pesan error
      return false;
    }
  }
}
