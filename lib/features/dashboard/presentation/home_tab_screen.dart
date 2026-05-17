import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Diperlukan untuk HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/profile_controller.dart';
import '../../habit/presentation/habit_controller.dart';

class HomeTabScreen extends ConsumerWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final habitState = ref.watch(habitControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Background otomatis mengikuti scaffoldBackgroundColor dari AppTheme (Warm Beige)
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Sapaan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mari mulai harimu,',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      profileState.when(
                        data: (userId) => Text(
                          'Kawan \u{1F33F}', // Menggunakan emoji daun (earthy)
                          style: theme.textTheme.titleLarge,
                        ),
                        loading: () => const Text('Memuat...'),
                        error: (_, __) => Text(
                          'Kawan \u{1F33F}',
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  // Avatar Minimalis
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 2. Afirmasi Harian (Flat Card)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.spa_outlined,
                      color: colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        '"Satu langkah kecil setiap hari adalah kunci perubahan besar."',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 3. Ringkasan Habit Hari Ini (Soft Primary Focus)
              Text('Fokus Hari Ini', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              habitState.when(
                data: (habits) {
                  final totalHabits = habits.length;
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primary, // Sage Green
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Kebiasaan',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              totalHabits > 0
                                  ? '$totalHabits Jadwal'
                                  : 'Belum ada jadwal',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.water_drop_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Text('Gagal memuat ringkasan.'),
              ),
              const SizedBox(height: 40),

              // 4. Quick Actions dengan Interaksi Haptic
              Text('Ruang Interaksi', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      title: 'Catat\nMood',
                      icon: Icons.mood,
                      color: colorScheme.secondary,
                      onTap: () {
                        HapticFeedback.lightImpact(); // Memberikan getaran halus
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Buka tab Mood Tracker'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      context,
                      title: 'Tulis\nJurnal',
                      icon: Icons.auto_stories_outlined,
                      color: colorScheme.tertiary, // Lavender Muda
                      onTap: () {
                        HapticFeedback.lightImpact(); // Memberikan getaran halus
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Buka tab Ruang Refleksi'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Bantuan dengan Material InkWell untuk efek Ripple dan aksesibilitas
  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onSurface,
                size: 32,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
