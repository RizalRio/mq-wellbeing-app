// lib/features/dashboard/presentation/home_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../insight/presentation/insight_controller.dart';
import '../../insight/domain/insight_summary.dart';

import '../../auth/presentation/profile_controller.dart';
import '../../mood_tracker/presentation/mood_screen.dart';
import '../../mood_tracker/presentation/mood_history_screen.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../journal/presentation/journal_history_screen.dart';
import '../../habit/presentation/habit_screen.dart';
import '../../habit/presentation/habit_controller.dart';
import '../../assessment/presentation/assessment_screen.dart';

// ─────────────────────────────────────────────────
// Data Model & Provider Khusus Log Hari Ini (Grid)
// ─────────────────────────────────────────────────
class DailyLogStatus {
  final bool isMoodDone;
  final String moodStatusText;
  final bool isJournalDone;
  final String journalStatusText;
  final bool isHabitDone;
  final String habitStatusText;
  final bool isAssessmentDone;
  final String assessmentStatusText;

  DailyLogStatus({
    required this.isMoodDone,
    required this.moodStatusText,
    required this.isJournalDone,
    required this.journalStatusText,
    required this.isHabitDone,
    required this.habitStatusText,
    required this.isAssessmentDone,
    required this.assessmentStatusText,
  });
}

// Helper Lokal: Mengubah Skor Mood Menjadi Teks
String _getMoodStatusLabel(int score) {
  switch (score) {
    case 5:
      return 'Sangat Baik';
    case 4:
      return 'Baik';
    case 3:
      return 'Netral';
    case 2:
      return 'Buruk';
    case 1:
      return 'Sangat Buruk';
    default:
      return 'Selesai';
  }
}

// Provider untuk mengambil data agregasi dari backend
final dailyLogStatusProvider = FutureProvider.autoDispose<DailyLogStatus>((
  ref,
) async {
  final moodList = await ref.watch(moodHistoryProvider.future);
  final journalList = await ref.watch(journalHistoryProvider.future);
  final habitList = await ref.watch(habitControllerProvider.future);

  final now = DateTime.now();
  final todayIdx = now.weekday - 1;

  // Filter Data Mood Hari Ini
  final todayMoods = moodList.where((m) {
    try {
      final d = DateTime.parse(m['logged_at'].toString()).toLocal();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    } catch (_) {
      return false;
    }
  }).toList();
  final bool isMoodDone = todayMoods.isNotEmpty;
  String moodStatusText = isMoodDone
      ? _getMoodStatusLabel(todayMoods.first['score'] as int? ?? 0)
      : 'Belum log';

  // Filter Data Jurnal Hari Ini
  final todayJournals = journalList.where((j) {
    try {
      final d = DateTime.parse(j['created_at'].toString()).toLocal();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    } catch (_) {
      return false;
    }
  }).toList();
  final bool isJournalDone = todayJournals.isNotEmpty;
  String journalStatusText = isJournalDone
      ? '${todayJournals.length} Catatan'
      : 'Belum log';

  // Filter Data Habit Hari Ini
  final int totalHabits = habitList.length;
  final int doneHabits = habitList
      .where(
        (h) => h.weeklyStatus.length > todayIdx && h.weeklyStatus[todayIdx],
      )
      .length;
  bool isHabitDone = false;
  String habitStatusText = 'Belum log';

  if (totalHabits == 0) {
    habitStatusText = 'Tidak ada target';
  } else if (doneHabits == totalHabits) {
    isHabitDone = true;
    habitStatusText = 'Semua Selesai';
  } else {
    habitStatusText = '$doneHabits/$totalHabits Selesai';
  }

  return DailyLogStatus(
    isMoodDone: isMoodDone,
    moodStatusText: moodStatusText,
    isJournalDone: isJournalDone,
    journalStatusText: journalStatusText,
    isHabitDone: isHabitDone,
    habitStatusText: habitStatusText,
    isAssessmentDone: false,
    assessmentStatusText: 'Cek kondisimu',
  );
});

// ─────────────────────────────────────────────────
// Data model pembantu untuk Log Action & Insight
// ─────────────────────────────────────────────────
class _LogAction {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final Color bgColor;
  final bool isDone;
  final VoidCallback onTap;

  const _LogAction({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.bgColor,
    required this.isDone,
    required this.onTap,
  });
}

class _InsightItem {
  final String title;
  final String subtitle;
  final String type;
  final String duration;
  final List<Color> gradientColors;
  final IconData typeIcon;

  const _InsightItem({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.duration,
    required this.gradientColors,
    required this.typeIcon,
  });
}

// ─────────────────────────────────────────────────
// HomeTabScreen
// ─────────────────────────────────────────────────
class HomeTabScreen extends ConsumerWidget {
  const HomeTabScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final insightState = ref.watch(insightControllerProvider);
    final logGridState = ref.watch(dailyLogStatusProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<_InsightItem> insightItems = [
      _InsightItem(
        title: 'Mengenal Subjective Wellbeing',
        subtitle: 'Apa itu kesejahteraan mental bagi masyarakat Indonesia?',
        type: 'Artikel',
        duration: '5 mnt',
        gradientColors: [colorScheme.primary, colorScheme.secondary],
        typeIcon: Icons.article_rounded,
      ),
      _InsightItem(
        title: 'Meditasi Napas 5 Menit',
        subtitle: 'Teknik sederhana untuk menenangkan pikiran sebelum tidur.',
        type: 'Audio',
        duration: '5 mnt',
        gradientColors: [
          colorScheme.secondary.withOpacity(0.7),
          colorScheme.secondary,
        ],
        typeIcon: Icons.headphones_rounded,
      ),
      _InsightItem(
        title: 'Rutinitas Pagi yang Sehat',
        subtitle: 'Mulai hari dengan kebiasaan sederhana yang berdampak besar.',
        type: 'Video',
        duration: '8 mnt',
        gradientColors: [colorScheme.secondary, colorScheme.primary],
        typeIcon: Icons.play_circle_rounded,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F6F0),
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: _buildGreetingSection(context, profileState),
              ),
              const SizedBox(height: 28),

              // Penanganan State untuk Skor Keseimbangan
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: insightState.when(
                  data: (data) => _buildWellbeingScoreCard(context, data),
                  loading: () => _buildWellbeingSkeleton(context),
                  error: (err, stack) => _buildWellbeingScoreCard(
                    context,
                    InsightSummary(
                      wellbeingScore: 0,
                      scoreCategory: 'Gagal',
                      dailyInsight: 'Gagal memuat data ringkasan.',
                      assessmentScore: 0,
                      averageMood: 0,
                      habitCompletionRate: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSectionHeader(
                  context,
                  'Log Hari Ini',
                  actionLabel: null,
                ),
              ),
              const SizedBox(height: 14),

              // Penanganan State untuk Log Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: logGridState.when(
                  data: (data) => _buildLogGrid(context, ref, data),
                  loading: () => _buildLogGridSkeleton(context),
                  error: (_, __) => _buildLogGrid(context, ref, null),
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildSectionHeader(
                  context,
                  'Insight Harian',
                  actionLabel: 'Lihat Semua',
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildQuoteCard(context),
              ),
              const SizedBox(height: 16),
              _buildInsightScroll(context, insightItems),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // AppBar, Header, Quote & Insight (Dipertahankan)
  // ─────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 24,
      title: Text(
        'MQ Wellbeing',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: colorScheme.onSurface,
        ),
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined, size: 22),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () {
            ref.read(insightControllerProvider.notifier).refreshInsight();
            ref.invalidate(moodHistoryProvider);
            ref.invalidate(journalHistoryProvider);
            ref.invalidate(habitControllerProvider);
          },
          icon: Icon(
            Icons.sync_outlined,
            color: colorScheme.onSurface.withOpacity(0.35),
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    String? actionLabel,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        if (actionLabel != null)
          GestureDetector(
            onTap: () {},
            child: Text(
              actionLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context, AsyncValue profileState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
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
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getFormattedDate(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text('${_getGreeting()},', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 2),
              profileState.when(
                data: (user) {
                  final firstName = (user.fullName.isNotEmpty)
                      ? user.fullName.trim().split(' ').first
                      : 'Kawan';
                  return Row(
                    children: [
                      Text(
                        firstName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('🌿', style: TextStyle(fontSize: 20)),
                    ],
                  );
                },
                loading: () => Container(
                  height: 28,
                  width: 130,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                error: (_, __) => Row(
                  children: [
                    Text(
                      'Kawan',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('🌿', style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Avatar Profil di kanan
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              profileState.when(
                data: (user) {
                  final fullName = user.fullName?.toString() ?? '';

                  final initial = fullName.trim().isNotEmpty
                      ? fullName
                            .trim()
                            .split(' ')
                            .take(2)
                            .map((e) => e[0])
                            .join()
                            .toUpperCase()
                      : 'U';

                  return Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: colorScheme.surface,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  );
                },

                loading: () => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                ),

                error: (_, __) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'U',
                    style: TextStyle(
                      color: colorScheme.surface,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  // Wellbeing Score Card
  // ─────────────────────────────────────────────────
  Widget _buildWellbeingScoreCard(BuildContext context, InsightSummary data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.45),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildScoreRing(context, data.wellbeingScore),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Insight Anda',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.surface,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.scoreCategory.toUpperCase(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.surface,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.dailyInsight,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.surface.withOpacity(0.72),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  color: colorScheme.surface.withOpacity(0.18),
                  thickness: 1,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSubMetric(
                      context,
                      Icons.psychology_rounded,
                      'Asesmen',
                      data.assessmentScore.toStringAsFixed(0),
                    ),
                    _buildSubMetricDivider(context),
                    _buildSubMetric(
                      context,
                      Icons.mood_rounded,
                      'Mood',
                      data.averageMood.toStringAsFixed(1),
                    ), // Nilai dinamis
                    _buildSubMetricDivider(context),
                    _buildSubMetric(
                      context,
                      Icons.task_alt_rounded,
                      'Habit',
                      '${data.habitCompletionRate.toStringAsFixed(0)}%',
                    ), // Nilai dinamis
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Skeleton Loader untuk Skor Keseimbangan
  Widget _buildWellbeingSkeleton(BuildContext context) {
    return Container(
      height: 220, // Perkiraan tinggi kartu
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }

  Widget _buildScoreRing(BuildContext context, int score) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 84,
      width: 84,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 7,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              colorScheme.surface.withOpacity(0.16),
            ),
          ),
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 7,
            backgroundColor: colorScheme.surface.withOpacity(0.16),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.surface),
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  score.toString(),
                  style: TextStyle(
                    color: colorScheme.surface,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                    height: 1.0,
                  ),
                ),
                Text(
                  '/ 100',
                  style: TextStyle(
                    color: colorScheme.surface.withOpacity(0.65),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMetric(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: colorScheme.surface.withOpacity(0.9)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.surface,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.surface.withOpacity(0.65),
              fontSize: 11,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMetricDivider(BuildContext context) => Container(
    width: 1,
    height: 44,
    color: Theme.of(context).colorScheme.surface.withOpacity(0.18),
  );

  // ─────────────────────────────────────────────────
  // Komponen Dinamis: Log Grid
  // ─────────────────────────────────────────────────
  Widget _buildLogGrid(
    BuildContext context,
    WidgetRef ref,
    DailyLogStatus? data,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    const Color asesmenColor = Color(0xFF9B8EC4);

    final actions = [
      _LogAction(
        icon: Icons.mood_rounded,
        label: 'Mood',
        sublabel: data?.isMoodDone == true
            ? (data?.moodStatusText ?? 'Selesai')
            : 'Belum log',
        color: colorScheme.primary,
        bgColor: colorScheme.primary.withOpacity(0.15),
        isDone: data?.isMoodDone ?? false,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MoodScreen()),
          );
          ref.read(insightControllerProvider.notifier).refreshInsight();
          ref.invalidate(moodHistoryProvider);
        },
      ),
      _LogAction(
        icon: Icons.auto_stories_rounded,
        label: 'Jurnal',
        sublabel: data?.isJournalDone == true
            ? (data?.journalStatusText ?? 'Selesai')
            : 'Belum log',
        color: colorScheme.secondary,
        bgColor: colorScheme.secondary.withOpacity(0.15),
        isDone: data?.isJournalDone ?? false,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JournalScreen()),
          );
          ref.read(insightControllerProvider.notifier).refreshInsight();
          ref.invalidate(journalHistoryProvider);
        },
      ),
      _LogAction(
        icon: Icons.check_circle_rounded,
        label: 'Habit',
        sublabel: data?.habitStatusText ?? 'Belum log',
        color: colorScheme.onSurface.withOpacity(0.6),
        bgColor: colorScheme.tertiary.withOpacity(0.5),
        isDone: data?.isHabitDone ?? false,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HabitScreen()),
          );
          ref.read(insightControllerProvider.notifier).refreshInsight();
          ref.invalidate(habitControllerProvider);
        },
      ),
      _LogAction(
        icon: Icons.spa_outlined,
        label: 'Asesmen',
        sublabel: data?.isAssessmentDone == true
            ? (data?.assessmentStatusText ?? 'Selesai')
            : 'Cek kondisimu',
        color: asesmenColor,
        bgColor: asesmenColor.withOpacity(0.15),
        isDone: data?.isAssessmentDone ?? false,
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AssessmentScreen()),
          );
          ref.read(insightControllerProvider.notifier).refreshInsight();
        },
      ),
    ];

    // Kembali menggunakan layout kolom dan baris (2x2 Grid)
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildLogCard(context, actions[0])),
            const SizedBox(width: 12),
            Expanded(child: _buildLogCard(context, actions[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLogCard(context, actions[2])),
            const SizedBox(width: 12),
            Expanded(child: _buildLogCard(context, actions[3])),
          ],
        ),
      ],
    );
  }

  Widget _buildLogGridSkeleton(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 72,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogCard(BuildContext context, _LogAction action) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          HapticFeedback.lightImpact();
          action.onTap();
        },
        child: Container(
          // Padding dibuat lebih rapat agar pas di layout grid 50%
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: action.color.withOpacity(0.18),
              width: 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon di kiri (Ukuran disesuaikan agar proporsional)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: action.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color, size: 20),
              ),
              const SizedBox(width: 12),

              // Judul & Status di kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      action.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        fontSize:
                            13, // Sedikit dikecilkan agar aman di layar sempit
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Logic status: Jika selesai tampil teks sukses, jika tidak tampil sublabel "Belum log"
                    Text(
                      action.isDone ? '✓ ${action.sublabel}' : action.sublabel,
                      style: TextStyle(
                        color: action.isDone
                            ? action.color
                            : colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 11,
                        fontWeight: action.isDone
                            ? FontWeight.w800
                            : FontWeight.w500,
                        fontFamily: 'Nunito',
                      ),
                      maxLines: 1,
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

  Widget _buildQuoteCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.surface, colorScheme.tertiary],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.tertiary, width: 1),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -14,
            right: -4,
            child: Text(
              '\u201C',
              style: TextStyle(
                fontSize: 110,
                color: colorScheme.onSurface.withOpacity(0.05),
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'KUTIPAN HARI INI',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Tidak apa-apa untuk beristirahat. Tumbuh tidak selalu berarti bergerak cepat.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w700,
                  height: 1.6,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightScroll(BuildContext context, List<_InsightItem> items) {
    return SizedBox(
      height: 226,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < items.length - 1 ? 14 : 0),
            child: _buildInsightCard(context, items[index]),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, _InsightItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradientColors,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -16,
                      right: -16,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surface.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      left: 10,
                      child: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.surface.withOpacity(0.07),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.typeIcon,
                              color: colorScheme.surface,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.type,
                              style: TextStyle(
                                color: colorScheme.surface,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.duration,
                          style: TextStyle(
                            color: colorScheme.surface,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        item.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
