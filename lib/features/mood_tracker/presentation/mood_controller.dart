import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/mood_repository.dart';

part 'mood_controller.g.dart';

@riverpod
class MoodController extends _$MoodController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> submit(int scale, List<String> tags, String note) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(moodRepositoryProvider);
      await repository.submitMood(scale, tags, note);
      state = const AsyncData(null);
      return true; // Mengembalikan true jika sukses
    } catch (e, st) {
      state = AsyncError(e, st);
      return false; // Mengembalikan false jika gagal
    }
  }
}
