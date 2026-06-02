import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habit_controller.dart';

class HabitScreen extends ConsumerStatefulWidget {
  const HabitScreen({super.key});

  @override
  ConsumerState<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends ConsumerState<HabitScreen> {
  void _showAddHabitDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Kebiasaan Baru',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: 'Contoh: Minum air putih',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                HapticFeedback.mediumImpact();

                // Proses penyimpanan data ke backend
                final success = await ref
                    .read(habitControllerProvider.notifier)
                    .addHabit(title);

                if (success && context.mounted) {
                  // PERBAIKAN 1: Paksa layar riwayat memuat ulang data dari API
                  ref.invalidate(habitControllerProvider);

                  // PERBAIKAN 2: Tutup Form/Dialog
                  Navigator.pop(context);

                  // Tampilkan notifikasi
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Satu langkah baik telah ditambahkan.'),
                    ),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitState = ref.watch(habitControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Jejak Kebiasaan')),
      body: habitState.when(
        data: (habits) {
          if (habits.isEmpty) {
            return Center(
              child: Text(
                'Belum ada kebiasaan.\nMari bangun rutinitas positifmu.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];

              // 1. Logika Cerdas: Cek apakah hari ini tercentang berdasarkan array Backend
              // DateTime.now().weekday mengembalikan 1 (Senin) hingga 7 (Minggu)
              final int todayIndex = DateTime.now().weekday - 1;
              final bool isCompleted = habit.weeklyStatus[todayIndex];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? theme.colorScheme.primary.withOpacity(0.05)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCompleted
                        ? theme.colorScheme.primary.withOpacity(0.3)
                        : theme.colorScheme.onSurface.withOpacity(0.08),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  title: Text(
                    habit.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: isCompleted
                          ? theme.colorScheme.onSurface.withOpacity(0.4)
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  trailing: Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: isCompleted, // 2. Gunakan status dari backend
                      activeColor: theme.colorScheme.primary,
                      onChanged: (bool? newValue) async {
                        if (newValue == null) return;

                        // 3. Kirim ke Golang menggunakan habit.id
                        final success = await ref
                            .read(habitControllerProvider.notifier)
                            .toggleHabitLog(habit.id, newValue);

                        if (success && context.mounted) {
                          // 4. Reload data master secara keseluruhan (KISS)
                          ref.invalidate(habitControllerProvider);
                          HapticFeedback.lightImpact();
                        } else if (!success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Gagal mencatat rutinitas. Periksa koneksi Anda.',
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(child: Text('Terjadi kesalahan: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddHabitDialog(context),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text('Kebiasaan'),
      ),
    );
  }
}
