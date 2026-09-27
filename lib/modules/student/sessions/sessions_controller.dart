import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/repositories/firestore_repository.dart';
import '../../../controllers/app_controller.dart';

class SessionsController extends GetxController {
  final FirestoreRepository _repository = FirestoreRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final appController = Get.find<AppController>();
  
  var sessions = <SessionModel>[].obs;
  var expertTutors = <TutorModel>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSessions();
    _loadTutors();
    ever(appController.user, (_) => _loadSessions());
  }

  void _loadSessions() {
    final user = _auth.currentUser;
    if (user != null) {
      sessions.bindStream(_repository.getUserSessions(user.uid));
      sessions.listen((_) => isLoading.value = false);
    } else {
      sessions.clear();
      isLoading.value = false;
    }
  }

  void _loadTutors() {
    _repository.getTutors().listen((tutors) {
      tutors.sort((a, b) => b.rating.compareTo(a.rating));
      expertTutors.assignAll(tutors.take(5).toList());
    });
  }

  List<SessionModel> get upcomingSessions => sessions
      .where((s) => s.status == 'upcoming' && s.dateTime.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<SessionModel> get pastSessions => sessions
      .where((s) => s.status == 'past' || (s.status == 'upcoming' && s.dateTime.isBefore(DateTime.now())))
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
}
