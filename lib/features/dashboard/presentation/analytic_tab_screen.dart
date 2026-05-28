// lib/features/dashboard/presentation/analytic_tab_screen.dart
import 'package:flutter/material.dart';

class AnalyticTabScreen extends StatelessWidget {
  const AnalyticTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Jejak Wellbeing')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Rangkuman Mood Mingguan (Placeholder Grafik)
              Text('Tren Energimu', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.7,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Grafik Mood (Placeholder)',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Minggu ini energimu cukup stabil (Rata-rata 3.5)',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 2. Rangkuman Habit (Streak)
              Text('Konsistensi Kebiasaan', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Text(
                            '90%',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const Text('Rasio Minggu Ini'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '5 Hari',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const Text('Streak Terpanjang'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
