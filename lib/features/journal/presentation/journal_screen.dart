import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'journal_controller.dart';
import 'journal_history_screen.dart'; // Import layar riwayat jurnal

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _contentController = TextEditingController();

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promptsState = ref.watch(journalPromptsProvider);
    final submitState = ref.watch(submitJournalControllerProvider);
    final isSubmitting = submitState.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Ruang Refleksi')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kotak Panduan (Warna Lavender Pudar)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: theme.colorScheme.onSurface,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Panduan Refleksi',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    promptsState.when(
                      data: (prompts) => Text(
                        prompts.isNotEmpty
                            ? prompts.first.text
                            : 'Ceritakan harimu dengan bebas...',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (err, st) => const Text('Gagal memuat panduan'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Kanvas Menulis Jurnal
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: theme.textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'Tuliskan perasaanmu di sini...',
                  ),
                  enabled: !isSubmitting,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Simpan
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final content = _contentController.text.trim();
                        if (content.isEmpty) return;

                        HapticFeedback.mediumImpact(); // Getaran saat menyimpan
                        final success = await ref
                            .read(submitJournalControllerProvider.notifier)
                            .submit(content);

                        if (success && context.mounted) {
                          // 1. Hancurkan cache data lama agar Riverpod menarik data baru
                          ref.invalidate(journalHistoryProvider);

                          // 2. Tampilkan notifikasi sukses
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jurnal tersimpan dengan aman.'),
                            ),
                          );

                          // 3. Tutup layar formulir
                          Navigator.pop(context);
                        } else if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Gagal menyimpan jurnal. Coba lagi nanti.',
                              ),
                            ),
                          );
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Jurnal',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
