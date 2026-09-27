import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/notification_model.dart';
import '../../../controllers/app_controller.dart';

class NotificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppController _appController = Get.find<AppController>();
  
  var isLoading = true.obs;
  var notifications = <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() {
    isLoading.value = true;
    final userRole = _appController.user.value?.role ?? 'student';

    _firestore
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      final list = snapshot.docs.map((doc) => NotificationModel.fromMap(doc.data(), doc.id)).where((n) {
        if (n.target == 'all') return true;
        if (userRole == 'tutor') {
          return n.target == 'tutor';
        } else {
          return n.target == 'student';
        }
      }).toList();

      notifications.assignAll(list);
      isLoading.value = false;
    }, onError: (_) {
      isLoading.value = false;
    });
  }

  Future<void> markAsRead(String id) async {
    await _firestore.collection('notifications').doc(id).set({'isRead': true}, SetOptions(merge: true));
  }
}
