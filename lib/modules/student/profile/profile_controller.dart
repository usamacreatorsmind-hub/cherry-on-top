import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../data/repositories/firestore_repository.dart';

class ProfileController extends GetxController {
  final appController = Get.find<AppController>();
  final _authController = Get.find<AuthController>();
  final _repository = FirestoreRepository();

  // Form Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Dropdown Values
  var selectedProfession = "".obs;
  var selectedGoal = "".obs;
  var selectedLevel = "".obs;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initValues();
  }

  void initValues() {
    final user = appController.user.value;
    if (user != null) {
      nameController.text = user.name;
      emailController.text = user.email;
      selectedProfession.value = user.profession ?? "Working Professional";
      selectedGoal.value = user.learningGoal ?? "Daily Conversational Skills";
      selectedLevel.value = user.englishLevel ?? "Intermediate";
    }
  }

  Future<bool> saveProfile() async {
    try {
      isLoading.value = true;
      final user = appController.user.value;
      if (user != null) {
        final updatedUser = user.copyWith(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          profession: selectedProfession.value,
          learningGoal: selectedGoal.value,
          englishLevel: selectedLevel.value,
        );

        await _repository.createUser(updatedUser);
        await appController.loadUserData(user.uid);
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authController.logout();
  }
}
