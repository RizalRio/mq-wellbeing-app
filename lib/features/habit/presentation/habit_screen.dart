import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habit_controller.dart';

class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});

  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  // ── Bottom sheet tambah kebiasaan baru ──
  void _showAddHabitSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    final ctrl = TextEditingController();
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddHabitSheet(
        controller: ctrl,
        onSave: (title) async {
          if (title.trim().isEmpty) return;
          HapticFeedback.mediumImpact();
          final ok = await ref
              .read(habitControllerProvider.notifier)
              .addHabit(title.trim());
          if (ok && context.mounted) {
            ref.invalidate(habitControllerProvider);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Satu langkah baik telah ditambahkan.',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: habitState.when(
          loading: () => const _HabitSkeleton(),
          error: (err, _) => _buildErrorState(context),
          data: (habits) {
            if (habits.isEmpty) return _buildEmptyState(context);

            final todayIdx = DateTime.now().weekday - 1;
            final doneToday = habits
                .where(
                  (h) =>
                      h.weeklyStatus.length > todayIdx &&
                      h.weeklyStatus[todayIdx],
                )
                .length;
            final total = habits.length;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + 72,
                  ),
                ),

                // Kartu Progres Hari Ini
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildProgressCard(
                      context,
                      done: doneToday,
                      total: total,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Header daftar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSectionHeader(context, total),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Daftar Habit
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _HabitCard(
                        habit: habits[i],
                        todayIndex: todayIdx,
                        onToggle: (newValue) async {
                          final ok = await ref
                              .read(habitControllerProvider.notifier)
                              .toggleHabitLog(habits[i].id, newValue);
                          if (ok && ctx.mounted) {
                            ref.invalidate(habitControllerProvider);
                            HapticFeedback.lightImpact();
                          } else if (!ok && ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Gagal mencatat. Periksa koneksimu.',
                                  style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                margin: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      childCount: habits.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: colorScheme.onSurface,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text(
        'Target Kebiasaan',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // Kartu Progres Hari Ini
  Widget _buildProgressCard(
    BuildContext context, {
    required int done,
    required int total,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pct = total == 0 ? 0.0 : done / total;
    final isAll = done == total;
    final motivasi = _getMotivasi(done, total);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.42),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Baris atas
          Row(
            children: [
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
                        'HARI INI',
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
                      motivasi,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.surface,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Skor besar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$done',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.surface,
                            height: 1.0,
                          ),
                        ),
                        TextSpan(
                          text: ' / $total',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.surface.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'selesai',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      color: colorScheme.surface.withOpacity(0.65),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: colorScheme.surface.withOpacity(0.18),
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.surface),
              minHeight: 8,
            ),
          ),

          if (isAll && total > 0) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'Semua kebiasaan hari ini selesai!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.surface.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getMotivasi(int done, int total) {
    if (total == 0) return 'Mulai bangun\nrutinitas baru';
    if (done == 0) return 'Mulai hari\nyang produktif!';
    if (done == total) return 'Luar biasa,\nsemua selesai!';
    if (done / total >= .5) return 'Hampir selesai,\nteruskan!';
    return 'Kamu sudah mulai,\nlanjutkan!';
  }

  // Section Header
  Widget _buildSectionHeader(BuildContext context, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.checklist_rounded,
            size: 18,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semua Kebiasaan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '$count kebiasaan aktif',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // FAB
  Widget _buildFAB(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => _showAddHabitSheet(context),
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.surface,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Kebiasaan Baru',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.15),
                    colorScheme.primary.withOpacity(0.05),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
              ),
              child: const Center(
                child: Text('🌱', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Belum Ada\nKebiasaan',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bangun rutinitas positifmu satu langkah\nkecil setiap harinya.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showAddHabitSheet(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tambah Kebiasaan Pertama'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colorScheme.surface,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error State
  Widget _buildErrorState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 52,
                color: colorScheme.error.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Gagal Memuat\nKebiasaan',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Periksa koneksi internetmu,\nlalu coba lagi.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(habitControllerProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.secondary,
                side: BorderSide(color: colorScheme.secondary, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Habit Card
class _HabitCard extends StatelessWidget {
  final dynamic habit;
  final int todayIndex;
  final Future<void> Function(bool) onToggle;

  const _HabitCard({
    required this.habit,
    required this.todayIndex,
    required this.onToggle,
  });

  int _streak(List<bool> ws) {
    int s = 0;
    for (int i = todayIndex; i >= 0; i--) {
      if (ws[i])
        s++;
      else
        break;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool done = habit.weeklyStatus.length > todayIndex
        ? habit.weeklyStatus[todayIndex] as bool
        : false;
    final List<bool> weekly = List<bool>.from(habit.weeklyStatus);
    final int streak = _streak(weekly);
    final int doneWeek = weekly.where((d) => d).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: done
              ? colorScheme.primary.withOpacity(0.35)
              : colorScheme.primary.withOpacity(0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: done
                ? colorScheme.primary.withOpacity(0.10)
                : colorScheme.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => onToggle(!done),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Ikon / Status Lingkaran
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: done
                        ? colorScheme.primary
                        : colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                    boxShadow: done
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutBack,
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      done ? Icons.check_rounded : Icons.local_florist_outlined,
                      key: ValueKey(done),
                      color: done ? colorScheme.surface : colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Konten Tengah
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title as String,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: done
                              ? colorScheme.onSurface.withOpacity(0.5)
                              : colorScheme.onSurface,
                          decoration: done ? TextDecoration.lineThrough : null,
                          decorationColor: colorScheme.onSurface.withOpacity(
                            0.5,
                          ),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 7 Dots Mingguan
                      _buildWeekDots(weekly, colorScheme),

                      const SizedBox(height: 8),

                      // Meta: streak + minggu ini
                      Row(
                        children: [
                          if (streak > 0) ...[
                            const Text('🔥', style: TextStyle(fontSize: 11)),
                            const SizedBox(width: 3),
                            Text(
                              '$streak hari beruntun',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$doneWeek/7 minggu ini',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Toggle Kanan
                GestureDetector(
                  onTap: () => onToggle(!done),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: done ? colorScheme.primary : colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: done
                            ? colorScheme.primary
                            : colorScheme.primary.withOpacity(0.35),
                        width: 2,
                      ),
                      boxShadow: done
                          ? [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: done
                        ? Icon(
                            Icons.check_rounded,
                            color: colorScheme.surface,
                            size: 18,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekDots(List<bool> weekly, ColorScheme colorScheme) {
    const labels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (i) {
        final isDone = weekly.length > i ? weekly[i] : false;
        final isToday = i == todayIndex;

        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDone
                      ? colorScheme.primary
                      : isToday
                      ? colorScheme.primary.withOpacity(0.12)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone
                        ? colorScheme.primary
                        : isToday
                        ? colorScheme.primary.withOpacity(0.5)
                        : colorScheme.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: isDone
                    ? Icon(
                        Icons.check_rounded,
                        color: colorScheme.surface,
                        size: 12,
                      )
                    : null,
              ),
              const SizedBox(height: 3),
              Text(
                labels[i],
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 9,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                  color: isToday
                      ? colorScheme.primary
                      : colorScheme.onSurface.withOpacity(0.4),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// Bottom Sheet — Tambah Kebiasaan Baru
class _AddHabitSheet extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String) onSave;

  const _AddHabitSheet({required this.controller, required this.onSave});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final List<String> _suggestions = const [
    'Minum 8 gelas air',
    'Olahraga 30 menit',
    'Membaca 10 halaman',
    'Meditasi 5 menit',
    'Tidur sebelum 23.00',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Kebiasaan Baru',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.22),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              autofocus: true,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Contoh: Minum air putih 8 gelas',
                hintStyle: TextStyle(
                  fontFamily: 'Nunito',
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: Icon(
                    Icons.local_florist_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: (v) => widget.onSave(v),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Inspirasi cepat:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map(
                  (s) => GestureDetector(
                    onTap: () {
                      widget.controller.text = s;
                      widget.controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: s.length),
                      );
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.22),
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => widget.onSave(widget.controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: colorScheme.surface,
                shadowColor: Colors.transparent,
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Simpan Kebiasaan'),
            ),
          ),
        ],
      ),
    );
  }
}

// Skeleton Loading (Statis & Minimalis)
class _HabitSkeleton extends StatelessWidget {
  const _HabitSkeleton();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      children: [
        _buildBox(
          double.infinity,
          120,
          radius: 28,
          color: baseColor,
        ), // progress card
        const SizedBox(height: 28),
        _buildBox(160, 18, radius: 10, color: baseColor),
        const SizedBox(height: 16),
        _buildBox(
          double.infinity,
          110,
          radius: 22,
          color: baseColor,
        ), // habit card 1
        const SizedBox(height: 14),
        _buildBox(
          double.infinity,
          110,
          radius: 22,
          color: baseColor,
        ), // habit card 2
        const SizedBox(height: 14),
        _buildBox(
          double.infinity,
          110,
          radius: 22,
          color: baseColor,
        ), // habit card 3
      ],
    );
  }

  Widget _buildBox(
    double width,
    double height, {
    required double radius,
    required Color color,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
