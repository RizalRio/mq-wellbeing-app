import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/insight_summary.dart';
// Sesuaikan dengan path file Dio Client Anda
import '../../../core/api/dio_client.dart';

class InsightRepository {
  final Dio _dio;

  InsightRepository(this._dio);

  Future<InsightSummary> fetchSummary() async {
    try {
      // Path URL tetap menembak /dashboard/summary sesuai struktur Golang
      final response = await _dio.get('/dashboard/summary');

      return InsightSummary.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat insight harian';
    }
  }
}

// Provider untuk injeksi ke Controller
final insightRepositoryProvider = Provider<InsightRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return InsightRepository(dio);
});
