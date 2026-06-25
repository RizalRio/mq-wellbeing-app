import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'counselor_controller.dart';

class CounselorDashboardScreen extends ConsumerWidget {
  const CounselorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final clientsState = ref.watch(highRiskClientsProvider);
    final schedulesState = ref.watch(counselorSchedulesProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Dasbor Pakar',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(highRiskClientsProvider);
          ref.invalidate(counselorSchedulesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            // --- SEKSI 1: KLIEN KRISIS ---
            Text(
              'Peringatan Krisis Klien',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            clientsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text(
                'Error: $err',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              data: (clients) {
                if (clients.isEmpty) {
                  return Card(
                    elevation: 0,
                    color: theme.colorScheme.primary.withOpacity(0.05),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Tidak ada klien berisiko tinggi saat ini. Semua terkendali.',
                      ),
                    ),
                  );
                }
                return Column(
                  children: clients
                      .map(
                        (c) => Card(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            leading: Icon(
                              Icons.warning_amber_rounded,
                              color: theme.colorScheme.error,
                              size: 32,
                            ),
                            title: Text(
                              c.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Alert: ${c.riskAlertStatus}\nSkor: ${c.wellbeingScore.toStringAsFixed(1)}',
                            ),
                            isThreeLine: true,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),

            // --- SEKSI 2: AGENDA JADWAL ---
            Text(
              'Agenda Praktik Anda',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            schedulesState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text(
                'Error: $err',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              data: (schedules) {
                if (schedules.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Anda belum mengatur jadwal praktik kosong.'),
                  );
                }
                return Column(
                  children: schedules.map((s) {
                    final isBooked = s.isBooked;
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 8.0),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isBooked ? Icons.event_busy : Icons.event_available,
                            color: isBooked ? Colors.orange : Colors.green,
                          ),
                        ),
                        title: Text(
                          '${s.availableDate} | ${s.startTime} - ${s.endTime}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: isBooked
                            ? Text(
                                'Dipesan oleh: ${s.patientName}',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Text(
                                'Slot Tersedia (Kosong)',
                                style: TextStyle(color: Colors.green),
                              ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
