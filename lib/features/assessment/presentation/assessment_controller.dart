import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/assessment_repository.dart';

part 'assessment_controller.g.dart';

@riverpod
class AssessmentController extends _$AssessmentController {
  @override
  FutureOr<void> build() {
    // Status awal kosong (tidak melakukan apa-apa)
  }

  Future<bool> submitAnswers(Map<int, int> answersMap) async {
    state =
        const AsyncLoading(); // Sekarang dikenali karena ada flutter_riverpod

    try {
      // 1. Ubah format Map {0: 4, 2: 5, 1: 3} menjadi List terurut [4, 3, 5...]
      final sortedKeys = answersMap.keys.toList()..sort();
      final answersList = sortedKeys.map((k) => answersMap[k]!).toList();

      // 2. Tembak ke API (Menggunakan UUID statis)
      final repo = ref.read(assessmentRepositoryProvider);
      const String staticAssessmentId = '11111111-1111-1111-1111-111111111111';

      final result = await repo.calculateAssessment(
        staticAssessmentId,
        answersList,
      );

      if (result['risk_alert_status'] != null) {
        print("ALERT DARI SPK: ${result['risk_alert_status']}");
      }

      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
