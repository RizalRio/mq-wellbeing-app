class AvailableSchedule {
  final String id;
  final String availableDate;
  final String startTime;
  final String endTime;

  AvailableSchedule({
    required this.id,
    required this.availableDate,
    required this.startTime,
    required this.endTime,
  });

  factory AvailableSchedule.fromJson(Map<String, dynamic> json) {
    return AvailableSchedule(
      id: json['id']?.toString() ?? '',
      availableDate: json['available_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

class PublicCounselor {
  final String counselorId;
  final String fullName;
  final String specialization;
  final int experienceYears;
  final double hourlyRate;
  final List<AvailableSchedule> schedules;

  PublicCounselor({
    required this.counselorId,
    required this.fullName,
    required this.specialization,
    required this.experienceYears,
    required this.hourlyRate,
    required this.schedules,
  });

  factory PublicCounselor.fromJson(Map<String, dynamic> json) {
    final schedList = json['schedules'] as List?;
    return PublicCounselor(
      counselorId: json['counselor_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Pakar Anonim',
      specialization: json['specialization']?.toString() ?? '-',
      experienceYears:
          int.tryParse(json['experience_years']?.toString() ?? '0') ?? 0,
      hourlyRate:
          double.tryParse(json['hourly_rate']?.toString() ?? '0') ?? 0.0,
      schedules:
          schedList?.map((e) => AvailableSchedule.fromJson(e)).toList() ?? [],
    );
  }
}
