import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'profile_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),

            // MENU ITEMS
            _buildMenuTile(
              title: "Subscription Plans",
              subtitle: "Choose sessions and save big",
              icon: Icons.card_membership_rounded,
              onTap: () => Get.toNamed(Routes.SUBSCRIPTION_PLANS),
            ),
            _buildMenuTile(
              title: "Favourite Tutors",
              icon: Icons.favorite_rounded,
              onTap: () => Get.toNamed(Routes.FAVOURITE_TUTORS),
            ),
            _buildMenuTile(
              title: "Share",
              subtitle: "Tell your friends about us",
              icon: Icons.share_rounded,
              onTap: () {
                Share.share("Check out Cherry on Top for the best English mentorship! Download now: https://cherryontop.com");
              },
            ),
            _buildMenuTile(title: "FAQs", icon: Icons.help_outline_rounded, onTap: () => Get.toNamed(Routes.FAQS)),
            _buildMenuTile(title: "Support", icon: Icons.headset_mic_rounded, onTap: () => Get.toNamed(Routes.SUPPORT)),
            _buildMenuTile(title: "More", icon: Icons.settings_rounded, onTap: () => Get.toNamed(Routes.SETTINGS_MORE)),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.maroon.withAlpha(10), borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: AppTheme.maroon,
              child: const Icon(Icons.person, color: Colors.white, size: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      controller.appController.userName.value,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                    ),
                  ),
                  const Text("Student Account", style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Get.toNamed(Routes.STUDENT_EDIT_PROFILE),
              icon: const Icon(Icons.edit_note_rounded, color: AppTheme.maroon, size: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(controller.appController.completedSessions.value.toString(), "Completed\nSession"),
                _buildStatItem(controller.appController.availableSessions.value.toString(), "Available\nSession"),
                _buildStatItem(controller.appController.remainingDays.value.toString(), "Remaining\ndays"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    // Ensure negative values are displayed as 0 for safety in UI
    int val = int.tryParse(value) ?? 0;
    String displayValue = val < 0 ? "0" : value;

    return Column(
      children: [
        Text(
          displayValue,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.maroon),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMenuTile({required String title, String? subtitle, required IconData icon, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: Colors.grey.shade50,
        leading: Icon(icon, color: AppTheme.maroon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
      ),
    );
  }
}
