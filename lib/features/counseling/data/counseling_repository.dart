import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/dio_client.dart';
import '../domain/catalog.dart';

class CounselingRepository {
  final Dio _dio;

  CounselingRepository(this._dio);

  Future<List<PublicCounselor>> getCatalog() async {
    try {
      final response = await _dio.get('/counselors');
      final List data = response.data['data'] ?? [];
      return data.map((e) => PublicCounselor.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat katalog pakar';
    }
  }

  Future<void> checkoutSchedule(String scheduleId) async {
    try {
      await _dio.post(
        '/bookings/checkout', // Endpoint Golang Anda
        data: {'schedule_id': scheduleId},
      );
      // Kita tidak mereturn objek karena di fase MVP ini kita hanya butuh status HTTP 201 Created
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Gagal memesan jadwal';
    } catch (e) {
      throw 'Terjadi kesalahan sistem';
    }
  }
}

final counselingRepositoryProvider = Provider<CounselingRepository>((ref) {
  return CounselingRepository(ref.watch(dioProvider));
});
