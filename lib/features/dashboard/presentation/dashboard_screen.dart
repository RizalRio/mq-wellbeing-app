import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dashboard_controller.dart';
import '../../mood_tracker/presentation/mood_screen.dart';
import '../../journal/presentation/journal_screen.dart';
import '../../habit/presentation/habit_screen.dart';
import '../../auth/presentation/profile_screen.dart';
import 'home_tab_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca indeks tab saat ini dari provider
    final currentIndex = ref.watch(dashboardNavProvider);

    // Daftar halaman sementara (Placeholder) untuk MVP
    final pages = [
      const HomeTabScreen(), // Menggantikan placeholder "Halaman Utama"
      const MoodScreen(), // Menggantikan placeholder "Halaman Utama"
      const JournalScreen(), // Menggantikan placeholder "Halaman Jurnal"
      const HabitScreen(), // Menggantikan placeholder "Halaman Habit"
      const ProfileScreen(), // Menggantikan placeholder "Halaman Profil"
    ];

    return Scaffold(
      // IndexedStack menyimpan state dari setiap tab
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            // Memperbarui state indeks saat tab ditekan
            ref.read(dashboardNavProvider.notifier).setIndex(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(
            context,
          ).colorScheme.onSurface.withOpacity(0.5),
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mood_outlined),
              label: 'Mood',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Jurnal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'Habit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
