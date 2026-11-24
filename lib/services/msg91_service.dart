import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Msg91Service extends GetxService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<bool> sendOtp(String phoneNumber) async {
    try {
      final result = await _functions.httpsCallable('sendMsg91Otp').call({
        'phoneNumber': phoneNumber,
      });
      return result.data['success'] == true;
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<String?> verifyOtp(String phoneNumber, String otp) async {
    try {
      final result = await _functions.httpsCallable('verifyMsg91Otp').call({
        'phoneNumber': phoneNumber,
        'otp': otp,
      });
      if (result.data['success'] == true) {
        return result.data['customToken'] as String?;
      }
      return null;
    } catch (e) {
      Get.snackbar(
        "Verification Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return null;
    }
  }
}
