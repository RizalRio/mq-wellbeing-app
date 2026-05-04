import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/auth/presentation/login_screen.dart';
// Import file tema yang baru dibuat
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: WellbeingApp()));
}

class WellbeingApp extends StatelessWidget {
  const WellbeingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellbeing App',
      // Gunakan lightTheme dari AppTheme
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
