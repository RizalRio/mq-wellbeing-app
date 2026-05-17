import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/dio_client.dart';
import '../domain/mood.dart';

part 'mood_repository.g.dart';

class MoodRepository {
  final Dio _dio;

  MoodRepository(this._dio);

  Future<Mood> submitMood(int scale, List<String> tags, String note) async {
    try {
      final response = await _dio.post(
        '/moods',
        data: {'score': scale, 'tags': tags, 'note': note},
      );
      return Mood.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ??
          'Gagal menyimpan data mood. Coba lagi nanti.';
    }
  }
}

@riverpod
MoodRepository moodRepository(MoodRepositoryRef ref) {
  return MoodRepository(ref.watch(dioProvider));
}
