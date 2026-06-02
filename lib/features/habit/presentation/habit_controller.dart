import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/dio_client.dart';
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

  // Di dalam class HabitController / Notifier Anda
  Future<bool> toggleHabitLog(String habitId, bool isCompleted) async {
    try {
      // 1. Terjemahkan boolean ke teks untuk Golang
      final String status = isCompleted ? 'completed' : 'skipped';

      // 2. Format tanggal ke YYYY-MM-DD secara manual (Aman dari zona waktu)
      final now = DateTime.now();
      final String year = now.year.toString();
      final String month = now.month.toString().padLeft(2, '0');
      final String day = now.day.toString().padLeft(2, '0');
      final String dateStr = "$year-$month-$day";

      // 3. Kirim ke API
      final dio = ref.read(dioProvider);
      final response = await dio.post(
        '/habits/log',
        data: {'habit_id': habitId, 'status': status, 'date': dateStr},
      );

      return response.statusCode == 200;
    } catch (e) {
      // Catat error di terminal
      debugPrint('Gagal mengirim log habit: $e');
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
