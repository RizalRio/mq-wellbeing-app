// lib/features/dashboard/presentation/home_tab_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/profile_controller.dart';
import '../../mood_tracker/presentation/mood_screen.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../habit/presentation/habit_screen.dart';

// ─────────────────────────────────────────────────
// Data Model Simulasi API (/api/v1/dashboard/summary)
// ─────────────────────────────────────────────────
class DashboardSummary {
  final int wellbeingScore;
  final String moodAvg;
  final String journalCount;
  final String habitPercent;
  final bool isMoodDone;
  final bool isJournalDone;
  final String habitStatusText;

  DashboardSummary({
    required this.wellbeingScore,
    required this.moodAvg,
    required this.journalCount,
    required this.habitPercent,
    required this.isMoodDone,
    required this.isJournalDone,
    required this.habitStatusText,
  });
}

// Provider untuk mengambil data agregasi dari backend
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  // Simulasi jeda jaringan API (hapus delay ini saat integrasi Dio/HTTP asli)
  await Future.delayed(const Duration(seconds: 2));
  return DashboardSummary(
    wellbeingScore: 78,
    moodAvg: '4.2 / 5',
    journalCount: '5 / 7 hr',
    habitPercent: '83 %',
    isMoodDone: false,
    isJournalDone: false,
    habitStatusText: '2 / 6 selesai',
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
    final summaryState = ref.watch(
      dashboardSummaryProvider,
    ); // Pantau API Dasbor
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
      appBar: _buildAppBar(context),
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
                child: summaryState.when(
                  data: (data) => _buildWellbeingScoreCard(context, data),
                  loading: () => _buildWellbeingSkeleton(context),
                  error: (err, stack) => _buildWellbeingScoreCard(
                    context,
                    DashboardSummary(
                      wellbeingScore: 0,
                      moodAvg: '-',
                      journalCount: '-',
                      habitPercent: '-',
                      isMoodDone: false,
                      isJournalDone: false,
                      habitStatusText: 'Gagal memuat',
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
                child: summaryState.when(
                  data: (data) => _buildLogGrid(context, data),
                  loading: () => _buildLogGridSkeleton(context),
                  error: (_, __) => _buildLogGrid(
                    context,
                    null,
                  ), // Tampilkan default jika error
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
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
          onPressed: () {},
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '7 hari',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.person_outline,
                color: colorScheme.surface,
                size: 22,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  // Komponen Dinamis: Wellbeing Score Card
  // ─────────────────────────────────────────────────
  Widget _buildWellbeingScoreCard(BuildContext context, DashboardSummary data) {
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
                    _buildScoreRing(
                      context,
                      data.wellbeingScore,
                    ), // Nilai dinamis
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
                              'MINGGU INI',
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
                            'Keseimbangan\nHidupmu',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.surface,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Agregat dari Mood, Jurnal & Habit',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.surface.withOpacity(0.72),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.surface.withOpacity(0.6),
                      size: 26,
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
                      '😊',
                      'Mood',
                      data.moodAvg,
                    ), // Nilai dinamis
                    _buildSubMetricDivider(context),
                    _buildSubMetric(
                      context,
                      '📝',
                      'Jurnal',
                      data.journalCount,
                    ), // Nilai dinamis
                    _buildSubMetricDivider(context),
                    _buildSubMetric(
                      context,
                      '✅',
                      'Habit',
                      data.habitPercent,
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
    String emoji,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
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
  Widget _buildLogGrid(BuildContext context, DashboardSummary? data) {
    final colorScheme = Theme.of(context).colorScheme;
    final actions = [
      _LogAction(
        icon: Icons.mood_rounded,
        label: 'Mood',
        sublabel: data?.isMoodDone == true ? 'Selesai' : 'Belum log',
        color: colorScheme.primary,
        bgColor: colorScheme.primary.withOpacity(0.15),
        isDone: data?.isMoodDone ?? false,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MoodScreen()),
        ),
      ),
      _LogAction(
        icon: Icons.auto_stories_rounded,
        label: 'Jurnal',
        sublabel: data?.isJournalDone == true ? 'Selesai' : 'Belum log',
        color: colorScheme.secondary,
        bgColor: colorScheme.secondary.withOpacity(0.15),
        isDone: data?.isJournalDone ?? false,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JournalScreen()),
        ),
      ),
      _LogAction(
        icon: Icons.check_circle_rounded,
        label: 'Habit',
        sublabel: data?.habitStatusText ?? 'Belum log',
        color: colorScheme.onSurface.withOpacity(0.6),
        bgColor: colorScheme.tertiary.withOpacity(0.5),
        isDone: (data != null && data.habitPercent == '100 %'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HabitScreen()),
        ),
      ),
    ];

    return Row(
      children: List.generate(
        actions.length,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < actions.length - 1 ? 12 : 0),
            child: _buildLogCard(context, actions[i]),
          ),
        ),
      ),
    );
  }

  // Skeleton Loader untuk Log Grid
  Widget _buildLogGridSkeleton(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 12 : 0),
            child: Container(
              height: 140, // Perkiraan tinggi kartu grid
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
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
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: action.color.withOpacity(0.18),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: action.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: action.color, size: 25),
              ),
              const SizedBox(height: 12),
              Text(
                action.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.sublabel,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (action.isDone) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '✓ Selesai',
                    style: TextStyle(
                      color: action.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ],
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
