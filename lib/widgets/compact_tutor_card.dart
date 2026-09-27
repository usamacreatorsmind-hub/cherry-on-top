import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../data/models/tutor_model.dart';
import '../data/models/availability_model.dart';
import '../routes/app_pages.dart';

class CompactTutorCard extends StatelessWidget {
  final TutorModel tutor;

  const CompactTutorCard({super.key, required this.tutor});

  String _getNextAvailability() {
    if (tutor.weeklySchedule == null || tutor.weeklySchedule!.isEmpty) {
      return "No slots set";
    }

    DateTime now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      DateTime date = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      String dayName = DateFormat('EEEE').format(date);
      AvailabilityModel? availability = tutor.weeklySchedule![dayName];

      if (availability != null && availability.isAvailable) {
        // Generate slots for this day
        DateTime start = _parseTime(date, availability.startTime);
        DateTime end = _parseTime(date, availability.endTime);
        int duration = availability.slotDuration;

        DateTime current = start;
        while (current.add(Duration(minutes: duration)).isBefore(end) || 
               current.add(Duration(minutes: duration)).isAtSameMomentAs(end)) {
          
          if (current.isAfter(now)) {
            return "${_formatTime12h(DateFormat('HH:mm').format(current))} ${DateFormat('MMM d').format(date)}";
          }
          current = current.add(Duration(minutes: duration));
        }
      }
    }
    return "No slots this week";
  }

  DateTime _parseTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatTime12h(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return "$hour12:$minute $period";
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.TUTOR_DETAILS, arguments: tutor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.maroon.withOpacity(0.1),
                  backgroundImage: (tutor.profilePic != null && tutor.profilePic!.isNotEmpty) 
                      ? NetworkImage(tutor.profilePic!) 
                      : null,
                  child: (tutor.profilePic == null || tutor.profilePic!.isEmpty)
                      ? const Icon(Icons.person, color: AppTheme.maroon, size: 30)
                      : null,
                ),
                const SizedBox(width: 12),
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
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            tutor.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "(${tutor.sessionsCount}+ sessions)", 
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Next availability", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      _getNextAvailability(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.BOOK_TUTOR, arguments: tutor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.maroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                  child: const Text("Book Now", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
