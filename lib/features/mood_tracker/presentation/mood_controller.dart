import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/mood_repository.dart';

part 'mood_controller.g.dart';

@riverpod
class MoodController extends _$MoodController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> submitDailyMood(
    int score,
    List<String> tags,
    String note,
  ) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(moodRepositoryProvider);
      await repository.submitMood(score, tags, note);
    });
  }
}
