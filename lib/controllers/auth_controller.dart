import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../routes/app_pages.dart';
import '../data/repositories/firestore_repository.dart';
import '../data/models/user_model.dart';
import 'app_controller.dart';
import '../services/msg91_service.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirestoreRepository _repository = FirestoreRepository();
  final Msg91Service _msg91Service = Get.put(Msg91Service());
  
  var verificationId = ''.obs;
  var currentPhoneNumber = ''.obs;
  var isLoading = false.obs;
  late Rx<User?> _user;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(auth.currentUser);
    _user.bindStream(auth.authStateChanges());
    
    // Listen for auth state changes and navigate accordingly
    ever(_user, _initialScreen);
  }

  bool _isNavigating = false;

  void _initialScreen(User? user) async {
    // Only delay for splash screen animation when app launches
    if (Get.currentRoute == Routes.SPLASH || Get.currentRoute == '/') {
      await Future.delayed(const Duration(seconds: 2));
    }

    if (user == null) {
      // Not logged in, go to Login if not already there
      if (Get.currentRoute != Routes.LOGIN && Get.currentRoute != Routes.SPLASH && Get.currentRoute != '/') {
        Get.offAllNamed(Routes.LOGIN);
      } else if (Get.currentRoute == Routes.SPLASH || Get.currentRoute == '/') {
        Get.offAllNamed(Routes.LOGIN);
      }
    } else {
      // Logged in, redirect only if at Splash/Login/OTP/Root
      if (Get.currentRoute == Routes.SPLASH ||
          Get.currentRoute == Routes.LOGIN || 
          Get.currentRoute == Routes.OTP || 
          Get.currentRoute == '/' ||
          Get.currentRoute == '') {
        await _handleUserPostLogin();
      }
    }
  }

  // Send OTP to the mobile number via MSG91
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    try {
      isLoading.value = true;
      currentPhoneNumber.value = phoneNumber;
      bool success = await _msg91Service.sendOtp(phoneNumber);
      isLoading.value = false;
      if (success) {
        Get.toNamed(Routes.OTP, arguments: phoneNumber);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", e.toString());
    }
  }

  // Verify the OTP entered by user via MSG91
  Future<void> signInWithOTP(String smsCode) async {
    try {
      isLoading.value = true;
      String? customToken = await _msg91Service.verifyOtp(currentPhoneNumber.value, smsCode);
      if (customToken != null) {
        await auth.signInWithCustomToken(customToken);
        await _handleUserPostLogin();
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Verification Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _handleUserPostLogin() async {
    if (_isNavigating) return;
    _isNavigating = true;

    try {
      User? user = auth.currentUser;
      if (user != null) {
        UserModel? existingUser = await _repository.getUser(user.uid);
        isLoading.value = false;
        if (existingUser == null || existingUser.role == null) {
          Get.offAllNamed(Routes.ROLE_SELECTION);
        } else {
          if (existingUser.role == 'student') {
            Get.offAllNamed(Routes.STUDENT_DASHBOARD);
          } else if (existingUser.role == 'tutor') {
            Get.offAllNamed(Routes.TUTOR_DASHBOARD);
          } else {
            Get.offAllNamed(Routes.HOME);
          }
        }
      } else {
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
    } finally {
      _isNavigating = false;
    }
  }

  void logout() async {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.maroon)),
        content: const Text("Are you sure you want to logout from Cherry on Top?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // 1. Sign out from Firebase
                await auth.signOut();
                
                // 2. Clear user data in AppController
                Get.find<AppController>().clearUserData();
                
                // 3. Navigate to Login. 
                // Get.offAllNamed will clear route-specific controllers automatically.
                Get.offAllNamed(Routes.LOGIN);
                
              } catch (e) {
                print("Logout error: $e");
                Get.offAllNamed(Routes.LOGIN);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
