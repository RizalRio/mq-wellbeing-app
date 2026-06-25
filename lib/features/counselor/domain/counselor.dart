class HighRiskClient {
  final String userId;
  final String fullName;
  final double wellbeingScore;
  final String riskAlertStatus;

  HighRiskClient({
    required this.userId,
    required this.fullName,
    required this.wellbeingScore,
    required this.riskAlertStatus,
  });

  factory HighRiskClient.fromJson(Map<String, dynamic> json) {
    return HighRiskClient(
      userId: json['user_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Klien Anonim',
      wellbeingScore:
          double.tryParse(json['wellbeing_score']?.toString() ?? '0') ?? 0.0,
      riskAlertStatus: json['risk_alert_status']?.toString() ?? 'Unknown',
    );
  }
}

class CounselorSchedule {
  final String scheduleId;
  final String availableDate;
  final String startTime;
  final String endTime;
  final bool isBooked;
  final String? patientName;

  CounselorSchedule({
    required this.scheduleId,
    required this.availableDate,
    required this.startTime,
    required this.endTime,
    required this.isBooked,
    this.patientName,
  });

  factory CounselorSchedule.fromJson(Map<String, dynamic> json) {
    return CounselorSchedule(
      scheduleId: json['schedule_id']?.toString() ?? '',
      availableDate: json['available_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      isBooked: json['is_booked'] == true,
      patientName: json['patient_name']?.toString(),
    );
  }
}
