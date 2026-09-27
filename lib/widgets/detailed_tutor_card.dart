import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_theme.dart';
import '../data/models/tutor_model.dart';
import '../data/models/availability_model.dart';
import '../routes/app_pages.dart';
import '../data/repositories/firestore_repository.dart';
import '../controllers/app_controller.dart';

class DetailedTutorCard extends StatelessWidget {
  final TutorModel tutor;

  const DetailedTutorCard({super.key, required this.tutor});

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
    final FirestoreRepository repository = FirestoreRepository();
    final AppController appController = Get.find<AppController>();
    final studentId = appController.user.value?.uid ?? '';

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.TUTOR_DETAILS, arguments: tutor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Avatar, Info, Heart
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.maroon.withOpacity(0.1), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.maroon.withOpacity(0.05),
                    backgroundImage: (tutor.profilePic != null && tutor.profilePic!.isNotEmpty) 
                        ? NetworkImage(tutor.profilePic!) 
                        : null,
                    child: (tutor.profilePic == null || tutor.profilePic!.isEmpty)
                        ? const Icon(Icons.person, color: AppTheme.maroon, size: 35)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        tutor.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800, 
                          fontSize: 18, 
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                          const SizedBox(width: 2),
                          Text(
                            tutor.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              color: Colors.amber, 
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "(${tutor.sessionsCount}+ sessions)", 
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  stream: repository.isFavourite(studentId, tutor.id),
                  builder: (context, snapshot) {
                    bool isFav = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () => repository.toggleFavouriteTutor(studentId, tutor),
                      icon: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                        color: isFav ? Colors.red : Colors.grey.shade400,
                        size: 28,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    );
                  }
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Expertise Row
            Row(
              children: [
                const Text(
                  "Expertise : ",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: tutor.expertise.map((e) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          e,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppTheme.maroon),
                const SizedBox(width: 8),
                Text(
                  "₹${tutor.hourlyRate} / session",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.maroon),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Bio Text
            Text(
              tutor.bio,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Next availability",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  _getNextAvailability(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.toNamed(Routes.BOOK_TUTOR, arguments: tutor),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.maroon,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      "Book Now",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.toNamed(Routes.TUTOR_DETAILS, arguments: tutor),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.maroon,
                      side: BorderSide(color: AppTheme.maroon.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      "View Profile",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
