import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import 'book_trial_controller.dart';
import '../../../data/models/tutor_model.dart';

class BookTrialScreen extends GetView<BookTrialController> {
  const BookTrialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller if not already there
    Get.lazyPut(() => BookTrialController());

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Header handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Choose Date",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                    ),
                    const SizedBox(height: 12),

                    // Date Slider
                    SizedBox(
                      height: 75,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.dates.length,
                        itemBuilder: (context, index) {
                          DateTime date = controller.dates[index];
                          bool isSelected =
                              DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(controller.selectedDate.value);
                          return GestureDetector(
                            onTap: () => controller.selectDate(date),
                            child: _buildDateItem(DateFormat('EEE').format(date), DateFormat('d').format(date), isSelected),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text("In your time zone: Asia/Kolkata (GMT+05:30)", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),

                    const SizedBox(height: 20),
                    const Text(
                      "Choose Time",
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                    ),
                    const SizedBox(height: 10),

                    // Time Range Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: AppTheme.maroon.withOpacity(0.3)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: controller.selectedTimeRange.value,
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.maroon, size: 20),
                          items: controller.timeRanges.map((String range) {
                            return DropdownMenuItem<String>(
                              value: range,
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time, size: 18, color: AppTheme.maroon),
                                  const SizedBox(width: 10),
                                  Text(
                                    range,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.selectTimeRange(val);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: controller.filters.map((filter) {
                          bool isSelected = controller.selectedFilter.value == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(filter, style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              onSelected: (val) => controller.setFilter(filter),
                              selectedColor: AppTheme.maroon.withOpacity(0.1),
                              checkmarkColor: AppTheme.maroon,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              labelStyle: TextStyle(
                                color: isSelected ? AppTheme.maroon : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: isSelected ? AppTheme.maroon : Colors.grey.shade300),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tutor List
                    if (controller.isLoading.value)
                      const Center(
                        child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()),
                      )
                    else if (controller.filteredTutors.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text("No tutors available for this selection.", style: TextStyle(fontSize: 13, color: Colors.grey)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.filteredTutors.length,
                        itemBuilder: (context, index) {
                          return _buildTutorCard(controller.filteredTutors[index]);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Book Now Button
          Obx(() {
            if (controller.selectedSlotTime.value.isEmpty) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: ElevatedButton(
                onPressed: controller.isBooking.value ? null : () => controller.bookTrial(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.maroon,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: controller.isBooking.value
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Book Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateItem(String day, String date, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      width: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.maroon : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppTheme.maroon : Colors.grey.shade100),
        boxShadow: isSelected ? [] : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 2),
          Text(
            date,
            style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorCard(TutorModel tutor) {
    List<Map<String, dynamic>> slots = controller.getSlotsForTutor(tutor);

    // Only show tutors that have slots in this range
    if (slots.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: tutor.profilePic != null
                    ? Image.network(tutor.profilePic!, width: 55, height: 55, fit: BoxFit.cover)
                    : Container(
                        width: 55,
                        height: 55,
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 3),
                        Text(tutor.rating.toString(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => controller.viewTutorProfile(tutor),
                          child: Text(
                            "View Profile",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Select a slot",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: slots.map((slot) {
                return Padding(padding: const EdgeInsets.only(right: 8), child: _buildSlotItem(tutor.id, slot['time'], slot['isReserved']));
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotItem(String tutorId, String text, bool isReserved) {
    return Obx(() {
      bool isSelected = controller.selectedTutorId.value == tutorId && controller.selectedSlotTime.value == text;

      return GestureDetector(
        onTap: isReserved ? null : () => controller.selectSlot(tutorId, text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isReserved ? Colors.grey.shade50 : (isSelected ? AppTheme.maroon.withOpacity(0.05) : Colors.white),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isReserved ? Colors.grey.shade200 : (isSelected ? AppTheme.maroon : Colors.grey.shade200)),
          ),
          child: Center(
            child: Text(
              isReserved ? "Reserved" : text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isReserved ? Colors.grey.shade400 : (isSelected ? AppTheme.maroon : Colors.black87),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 10.5,
              ),
            ),
          ),
        ),
      );
    });
  }
}
