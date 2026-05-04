import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mood_controller.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});

  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int _selectedMood = 3; // Default: Netral (3)
  final List<String> _selectedTags = [];
  final _noteController = TextEditingController();

  final List<String> _availableTags = [
    'Kerja',
    'Keluarga',
    'Istirahat',
    'Olahraga',
    'Belajar',
  ];

  final Map<int, IconData> _moodIcons = {
    1: Icons.sentiment_very_dissatisfied,
    2: Icons.sentiment_dissatisfied,
    3: Icons.sentiment_neutral,
    4: Icons.sentiment_satisfied,
    5: Icons.sentiment_very_satisfied,
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
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
    ref.listen(moodControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.red,
            ),
          );
        },
        data: (_) {
          if (previous?.isLoading == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mood berhasil dicatat!'),
                backgroundColor: Colors.green,
              ),
            );
            // Kosongkan form setelah sukses
            setState(() {
              _selectedMood = 3;
              _selectedTags.clear();
              _noteController.clear();
            });
          }
        },
      );
    });

    final moodState = ref.watch(moodControllerProvider);
    final isLoading = moodState.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Bagaimana Perasaanmu?')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pilih Skala Emosi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _moodIcons.entries.map((entry) {
                final isSelected = _selectedMood == entry.key;
                return IconButton(
                  iconSize: 48,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade400,
                  icon: Icon(entry.value),
                  onPressed: () {
                    setState(() {
                      _selectedMood = entry.key;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text(
              'Aktivitas Dominan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return ChoiceChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (_) => _toggleTag(tag),
                  selectedColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.3),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            Text(
              'Catatan Tambahan (Opsional)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Ada hal spesifik yang memengaruhi perasaanmu hari ini?',
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      ref
                          .read(moodControllerProvider.notifier)
                          .submitDailyMood(
                            _selectedMood,
                            _selectedTags,
                            _noteController.text,
                          );
                    },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Simpan Jurnal Emosi'),
            ),
          ],
        ),
      ),
    );
  }
}
