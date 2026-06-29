// lib/features/assessment/presentation/assessment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'assessment_controller.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _questions = [
    {
      'dimensi': 'Kesehatan Fisik',
      'pertanyaan':
          'Dalam seminggu terakhir, seberapa sering Anda bangun tidur dengan tubuh terasa bugar dan berenergi?',
    },
    {
      'dimensi': 'Kesehatan Psikologis',
      'pertanyaan':
          'Dalam seminggu terakhir, seberapa mampu Anda mengelola stres atau pikiran yang membebani?',
    },
    {
      'dimensi': 'Kesehatan Sosial',
      'pertanyaan':
          'Dalam seminggu terakhir, seberapa sering Anda merasa terhubung dan didukung oleh lingkungan sekitar?',
    },
    {
      'dimensi': 'Kesehatan Keluarga',
      'pertanyaan':
          'Dalam seminggu terakhir, seberapa rukun dan harmonis interaksi Anda dengan anggota keluarga?',
    },
    {
      'dimensi': 'Kesehatan Spiritual',
      'pertanyaan':
          'Dalam seminggu terakhir, seberapa sering Anda merasakan kedamaian batin dalam aktivitas sehari-hari?',
    },
  ];

  // Palet warna untuk opsi 1-5
  final List<Color> _scoreColors = [
    const Color(0xFFB86B6B), // 1 - Merah pudar
    const Color(0xFFBF8070), // 2 - Terracotta
    const Color(0xFFA89070), // 3 - Khaki
    const Color(0xFF8CA595), // 4 - Sage green
    const Color(0xFF5E9E8E), // 5 - Teal toska
  ];

  final Map<int, int> _answers = {};

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage < _questions.length - 1) {
      HapticFeedback.lightImpact();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      HapticFeedback.heavyImpact();
      final success = await ref
          .read(assessmentControllerProvider.notifier)
          .submitAnswers(_answers);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Hasil berhasil dikirim dan dihitung!',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Gagal mengirim hasil tes.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLastPage = _currentPage == _questions.length - 1;
    final isCurrentAnswered = _answers.containsKey(_currentPage);

    final assessmentState = ref.watch(assessmentControllerProvider);
    final isLoading = assessmentState.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
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
            onPressed: isLoading
                ? null
                : () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
          ),
        ),
        title: Text(
          'Indeks Kesejahteraan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: (_currentPage + 1) / _questions.length,
                  ),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: colorScheme.primary.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary.withOpacity(0.85),
                      ),
                      minHeight: 6,
                    );
                  },
                ),
              ),
            ),

            // ── Label Dimensi ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.15),
                ),
              ),
              child: Text(
                'Dimensi ${_questions[_currentPage]['dimensi']} (${_currentPage + 1} dari ${_questions.length})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Teks Pertanyaan ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _questions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Center(
                      child: Text(
                        _questions[index]['pertanyaan']!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface.withOpacity(0.85),
                          height: 1.5,
                          letterSpacing: -0.3,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Pilihan Jawaban ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(5, (index) {
                  final score = index + 1;
                  final isSelected = _answers[_currentPage] == score;
                  final activeColor = _scoreColors[index];

                  // Tentukan teks label
                  String label = '';
                  if (score == 1) label = 'Sangat\nJarang';
                  if (score == 3) label = 'Kadang';
                  if (score == 5) label = 'Sangat\nSering';

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                setState(() => _answers[_currentPage] = score);
                              },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeColor
                                : colorScheme.surface,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? activeColor
                                  : activeColor.withOpacity(0.4),
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: activeColor.withOpacity(0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            score.toString(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: isSelected
                                  ? colorScheme.surface
                                  : activeColor,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Teks Label
                      SizedBox(
                        height: 32,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),

            // Tombol Aksi
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: (isCurrentAnswered && !isLoading)
                      ? LinearGradient(
                          colors: [colorScheme.primary, colorScheme.secondary],
                        )
                      : null,
                  color: (isCurrentAnswered && !isLoading)
                      ? null
                      : colorScheme.onSurface.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: (isCurrentAnswered && !isLoading)
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: ElevatedButton(
                  onPressed: (isCurrentAnswered && !isLoading)
                      ? _nextPage
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: colorScheme.surface,
                    disabledForegroundColor: colorScheme.onSurface.withOpacity(
                      0.4,
                    ),
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: isLoading && isLastPage
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.surface,
                          ),
                        )
                      : Text(
                          isLastPage ? 'Kirim Hasil' : 'Selanjutnya',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
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
