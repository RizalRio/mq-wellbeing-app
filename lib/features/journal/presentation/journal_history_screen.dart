import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';
import 'journal_screen.dart';

// Provider
final journalHistoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      try {
        final dio = ref.watch(dioProvider);
        final response = await dio.get('/journals');
        final List<dynamic> responseData = response.data['data'] ?? [];
        return responseData.map((e) => e as Map<String, dynamic>).toList();
      } catch (e) {
        throw Exception('Gagal memuat jurnal: $e');
      }
    });

// JournalHistoryScreen
class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(journalHistoryProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: historyAsync.when(
          loading: () => const _JournalSkeleton(),
          error: (err, _) => _buildErrorState(context, ref),
          data: (journals) {
            if (journals.isEmpty) return _buildEmptyState(context);

            // Hitung statistik ringkasan
            final int totalEntries = journals.length;
            final int thisWeek = _countThisWeek(journals);
            final int aiInsights = journals
                .where((j) => j['ai_analysis_status'] == 'completed')
                .length;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).padding.top + 72,
                  ),
                ),

                // Kartu Statistik
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildStatsCard(
                      context,
                      total: totalEntries,
                      thisWeek: thisWeek,
                      insights: aiInsights,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // Header daftar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildSectionHeader(context, totalEntries),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Daftar Jurnal
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildJournalCard(ctx, journals[i]),
                      childCount: journals.length,
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
        'Koleksi Jurnal',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  // Kartu Statistik Ringkasan
  Widget _buildStatsCard(
    BuildContext context, {
    required int total,
    required int thisWeek,
    required int insights,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
            color: colorScheme.primary.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Baris atas: ikon + judul
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
                        color: colorScheme.onSurface.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'REFLEKSI SAYA',
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
                      'Jejak Pikiranmu',
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
              // Dekorasi buku/quote besar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.surface.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('📖', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Divider(color: colorScheme.surface.withOpacity(0.18), thickness: 1),
          const SizedBox(height: 16),

          // Baris statistik
          Row(
            children: [
              _buildStatItem(context, '$total', 'Total\nEntri'),
              _buildStatDivider(context),
              _buildStatItem(context, '$thisWeek', 'Minggu\nIni'),
              _buildStatDivider(context),
              _buildStatItem(context, '$insights', 'AI\nInsight'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: colorScheme.surface,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.surface.withOpacity(0.8),
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider(BuildContext context) => Container(
    width: 1,
    height: 40,
    color: Theme.of(context).colorScheme.surface.withOpacity(0.18),
  );

  // Section Header
  Widget _buildSectionHeader(BuildContext context, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: colorScheme.tertiary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.history_rounded,
            size: 18,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Semua Catatan',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '$count entri tersimpan',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Journal Card
  Widget _buildJournalCard(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String content = data['content']?.toString() ?? '';
    final String rawDate = data['created_at']?.toString() ?? '';
    final String aiStatus = data['ai_analysis_status']?.toString() ?? 'none';

    // Format tanggal & waktu
    String datePart = 'Waktu tidak diketahui';
    String timePart = '';
    try {
      if (rawDate.isNotEmpty) {
        final parsed = DateTime.parse(rawDate).toLocal();
        final now = DateTime.now();
        final diff = now.difference(parsed);
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

        if (diff.inDays == 0 && now.day == parsed.day) {
          datePart = 'Hari ini';
        } else if (diff.inDays == 1 ||
            (diff.inDays == 0 && now.day != parsed.day)) {
          datePart = 'Kemarin';
        } else {
          datePart = '${parsed.day} ${months[parsed.month]} ${parsed.year}';
        }
        timePart =
            '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      }
    } catch (_) {
      datePart = 'Format salah';
    }

    // Hitung kata & estimasi baca
    final int wordCount = content.trim().isEmpty
        ? 0
        : content.trim().split(RegExp(r'\s+')).length;
    final String readTime = wordCount < 200
        ? '<1 mnt'
        : '${(wordCount / 200).ceil()} mnt';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withOpacity(0.06),
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
          onTap: () {
            HapticFeedback.lightImpact();
            _showReadDialog(context, datePart, timePart, content);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header kartu
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(21),
                    topRight: Radius.circular(21),
                  ),
                ),
                child: Row(
                  children: [
                    // Ikon tanggal
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tanggal + waktu
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            datePart,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                          if (timePart.isNotEmpty)
                            Text(
                              timePart,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Badge AI Status
                    if (aiStatus != 'none') _buildAIBadge(context, aiStatus),
                  ],
                ),
              ),

              // Konten Jurnal
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: content.isNotEmpty
                    ? Text(
                        content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.85),
                          height: 1.6,
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        'Tidak ada konten.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
              ),

              // Footer: Meta info + baca selengkapnya
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 14, 14),
                child: Row(
                  children: [
                    // Chip waktu baca
                    _buildMetaChip(
                      context,
                      Icons.timer_outlined,
                      '$readTime baca',
                    ),
                    const SizedBox(width: 8),
                    // Chip jumlah kata
                    _buildMetaChip(
                      context,
                      Icons.notes_rounded,
                      '$wordCount kata',
                    ),
                    const Spacer(),
                    // Hint baca selengkapnya
                    Text(
                      'Baca',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: colorScheme.primary,
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

  // Jendela Mengambang (Pop-up Dialog Mandiri)
  void _showReadDialog(
    BuildContext context,
    String date,
    String time,
    String content,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colorScheme.surface,
        // Tambahkan antiAlias agar warna header ikut melengkung di sudut atas
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        // Hapus Padding global di sini, pindahkan ke masing-masing elemen
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAGIAN HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
              color: colorScheme.secondary.withOpacity(0.3),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surface.withOpacity(0.5),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // BAGIAN ISI KONTEN
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.85),
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Meta chip kecil (waktu baca / jumlah kata)
  Widget _buildMetaChip(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // AI Status Badge
  Widget _buildAIBadge(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    final Map<String, dynamic> cfg =
        {
          'pending': {
            "icon": Icons.hourglass_top,
            "color": colorScheme.onSurface.withOpacity(0.5),
          },
          'processing': {
            "icon": Icons.auto_awesome_motion,
            "color": colorScheme.secondary,
          },
          'completed': {
            "icon": Icons.auto_awesome,
            "color": colorScheme.tertiary,
          },
        }[status] ??
        {"icon": Icons.help_outline, "color": Colors.grey};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (cfg['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Icon(
        cfg['icon'] as IconData,
        size: 12,
        color: cfg['color'] as Color,
      ),
    );
  }

  // FAB
  Widget _buildFAB(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
            MaterialPageRoute(builder: (_) => const JournalScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: const Text(
          'Tulis Refleksi',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📓', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 20),
          Text(
            'Ruang Refleksi Kosong',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Mulailah menulis — refleksi kecil setiap\nhari membangun pemahaman diri yang besar.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF7D8F85),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalScreen()),
            ),
            child: const Text('Tulis Jurnal Pertama'),
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(child: Text('Gagal Memuat Jurnal'));
  }

  int _countThisWeek(List<Map<String, dynamic>> journals) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return journals.where((j) {
      try {
        return DateTime.parse(j['created_at'].toString()).isAfter(weekAgo);
      } catch (_) {
        return false;
      }
    }).length;
  }
}

// Skeleton Loading (Statis & Minimalis)
class _JournalSkeleton extends StatelessWidget {
  const _JournalSkeleton();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
      children: [
        _buildBox(double.infinity, 130, radius: 28, color: baseColor),
        const SizedBox(height: 32),
        _buildBox(160, 18, radius: 10, color: baseColor),
        const SizedBox(height: 16),
        _buildBox(double.infinity, 148, radius: 22, color: baseColor),
        const SizedBox(height: 14),
        _buildBox(double.infinity, 148, radius: 22, color: baseColor),
        const SizedBox(height: 14),
        _buildBox(double.infinity, 100, radius: 22, color: baseColor),
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
