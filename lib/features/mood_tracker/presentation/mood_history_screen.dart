import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/dio_client.dart';

import 'mood_screen.dart';

// 1. PROVIDER DINAMIS (Ganti isi fungsi ini dengan request HTTP ke Golang nantinya)
final moodHistoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      try {
        // TODO: Buka komentar di bawah ini jika integrasi API Dio sudah siap
        final dio = ref.watch(dioProvider);
        final response = await dio.get('/moods');
        final List<dynamic> responseData = response.data['data'] ?? [];
        return responseData.map((e) => e as Map<String, dynamic>).toList();
      } catch (e) {
        throw Exception('Gagal memuat riwayat: $e');
      }
    });

class MoodHistoryScreen extends ConsumerWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 2. MENDENGARKAN STATE DINAMIS DARI RIVERPOD
    final historyAsync = ref.watch(moodHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Emosi'), centerTitle: true),
      body: SafeArea(
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Gagal memuat data: $err')),
          data: (historyData) {
            if (historyData.isEmpty) {
              return const Center(
                child: Text('Belum ada catatan emosi minggu ini.'),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Distribusi Emosi (7 Hari Terakhir)',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        // Memanggil Pie Ring Chart
                        _buildRingChartSection(context, historyData),
                        const SizedBox(height: 48),
                        Text(
                          'Catatan Sebelumnya',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildHistoryCard(context, historyData[index]),
                      childCount: historyData.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ), // Ruang aman FAB
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MoodScreen()),
          );
        },
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text('Catat Mood'),
      ),
    );
  }

  // Widget Bantuan: Area Ring Chart & Keterangan Legend
  Widget _buildRingChartSection(
    BuildContext context,
    List<Map<String, dynamic>> data,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Agregasi jumlah data per skor emosi (1-5)
    final Map<int, int> scoreCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var item in data) {
      final int score = item['score'];
      if (scoreCounts.containsKey(score)) {
        scoreCounts[score] = scoreCounts[score]! + 1;
      }
    }

    // Definisi warna berdasarkan tingkat emosi (Calm Minimalism)
    final Map<int, Color> scoreColors = {
      5: colorScheme.secondary, // Sangat Baik (Soft Teal)
      4: colorScheme.primary, // Baik (Sage Green)
      3: colorScheme.primary.withOpacity(0.4), // Netral
      2: Colors.orange.shade300, // Buruk
      1: Colors.redAccent.shade200, // Sangat Buruk
    };

    return Row(
      children: [
        // Kanvas Donut Chart
        SizedBox(
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: RingChartPainter(
              counts: scoreCounts,
              colors: scoreColors,
              total: data.length,
            ),
            child: Center(
              child: Text(
                '${data.length}\nData',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        // Legend Keterangan Warna
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend(
                context,
                color: scoreColors[5]!,
                label: 'Sangat Baik',
                count: scoreCounts[5]!,
              ),
              _buildLegend(
                context,
                color: scoreColors[4]!,
                label: 'Baik',
                count: scoreCounts[4]!,
              ),
              _buildLegend(
                context,
                color: scoreColors[3]!,
                label: 'Netral',
                count: scoreCounts[3]!,
              ),
              _buildLegend(
                context,
                color: scoreColors[2]!,
                label: 'Buruk',
                count: scoreCounts[2]!,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(
    BuildContext context, {
    required Color color,
    required String label,
    required int count,
  }) {
    if (count == 0)
      return const SizedBox.shrink(); // Sembunyikan jika tidak ada data
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget Bantuan: Kartu Riwayat Individual (Sama seperti sebelumnya)
  Widget _buildHistoryCard(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 1. Proteksi tipe data dasar
    final int score = data['score'] as int? ?? 0;
    final String rawDate = data['logged_at']?.toString() ?? '';
    final String note = data['note']?.toString() ?? '';
    final List<String> tags =
        (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [];

    // 2. Logika Parsing Tanggal (Timestamp ke Human-Readable)
    String formattedDate = 'Waktu tidak diketahui';
    try {
      if (rawDate.isNotEmpty) {
        final DateTime parsedDate = DateTime.parse(rawDate).toLocal();
        final DateTime now = DateTime.now();
        final Duration diff = now.difference(parsedDate);

        if (diff.inDays == 0 && now.day == parsedDate.day) {
          formattedDate = 'Hari ini';
        } else if (diff.inDays == 1 ||
            (diff.inDays == 0 && now.day != parsedDate.day)) {
          formattedDate = 'Kemarin';
        } else {
          final List<String> months = [
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
              '${parsedDate.day} ${months[parsedDate.month]} ${parsedDate.year}';
        }
      }
    } catch (e) {
      formattedDate = 'Format tanggal salah';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate, // Menggunakan tanggal hasil konversi
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Skor $score',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tag,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(note, style: theme.textTheme.bodyLarge?.copyWith(height: 1.4)),
          ],
        ],
      ),
    );
  }
}

// 3. LOGIKA CUSTOM PAINTER UNTUK PIE RING CHART
class RingChartPainter extends CustomPainter {
  final Map<int, int> counts;
  final Map<int, Color> colors;
  final int total;

  RingChartPainter({
    required this.counts,
    required this.colors,
    required this.total,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final double strokeWidth = 16.0;
    final Rect rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Latar belakang cincin abu-abu halus
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    double startAngle = -pi / 2; // Mulai dari posisi jam 12 atas

    // Menggambar busur untuk setiap skor
    for (int score = 5; score >= 1; score--) {
      final count = counts[score] ?? 0;
      if (count > 0) {
        final double sweepAngle = (count / total) * 2 * pi;
        final paint = Paint()
          ..color = colors[score]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round; // Ujung busur yang membulat (Soft UI)

        // Sedikit celah antar busur (opsional, dikurangi sedikit dari sweepAngle)
        canvas.drawArc(rect, startAngle, sweepAngle - 0.05, false, paint);
        startAngle += sweepAngle;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
