import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../tutor_details_controller.dart';

class TutorBookingScreen extends GetView<TutorDetailsController> {
  const TutorBookingScreen({super.key});

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
          "Select a Slot",
          style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Date", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.maroon)),
              const SizedBox(height: 12),
              _buildDateSelector(),
              const SizedBox(height: 12),
              const Text(
                "In your time zone: Asia/Kolkata (GMT+05:30)",
                style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 20, color: Colors.black87),
                  const SizedBox(width: 8),
                  const Expanded(child: Divider(thickness: 1, endIndent: 10, indent: 10)),
                  const Text("Select your time slot", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Expanded(child: Divider(thickness: 1, endIndent: 10, indent: 10)),
                  const Icon(Icons.access_time, size: 20, color: Colors.black87),
                ],
              ),
              const SizedBox(height: 20),
              _buildSlotGrid(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBookingButton(),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 85,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.next7Days.length,
        itemBuilder: (context, index) {
          DateTime date = controller.next7Days[index];
          return Obx(() {
            bool isSelected = controller.selectedDateIndex.value == index;
            bool hasSlots = controller.hasAvailableSlotsForDate(date);

            return GestureDetector(
              onTap: () => controller.onDateSelected(index),
              child: Stack(
                children: [
                  Container(
                    width: 65,
                    margin: const EdgeInsets.only(right: 12, top: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.maroon
                          : (hasSlots ? Colors.grey.shade50 : Colors.grey.shade100.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.maroon : (hasSlots ? AppTheme.maroon.withOpacity(0.3) : Colors.grey.shade200),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('E').format(date),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white70
                                : (hasSlots ? AppTheme.maroon : Colors.grey),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (hasSlots ? Colors.black87 : Colors.grey.shade400),
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasSlots)
                    Positioned(
                      right: 16,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.greenAccent : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildSlotGrid() {
    return Obx(() {
      if (controller.availableSlots.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(28),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              const Text(
                "No open slots on this date",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                "Please select another date with green indicator dots",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        );
      }

      DateTime selectedDate = controller.next7Days[controller.selectedDateIndex.value];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3.2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
        ),
        itemCount: controller.availableSlots.length,
        itemBuilder: (context, index) {
          String slot = controller.availableSlots[index];
          bool isBooked = controller.isSlotStringBooked(slot, selectedDate);

          return Obx(() {
            bool isSelected = controller.selectedSlot.value == slot;

            if (isBooked) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 6),
                      Text(
                        slot,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GestureDetector(
              onTap: () => controller.selectedSlot.value = slot,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.maroon.withOpacity(0.08) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? AppTheme.maroon : Colors.grey.shade200,
                    width: isSelected ? 2.0 : 1.0,
                  ),
                ),
                child: Center(
                  child: Text(
                    slot,
                    style: TextStyle(
                      color: isSelected ? AppTheme.maroon : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      );
    });
  }

  Widget _buildBookingButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Session time", style: TextStyle(color: Colors.grey, fontSize: 12)),
                Obx(() => Text(
                  controller.selectedSlot.value.isEmpty ? "Select a slot" : controller.selectedSlot.value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                )),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value || controller.selectedSlot.value.isEmpty 
                  ? null 
                  : () => _showBookingConfirmation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.maroon,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Book Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            )),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation() {
    final tutor = controller.tutor;
    final date = controller.next7Days[controller.selectedDateIndex.value];
    final slot = controller.selectedSlot.value;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Confirm Booking",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                ),
              ),
              const SizedBox(height: 20),

              // Tutor Profile Card Preview inside Confirmation
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppTheme.maroon.withOpacity(0.1),
                      backgroundImage: (tutor.profilePic != null && tutor.profilePic!.isNotEmpty)
                          ? NetworkImage(tutor.profilePic!)
                          : null,
                      child: (tutor.profilePic == null || tutor.profilePic!.isEmpty)
                          ? const Icon(Icons.person, color: AppTheme.maroon, size: 28)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tutor.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 2),
                              Text(
                                tutor.rating.toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "(${tutor.sessionsCount}+ sessions)",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                            ],
                          ),
                          if (tutor.bio.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              tutor.bio,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12, height: 1.3),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (tutor.expertise.isNotEmpty) ...[
                const Text("Expertise", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tutor.expertise.map((e) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.maroon.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      e,
                      style: const TextStyle(color: AppTheme.maroon, fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
              ],

              _buildConfirmationItem("Date", DateFormat('EEEE, MMM d, yyyy').format(date), Icons.calendar_today_outlined),
              _buildConfirmationItem("Time Slot", slot, Icons.access_time),
              _buildConfirmationItem("Total Price", "₹${tutor.hourlyRate}", Icons.account_balance_wallet_outlined),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.bookSession();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.maroon,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Confirm & Pay", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildConfirmationItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.maroon.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.maroon, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }
}
