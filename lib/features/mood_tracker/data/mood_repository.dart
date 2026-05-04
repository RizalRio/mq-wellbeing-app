import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/dio_client.dart';
import '../domain/mood_log.dart';

part 'mood_repository.g.dart';

class MoodRepository {
  final Dio _dio;

  MoodRepository(this._dio);

  Future<MoodLog> submitMood(int score, List<String> tags, String note) async {
    try {
      final response = await _dio.post(
        '/moods',
        data: {'mood_score': score, 'activity_tags': tags, 'note': note},
      );
      return MoodLog.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal menyimpan mood hari ini.';
    }
  }
}

@riverpod
MoodRepository moodRepository(MoodRepositoryRef ref) {
  return MoodRepository(ref.watch(dioProvider));
}
