import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// PASTIKAN IMPORT INI SESUAI DENGAN LOKASI CONTROLLER MOOD KAMU
import 'mood_controller.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  // State lokal untuk form
  int _selectedScale = 3; // Default di tengah (Netral)
  final Set<String> _selectedTags = {};
  final TextEditingController _noteController = TextEditingController();

  // Daftar tag statis (MVP)
  final List<String> _availableTags = [
    'Pekerjaan',
    'Keluarga',
    'Istirahat',
    'Kesehatan',
    'Sosial',
    'Hobi',
    'Keuangan',
    'Olahraga',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    HapticFeedback.lightImpact(); // Getaran saat memilih tag
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tautkan dengan Controller asli kamu.
    // Buka komentar di bawah ini jika file controller sudah tersedia:
    final submitState = ref.watch(moodControllerProvider);
    final isSubmitting = submitState.isLoading;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Catat Perasaanmu')),
      body: SafeArea(
        child: SingleChildScrollView(
          // Padding yang sangat luas untuk ruang bernapas
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bagian Skala Mood
              Text(
                'Bagaimana energimu hari ini?',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '1 (Sangat Lelah) hingga 5 (Sangat Bersemangat)',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final scale = index + 1;
                  final isSelected = _selectedScale == scale;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _selectedScale = scale);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 56,
                      height: 56, // Target sentuh besar
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.1),
                          width: 1.5,
                        ),
                        // Pendaran halus hanya saat elemen dipilih
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          scale.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 56), // Jarak luas pemisah antar sesi
              // 2. Bagian Tag Aktivitas Kustom (Flat Design)
              Text(
                'Apa yang memengaruhi perasaanmu?',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12.0,
                runSpacing: 16.0,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return GestureDetector(
                    onTap: () => _toggleTag(tag),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.secondary
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          24,
                        ), // Bentuk pil bulat
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.secondary
                              : colorScheme.onSurface.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 56),

              // 3. Bagian Catatan Jurnal Mini
              Text(
                'Ada yang ingin diceritakan lebih lanjut?',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 4,
                style: theme.textTheme.bodyLarge,
                decoration: const InputDecoration(
                  hintText: 'Tuliskan pemikiran singkatmu... (Opsional)',
                ),
                enabled: !isSubmitting,
              ),
              const SizedBox(height: 48),

              // 4. Tombol Simpan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          HapticFeedback.heavyImpact(); // Konfirmasi kuat tindakan utama

                          // Buka komentar ini untuk mengaktifkan pengiriman data ke Backend
                          // final success = await ref.read(moodControllerProvider.notifier)
                          //     .submitMood(_selectedScale, _selectedTags.toList(), _noteController.text);
                          final bool success = true;

                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Perasaanmu telah dicatat. Terima kasih sudah berbagi.',
                                ),
                              ),
                            );

                            setState(() {
                              _selectedScale = 3;
                              _selectedTags.clear();
                              _noteController.clear();
                            });
                            FocusScope.of(context).unfocus();
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
                          'Simpan Catatan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
