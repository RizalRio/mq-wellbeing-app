// lib/features/auth/presentation/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_controller.dart';
import 'login_screen.dart';

// ─────────────────────────────────────────────────
// ProfileScreen
// ─────────────────────────────────────────────────
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Derivasi inisial dari nama lengkap
  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.isEmpty || name.trim().isEmpty) return '?';
    if (p.length == 1) return p[0][0].toUpperCase();
    return '${p[0][0]}${p[1][0]}'.toUpperCase();
  }

  // Konfirmasi logout via bottom sheet
  Future<void> _executeLogout(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LogoutSheet(),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(profileControllerProvider.notifier).processLogout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildFixedAppBar(context),
      body: profileState.when(
        loading: () => const _ProfileSkeleton(),
        error: (_, __) => _buildErrorState(context, ref),
        data: (user) => _buildBody(context, ref, user),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // Sticky / Fixed AppBar
  // ─────────────────────────────────────────────────
  PreferredSizeWidget _buildFixedAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 4, // Memberikan sedikit bayangan saat di-scroll
      shadowColor: colorScheme.primary.withOpacity(0.4),
      // Menerapkan gradien pada AppBar agar senada dengan tema header
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [colorScheme.primary, colorScheme.secondary],
          ),
        ),
      ),
      title: Text(
        'Profil',
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
          color: colorScheme.surface,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              // TODO: Navigasi Edit Profil
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: colorScheme.surface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  // Body Utama
  // ─────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, WidgetRef ref, dynamic user) {
    final String fullName = user.fullName?.toString() ?? '';
    final String email = user.email?.toString() ?? '';
    final String userId = user.id?.toString() ?? '';
    final String initial = _initials(fullName);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // ── Hero Header (Gradient + Avatar Float) ──
          _buildHeroHeader(context, fullName, email, initial),
          const SizedBox(height: 28),

          // ── Konten ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 120),
                // Informasi Akun
                _buildSectionLabel(context, 'Informasi Akun'),
                const SizedBox(height: 12),
                _buildInfoGroup(context, [
                  _InfoItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: email,
                  ),
                  _InfoItem(
                    icon: Icons.badge_outlined,
                    label: 'ID Pengguna',
                    value: userId,
                    isMonospace: true,
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: 28),

                // Pengaturan
                _buildSectionLabel(context, 'Pengaturan'),
                const SizedBox(height: 12),
                _buildMenuGroup(context, [
                  _MenuItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifikasi',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.shield_outlined,
                    label: 'Privasi & Keamanan',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Bantuan & Dukungan',
                    onTap: () {},
                  ),
                  _MenuItem(
                    icon: Icons.info_outline_rounded,
                    label: 'Tentang Aplikasi',
                    onTap: () {},
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: 28),

                // Logout
                _buildSectionLabel(context, 'Sesi'),
                const SizedBox(height: 12),
                _buildLogoutTile(context, ref),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // Hero Header — Gradient + Avatar floating
  // ─────────────────────────────────────────────────
  Widget _buildHeroHeader(
    BuildContext context,
    String name,
    String email,
    String initial,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Gradient background
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [colorScheme.primary, colorScheme.secondary],
            ),
          ),
        ),

        // Avatar lingkaran (float di boundary)
        Positioned(
          bottom: -110,
          child: Column(
            children: [
              // Avatar with gradient + initials
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: colorScheme.surface,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Nama lengkap
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────
  // Section Label
  // ─────────────────────────────────────────────────
  Widget _buildSectionLabel(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 0.7,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // Info Group (kartu info dengan divider internal)
  // ─────────────────────────────────────────────────
  Widget _buildInfoGroup(BuildContext context, List<_InfoItem> items) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Ikon
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        item.icon,
                        size: 17,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Label + value
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (item.badge != null) ...[
                                Text(
                                  item.badge!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(width: 5),
                              ],
                              Expanded(
                                child: Text(
                                  item.value,
                                  style: TextStyle(
                                    fontFamily: item.isMonospace
                                        ? 'monospace'
                                        : 'Nunito',
                                    fontSize: item.isMonospace ? 12 : 14,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        item.valueColor ??
                                        colorScheme.onSurface,
                                    letterSpacing: item.isMonospace ? 0.3 : 0,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Chevron (visual affordance)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colorScheme.onSurface.withOpacity(0.25),
                    ),
                  ],
                ),
              ),
              if (!item.isLast)
                Divider(
                  height: 1,
                  indent: 52,
                  color: colorScheme.primary.withOpacity(0.08),
                ),
            ],
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // Settings Menu Group
  // ─────────────────────────────────────────────────
  Widget _buildMenuGroup(BuildContext context, List<_MenuItem> items) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    item.onTap();
                  },
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(20) : Radius.zero,
                    bottom: item.isLast
                        ? const Radius.circular(20)
                        : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 15,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            item.icon,
                            size: 17,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: colorScheme.onSurface.withOpacity(0.25),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!item.isLast)
                Divider(
                  height: 1,
                  indent: 52,
                  color: colorScheme.primary.withOpacity(0.08),
                ),
            ],
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // Logout Tile
  // ─────────────────────────────────────────────────
  Widget _buildLogoutTile(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _executeLogout(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 17,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Keluar dari Akun',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.error,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: colorScheme.error.withOpacity(0.35),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────
  // Error State
  // ─────────────────────────────────────────────────
  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: colorScheme.error.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 52,
                color: colorScheme.error.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Gagal Memuat Profil',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Periksa koneksi internetmu,\nlalu coba lagi.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(profileControllerProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.secondary,
                side: BorderSide(color: colorScheme.secondary, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Logout Bottom Sheet
// ─────────────────────────────────────────────────
class _LogoutSheet extends StatelessWidget {
  const _LogoutSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom +
            24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Ikon peringatan
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.error.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.logout_rounded,
              size: 30,
              color: colorScheme.error,
            ),
          ),
          const SizedBox(height: 18),

          // Judul
          Text(
            'Beristirahat sejenak?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Deskripsi
          Text(
            'Kamu akan keluar dari akun ini.\nData harianmu tetap tersimpan.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 28),

          // Tombol Keluar
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, true),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.error,
                side: BorderSide(color: colorScheme.error, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              child: const Text('Ya, Keluar'),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Batal
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.onSurface,
                elevation: 0,
                side: BorderSide(color: colorScheme.primary.withOpacity(0.25)),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              child: const Text('Tidak, Lanjutkan'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────
// Data model pembantu (private)
// ─────────────────────────────────────────────────
class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final String? badge;
  final bool isMonospace;
  final bool isLast;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.badge,
    this.isMonospace = false,
    this.isLast = false,
  });
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });
}

// ─────────────────────────────────────────────────
// Skeleton Loading (Statis & Ringan)
// ─────────────────────────────────────────────────
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.06);

    return SingleChildScrollView(
      physics:
          const NeverScrollableScrollPhysics(), // Nonaktifkan scroll saat loading
      child: Column(
        children: [
          // Header placeholder
          _box(double.infinity, 60, baseColor, r: 0),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 110),
                _box(80, 12, baseColor),
                const SizedBox(height: 12),
                _box(double.infinity, 140, baseColor, r: 20),
                const SizedBox(height: 28),
                _box(80, 12, baseColor),
                const SizedBox(height: 12),
                _box(double.infinity, 172, baseColor, r: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(double w, double h, Color color, {double r = 8}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(r),
    ),
  );
}
