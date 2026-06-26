import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/counseling_repository.dart';
import '../domain/booking.dart';

part 'booking_history_controller.g.dart';

@riverpod
class BookingHistoryController extends _$BookingHistoryController {
  @override
  FutureOr<List<BookingHistory>> build() async {
    return ref.watch(counselingRepositoryProvider).getBookingHistory();
  }
}
