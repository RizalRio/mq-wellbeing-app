// lib/features/mood_tracker/presentation/mood_history_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/dio_client.dart';
import 'mood_screen.dart';

// Provider
final moodHistoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      try {
        final dio = ref.watch(dioProvider);
        final response = await dio.get('/moods');
        final List<dynamic> responseData = response.data['data'] ?? [];
        return responseData.map((e) => e as Map<String, dynamic>).toList();
      } catch (e) {
        throw Exception('Gagal memuat riwayat: $e');
      }
    });

// Palet warna skor — earthy tones selaras AppTheme
const Map<int, Color> _kScoreColors = {
  5: Color(0xFF5E9E8E), // Teal toska hangat  → Sangat Baik
  4: Color(0xFF8CA595), // Sage green          → Baik
  3: Color(0xFFA89070), // Khaki hangat        → Netral
  2: Color(0xFFBF8070), // Terracotta muted    → Buruk
  1: Color(0xFFB86B6B), // Merah desaturated   → Sangat Buruk
};

const Map<int, Color> _kScoreBgColors = {
  5: Color(0xFFE5F2EF),
  4: Color(0xFFE8F0EA),
  3: Color(0xFFF3EDE3),
  2: Color(0xFFF3E8E3),
  1: Color(0xFFF2E5E5),
};

// MoodHistoryScreen
class MoodHistoryScreen extends ConsumerWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(moodHistoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        top: false,
        child: historyAsync.when(
          loading: () => const _SkeletonLoading(),
          error: (err, _) => _buildErrorState(context, ref),
          data: (historyData) {
            if (historyData.isEmpty) return _buildEmptyState(context);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + 72,
                  ),
                ),

                // Kartu Ringkasan & Visualisasi
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                          context,
                          icon: Icons.insights_rounded,
                          title: 'Ringkasan Emosi',
                          subtitle: '7 Hari Terakhir',
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCard(context, historyData),
                        const SizedBox(height: 32),
                        _buildSectionHeader(
                          context,
                          icon: Icons.history_rounded,
                          title: 'Catatan Sebelumnya',
                          subtitle: '${historyData.length} entri',
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Daftar Riwayat
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) =>
                          _buildHistoryCard(context, historyData[i]),
                      childCount: historyData.length,
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
  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
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
        'Riwayat Emosi',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Kartu Ringkasan: Donut Chart + Weekly Bar
  Widget _buildSummaryCard(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Hitung distribusi skor
    final Map<int, int> scoreCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var item in data) {
      final int s = item['score'] as int? ?? 0;
      if (scoreCounts.containsKey(s)) scoreCounts[s] = scoreCounts[s]! + 1;
    }

    // Cari mood dominan
    int dominantScore = 3;
    int maxCount = 0;
    scoreCounts.forEach((score, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantScore = score;
      }
    });

    // Hitung rata-rata skor
    double avgScore = 0;
    if (data.isNotEmpty) {
      final total = data.fold<int>(
        0,
        (sum, e) => sum + (e['score'] as int? ?? 0),
      );
      avgScore = total / data.length;
    }

    // Ambil data 7 hari terakhir untuk weekly bar
    final weeklyData = _buildWeeklyData(data);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Baris atas: Donut + Info Dominan
          Row(
            children: [
              // Donut chart
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: RingChartPainter(
                    counts: scoreCounts,
                    colors: _kScoreColors,
                    total: data.length,
                    theme: theme,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getMoodEmoji(dominantScore),
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${data.length}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            height: 1,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'entri',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Info kanan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mood dominan pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _kScoreBgColors[dominantScore],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getMoodEmoji(dominantScore),
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _getMoodLabel(dominantScore),
                            style: TextStyle(
                              color: _kScoreColors[dominantScore],
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Mood Dominan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$maxCount dari ${data.length} catatan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Progress bar dominan
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: data.isEmpty ? 0 : maxCount / data.length,
                        backgroundColor: colorScheme.onSurface.withOpacity(
                          0.06,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _kScoreColors[dominantScore]!,
                        ),
                        minHeight: 7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rata-rata
                    Row(
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          size: 13,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Rata-rata skor: ${avgScore.toStringAsFixed(1)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Divider
          const SizedBox(height: 20),
          Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.07)),
          const SizedBox(height: 20),

          // Weekly Bar (7 Hari)
          _buildWeeklyBar(context, weeklyData),

          // Divider
          const SizedBox(height: 20),
          Divider(height: 1, color: colorScheme.onSurface.withOpacity(0.07)),
          const SizedBox(height: 16),

          // Legend Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [5, 4, 3, 2, 1]
                .where((s) => scoreCounts[s]! > 0)
                .map(
                  (s) => _buildLegendChip(
                    context,
                    score: s,
                    count: scoreCounts[s]!,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // Weekly Bar — 7 hari terakhir dengan indikator emoji
  List<Map<String, dynamic>> _buildWeeklyData(
    List<Map<String, dynamic>> allData,
  ) {
    final now = DateTime.now();
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final result = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayLabel = days[day.weekday - 1];
      final isToday = i == 0;

      // Cari entry untuk hari ini
      final entries = allData.where((e) {
        try {
          final d = DateTime.parse(e['logged_at'].toString()).toLocal();
          return d.year == day.year && d.month == day.month && d.day == day.day;
        } catch (_) {
          return false;
        }
      }).toList();

      int? score;
      if (entries.isNotEmpty) {
        // Ambil rata-rata score untuk hari tersebut
        final avg =
            entries.fold<int>(0, (s, e) => s + (e['score'] as int? ?? 0)) /
            entries.length;
        score = avg.round().clamp(1, 5);
      }

      result.add({'label': dayLabel, 'score': score, 'isToday': isToday});
    }

    return result;
  }

  Widget _buildWeeklyBar(
    BuildContext context,
    List<Map<String, dynamic>> weeklyData,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '7 Hari Terakhir',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w700,
            fontSize: 11,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: weeklyData.map((day) {
            final int? score = day['score'] as int?;
            final bool isToday = day['isToday'] as bool;
            final String label = day['label'] as String;

            // Tinggi bar proporsional terhadap skor
            final double barHeight = score != null ? (score / 5.0) * 48 : 6;
            final Color barColor = score != null
                ? _kScoreColors[score]!
                : colorScheme.onSurface.withOpacity(0.08);

            return Expanded(
              child: Column(
                children: [
                  // Emoji (hanya jika ada entry)
                  SizedBox(
                    height: 22,
                    child: score != null
                        ? Text(
                            _getMoodEmoji(score),
                            style: const TextStyle(fontSize: 14),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 4),
                  // Bar
                  Container(
                    height: barHeight.clamp(6, 48),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Label hari
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isToday
                          ? colorScheme.primary
                          : colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                  // Titik penanda "hari ini"
                  if (isToday)
                    Container(
                      margin: const EdgeInsets.only(top: 3),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Legend Chip
  Widget _buildLegendChip(
    BuildContext context, {
    required int score,
    required int count,
  }) {
    final theme = Theme.of(context);
    final color = _kScoreColors[score]!;
    final bgColor = _kScoreBgColors[score]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getMoodEmoji(score), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            '${_getMoodLabel(score)} · $count',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // History Card
  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final int score = data['score'] as int? ?? 0;
    final String rawDate = data['logged_at']?.toString() ?? '';
    final String note = data['note']?.toString() ?? '';
    final List<String> tags =
        (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];

    // Format tanggal & waktu
    String formattedDate = 'Waktu tidak diketahui';
    String formattedTime = '';
    try {
      if (rawDate.isNotEmpty) {
        final parsed = DateTime.parse(rawDate).toLocal();
        final now = DateTime.now();
        final diff = now.difference(parsed);

        if (diff.inDays == 0 && now.day == parsed.day) {
          formattedDate = 'Hari ini';
        } else if (diff.inDays == 1 ||
            (diff.inDays == 0 && now.day != parsed.day)) {
          formattedDate = 'Kemarin';
        } else {
          const months = [
            '',
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
          formattedDate =
              '${parsed.day} ${months[parsed.month]} ${parsed.year}';
        }
        formattedTime =
            '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      formattedDate = 'Format salah';
    }

    final color = _kScoreColors[score] ?? Colors.grey;
    final bgColor = _kScoreBgColors[score] ?? colorScheme.surface;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => HapticFeedback.selectionClick(),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Emoji + Label + Tanggal
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Emoji dalam lingkaran berwarna
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getMoodEmoji(score),
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Label + waktu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getMoodLabel(score),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: color,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                formattedDate,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (formattedTime.isNotEmpty) ...[
                                Text(
                                  ' · ',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                                Text(
                                  formattedTime,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(
                                      0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Skor badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$score',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Tags
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: tags
                        .map(
                          (tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.18),
                              ),
                            ),
                            child: Text(
                              '# $tag',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],

                // Catatan / Note
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.tertiary.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 16,
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.55,
                              color: colorScheme.onSurface.withOpacity(0.75),
                              fontStyle: FontStyle.italic,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
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
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MoodScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.surface,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: const Text(
          'Catat Mood',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            fontFamily: 'Nunito',
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
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('🌱', style: TextStyle(fontSize: 52)),
            ),
            const SizedBox(height: 28),
            Text(
              'Belum Ada Catatan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Mulai catat emosimu hari ini\nuntuk melihat ringkasan di sini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.55,
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
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MoodScreen()),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Catat Mood Pertamamu'),
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
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Nunito',
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
  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
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
              'Gagal Memuat Data',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: colorScheme.onSurface,
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
              onPressed: () => ref.invalidate(moodHistoryProvider),
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
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Nunito',
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  static String _getMoodEmoji(int score) {
    switch (score) {
      case 5:
        return '😄';
      case 4:
        return '🙂';
      case 3:
        return '😐';
      case 2:
        return '😟';
      case 1:
        return '😢';
      default:
        return '❓';
    }
  }

  static String _getMoodLabel(int score) {
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
        return 'Tidak diketahui';
    }
  }
}

// Skeleton Loading (Statis & Minimalis)
class _SkeletonLoading extends StatelessWidget {
  const _SkeletonLoading();

  @override
  Widget build(BuildContext context) {
    // Menggunakan warna dasar dari tema dengan opasitas rendah sebagai warna skeleton
    final baseColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      children: [
        _buildSkeletonBox(width: 160, height: 18, color: baseColor),
        const SizedBox(height: 20),
        _buildSkeletonCard(height: 240, color: baseColor),
        const SizedBox(height: 32),
        _buildSkeletonBox(width: 180, height: 18, color: baseColor),
        const SizedBox(height: 16),
        _buildSkeletonCard(height: 110, color: baseColor),
        const SizedBox(height: 14),
        _buildSkeletonCard(height: 110, color: baseColor),
        const SizedBox(height: 14),
        _buildSkeletonCard(height: 110, color: baseColor),
      ],
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    required Color color,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSkeletonCard({required double height, required Color color}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// Ring Chart Painter (earthy palette)
class RingChartPainter extends CustomPainter {
  final Map<int, int> counts;
  final Map<int, Color> colors;
  final int total;
  final ThemeData theme;

  const RingChartPainter({
    required this.counts,
    required this.colors,
    required this.total,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    const double strokeWidth = 13.0;
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Track ring (background)
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      Paint()
        ..color = theme.colorScheme.onSurface.withOpacity(0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    double startAngle = -pi / 2;
    const double gap = 0.06;

    for (int score = 5; score >= 1; score--) {
      final count = counts[score] ?? 0;
      if (count == 0) continue;

      final double sweepAngle = (count / total) * 2 * pi;
      final color = colors[score]!;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle - gap,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant RingChartPainter old) =>
      old.counts != counts || old.total != total;
}
