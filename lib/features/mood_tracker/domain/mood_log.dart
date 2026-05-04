class MoodLog {
  final String id;
  final int moodScore;
  final List<String> activityTags;
  final String note;

  MoodLog({
    required this.id,
    required this.moodScore,
    required this.activityTags,
    this.note = '',
  });

  factory MoodLog.fromJson(Map<String, dynamic> json) {
    return MoodLog(
      id: json['id'] ?? '',
      moodScore: json['mood_score'] ?? 3,
      activityTags: List<String>.from(json['activity_tags'] ?? []),
      note: json['note'] ?? '',
    );
  }
}
