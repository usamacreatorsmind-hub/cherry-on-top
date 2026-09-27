import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';
import '../../../data/models/availability_model.dart';
import '../../../data/repositories/firestore_repository.dart';

class TutorScheduleController extends GetxController {
  final appController = Get.find<AppController>();
  final FirestoreRepository _repository = FirestoreRepository();

  var isLoading = false.obs;
  var weeklySchedule = <String, AvailabilityModel>{}.obs;

  final List<String> days = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  @override
  void onInit() {
    super.onInit();
    _loadSchedule();
  }

  void _loadSchedule() {
    final user = appController.user.value;
    if (user?.weeklySchedule != null && user!.weeklySchedule!.isNotEmpty) {
      weeklySchedule.addAll(user.weeklySchedule!);
    } else {
      // Initialize with default values
      for (var day in days) {
        weeklySchedule[day] = AvailabilityModel(isAvailable: false);
      }
    }
  }

  void toggleAvailability(String day, bool value) {
    var current = weeklySchedule[day] ?? AvailabilityModel();
    weeklySchedule[day] = current.copyWith(isAvailable: value);
  }

  void updateSchedule(String day, String start, String end, int duration) {
    var current = weeklySchedule[day] ?? AvailabilityModel();
    weeklySchedule[day] = current.copyWith(
      startTime: start,
      endTime: end,
      slotDuration: duration,
      isAvailable: true,
    );
  }

  Future<void> saveSchedule() async {
    try {
      isLoading.value = true;
      final user = appController.user.value;
      if (user != null) {
        final updatedUser = user.copyWith(weeklySchedule: Map<String, AvailabilityModel>.from(weeklySchedule));
        
        // 1. Update private user document
        await _repository.createUser(updatedUser);
        
        // 2. Update public tutor profile (Crucial for students to see slots)
        await _repository.updateTutorPublicProfile(updatedUser);
        
        // 3. Refresh local app state
        await appController.loadUserData(user.uid);
        
        Get.back();
        Get.snackbar("Success", "Schedule updated successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
