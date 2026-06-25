import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'counseling_controller.dart';
import 'booking_controller.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final catalogState = ref.watch(counselingCatalogProvider);

    // Format rupiah
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konseling Profesional'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(counselingCatalogProvider),
        child: catalogState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text(
              'Error: $err',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          data: (counselors) {
            if (counselors.isEmpty) {
              return const Center(
                child: Text('Belum ada konselor yang tersedia saat ini.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: counselors.length,
              itemBuilder: (context, index) {
                final counselor = counselors[index];
                final hasSchedules = counselor.schedules.isNotEmpty;

                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    shape: const Border(),
                    leading: CircleAvatar(
                      backgroundColor: theme.colorScheme.primary.withOpacity(
                        0.1,
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      counselor.fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${counselor.specialization} • ${counselor.experienceYears} Tahun\n${currencyFormatter.format(counselor.hourlyRate)} / Sesi',
                    ),
                    children: [
                      const Divider(height: 1),
                      if (!hasSchedules)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Belum ada jadwal kosong yang dibuka.'),
                        )
                      else
                        ...counselor.schedules.map(
                          (schedule) => ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 4,
                            ),
                            leading: const Icon(Icons.calendar_today, size: 20),
                            title: Text(
                              schedule.availableDate,
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${schedule.startTime} - ${schedule.endTime}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // PERUBAHAN: Membaca status loading dari controller spesifik
                                Consumer(
                                  builder: (context, ref, child) {
                                    final bookingState = ref.watch(
                                      bookingControllerProvider,
                                    );
                                    final isLoading =
                                        bookingState is AsyncLoading;

                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        minimumSize: const Size(0, 36),
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : () async {
                                              HapticFeedback.lightImpact();

                                              // 1. Munculkan Dialog Konfirmasi (KISS)
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text(
                                                    'Konfirmasi Pemesanan',
                                                  ),
                                                  content: Text(
                                                    'Anda akan memesan jadwal konsultasi dengan ${counselor.fullName} pada ${schedule.availableDate} jam ${schedule.startTime}. Lanjutkan?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            false,
                                                          ),
                                                      child: Text(
                                                        'Batal',
                                                        style: TextStyle(
                                                          color: theme
                                                              .colorScheme
                                                              .secondary,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                            ctx,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Ya, Pesan',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              // 2. Eksekusi jika user menekan "Ya, Pesan"
                                              if (confirm == true) {
                                                final success = await ref
                                                    .read(
                                                      bookingControllerProvider
                                                          .notifier,
                                                    )
                                                    .checkout(schedule.id);

                                                if (context.mounted) {
                                                  if (success) {
                                                    HapticFeedback.mediumImpact();
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Jadwal berhasil dipesan!',
                                                        ),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );
                                                    // Refresh katalog agar jadwal yang dipesan menghilang dari daftar
                                                    ref.invalidate(
                                                      counselingCatalogProvider,
                                                    );
                                                  } else {
                                                    HapticFeedback.heavyImpact();
                                                    final errorMsg = ref
                                                        .read(
                                                          bookingControllerProvider,
                                                        )
                                                        .error
                                                        .toString();
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(errorMsg),
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                    );
                                                  }
                                                }
                                              }
                                            },
                                      child: isLoading
                                          ? const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text('Pilih'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
