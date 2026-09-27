import 'package:get/get.dart';
import 'home_controller.dart';
import '../profile/profile_controller.dart';
import '../tutors/tutors_controller.dart';
import '../sessions/sessions_controller.dart';
import '../../tutor/tutor_dashboard_controller.dart';
import '../../tutor/earnings/tutor_earnings_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<TutorsController>(() => TutorsController());
    Get.lazyPut<SessionsController>(() => SessionsController());
    Get.lazyPut<TutorDashboardController>(() => TutorDashboardController(), fenix: true);
    Get.lazyPut<TutorEarningsController>(() => TutorEarningsController());
  }
}
