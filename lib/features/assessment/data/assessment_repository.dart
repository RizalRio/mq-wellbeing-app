import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// TODO: Sesuaikan path import Dio client Anda
import '../../../../core/api/dio_client.dart';

class AssessmentRepository {
  final Dio _dio;

  AssessmentRepository(this._dio);

  Future<Map<String, dynamic>> calculateAssessment(
    String assessmentId,
    List<int> answers,
  ) async {
    try {
      final response = await _dio.post(
        '/assessments/$assessmentId/calculate',
        data: {'answers': answers},
      );

      // Mengembalikan objek AssessmentResult dari JSON Golang
      return response.data['data'];
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal menghubungi server komputasi';
    }
  }
}

// Provider untuk memudahkan injeksi dependensi
final assessmentRepositoryProvider = Provider<AssessmentRepository>((ref) {
  final dio = ref.watch(
    dioProvider,
  ); // Asumsi Anda memiliki provider Dio global
  return AssessmentRepository(dio);
});
