import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/dio_client.dart';

// Import layar input jurnal
import 'journal_screen.dart';

// 1. PROVIDER DINAMIS (Integrasi JSON Aktual)
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

class JournalHistoryScreen extends ConsumerWidget {
  const JournalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final historyAsync = ref.watch(journalHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Koleksi Jurnal'), centerTitle: true),
      body: SafeArea(
        child: historyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text('Gagal memuat jurnal: $err')),
          data: (journals) {
            if (journals.isEmpty) {
              return const Center(
                child: Text('Ruang refleksimu masih kosong.'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              itemCount: journals.length,
              itemBuilder: (context, index) {
                return _buildJournalCard(context, journals[index]);
              },
            );
          },
        ),
      ),
      // FAB Tetap Dipertahankan untuk menambah jurnal baru
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JournalScreen()),
          );
        },
        backgroundColor:
            colorScheme.tertiary, // Menggunakan warna Lavender untuk Jurnal
        foregroundColor: colorScheme.onSurface, // Teks warna gelap agar kontras
        elevation: 0,
        icon: const Icon(Icons.edit_note),
        label: const Text(
          'Tulis Refleksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget Bantuan: Kartu Jurnal
  // Widget Bantuan: Kartu Jurnal
  Widget _buildJournalCard(BuildContext context, Map<String, dynamic> data) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Ekstraksi data dengan aman (Null-Safety)
    final String content =
        data['content']?.toString() ?? 'Konten tidak tersedia';
    final String rawDate = data['created_at']?.toString() ?? '';
    final String aiStatus = data['ai_analysis_status']?.toString() ?? 'none';

    // Logika menampilkan ikon AI jika status bukan 'none'
    final bool hasInsights = aiStatus != 'none';

    // Konversi Waktu (Sama dengan logika MoodHistory)
    String formattedDate = 'Waktu tidak diketahui';
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
          final months = [
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
      }
    } catch (_) {
      formattedDate = 'Format salah';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),

              // Menampilkan Ikon Sparkle jika AI Status aktif (Fase 3)
              if (hasInsights)
                Icon(
                  Icons.auto_awesome,
                  color: colorScheme.secondary,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
