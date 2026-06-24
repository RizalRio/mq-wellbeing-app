// lib/features/journal/presentation/journal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'journal_controller.dart';
import 'journal_history_screen.dart';

// Palette (cermin app_theme.dart — Calm Minimalism)
class _C {
  static const warmBeige = Color(0xFFF9F6F0);
  static const sageGreen = Color(0xFF8CA595);
  static const softTeal = Color(0xFF7CA9A9);
  static const lavenderMuda = Color(0xFFE8E6F8);
  static const textDark = Color(0xFF2E4037);
  static const textLight = Color(0xFF7D8F85);

  // Turunan
  static const lavTint = Color(0xFFF0EFF9); // lavender dipudarkan
  static const accentDark = Color(0xFF4F7F7F); // softTeal lebih dalam
  static const cardBorder = Color(0x268CA595); // sageGreen 15%
}

// Screen
class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _contentController = TextEditingController();
  int _wordCount = 0;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final words = _contentController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;
    if (words != _wordCount) {
      setState(() => _wordCount = words);
    }
  }

  @override
  void dispose() {
    _contentController.removeListener(_onTextChanged);
    _contentController.dispose();
    super.dispose();
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
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final promptsState = ref.watch(journalPromptsProvider);
    final submitState = ref.watch(submitJournalControllerProvider);
    final isSubmitting = submitState.isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _C.warmBeige,
      appBar: AppBar(
        backgroundColor: _C.warmBeige,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFECE9E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: _C.textDark,
              ),
            ),
          ),
        ),
        title: Text(
          'Ruang Refleksi',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _C.textDark,
            fontSize: 17,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: _C.textLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getFormattedDate(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _C.textLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Judul halaman
                    Text(
                      'Apa yang ada\ndi pikiranmu?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: _C.textDark,
                        height: 1.15,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tidak ada yang salah di sini — tulis saja.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _C.textLight,
                        fontSize: 13.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Prompt card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _C.lavTint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.lavenderMuda, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: _C.lavenderMuda,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    '✨',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Panduan Refleksi',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _C.textDark,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          promptsState.when(
                            data: (prompts) => Text(
                              prompts.isNotEmpty
                                  ? prompts.first.text
                                  : 'Ceritakan harimu dengan bebas. Tidak ada yang benar atau salah di sini.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _C.textDark.withOpacity(0.75),
                                height: 1.6,
                                fontSize: 13.5,
                              ),
                            ),
                            loading: () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ShimmerLine(width: double.infinity),
                                const SizedBox(height: 6),
                                _ShimmerLine(width: 220),
                              ],
                            ),
                            error: (_, __) => Text(
                              'Gagal memuat panduan.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: _C.textLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Kanvas menulis
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _C.cardBorder, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Header kanvas
                          Padding(
                            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: _C.sageGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tulisanmu',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: _C.sageGreen,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // TextField
                          TextField(
                            controller: _contentController,
                            maxLines: 12,
                            enabled: !isSubmitting,
                            textAlignVertical: TextAlignVertical.top,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: _C.textDark,
                              fontSize: 15,
                              height: 1.65,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Mulai menulis di sini...',
                              hintStyle: TextStyle(
                                color: _C.textLight.withOpacity(0.45),
                                fontSize: 15,
                                fontFamily: 'Nunito',
                                height: 1.65,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.fromLTRB(
                                18,
                                10,
                                18,
                                14,
                              ),
                            ),
                          ),
                          // Word count
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 16, 12),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                _wordCount == 0
                                    ? 'Mulai menulis...'
                                    : '$_wordCount kata',
                                key: ValueKey(_wordCount == 0),
                                style: TextStyle(
                                  color: _wordCount > 0
                                      ? _C.sageGreen
                                      : _C.textLight.withOpacity(0.4),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Nunito',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Tombol simpan — sticky di bawah
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              decoration: BoxDecoration(
                color: _C.warmBeige,
                border: Border(
                  top: BorderSide(
                    color: _C.sageGreen.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final content = _contentController.text.trim();
                          if (content.isEmpty) return;

                          HapticFeedback.mediumImpact();
                          final success = await ref
                              .read(submitJournalControllerProvider.notifier)
                              .submit(content);

                          if (success && context.mounted) {
                            ref.invalidate(journalHistoryProvider);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jurnal tersimpan dengan aman.'),
                              ),
                            );
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.accentDark,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    disabledBackgroundColor: _C.accentDark.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(Icons.bookmark_rounded, size: 20),
                  label: Text(
                    isSubmitting ? 'Menyimpan...' : 'Simpan Jurnal',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Nunito',
                      letterSpacing: -0.2,
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
}

// Shimmer placeholder saat prompt loading
class _ShimmerLine extends StatefulWidget {
  const _ShimmerLine({required this.width});
  final double width;

  @override
  State<_ShimmerLine> createState() => _ShimmerLineState();
}

class _ShimmerLineState extends State<_ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 12,
        width: widget.width,
        decoration: BoxDecoration(
          color: _C.lavenderMuda.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
