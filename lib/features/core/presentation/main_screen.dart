// lib/features/main/presentation/main_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Import Tab 1 yang baru (akan kita buat selanjutnya)
import '../../home/presentation/home_tab_screen.dart';
import '../../reflection/presentation/feeling_tab_screen.dart';
import '../../counseling/presentation/catalog_screen.dart';
import '../../auth/presentation/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman murni untuk konten Tab (SAMPADA)
  final List<Widget> _pages = [
    const HomeTabScreen(), // Tab 1: Ringkasan API yang baru kita buat
    const FeelingTabScreen(), // Tab 2: Catatan Mood/Habit
    const CatalogScreen(), // Tab 3: Konseling Profesional
    const Center(child: Text('Komunitas Ruang Aman (v0.1)')),
    const ProfileScreen(), // Tab 5: Profil
  ];

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: colorScheme.onSurface.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), // Beranda sejati
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.insights_outlined,
              ), // Representasi gabungan SPK & Mood
              activeIcon: Icon(Icons.insights),
              label: 'Insight',
            ),
            BottomNavigationBarItem(
              // Mengubah event menjadi support untuk menekankan aspek bantuan profesional
              icon: Icon(Icons.support_agent_outlined),
              activeIcon: Icon(Icons.support_agent),
              label: 'Konseling',
            ),
            BottomNavigationBarItem(
              // Forum diubah ke groups agar lebih merepresentasikan "Ruang Aman"
              icon: Icon(Icons.groups_outlined),
              activeIcon: Icon(Icons.groups),
              label: 'Komunitas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
