class Habit {
  final String id;
  final String title;
  final String frequency;

  Habit({required this.id, required this.title, required this.frequency});

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Tanpa Judul',
      frequency: json['frequency'] ?? 'daily',
    );
  }
}
