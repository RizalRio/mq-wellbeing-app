import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/dio_client.dart';
import '../domain/counselor.dart';

class CounselorRepository {
  final Dio _dio;

  CounselorRepository(this._dio);

  Future<List<HighRiskClient>> getHighRiskClients() async {
    try {
      final response = await _dio.get('/counselor/clients');
      final List data = response.data['data'] ?? [];
      return data.map((e) => HighRiskClient.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat daftar klien krisis';
    }
  }

  Future<List<CounselorSchedule>> getSchedules() async {
    try {
      final response = await _dio.get('/counselor/schedules');
      final List data = response.data['data'] ?? [];
      return data.map((e) => CounselorSchedule.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat agenda jadwal';
    }
  }
}

final counselorRepositoryProvider = Provider<CounselorRepository>((ref) {
  // Asumsi dioProvider di core/api/dio_client.dart
  final dio = ref.watch(dioProvider);
  return CounselorRepository(dio);
});
