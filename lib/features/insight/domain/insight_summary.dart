class InsightSummary {
  final int wellbeingScore;
  final String scoreCategory;
  final String dailyInsight;
  final String? riskAlertStatus;
  final double assessmentScore;
  final double averageMood;
  final double habitCompletionRate;

  InsightSummary({
    required this.wellbeingScore,
    required this.scoreCategory,
    required this.dailyInsight,
    this.riskAlertStatus,
    required this.assessmentScore,
    required this.averageMood,
    required this.habitCompletionRate,
  });

  factory InsightSummary.fromJson(Map<String, dynamic> json) {
    final components = json['components'] as Map<String, dynamic>;
    return InsightSummary(
      wellbeingScore: json['wellbeing_score'] as int,
      scoreCategory: json['score_category'] as String,
      dailyInsight: json['daily_insight'] as String,
      riskAlertStatus: json['risk_alert_status'] as String?,
      // Konversi eksplisit ke double untuk mengamankan tipe data presisi (float/float64)
      assessmentScore: (components['assessment_score'] as num).toDouble(),
      averageMood: (components['average_mood'] as num).toDouble(),
      habitCompletionRate: (components['habit_completion_rate'] as num)
          .toDouble(),
    );
  }
}
