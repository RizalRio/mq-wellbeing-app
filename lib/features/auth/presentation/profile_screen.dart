import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_controller.dart';
import 'login_screen.dart'; // Pastikan ini sesuai dengan lokasi LoginScreen Anda

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _executeLogout(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Beristirahat sejenak?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Kamu akan keluar dari akun ini.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors
                  .redAccent
                  .shade100, // Merah pudar agar tidak mengintimidasi
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(profileControllerProvider.notifier).processLogout();
      // Uncomment navigasi login di bawah ini sesuai nama halaman Anda:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: profileState.when(
        data: (userId) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 60,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 32),

              Text('ID Pengguna', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 8),
              Text(
                userId,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Tombol Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    side: BorderSide(
                      color: Colors.redAccent.withOpacity(0.3),
                      width: 1.5,
                    ),
                    foregroundColor: Colors.redAccent.shade200,
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Keluar dari Akun',
                    style: TextStyle(fontSize: 16),
                  ),
                  onPressed: () => _executeLogout(context, ref),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => const Center(child: Text('Gagal memuat profil.')),
      ),
    );
  }
}
