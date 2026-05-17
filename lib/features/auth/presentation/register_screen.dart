import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Ditambahkan untuk HapticFeedback
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_controller.dart';
// Import halaman login untuk rute kembali
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController =
      TextEditingController(); // Opsional: Untuk sapaan di dasbor
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 1. Mendengarkan perubahan state untuk efek samping (Notifikasi & Navigasi)
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          HapticFeedback.vibrate(); // Getaran saat ada kendala
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.redAccent.shade200,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        data: (user) {
          // Asumsi: Setelah register berhasil, langsung login atau kembali ke halaman login
          if (user != null) {
            HapticFeedback.mediumImpact(); // Getaran sukses
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Langkah pertamamu berhasil! Selamat datang.',
                ),
                backgroundColor: colorScheme.secondary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );

            // Kembali ke halaman login atau langsung tembus ke Dasbor (sesuaikan alurmu)
            Navigator.pop(context);
          }
        },
      );
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Ikon Jangkar Visual (Self Improvement)
                Icon(
                  Icons.self_improvement_rounded,
                  size: 64,
                  color: colorScheme.secondary.withOpacity(
                    0.8,
                  ), // Menggunakan Soft Teal
                ),
                const SizedBox(height: 24),

                // Microcopy yang empatik
                Text(
                  'Halo, Kawan Baru',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Mari mulai perjalanan wellbeing-mu hari ini.',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Form Input
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Panggilan',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 20),
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

                // Tombol Mulai Perjalanan
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          final name = _nameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text.trim();

                          if (email.isNotEmpty &&
                              password.isNotEmpty &&
                              name.isNotEmpty) {
                            // Sesuaikan fungsi register ini dengan AuthController Golang kamu
                            // Jika controllermu tidak butuh 'name', hapus variabel 'name' dan blok terkait
                            ref
                                .read(authControllerProvider.notifier)
                                .register(name, email, password);
                          } else {
                            HapticFeedback.heavyImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Bantu kami mengenalmu dengan mengisi semua kolom ya.',
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
                          'Mulai Perjalanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Navigasi kembali ke halaman Login
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(
                            context,
                          ); // Cukup di-pop karena halaman login ada di bawahnya
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.secondary,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Sudah terdaftar? Kembali untuk masuk',
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
