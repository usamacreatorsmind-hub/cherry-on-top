import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import 'onboarding_controller.dart';
import '../../routes/app_pages.dart';

class ProfileCompletionScreen extends GetView<OnboardingController> {
  const ProfileCompletionScreen({super.key});

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Complete your profile",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppTheme.maroon, letterSpacing: -0.5),
              ),
              const SizedBox(height: 10),
              Text(
                "Help us personalize your learning experience and find the perfect tutor for you.",
                style: TextStyle(fontSize: 16, color: Colors.black.withOpacity(0.5), fontWeight: FontWeight.w500, height: 1.4),
              ),

              const SizedBox(height: 32),

              Center(
                child: GestureDetector(
                  onTap: () => controller.showImageSourceBottomSheet(),
                  child: Obx(() => Container(
                    height: 120, width: 120,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.maroon.withOpacity(0.2), width: 2),
                      image: controller.profilePicPath.value.isNotEmpty
                          ? DecorationImage(image: FileImage(File(controller.profilePicPath.value)), fit: BoxFit.cover)
                          : null,
                    ),
                    child: controller.profilePicPath.value.isEmpty
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 30, color: AppTheme.maroon),
                              SizedBox(height: 4),
                              Text("Upload", style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          )
                        : null,
                  )),
                ),
              ),

              const SizedBox(height: 32),

              _buildLabel("Full Name"),
              const SizedBox(height: 10),
              _buildTextField(controller: controller.nameController, hint: "Enter Name", icon: Icons.person_outline_rounded),
              const SizedBox(height: 24),

              _buildLabel("Email Address"),
              const SizedBox(height: 10),
              _buildTextField(
                controller: controller.emailController,
                hint: "xyz@example.com",
                keyboardType: TextInputType.emailAddress,
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    if (controller.nameController.text.trim().isNotEmpty && controller.emailController.text.trim().isNotEmpty) {
                      if (controller.selectedRole.value == 'student') {
                        Get.toNamed(Routes.STUDENT_SURVEY);
                      } else {
                        Get.toNamed(Routes.TUTOR_SURVEY);
                      }
                    } else {
                      Get.snackbar(
                        "Information Required",
                        "Please fill in your name and email to proceed",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppTheme.maroon,
                        colorText: Colors.white,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    shadowColor: AppTheme.maroon.withOpacity(0.3),
                  ),
                  child: const Text("Continue", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.black.withOpacity(0.45), letterSpacing: 0.5),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, TextInputType? keyboardType, IconData? icon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: AppTheme.maroon.withOpacity(0.5), size: 22) : null,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
