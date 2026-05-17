import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/journal_repository.dart';
import '../domain/journal.dart';

part 'journal_controller.g.dart';

@riverpod
class JournalPrompts extends _$JournalPrompts {
  @override
  FutureOr<List<JournalPrompt>> build() async {
    final repository = ref.read(journalRepositoryProvider);
    return await repository.getPrompts();
  }
}

@riverpod
class SubmitJournalController extends _$SubmitJournalController {
  @override
  AsyncValue<void> build() {
    return const AsyncData(null);
  }

  Future<bool> submit(String content) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(journalRepositoryProvider);
      await repository.submitJournal(content);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}
