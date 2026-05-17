import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/dio_client.dart';
import '../domain/journal.dart';

part 'journal_repository.g.dart';

class JournalRepository {
  final Dio _dio;

  JournalRepository(this._dio);

  Future<List<JournalPrompt>> getPrompts() async {
    try {
      final response = await _dio.get('/journals/prompts');
      final List data = response.data['data'] ?? [];
      return data.map((e) => JournalPrompt.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengambil panduan jurnal.';
    }
  }

  Future<void> submitJournal(String content) async {
    try {
      // Sesuai dengan DTO CreateJournalRequest di Golang {"content": "..."}
      await _dio.post('/journals', data: {'content': content});
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal menyimpan jurnal.';
    }
  }
}

@riverpod
JournalRepository journalRepository(JournalRepositoryRef ref) {
  return JournalRepository(ref.watch(dioProvider));
}
