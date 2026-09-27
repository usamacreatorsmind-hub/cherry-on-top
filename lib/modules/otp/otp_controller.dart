import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';

class OTPController extends GetxController {
  final otpController = TextEditingController();
  final AuthController authController = Get.find<AuthController>();

  void verifyOtp() {
    if (otpController.text.length == 6) {
      authController.signInWithOTP(otpController.text);
    } else {
      Get.snackbar("Error", "Please enter a valid 6-digit OTP");
    }
  }

  void resendOtp(String phoneNumber) {
    authController.verifyPhoneNumber(phoneNumber);
    Get.snackbar("OTP Resent", "A new OTP has been sent to your number");
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
