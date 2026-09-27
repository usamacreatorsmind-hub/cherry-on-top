import 'package:get/get.dart';
import 'book_trial_controller.dart';

class BookTrialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookTrialController>(() => BookTrialController());
  }
}
