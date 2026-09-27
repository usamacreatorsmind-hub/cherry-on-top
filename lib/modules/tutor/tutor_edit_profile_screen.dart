import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_theme.dart';
import 'tutor_dashboard_controller.dart';

class TutorEditProfileScreen extends GetView<TutorDashboardController> {
  const TutorEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.maroon),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Show loading
              Get.dialog(const Center(child: CircularProgressIndicator(color: AppTheme.maroon)), barrierDismissible: false);

              bool success = await controller.saveProfile();

              // Close loading
              Get.back();

              if (success) {
                Get.back(); // Return to dashboard
                Get.snackbar(
                  "Success",
                  "Profile updated successfully",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text(
              "Save",
              style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildProfileImagePicker(),
          const SizedBox(height: 28),
          _buildInputField("Full Name", controller.nameController),
          const SizedBox(height: 20),
          _buildInputField("Bio", controller.bioController, maxLines: 4),
          const SizedBox(height: 20),
          _buildInputField("Experience", controller.experienceController),
          const SizedBox(height: 20),
          _buildInputField("Session Price (₹)", controller.rateController, keyboardType: TextInputType.number),
          const SizedBox(height: 32),
          const Text(
            "Expertise",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.maroon, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ["Business English", "IELTS", "Spoken English", "Interview Prep"].map((e) {
                bool isSelected = controller.selectedExpertise.contains(e);
                return ChoiceChip(
                  label: Text(e),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) {
                      controller.selectedExpertise.add(e);
                    } else {
                      controller.selectedExpertise.remove(e);
                    }
                  },
                  selectedColor: AppTheme.maroon.withOpacity(0.1),
                  checkmarkColor: AppTheme.maroon,
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.maroon : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: isSelected ? AppTheme.maroon : Colors.grey.shade200),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => controller.showImageSourceBottomSheet(),
            child: Obx(() {
              final user = controller.appController.user.value;
              final localPath = controller.profilePicPath.value;

              ImageProvider? imageProvider;
              if (localPath.isNotEmpty) {
                imageProvider = FileImage(File(localPath));
              } else if (user?.profilePic != null && user!.profilePic!.isNotEmpty) {
                imageProvider = NetworkImage(user.profilePic!);
              }

              return Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.maroon.withOpacity(0.08),
                      border: Border.all(color: AppTheme.maroon.withOpacity(0.2), width: 3),
                      image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                    ),
                    child: imageProvider == null ? const Icon(Icons.person, size: 60, color: AppTheme.maroon) : null,
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.maroon,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => controller.showImageSourceBottomSheet(),
            child: const Text(
              "Change Profile Photo",
              style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController textController, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black.withOpacity(0.5), fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.maroon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
