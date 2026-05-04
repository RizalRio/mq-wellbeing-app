import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'register_screen.dart';
import 'auth_controller.dart';
import '../../dashboard/presentation/dashboard_screen.dart';

// Kita menggunakan ConsumerStatefulWidget agar bisa menggunakan ref (Riverpod)
// dan Controller untuk TextField secara bersamaan.
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
    // 1. ref.listen digunakan untuk efek samping (side-effects) seperti navigasi atau menampilkan peringatan.
    // Ini dipanggil sekali setiap ada perubahan state, bukan pada saat proses render UI.
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        data: (user) {
          if (user != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selamat datang kembali!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Navigasi ke Dashboard dan hapus riwayat rute sebelumnya agar pengguna tidak bisa kembali ke halaman login dengan menekan tombol "Back"
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
        },
      );
    });

    // 2. ref.watch digunakan untuk membangun ulang UI saat state berubah (misalnya saat loading).
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Menggunakan tipografi dari AppTheme
                Text(
                  'Selamat Datang Kembali',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 28),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Silakan masuk untuk melanjutkan perjalanan wellbeing kamu.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Form Input
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 32),

                // Tombol Login dengan indikator loading
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final email = _emailController.text;
                          final password = _passwordController.text;
                          if (email.isNotEmpty && password.isNotEmpty) {
                            // Memanggil fungsi login di AuthController
                            ref
                                .read(authControllerProvider.notifier)
                                .login(email, password);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harap isi email dan kata sandi'),
                              ),
                            );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text('Masuk'),
                ),
                const SizedBox(height: 16),

                // Navigasi ke halaman Register
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Text('Belum punya akun? Daftar di sini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
