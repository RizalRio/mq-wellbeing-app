import 'package:riverpod_annotation/riverpod_annotation.dart';

// Pastikan ejaannya persis seperti nama file
part 'dashboard_controller.g.dart';

@riverpod
class DashboardNav extends _$DashboardNav {
  @override
  int build() {
    return 0;
  }

  void setIndex(int index) {
    state = index;
  }
}
