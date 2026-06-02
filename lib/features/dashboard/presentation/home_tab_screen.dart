// lib/features/dashboard/presentation/home_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/profile_controller.dart';
import '../../mood_tracker/presentation/mood_screen.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../assessment/presentation/assessment_screen.dart';
// Import kustom widget yang flat design (reusable card)
// import '../../../../core/widgets/flat_card.dart';

class HomeTabScreen extends ConsumerWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MQ Wellbeing'),
        actions: [
          // Indikator sinkronisasi data minimalis (SAMPADA v2.0)
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.sync_outlined,
              color: colorScheme.primary.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sapaan Empatik Minimalis
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mari kembali terhubung,',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      profileState.when(
                        data: (user) {
                          // PERBAIKAN: Ekstrak nama depan dari objek User
                          final String fullName = user.fullName;

                          // Ambil kata pertama (Nama Depan), jika kosong gunakan fallback 'Kawan'
                          final String firstName = fullName.isNotEmpty
                              ? fullName.trim().split(' ').first
                              : 'Kawan';

                          return Text(
                            '$firstName \u{1F33F}', // Output: Rizal 🌿
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                        loading: () => Text(
                          'Memuat...',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                        error: (_, __) => Text(
                          'Kawan \u{1F33F}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: colorScheme.secondary.withOpacity(0.1),
                    radius: 24,
                    child: Icon(
                      Icons.person_outline,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 2. Akses Cepat Minimalis (Adaptive UI)
              Text('Log Hari Ini', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildLogActionButton(
                      context,
                      icon: Icons.mood,
                      label: 'Mood',
                      color: Colors.orange.shade300,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoodScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLogActionButton(
                      context,
                      icon: Icons.book,
                      label: 'Jurnal',
                      color: Colors.blue.shade300,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JournalScreen(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLogActionButton(
                      context,
                      icon: Icons.spa_outlined,
                      label: 'Asesmen',
                      color: Colors.purple.shade300,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssessmentScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 3. Resource Library (Insight & Artikel) - Prioritas Utama Beranda (SAMPADA)
              Text('Ruang Insight', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              _buildInsightCard(
                context,
                title: 'MengenalSubjective Wellbeing (SWB)',
                subtitle:
                    'Apa itu kesejahteraan mental bagi masyarakat Indonesia?',
                type: 'Artikel',
                icon: Icons.article_outlined,
              ),
              const SizedBox(height: 16),
              _buildInsightCard(
                context,
                title: '5 Menit Meditasi Nusantara',
                subtitle: 'Temukan ketenangan di tengah hiruk pikuk kota.',
                type: 'Audio Relax',
                icon: Icons.headset_mic_outlined,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Bantuan: Tombol Akses Log Minimalis
  Widget _buildLogActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact(); // Getaran taktil adaptif
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Bantuan: Kartu Insight (Resource Library)
  Widget _buildInsightCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String type,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(
                    0.2,
                  ), // Lavender Pudar
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: theme.colorScheme.tertiary, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        type,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
