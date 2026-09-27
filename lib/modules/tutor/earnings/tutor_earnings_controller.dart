import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';
import '../../../data/models/session_model.dart';
import '../../../data/repositories/firestore_repository.dart';

class TutorEarningsController extends GetxController {
  final appController = Get.find<AppController>();
  final FirestoreRepository _repository = FirestoreRepository();

  var sessions = <SessionModel>[].obs;
  var isLoading = true.obs;
  var selectedFilter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadEarnings();
    ever(appController.user, (_) => _loadEarnings());
  }

  void _loadEarnings() {
    final user = appController.user.value;
    if (user != null) {
      sessions.bindStream(_repository.getTutorSessions(user.uid));
      sessions.listen((_) => isLoading.value = false);
    } else {
      sessions.clear();
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  double get totalEarnings => earningsHistory.fold(0.0, (sum, item) => sum + item.price);

  List<SessionModel> get earningsHistory {
    var past = sessions.where((s) => s.status == 'past').toList();
    DateTime now = DateTime.now();

    switch (selectedFilter.value) {
      case 'Today':
        past = past.where((s) => 
          s.dateTime.year == now.year && 
          s.dateTime.month == now.month && 
          s.dateTime.day == now.day
        ).toList();
        break;
      case 'Last 7 Days':
        DateTime threshold = now.subtract(const Duration(days: 7));
        past = past.where((s) => s.dateTime.isAfter(threshold)).toList();
        break;
      case 'Last 15 Days':
        DateTime threshold = now.subtract(const Duration(days: 15));
        past = past.where((s) => s.dateTime.isAfter(threshold)).toList();
        break;
      case 'Last Month':
        DateTime threshold = now.subtract(const Duration(days: 30));
        past = past.where((s) => s.dateTime.isAfter(threshold)).toList();
        break;
      case '6 Months':
        DateTime threshold = now.subtract(const Duration(days: 180));
        past = past.where((s) => s.dateTime.isAfter(threshold)).toList();
        break;
      case 'Amount Wise':
        past.sort((a, b) => b.price.compareTo(a.price));
        return past;
      default:
        break;
    }

    past.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return past;
  }

  Map<String, double> get earningsByStudent {
    Map<String, double> map = {};
    for (var session in earningsHistory) {
      map[session.userName] = (map[session.userName] ?? 0.0) + session.price;
    }
    return map;
  }
}
