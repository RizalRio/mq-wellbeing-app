import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import halaman input yang sudah ada untuk dipanggil via FAB
import '../../mood_tracker/presentation/mood_screen.dart';
import '../../mood_tracker/presentation/mood_history_screen.dart'; // Halaman riwayat mood
import '../../journal/presentation/journal_screen.dart';
import '../../journal/presentation/journal_history_screen.dart'; // Halaman riwayat jurnal
import '../../habit/presentation/habit_screen.dart';
import '../../habit/presentation/habit_history_screen.dart'; // Halaman riwayat kebiasaan

class FeelingTabScreen extends ConsumerWidget {
  const FeelingTabScreen({super.key});

  // Fungsi untuk memunculkan menu dari bawah (Bottom Sheet)
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
                    Navigator.pop(context); // Tutup bottom sheet
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
                    // Arahkan ke halaman habit atau panggil dialog tambah habit
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

    return Scaffold(
      appBar: AppBar(title: const Text('Ruang Refleksi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'Pantau perjalanan emosional dan rutinitasmu di sini.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),

            // Kartu Rangkuman (Akan mengarah ke halaman History masing-masing saat di-tap)
            _buildSummaryCard(
              context,
              title: 'Riwayat Mood',
              subtitle: 'Lihat fluktuasi energimu minggu ini.',
              icon: Icons.bar_chart_rounded,
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
            const SizedBox(height: 16),
            _buildSummaryCard(
              context,
              title: 'Jurnal Tersimpan',
              subtitle: 'Baca kembali pemikiran dan refleksimu.',
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
            const SizedBox(height: 16),
            _buildSummaryCard(
              context,
              title: 'Jejak Kebiasaan',
              subtitle: 'Pantau konsistensi dan lencanamu.',
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
          ],
        ),
      ),
      // FAB Sentral untuk semua input
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(width: 20),
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
                    Text(subtitle, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
