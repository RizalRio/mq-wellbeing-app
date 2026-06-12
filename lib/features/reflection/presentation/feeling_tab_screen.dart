import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../insight/presentation/insight_controller.dart';
import '../../insight/domain/insight_summary.dart';

import '../../assessment/presentation/assessment_screen.dart';
import '../../mood_tracker/presentation/mood_screen.dart';
import '../../mood_tracker/presentation/mood_history_screen.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../journal/presentation/journal_history_screen.dart';
import '../../habit/presentation/habit_screen.dart';
import '../../habit/presentation/habit_history_screen.dart';

class FeelingTabScreen extends ConsumerWidget {
  const FeelingTabScreen({super.key});

  void _showAddMenu(BuildContext context) {
    HapticFeedback.mediumImpact();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 24.0,
              horizontal: 16.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Apa yang ingin kamu catat?',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                _buildMenuOption(
                  context,
                  icon: Icons.mood,
                  label: 'Perasaan Hari Ini (Mood)',
                  color: Colors.orange.shade300,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MoodScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuOption(
                  context,
                  icon: Icons.auto_stories_outlined,
                  label: 'Tulis Jurnal Refleksi',
                  color: colorScheme.tertiary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JournalScreen(),
                      ),
                    );
                  },
                ),
                _buildMenuOption(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Tambah Target Kebiasaan',
                  color: colorScheme.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HabitScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final insightState = ref.watch(insightControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Insight'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(insightControllerProvider.notifier).refreshInsight(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          children: [
            insightState.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) =>
                  _buildErrorCard(context, error.toString(), ref),
              data: (summary) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lapis 1: Hero Section (Skor Utama)
                  _buildInsightBoard(context, summary),

                  const SizedBox(height: 40),
                  Text('Detail Pemantauan', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),

                  // Lapis 2: Kartu Modul Dinamis
                  _buildDynamicModuleCard(
                    context,
                    title: 'Indeks TIKES (SPK)',
                    subtitle: 'Skor asesmen terakhir Anda.',
                    metricValue: summary.assessmentScore.toStringAsFixed(1),
                    metricLabel: '/ 100',
                    icon: Icons.spa_outlined,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AssessmentScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDynamicModuleCard(
                    context,
                    title: 'Rata-rata Mood',
                    subtitle: 'Kondisi 7 hari terakhir.',
                    metricValue: summary.averageMood.toStringAsFixed(1),
                    metricLabel: '/ 5.0',
                    icon: Icons.mood,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MoodHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDynamicModuleCard(
                    context,
                    title: 'Konsistensi Kebiasaan',
                    subtitle: 'Target yang diselesaikan.',
                    metricValue: summary.habitCompletionRate.toInt().toString(),
                    metricLabel: '%',
                    icon: Icons.checklist_rtl_rounded,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HabitHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildDynamicModuleCard(
                    context,
                    title: 'Jurnal Refleksi',
                    subtitle: 'Catatan pikiran Anda.',
                    metricValue: '-', // Placeholder statis untuk Jurnal
                    metricLabel: 'Entri',
                    icon: Icons.history_edu,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JournalHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // Komponen UI: Kartu Indikator Keseimbangan Utama
  Widget _buildInsightBoard(BuildContext context, InsightSummary summary) {
    final theme = Theme.of(context);
    final hasAlert =
        summary.riskAlertStatus != null && summary.riskAlertStatus!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    summary.wellbeingScore.toString(),
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      '/ 100',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary.withOpacity(0.6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  summary.scoreCategory,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                summary.dailyInsight,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),

        if (hasAlert) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.error.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: theme.colorScheme.error,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Perhatian Khusus',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary.riskAlertStatus!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Komponen UI: Penanganan Error Minimalis
  Widget _buildErrorCard(BuildContext context, String message, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 32),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () =>
                ref.read(insightControllerProvider.notifier).refreshInsight(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // Komponen UI: Kartu Modul dengan Nilai Metrik Dinamis
  Widget _buildDynamicModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String metricValue,
    required String metricLabel,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              // Bagian Metrik di Kanan
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    metricValue,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    metricLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
