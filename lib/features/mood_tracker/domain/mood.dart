class Mood {
  final String id;
  final int scale;
  final List<String> tags;
  final String? note;
  final DateTime createdAt;

  Mood({
    required this.id,
    required this.scale,
    required this.tags,
    this.note,
    required this.createdAt,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'] ?? '',
      scale: json['scale'] ?? 3,
      tags: List<String>.from(json['tags'] ?? []),
      note: json['note'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
