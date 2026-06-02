import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'habit_screen.dart';
import 'habit_controller.dart';
import '../domain/habit.dart';

class HabitHistoryScreen extends ConsumerWidget {
  const HabitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Membaca langsung dari controller utama (Single Source of Truth)
    // Tidak perlu lagi membuat FutureProvider terpisah
    final historyAsync = ref.watch(habitControllerProvider);

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          // Navigasi ke layar pembuatan habit baru
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

  // Widget Bantuan: Kartu Visualisasi Kebiasaan (Menerima objek Habit)
  Widget _buildHabitHistoryCard(BuildContext context, Habit habit) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Label statis untuk kalender Senin - Minggu
    final List<String> days = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

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
                  habit.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Menampilkan lencana api jika streak lebih dari 0
              if (habit.streakCount > 0)
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
                        '${habit.streakCount} Hari',
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

          // Deretan 7 Lingkaran Harian
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              // Pengamanan akses array
              final bool isDone = habit.weeklyStatus.length > index
                  ? habit.weeklyStatus[index]
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
