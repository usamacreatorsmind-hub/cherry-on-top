import 'package:get/get.dart';

import 'tutor_dashboard_controller.dart';
import 'earnings/tutor_earnings_controller.dart';

class TutorDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TutorDashboardController>(() => TutorDashboardController(), fenix: true);
    Get.lazyPut<TutorEarningsController>(() => TutorEarningsController());
  }
}
