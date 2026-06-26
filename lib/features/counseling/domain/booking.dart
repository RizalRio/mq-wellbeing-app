class BookingHistory {
  final String bookingId;
  final String counselorName;
  final String specialization;
  final String availableDate;
  final String startTime;
  final String endTime;
  final String bookingStatus;
  final String paymentStatus;
  final double paymentAmount;

  BookingHistory({
    required this.bookingId,
    required this.counselorName,
    required this.specialization,
    required this.availableDate,
    required this.startTime,
    required this.endTime,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.paymentAmount,
  });

  factory BookingHistory.fromJson(Map<String, dynamic> json) {
    return BookingHistory(
      bookingId: json['booking_id']?.toString() ?? '',
      counselorName: json['counselor_name']?.toString() ?? 'Pakar Anonim',
      specialization: json['specialization']?.toString() ?? '-',
      availableDate: json['available_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      bookingStatus: json['booking_status']?.toString() ?? 'PENDING',
      paymentStatus: json['payment_status']?.toString() ?? 'UNPAID',
      paymentAmount:
          double.tryParse(json['payment_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}
