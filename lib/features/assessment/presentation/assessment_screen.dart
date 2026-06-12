import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'assessment_controller.dart'; // WAJIB: Pastikan import ini sesuai

// 1. UBAH menjadi ConsumerStatefulWidget
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

  final Map<int, int> _answers = {};

  // 2. MODIFIKASI logika nextPage untuk memanggil API
  Future<void> _nextPage() async {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Panggil Controller Riverpod
      final success = await ref
          .read(assessmentControllerProvider.notifier)
          .submitAnswers(_answers);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hasil berhasil dikirim dan dihitung!')),
        );
        // (Opsional) Kembali ke Dashboard setelah selesai
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengirim hasil tes.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _questions.length - 1;
    final isCurrentAnswered = _answers.containsKey(_currentPage);

    // 3. PANTAU status state (untuk menampilkan animasi loading)
    final assessmentState = ref.watch(assessmentControllerProvider);
    final isLoading = assessmentState is AsyncLoading;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading
              ? null
              : () {
                  // Nonaktifkan tombol back saat loading
                  if (_currentPage > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
        ),
        title: Text(
          'Indeks Titian Kesehatan',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentPage + 1) / _questions.length,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Dimensi ${_questions[_currentPage]['dimensi']} (${_currentPage + 1}/${_questions.length})',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final score = index + 1;
                    final isSelected = _answers[_currentPage] == score;
                    return GestureDetector(
                      onTap: isLoading
                          ? null
                          : () =>
                                setState(() => _answers[_currentPage] = score),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.15),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          score.toString(),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sangat Jarang',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      'Sangat Sering',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                // Nonaktifkan tombol jika sedang loading ATAU belum menjawab
                onPressed: (isCurrentAnswered && !isLoading) ? _nextPage : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading && isLastPage
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isLastPage ? 'Kirim Hasil' : 'Selanjutnya',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
