import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Ditambahkan untuk HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'register_screen.dart';
import 'auth_controller.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 1. ref.listen untuk efek samping (navigasi & notifikasi)
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          HapticFeedback.vibrate(); // Getaran peringatan saat gagal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor:
                  Colors.redAccent.shade200, // Warna merah yang lebih pudar
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        data: (user) {
          if (user != null) {
            HapticFeedback.mediumImpact(); // Getaran sukses
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Senang melihatmu kembali!'),
                backgroundColor: colorScheme
                    .secondary, // Menggunakan warna Soft Teal dari tema
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      // Background otomatis mengikuti scaffoldBackgroundColor (Warm Beige)
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ), // Padding samping sedikit dilebarkan
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ikon Jangkar Visual yang Menenangkan
                Icon(
                  Icons.spa_rounded,
                  size: 64,
                  color: colorScheme.primary.withOpacity(0.8),
                ),
                const SizedBox(height: 24),

                // Microcopy yang empatik
                Text(
                  'Mari kembali terhubung',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Lanjutkan perjalanan wellbeing-mu hari ini.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 48,
                ), // Ruang napas (whitespace) yang luas
                // Form Input (Otomatis mewarisi gaya dari app_theme.dart)
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 40),

                // Tombol Login
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact(); // Getaran saat tombol ditekan
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          if (email.isNotEmpty && password.isNotEmpty) {
                            ref
                                .read(authControllerProvider.notifier)
                                .login(email, password);
                          } else {
                            HapticFeedback.heavyImpact(); // Peringatan form kosong
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Mohon lengkapi email dan kata sandimu ya.',
                                ),
                                backgroundColor: colorScheme.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Navigasi ke halaman Register dengan warna sekunder (Soft Teal)
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.secondary,
                    minimumSize: const Size(
                      double.infinity,
                      48,
                    ), // Target sentuh inklusif
                  ),
                  child: const Text(
                    'Belum punya akun? Yuk, daftar di sini',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
