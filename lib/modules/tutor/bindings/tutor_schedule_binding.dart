import 'package:get/get.dart';
import '../controllers/tutor_schedule_controller.dart';

class TutorScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TutorScheduleController>(() => TutorScheduleController());
  }
}
