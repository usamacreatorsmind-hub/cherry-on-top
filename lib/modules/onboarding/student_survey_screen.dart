import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'onboarding_controller.dart';
import '../../core/theme/app_theme.dart';

class StudentSurveyScreen extends GetView<OnboardingController> {
  const StudentSurveyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.maroon),
          onPressed: () => controller.previousStep(),
        ),
        title: const Text(
          "Let's find the right tutor for you", 
          style: TextStyle(color: AppTheme.maroon, fontSize: 16, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Obx(() => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        "Step ${controller.currentStep.value} of 5", 
                        style: const TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.w800, fontSize: 12)
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LinearProgressIndicator(
                    value: controller.currentStep.value / 5,
                    backgroundColor: Colors.pink.shade50.withOpacity(0.5),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.maroon),
                    borderRadius: BorderRadius.circular(10),
                    minHeight: 8,
                  ),
                ),
              ],
            )),
            
            Expanded(
              child: Obx(() {
                switch (controller.currentStep.value) {
                  case 1: return _buildStep1();
                  case 2: return _buildStep2();
                  case 3: return _buildStep3();
                  case 4: return _buildStep4();
                  case 5: return _buildStep5();
                  default: return const SizedBox();
                }
              }),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () => controller.nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    shadowColor: AppTheme.maroon.withOpacity(0.3),
                  ),
                  child: Obx(() => Text(
                    controller.currentStep.value == 5 ? "Finish" : "Continue",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return _buildSurveyContent(
      image: "💬",
      question: "Problem faced while\nspeaking English?",
      options: ["Confidence", "Fluency", "Vocabulary", "Sentence Construction"],
      isMultiSelect: true,
      selectedItems: controller.selectedProblems,
      otherController: controller.otherProblem,
    );
  }

  Widget _buildStep2() {
    return _buildSurveyContent(
      image: "🎯",
      question: "What's your learning goal?",
      options: ["Daily Conversational Skills", "Job Opportunities", "Business Communication", "Live or Work Abroad"],
      selectedItem: controller.selectedGoal,
      otherController: controller.otherGoal,
    );
  }

  Widget _buildStep3() {
    return _buildSurveyContent(
      image: "💼",
      question: "What's your profession?",
      options: ["Working Professional", "Student", "Business Owner / Entrepreneur", "Freelancer"],
      selectedItem: controller.selectedProfession,
      otherController: controller.otherProfession,
    );
  }

  Widget _buildStep4() {
    return _buildSurveyContent(
      image: "📊",
      question: "What's your English level?",
      options: ["Beginner", "Intermediate", "Upper Intermediate", "Advanced"],
      selectedItem: controller.selectedLevel,
    );
  }

  Widget _buildStep5() {
    return _buildSurveyContent(
      image: "📅",
      question: "What's your preferred\nsession time?",
      options: ["6 AM - 9 AM", "9 AM - 12 PM", "12 PM - 3 PM", "3 PM - 6 PM", "6 PM - 9 PM"],
      selectedItem: controller.selectedTime,
    );
  }

  Widget _buildSurveyContent({
    required String image,
    required String question,
    required List<String> options,
    bool isMultiSelect = false,
    RxList<String>? selectedItems,
    RxString? selectedItem,
    TextEditingController? otherController,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: Colors.pink.shade50.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(image, style: const TextStyle(fontSize: 70))),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              question,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.maroon, height: 1.2),
            ),
          ),
          const SizedBox(height: 24),
          ...options.map((option) {
            return _buildOptionTile(
              label: option,
              isSelected: isMultiSelect 
                ? selectedItems!.contains(option) 
                : selectedItem!.value == option,
              onTap: () {
                if (isMultiSelect) {
                  if (selectedItems!.contains(option)) {
                    selectedItems.remove(option);
                  } else {
                    selectedItems.add(option);
                  }
                } else {
                  selectedItem!.value = option;
                }
              },
              isCheckbox: isMultiSelect,
            );
          }).toList(),
          if (otherController != null)
            _buildOtherInput(otherController),
        ],
      ),
    );
  }

  Widget _buildOptionTile({required String label, required bool isSelected, required VoidCallback onTap, bool isCheckbox = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade50.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.maroon : Colors.grey.shade100, 
            width: isSelected ? 2 : 1.5
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label, 
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppTheme.maroon : Colors.black87,
                )
              )
            ),
            if (isCheckbox)
              Icon(
                isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, 
                color: isSelected ? AppTheme.maroon : Colors.grey.shade300
              )
            else
              Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded, 
                color: isSelected ? AppTheme.maroon : Colors.grey.shade300
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherInput(TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          hintText: "Something else? Write here",
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
