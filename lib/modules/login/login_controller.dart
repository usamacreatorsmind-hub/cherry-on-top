import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  var isValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(() {
      isValid.value = phoneController.text.length == 10;
    });
  }

  void sendOtp() {
    if (isValid.value) {
      authController.verifyPhoneNumber(phoneController.text.trim());
    } else {
      Get.snackbar("Error", "Enter valid 10-digit number");
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
