import 'package:get/get.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/repositories/firestore_repository.dart';


class TutorsController extends GetxController {
  final FirestoreRepository _repository = FirestoreRepository();
  var tutors = <TutorModel>[].obs;
  var isLoading = true.obs;
  var selectedFilter = "All Tutors".obs;

  @override
  void onInit() {
    super.onInit();
    tutors.bindStream(_repository.getTutors());
    tutors.listen((_) => isLoading.value = false);
  }

  List<TutorModel> get filteredTutors {
    if (selectedFilter.value == "All Tutors") {
      return tutors;
    }
    return tutors.where((tutor) {
      return tutor.expertise.contains(selectedFilter.value);
    }).toList();
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }
}
