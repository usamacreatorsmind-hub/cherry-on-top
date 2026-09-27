import 'sessions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/session_model.dart';
import '../../../controllers/video_call_controller.dart';
import '../../../widgets/compact_tutor_card.dart';

class SessionsScreen extends GetView<SessionsController> {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppTheme.maroon,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppTheme.maroon,
              indicatorWeight: 3,
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                Tab(text: "Upcoming"),
                Tab(text: "Past"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSessionList(isUpcoming: true),
                _buildSessionList(isUpcoming: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionList({required bool isUpcoming}) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.maroon));
      }

      final list = isUpcoming ? controller.upcomingSessions : controller.pastSessions;

      if (list.isEmpty) {
        return _buildEmptyState(isUpcoming);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final session = list[index];
          return _buildSessionCard(session, isUpcoming);
        },
      );
    });
  }

  Widget _buildSessionCard(SessionModel session, bool isUpcoming) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.maroon.withOpacity(0.1),
            child: Text(
              session.tutorName.isNotEmpty ? session.tutorName[0].toUpperCase() : 'T',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.maroon, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.tutorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "${DateFormat('EEE, MMM d').format(session.dateTime)} • ${DateFormat('hh:mm a').format(session.dateTime)}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isUpcoming)
            ElevatedButton(
              onPressed: () {
                VideoCallController.instance.makeCall(
                  receiverId: session.tutorId,
                  receiverName: session.tutorName,
                  callerName: session.userName,
                  durationInMinutes: session.duration,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.maroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("Join", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Text(
                "Completed",
                style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    if (!isUpcoming) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text("🙄", style: TextStyle(fontSize: 50)),
              SizedBox(height: 16),
              Text(
                "No past sessions found",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Column(
              children: [
                const Text("🙄", style: TextStyle(fontSize: 45)),
                const SizedBox(height: 12),
                const Text(
                  "You have no upcoming sessions",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                ),
                const SizedBox(height: 6),
                Text(
                  "Book a session with our expert tutors below to get started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Expert Tutors Available",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.maroon),
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.expertTutors.isEmpty) {
              return const Center(child: Text("No expert tutors available right now."));
            }
            return Column(
              children: controller.expertTutors.map((tutor) => CompactTutorCard(tutor: tutor)).toList(),
            );
          }),
        ],
      ),
    );
  }
}
