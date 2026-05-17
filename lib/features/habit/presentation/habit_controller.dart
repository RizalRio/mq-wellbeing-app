import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/habit_repository.dart';
import '../domain/habit.dart';

part 'habit_controller.g.dart';

@riverpod
class HabitController extends _$HabitController {
  @override
  FutureOr<List<Habit>> build() async {
    return _fetchHabits();
  }

  Future<List<Habit>> _fetchHabits() async {
    final repository = ref.read(habitRepositoryProvider);
    return await repository.getHabits();
  }

  // Fungsi untuk menambah habit dan memuat ulang daftar
  Future<bool> addHabit(String title) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      await repository.createHabit(title, 'daily');
      // Memuat ulang data dari backend setelah berhasil
      state = AsyncData(await _fetchHabits());
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  // Fungsi untuk mencatat (log) aktivitas habit hari ini
  Future<bool> logHabitDone(String habitId) async {
    try {
      final repository = ref.read(habitRepositoryProvider);

      // Mengambil tanggal hari ini dengan format YYYY-MM-DD
      final now = DateTime.now();
      final dateString =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      await repository.logActivity(habitId, 'completed', dateString);
      return true;
    } catch (e) {
      return false;
    }
  }
}
