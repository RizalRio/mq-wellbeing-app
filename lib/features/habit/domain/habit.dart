class Habit {
  final String id;
  final String title;
  final String frequency;
  final List<bool> weeklyStatus; // Wadah untuk 7 lingkaran status
  final int streakCount; // Wadah untuk jumlah bara api

  Habit({
    required this.id,
    required this.title,
    required this.frequency,
    required this.weeklyStatus,
    required this.streakCount,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    // Parsing array boolean secara aman
    List<bool> parsedStatus = List.generate(7, (_) => false);
    if (json['weekly_status'] is List) {
      final List<dynamic> rawList = json['weekly_status'];
      for (int i = 0; i < rawList.length && i < 7; i++) {
        parsedStatus[i] = rawList[i] == true;
      }
    }

    return Habit(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Tanpa Judul',
      frequency: json['frequency'] ?? 'daily',
      weeklyStatus: parsedStatus,
      streakCount: int.tryParse(json['streak_count']?.toString() ?? '0') ?? 0,
    );
  }
}
