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
    final colorScheme = Theme.of(context).colorScheme;
    final historyAsync = ref.watch(habitControllerProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: historyAsync.when(
        loading: () => const _HabitSkeleton(),
        error: (err, stack) => _ErrorState(message: err.toString()),
        data: (habits) => CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            _HabitSliverAppBar(habits: habits),
            if (habits.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _HabitHistoryCard(habit: habits[index]),
                    ),
                    childCount: habits.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _AddHabitFAB(colorScheme: colorScheme),
    );
  }
}

// Sliver App Bar

class _HabitSliverAppBar extends StatelessWidget {
  final List<Habit> habits;

  const _HabitSliverAppBar({required this.habits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasHabits = habits.isNotEmpty;

    return SliverAppBar(
      expandedHeight: hasHabits ? 190 : 120,
      pinned: true,
      stretch: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Jejak Kebiasaan',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: colorScheme.surface,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: colorScheme.surface,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _AppBarBackground(habits: habits),
      ),
    );
  }
}

class _AppBarBackground extends StatelessWidget {
  final List<Habit> habits;

  const _AppBarBackground({required this.habits});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate aggregate stats
    final todayIndex = DateTime.now().weekday - 1; // 0=Mon, 6=Sun
    final completedToday = habits
        .where(
          (h) =>
              h.weeklyStatus.length > todayIndex && h.weeklyStatus[todayIndex],
        )
        .length;
    final bestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => h.streakCount).reduce((a, b) => a > b ? a : b);
    final completionRate = habits.isEmpty
        ? 0
        : (completedToday / habits.length * 100).round();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
      ),
      child: habits.isEmpty
          ? const SizedBox.shrink()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 56, left: 20, right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        _StatChip(
                          value: '${habits.length}',
                          label: 'Kebiasaan',
                          icon: Icons.track_changes_rounded,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          value: '$completionRate%',
                          label: 'Selesai Hari Ini',
                          icon: Icons.today_rounded,
                        ),
                        const SizedBox(width: 10),
                        _StatChip(
                          value: '$bestStreak Hari',
                          label: 'Streak Terbaik',
                          icon: Icons.local_fire_department_rounded,
                          accent: const Color(0xFFD99A71),
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

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? accent;

  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final isAccented = accent != null;
    final surface = Theme.of(context).colorScheme.surface;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isAccented
              ? accent!.withOpacity(0.22)
              : surface.withOpacity(0.14),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isAccented
                ? accent!.withOpacity(0.45)
                : surface.withOpacity(0.18),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: isAccented ? surface : surface.withOpacity(0.75),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: surface,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: surface.withOpacity(0.7),
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Habit History Card

class _HabitHistoryCard extends StatelessWidget {
  final Habit habit;

  const _HabitHistoryCard({required this.habit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final completedDays = habit.weeklyStatus.where((s) => s).length;
    final completionRate = habit.weeklyStatus.isEmpty
        ? 0.0
        : completedDays / habit.weeklyStatus.length;
    final completionPercent = (completionRate * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: ring + title + streak
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProgressRing(value: completionRate, colorScheme: colorScheme),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$completedDays dari 7 hari tercapai',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.55),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (habit.streakCount > 0) ...[
                  const SizedBox(width: 8),
                  _StreakBadge(count: habit.streakCount),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _ProgressBar(
              colorScheme: colorScheme,
              value: completionRate,
              percent: completionPercent,
            ),
          ),

          const SizedBox(height: 16),

          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.onSurface.withOpacity(0.06),
          ),

          // Weekly timeline
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: _WeeklyTimeline(
              habit: habit,
              colorScheme: colorScheme,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

// Progress Ring

class _ProgressRing extends StatelessWidget {
  final double value;
  final ColorScheme colorScheme;

  const _ProgressRing({required this.value, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: 4.5,
            strokeCap: StrokeCap.round,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              value >= 1.0 ? colorScheme.secondary : colorScheme.primary,
            ),
          ),
          Center(
            child: value >= 1.0
                ? Icon(
                    Icons.done_all_rounded,
                    size: 20,
                    color: colorScheme.secondary,
                  )
                : Icon(
                    Icons.bolt_rounded,
                    size: 22,
                    color: value > 0
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.25),
                  ),
          ),
        ],
      ),
    );
  }
}

// Streak Badge

class _StreakBadge extends StatelessWidget {
  final int count;

  const _StreakBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFD99A71).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD99A71).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 14,
            color: Color(0xFFC77D5A),
          ),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFFC77D5A),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// Progress Bar

class _ProgressBar extends StatelessWidget {
  final ColorScheme colorScheme;
  final double value;
  final int percent;

  const _ProgressBar({
    required this.colorScheme,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = value >= 1.0 ? colorScheme.secondary : colorScheme.primary;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pencapaian Minggu Ini',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withOpacity(0.5),
                letterSpacing: 0.4,
              ),
            ),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: value >= 0.5
                    ? barColor
                    : colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 7,
            backgroundColor: colorScheme.primary.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

// Weekly Timeline

class _WeeklyTimeline extends StatelessWidget {
  final Habit habit;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _WeeklyTimeline({
    required this.habit,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final int todayIndex = DateTime.now().weekday - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final bool isDone = habit.weeklyStatus.length > index
            ? habit.weeklyStatus[index]
            : false;
        final bool isToday = index == todayIndex;
        final bool isFuture = index > todayIndex;

        return _DayDot(
          label: days[index],
          isDone: isDone,
          isToday: isToday,
          isFuture: isFuture,
          colorScheme: colorScheme,
          theme: theme,
        );
      }),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isToday;
  final bool isFuture;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _DayDot({
    required this.label,
    required this.isDone,
    required this.isToday,
    required this.isFuture,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    Color dotFill;
    Color dotBorder;
    Color labelColor;
    Widget dotChild;
    List<BoxShadow> shadows = [];

    if (isDone) {
      dotFill = colorScheme.primary;
      dotBorder = colorScheme.primary;
      labelColor = colorScheme.primary;
      dotChild = const Icon(Icons.check_rounded, size: 15, color: Colors.white);
      shadows = [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.35),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ];
    } else if (isFuture) {
      dotFill = Colors.transparent;
      dotBorder = colorScheme.onSurface.withOpacity(0.15);
      labelColor = colorScheme.onSurface.withOpacity(0.3);
      dotChild = const SizedBox.shrink();
    } else {
      // Past, not done
      dotFill = colorScheme.error.withOpacity(0.1);
      dotBorder = colorScheme.error.withOpacity(0.2);
      labelColor = colorScheme.onSurface.withOpacity(0.4);
      dotChild = Icon(
        Icons.close_rounded,
        size: 13,
        color: colorScheme.error.withOpacity(0.7),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isToday ? colorScheme.primary : labelColor,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: dotFill,
            shape: BoxShape.circle,
            border: Border.all(color: dotBorder, width: 1.5),
            boxShadow: shadows,
          ),
          child: Center(child: dotChild),
        ),
        const SizedBox(height: 5),
        // Today indicator dot
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isToday ? 1.0 : 0.0,
          child: Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

// Empty State

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.spa_outlined,
                size: 46,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Mulai Perjalananmu',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Belum ada kebiasaan yang tercatat.\nTambahkan target pertamamu dan bangun\nkonsistensi hari demi hari!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.55),
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Error State

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

// FAB

class _AddHabitFAB extends StatelessWidget {
  final ColorScheme colorScheme;

  const _AddHabitFAB({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
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
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HabitScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Target Baru',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
    );
  }
}

// Skeleton Loading (Minimalis)

class _HabitSkeleton extends StatelessWidget {
  const _HabitSkeleton();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);

    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 210,
          backgroundColor: baseColor,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(color: baseColor),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
              childCount: 3, // Menampilkan 3 kartu kosong sebagai placeholder
            ),
          ),
        ),
      ],
    );
  }
}
