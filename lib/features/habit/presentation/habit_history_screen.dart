import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';

import 'habit_screen.dart'; // Menggunakan dialog penambahan habit dari screen lama

// 1. PROVIDER DINAMIS (Integrasi JSON Master Habit)
final habitHistoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      try {
        // 1. Ambil data dari API
        final dio = ref.watch(
          dioProvider,
        ); // Sesuaikan dengan instance Dio kamu
        final response = await dio.get('/habits'); // Sesuaikan rute

        // 2. PERBAIKAN: Deteksi Struktur JSON yang sangat aman
        List<dynamic> responseData = [];

        if (response.data is List) {
          // Jika JSON diawali dengan [ ... ] (Array langsung)
          responseData = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          // Jika JSON diawali dengan { "data": [ ... ] } (Objek)
          responseData = response.data['data'];
        } else {
          // Jika kosong atau format tidak dikenali
          responseData = [];
        }

        // 3. Kembalikan data yang sudah dipetakan dengan aman
        return responseData.map((e) => e as Map<String, dynamic>).toList();
      } catch (e) {
        throw Exception('Gagal memuat data habit: $e');
      }
    });

class HabitHistoryScreen extends ConsumerWidget {
  const HabitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final historyAsync = ref.watch(habitHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Jejak Kebiasaan'), centerTitle: true),
      body: SafeArea(
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Gagal memuat jejak rutinitas: $err')),
          data: (habits) {
            if (habits.isEmpty) {
              return const Center(
                child: Text('Belum ada kebiasaan yang tercatat.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                return _buildHabitHistoryCard(context, habits[index]);
              },
            );
          },
        ),
      ),
      // FAB Sentral untuk penambahan kebiasaan baru
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          // Panggil HabitScreen lama tempat dialog form pembuatan berada
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HabitScreen()),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text(
          'Target Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget Bantuan: Kartu Visualisasi Kebiasaan
  Widget _buildHabitHistoryCard(
    BuildContext context,
    Map<String, dynamic> habit,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<String> days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

    // 1. Ekstraksi Judul (Aman)
    final String title = habit['title']?.toString() ?? 'Kebiasaan';

    // 2. PERBAIKAN: Ekstraksi Angka yang Sangat Aman (Anti-Crash)
    int streak = 0;
    if (habit['streak_count'] != null) {
      // Ubah apapun yang datang dari API menjadi String dulu, baru di-parse ke Int
      streak = int.tryParse(habit['streak_count'].toString()) ?? 0;
    }

    // 3. PERBAIKAN: Ekstraksi Array yang Sangat Aman
    List<dynamic> weeklyStatus = [
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    ];
    if (habit['weekly_status'] is List) {
      weeklyStatus = habit['weekly_status'] as List<dynamic>;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title, // Membaca judul dinamis dari JSON
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak Hari',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              // Jika array dari backend kurang dari 7, sisanya anggap false
              final bool isDone = index < weeklyStatus.length
                  ? weeklyStatus[index] == true
                  : false;

              return Column(
                children: [
                  Text(
                    days[index],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isDone ? colorScheme.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.15),
                        width: 1.5,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : const SizedBox.shrink(),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
