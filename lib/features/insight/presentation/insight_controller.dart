import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/insight_repository.dart';
import '../domain/insight_summary.dart';

part 'insight_controller.g.dart';

@riverpod
class InsightController extends _$InsightController {
  @override
  FutureOr<InsightSummary> build() async {
    return _fetchData();
  }

  Future<InsightSummary> _fetchData() async {
    final repo = ref.read(insightRepositoryProvider);
    return await repo.fetchSummary();
  }

  // Fungsi yang dipanggil saat pengguna melakukan pull-to-refresh
  Future<void> refreshInsight() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchData());
  }
}
