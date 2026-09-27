import 'package:get/get.dart';
import 'tutor_earnings_controller.dart';

class TutorEarningsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TutorEarningsController>(() => TutorEarningsController());
  }
}
