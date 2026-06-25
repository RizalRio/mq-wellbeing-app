import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/counseling_repository.dart';
import '../domain/catalog.dart';

part 'counseling_controller.g.dart';

@riverpod
class CounselingCatalog extends _$CounselingCatalog {
  @override
  FutureOr<List<PublicCounselor>> build() async {
    return ref.watch(counselingRepositoryProvider).getCatalog();
  }
}
