import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/api/dio_client.dart';
import '../domain/habit.dart';

part 'habit_repository.g.dart';

class HabitRepository {
  final Dio _dio;

  HabitRepository(this._dio);

  Future<List<Habit>> getHabits() async {
    try {
      final response = await _dio.get('/habits');

      // PERBAIKAN: Deteksi otomatis bentuk respons dari Backend
      List data = [];
      final responseData = response.data;

      if (responseData is List) {
        // Jika Golang mengirimkan array langsung: [ {id:...}, {id:...} ]
        data = responseData;
      } else if (responseData is Map<String, dynamic>) {
        // Jika Golang mengirimkan objek terbungkus: {"data": [ {id:...} ]}
        data = responseData['data'] ?? [];
      }

      return data.map((e) => Habit.fromJson(e)).toList();
    } on DioException catch (e) {
      // Penanganan error yang lebih aman jika backend mengembalikan error text
      final errorData = e.response?.data;
      final errorMessage = errorData is Map
          ? errorData['error'] ?? errorData['message']
          : 'Gagal mengambil daftar habit.';
      throw errorMessage;
    }
  }

  Future<void> createHabit(String title, String frequency) async {
    try {
      await _dio.post(
        '/habits',
        data: {'title': title, 'frequency': frequency},
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal membuat habit baru.';
    }
  }

  Future<void> logActivity(String habitId, String status, String date) async {
    try {
      await _dio.post(
        '/habits/log',
        data: {'habit_id': habitId, 'status': status, 'date': date},
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mencatat aktivitas.';
    }
  }
}

@riverpod
HabitRepository habitRepository(HabitRepositoryRef ref) {
  return HabitRepository(ref.watch(dioProvider));
}
