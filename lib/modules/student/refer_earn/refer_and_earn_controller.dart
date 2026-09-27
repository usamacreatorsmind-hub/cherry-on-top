import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/repositories/firestore_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../controllers/app_controller.dart';

class ReferAndEarnController extends GetxController {
  final FirestoreRepository _repository = FirestoreRepository();
  final AppController _appController = Get.find<AppController>();

  var isLoading = true.obs;
  var walletBalance = 0.0.obs;
  var pendingInvites = 0.obs;
  var successfulInvites = 0.obs;
  var referralCode = 'CHERRY123456'.obs;
  var selectedShareTab = 0.obs; // 0: Share Code, 1: Share Link

  @override
  void onInit() {
    super.onInit();
    final userName = _appController.user.value?.name ?? 'User';
    String prefix = userName.isNotEmpty ? userName.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase() : 'USER';
    if (prefix.length > 3) prefix = prefix.substring(0, 3);
    referralCode.value = "$prefix${100000 + (userName.hashCode.abs() % 900000)}";

    fetchReferralData();
  }

  Future<void> fetchReferralData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? _appController.user.value?.uid ?? '';
      final userName = _appController.user.value?.name ?? 'User';

      final referralData = await _repository.getOrCreateReferralData(userId, userName);
      
      walletBalance.value = referralData.walletBalance;
      pendingInvites.value = referralData.pendingInvites;
      successfulInvites.value = referralData.successfulInvites;
      if (referralData.referralCode.isNotEmpty) {
        referralCode.value = referralData.referralCode;
      }
    } catch (_) {
      // Keep fallback
    } finally {
      isLoading.value = false;
    }
  }

  void copyCode() {
    Clipboard.setData(ClipboardData(text: referralCode.value));
    Get.snackbar(
      "Copied",
      "Referral code copied to clipboard!",
      backgroundColor: AppTheme.maroon,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void inviteFriends() {
    final link = "https://cherryontop.com/invite?code=${referralCode.value}";
    final message = selectedShareTab.value == 0
        ? "Hey! Join Cherry on Top and learn English fluently. Use my referral code: *${referralCode.value}* to sign up and get rewards!"
        : "Hey! Join Cherry on Top and learn English fluently. Sign up using my invite link: $link";
    Share.share(message);
  }
}
