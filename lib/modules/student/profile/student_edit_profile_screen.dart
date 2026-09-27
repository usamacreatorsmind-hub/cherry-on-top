import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import 'profile_controller.dart';

class StudentEditProfileScreen extends GetView<ProfileController> {
  const StudentEditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initValues(); // Ensure values are fresh

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
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel("FULL NAME"),
            _buildTextField(controller: controller.nameController, hint: "Enter your name", icon: Icons.person_outline_rounded),
            const SizedBox(height: 24),

            _buildSectionLabel("PROFESSION"),
            _buildDropdown(
              value: controller.selectedProfession,
              items: ["Working Professional", "Student", "Business Owner / Entrepreneur", "Freelancer", "Other"],
              icon: Icons.work_outline_rounded,
            ),
            const SizedBox(height: 24),

            _buildSectionLabel("LEARNING GOAL"),
            _buildDropdown(
              value: controller.selectedGoal,
              items: ["Daily Conversational Skills", "Job Opportunities", "Business Communication", "Live or Work Abroad", "Other"],
              icon: Icons.school,
            ),
            const SizedBox(height: 24),

            _buildSectionLabel("ENGLISH LEVEL"),
            _buildDropdown(
              value: controller.selectedLevel,
              items: ["Beginner", "Intermediate", "Upper Intermediate", "Advanced"],
              icon: Icons.auto_awesome_outlined,
            ),

            _buildSectionLabel("EMAIL ADDRESS"),
            _buildTextField(controller: controller.emailController, hint: "Enter your email", icon: Icons.email_outlined),
            const SizedBox(height: 24),

            _buildSectionLabel("PHONE NUMBER"),
            _buildReadOnlyField(value: controller.appController.user.value?.phoneNumber ?? "", icon: Icons.phone_outlined),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text("Phone number is verified and cannot be changed", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 120), // Space for bottom button
          ],
        ),
      ),
      bottomSheet: _buildSaveButton(),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey.shade400, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F7FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEEBFF)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.maroon.withAlpha(128)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDropdown({required RxString value, required List<String> items, required IconData icon}) {
    return Obx(
      () {
        // Safety: Ensure current value is in the items list to prevent Dropdown crash
        List<String> dropDownItems = List.from(items);
        if (value.value.isNotEmpty && !dropDownItems.contains(value.value)) {
          dropDownItems.add(value.value);
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F7FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEEEBFF)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: value.value.isEmpty ? dropDownItems[0] : value.value,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: AppTheme.maroon.withAlpha(128)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
              items: dropDownItems.map((String item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (val) => value.value = val!,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyField({required String value, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade300),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade400),
          ),
          const Spacer(),
          Icon(Icons.lock_outline_rounded, color: Colors.grey.shade300, size: 20),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () async {
                  bool success = await controller.saveProfile();
                  if (success) {
                    Get.back();
                    Get.snackbar(
                      "Success",
                      "Profile updated successfully!",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.maroon,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: controller.isLoading.value
              ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
