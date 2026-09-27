import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/app_controller.dart';
import '../../data/repositories/firestore_repository.dart';
import '../../data/models/session_model.dart';

class TutorDashboardController extends GetxController {
  final appController = Get.find<AppController>();
  final FirestoreRepository _repository = FirestoreRepository();

  var currentIndex = 0.obs;
  var isEditing = false.obs;
  var sessions = <SessionModel>[].obs;
  var isLoadingSessions = true.obs;

  // Edit Controllers
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final experienceController = TextEditingController();
  final rateController = TextEditingController();
  var selectedExpertise = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    _loadSessions();
    // Also listen for changes in user data to keep controllers in sync
    ever(appController.user, (_) {
      _loadInitialData();
      _loadSessions();
    });
  }

  void _loadSessions() {
    final user = appController.user.value;
    if (user != null) {
      sessions.bindStream(_repository.getTutorSessions(user.uid));
      sessions.listen((_) => isLoadingSessions.value = false);
    } else {
      sessions.clear();
      isLoadingSessions.value = false;
    }
  }

  List<SessionModel> get upcomingSessions => sessions
      .where((s) => s.status == 'upcoming' && s.dateTime.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<SessionModel> get pastSessions => sessions
      .where((s) => s.status == 'past' || (s.status == 'upcoming' && s.dateTime.isBefore(DateTime.now())))
      .toList()
    ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  double get totalEarnings => sessions
      .where((s) => s.status == 'past')
      .fold(0.0, (sum, item) => sum + item.price);

  void _loadInitialData() {
    final user = appController.user.value;
    if (user != null) {
      nameController.text = user.name;
      bioController.text = user.bio ?? '';
      experienceController.text = user.experience ?? '';
      rateController.text = user.hourlyRate?.toString() ?? '0';
      selectedExpertise.assignAll(user.expertise ?? []);
    }
  }

  void changeIndex(int index) {
    currentIndex.value = index;
    isEditing.value = false;
  }

  Future<void> completeSession(SessionModel session) async {
    try {
      await _repository.completeSessionAndAddEarnings(session);
      Get.snackbar("Success", "Session marked as completed and earnings updated");
    } catch (e) {
      Get.snackbar("Error", "Failed to update session: $e");
    }
  }

  void toggleEdit() {
    if (isEditing.value) {
      saveProfile();
    }
    isEditing.value = !isEditing.value;
  }

  Future<bool> saveProfile() async {
    try {
      final user = appController.user.value;
      if (user != null) {
        // Create a plain list from RxList to ensure Firestore compatibility
        final expertiseList = selectedExpertise.toList();
        
        final updatedUser = user.copyWith(
          name: nameController.text.trim(),
          bio: bioController.text.trim(),
          experience: experienceController.text.trim(),
          hourlyRate: double.tryParse(rateController.text.trim()) ?? 0.0,
          expertise: expertiseList,
        );
        
        // 1. Update user private data
        await _repository.createUser(updatedUser);
        
        // 2. Update tutor public data (crucial for student side)
        await _repository.updateTutorPublicProfile(updatedUser);
        
        // 3. Reload local data to reflect changes
        await appController.loadUserData(user.uid);
        
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        "Update Failed", 
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    experienceController.dispose();
    rateController.dispose();
    super.onClose();
  }
}
