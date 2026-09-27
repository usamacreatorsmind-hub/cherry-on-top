import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/tutor_schedule_controller.dart';
import '../../../data/models/availability_model.dart';

class ManageScheduleScreen extends GetView<TutorScheduleController> {
  const ManageScheduleScreen({super.key});

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
          "Manage Schedule",
          style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: AppTheme.maroon),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.days.length,
          itemBuilder: (context, index) {
            String day = controller.days[index];
            AvailabilityModel availability = controller.weeklySchedule[day] ?? AvailabilityModel();
            return _buildDayCard(context, day, availability);
          },
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: controller.saveSchedule,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.maroon,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("Save Schedule", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDayCard(BuildContext context, String day, AvailabilityModel availability) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                day,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              Switch(
                value: availability.isAvailable,
                activeColor: AppTheme.maroon,
                onChanged: (val) {
                  controller.toggleAvailability(day, val);
                  if (val) {
                    _showSetScheduleSheet(context, day, availability);
                  }
                },
              ),
            ],
          ),
          if (!availability.isAvailable)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Not available", style: TextStyle(color: Colors.grey, fontSize: 14)),
            )
          else ...[
            const Divider(),
            InkWell(
              onTap: () => _showSetScheduleSheet(context, day, availability),
              child: Row(
                children: [
                  _buildChip(Icons.access_time, "${availability.startTime} - ${availability.endTime}"),
                  const SizedBox(width: 12),
                  _buildChip(Icons.timer_outlined, "${availability.slotDuration} min/slot"),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  void _showSetScheduleSheet(BuildContext context, String day, AvailabilityModel current) {
    String startTime = current.startTime;
    String endTime = current.endTime;
    int duration = current.slotDuration;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Set Schedule for $day",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.maroon),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(context, "Start Time", startTime, (time) {
                    startTime = time;
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimePicker(context, "End Time", endTime, (time) {
                    endTime = time;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Slot Duration (Minutes)",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: duration,
                      isExpanded: true,
                      items: [15, 25, 30, 45, 60].map((int val) {
                        return DropdownMenuItem<int>(
                          value: val,
                          child: Text("$val mins"),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => duration = val);
                        }
                      },
                    ),
                  ),
                );
              }
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                controller.updateSchedule(day, startTime, endTime, duration);
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.maroon,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Save Schedule", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTimePicker(BuildContext context, String label, String currentTime, Function(String) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        StatefulBuilder(
          builder: (context, setState) {
            return InkWell(
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: int.parse(currentTime.split(":")[0]),
                    minute: int.parse(currentTime.split(":")[1]),
                  ),
                );
                if (picked != null) {
                  String formattedTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                  setState(() => currentTime = formattedTime);
                  onPicked(formattedTime);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 18, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      currentTime,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            );
          }
        ),
      ],
    );
  }
}
