import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/counselor_repository.dart';
import '../domain/counselor.dart';

part 'counselor_controller.g.dart';

@riverpod
class HighRiskClients extends _$HighRiskClients {
  @override
  FutureOr<List<HighRiskClient>> build() async {
    return ref.watch(counselorRepositoryProvider).getHighRiskClients();
  }
}

@riverpod
class CounselorSchedules extends _$CounselorSchedules {
  @override
  FutureOr<List<CounselorSchedule>> build() async {
    return ref.watch(counselorRepositoryProvider).getSchedules();
  }
}
