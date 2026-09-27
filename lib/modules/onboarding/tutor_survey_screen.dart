import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'onboarding_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/availability_model.dart';

class TutorSurveyScreen extends GetView<OnboardingController> {
  const TutorSurveyScreen({super.key});

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
          "Set up your Tutor Profile", 
          style: TextStyle(color: AppTheme.maroon, fontSize: 16, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        "Step ${controller.tutorCurrentStep.value} of 5", 
                        style: const TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.w800, fontSize: 12)
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LinearProgressIndicator(
                    value: controller.tutorCurrentStep.value / 5,
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
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.maroon));
                }
                switch (controller.tutorCurrentStep.value) {
                  case 1: return _buildStep1();
                  case 2: return _buildStep2();
                  case 3: return _buildStep3();
                  case 4: return _buildStep4();
                  case 5: return _buildScheduleStep();
                  default: return const SizedBox();
                }
              }),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => controller.nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 8,
                    shadowColor: AppTheme.maroon.withOpacity(0.3),
                  ),
                  child: Text(
                    controller.tutorCurrentStep.value == 5 ? "Finish" : "Continue",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return _buildSurveyContent(
      image: "🎓",
      question: "What is your expertise?",
      options: ["Business English", "IELTS Prep", "Spoken English", "Interview Prep", "Kid's English"],
      isMultiSelect: true,
      selectedItems: controller.selectedExpertise,
    );
  }

  Widget _buildStep2() {
    return _buildInputStep(
      image: "💼",
      question: "Years of Experience",
      hint: "e.g. 5 years of teaching...",
      controller: controller.experienceController,
    );
  }

  Widget _buildStep3() {
    return _buildInputStep(
      image: "📝",
      question: "Write a short Bio",
      hint: "Tell students about your teaching style...",
      controller: controller.bioController,
      maxLines: 4,
    );
  }

  Widget _buildStep4() {
    return _buildInputStep(
      image: "💰",
      question: "Your Session Price (₹)",
      hint: "e.g. 500",
      controller: controller.rateController,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildScheduleStep() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: controller.days.length,
      itemBuilder: (context, index) {
        String day = controller.days[index];
        return Obx(() {
          AvailabilityModel availability = controller.weeklySchedule[day] ?? AvailabilityModel();
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: availability.isAvailable ? AppTheme.maroon.withOpacity(0.3) : Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Switch(
                      value: availability.isAvailable,
                      activeColor: AppTheme.maroon,
                      onChanged: (val) {
                        controller.toggleAvailability(day, val);
                        if (val) {
                          _showTimePicker(context, day, availability);
                        }
                      },
                    ),
                  ],
                ),
                if (availability.isAvailable)
                  InkWell(
                    onTap: () => _showTimePicker(context, day, availability),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            "${_formatTime12h(availability.startTime)} - ${_formatTime12h(availability.endTime)}",
                            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(6)),
                            child: Text("${availability.slotDuration} min", style: TextStyle(fontSize: 11, color: Colors.blue.shade900, fontWeight: FontWeight.w800)),
                          ),
                          const Spacer(),
                          const Icon(Icons.edit, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  String _formatTime12h(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return "${hour12.toString().padLeft(2, '0')}:$minute $period";
    } catch (e) {
      return time24;
    }
  }

  void _showTimePicker(BuildContext context, String day, AvailabilityModel current) {
    String start = current.startTime;
    String end = current.endTime;
    int duration = current.slotDuration;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Set Hours for $day", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.maroon)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _timeField(context, "Start Time", start, (t) => start = t)),
                const SizedBox(width: 16),
                Expanded(child: _timeField(context, "End Time", end, (t) => end = t)),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Slot Duration", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StatefulBuilder(builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: duration,
                    isExpanded: true,
                    items: [15, 25, 30, 45, 60].map((int val) {
                      return DropdownMenuItem<int>(value: val, child: Text("$val minutes per session"));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => duration = val);
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                controller.updateDaySchedule(day, start, end, duration);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.maroon,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Save Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _timeField(BuildContext context, String label, String current, Function(String) onPick) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        StatefulBuilder(builder: (context, setState) {
          return InkWell(
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(hour: int.parse(current.split(":")[0]), minute: int.parse(current.split(":")[1])),
              );
              if (picked != null) {
                String formatted = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                setState(() => current = formatted);
                onPick(formatted);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(_formatTime12h(current), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSurveyContent({
    required String image,
    required String question,
    required List<String> options,
    bool isMultiSelect = false,
    RxList<String>? selectedItems,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            height: 120, width: 140,
            decoration: BoxDecoration(color: Colors.pink.shade50.withOpacity(0.3), shape: BoxShape.circle),
            child: Center(child: Text(image, style: const TextStyle(fontSize: 60))),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.maroon)),
          ),
          const SizedBox(height: 24),
          ...options.map((option) => _buildOptionTile(
            label: option,
            isSelected: selectedItems?.contains(option) ?? false,
            onTap: () {
              if (selectedItems == null) return;
              if (selectedItems.contains(option)) {
                selectedItems.remove(option);
              } else {
                selectedItems.add(option);
              }
            },
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildInputStep({required String image, required String question, required String hint, required TextEditingController controller, int maxLines = 1, TextInputType? keyboardType}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            height: 120, width: 140,
            decoration: BoxDecoration(color: Colors.pink.shade50.withOpacity(0.3), shape: BoxShape.circle),
            child: Center(child: Text(image, style: const TextStyle(fontSize: 60))),
          ),
          const SizedBox(height: 32),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(question, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.maroon)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade100, width: 1.5),
            ),
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: const TextStyle(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? Colors.pink.shade50.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? AppTheme.maroon : Colors.grey.shade100, width: 2),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600, color: isSelected ? AppTheme.maroon : Colors.black87))),
            Icon(isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded, color: isSelected ? AppTheme.maroon : Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
