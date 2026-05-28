// lib/features/dashboard/presentation/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk HapticFeedback

// Import fitur-fitur yang sudah kita buat
import 'home_tab_screen.dart'; // Tab 1 (Sapaan & Insight)
// Import AnalyticTabScreen (Baru), HabitScreen, dll.
import '../../reflection/presentation/feeling_tab_screen.dart'; // Tab 2 (Rangkuman - Akan Dibuat)
import '../../auth/presentation/profile_screen.dart'; // Tab 5

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Daftar halaman berdasarkan tab navigasi SAMPADA
  final List<Widget> _pages = [
    const HomeTabScreen(), // Tab 1 (Insight & Sapaan)
    const FeelingTabScreen(), // Tab 2 (Rangkuman - Akan Dibuat)
    const Center(child: Text('Halaman Konsul')),
    // const CommunityScreen(),   // Tab 4 (Komunitas - v2+)
    const Center(
      child: Text('Komunitas Ruang Aman (v0.1)'),
    ), // Placeholder Tab 4
    const ProfileScreen(), // Tab 5
  ];

  void _onItemTapped(int index) {
    HapticFeedback.lightImpact(); // Getaran lembut saat pindah tab (Adaptive UI)
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
          type: BottomNavigationBarType.fixed, // Penting untuk >3 tab
          selectedItemColor: colorScheme.primary, // Sage Green aktif
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.5),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.spa_outlined),
              activeIcon: Icon(Icons.spa),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Feeling',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_available_outlined),
              activeIcon: Icon(Icons.event_available),
              label: 'Konsultasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_outlined),
              activeIcon: Icon(Icons.forum),
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
