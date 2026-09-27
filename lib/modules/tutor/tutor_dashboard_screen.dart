import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/video_call_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_pages.dart';
import '../../data/models/session_model.dart';
import 'tutor_dashboard_controller.dart';
import 'earnings/tutor_earnings_screen.dart';
import '../../controllers/auth_controller.dart';
import '../../../widgets/tutor_bottom_nav.dart';
import 'package:intl/intl.dart';

class TutorDashboardScreen extends GetView<TutorDashboardController> {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [_buildHome(), _buildSchedule(), const TutorEarningsScreen(), _buildProfile(context)];

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        shadowColor: Colors.black.withOpacity(0.05),
        title: Obx(
          () => Text(
            controller.isEditing.value ? "Edit Profile" : "Tutor Dashboard",
            style: const TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        actions: [
          Obx(
            () => controller.currentIndex.value == 3
                ? TextButton(
                    onPressed: () => Get.toNamed(Routes.TUTOR_EDIT_PROFILE),
                    child: const Text(
                      "Edit",
                      style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  )
                : IconButton(
                    onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
                    icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.maroon),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() => screens[controller.currentIndex.value]),
      bottomNavigationBar: Obx(() => TutorBottomNav(currentIndex: controller.currentIndex.value, onTap: controller.changeIndex)),
    );
  }

  Widget _buildHome() {
    return Obx(() {
      final upcoming = controller.upcomingSessions;
      final user = controller.appController.user.value;

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Premium Welcome Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.maroon, AppTheme.darkMaroon],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: AppTheme.maroon.withOpacity(0.25), blurRadius: 15, offset: const Offset(0, 6))],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.maroon.withOpacity(0.1),
                    backgroundImage: (user?.profilePic != null && user!.profilePic!.isNotEmpty) ? NetworkImage(user.profilePic!) : null,
                    child: (user?.profilePic == null || user!.profilePic!.isEmpty)
                        ? const Icon(Icons.person, color: AppTheme.maroon, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [Text("Welcome back", style: TextStyle(fontSize: 14, color: Colors.white70))],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.name ?? 'Tutor',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stat Cards
          Row(
            children: [
              _buildStatCard("Upcoming Sessions", upcoming.length.toString(), Icons.video_call_rounded, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard("Total Earnings", "₹${controller.totalEarnings.toInt()}", Icons.account_balance_wallet_rounded, Colors.green),
            ],
          ),
          const SizedBox(height: 28),

          // Quick View Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Next Sessions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E1E2C)),
              ),
              TextButton(
                onPressed: () => controller.changeIndex(1), // Switch to Schedule tab
                child: const Text(
                  "View All",
                  style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (upcoming.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.event_available_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    "No upcoming sessions booked yet.",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Keep your schedule updated to receive more bookings.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          else
            ...upcoming.take(3).map((session) => _buildUpcomingSessionCard(session, DateFormat('MMM d, hh:mm a').format(session.dateTime))),
        ],
      );
    });
  }

  Widget _buildSchedule() {
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
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              tabs: [
                Tab(text: "Upcoming"),
                Tab(text: "Past"),
              ],
            ),
          ),
          Expanded(child: TabBarView(children: [_buildSessionList(true), _buildSessionList(false)])),
        ],
      ),
    );
  }

  Widget _buildSessionList(bool isUpcoming) {
    return Obx(() {
      if (controller.isLoadingSessions.value) {
        return const Center(child: CircularProgressIndicator(color: AppTheme.maroon));
      }
      final list = isUpcoming ? controller.upcomingSessions : controller.pastSessions;
      if (list.isEmpty) {
        return Center(
          child: Text("No ${isUpcoming ? 'upcoming' : 'past'} sessions found", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final session = list[index];
          return _buildUpcomingSessionCard(
            session,
            "${DateFormat('EEEE, MMM d').format(session.dateTime)} at ${DateFormat('hh:mm a').format(session.dateTime)}",
          );
        },
      );
    });
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSessionCard(SessionModel session, String time) {
    final studentName = session.userName;
    final isUpcoming = session.status == 'upcoming';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.maroon.withOpacity(0.1),
            child: Text(
              studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.maroon, fontSize: 18),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(time, style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUpcoming)
            ElevatedButton(
              onPressed: () => _showSessionActions(session),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.maroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text("Manage", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

  void _showSessionActions(SessionModel session) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Session Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.maroon),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.video_call_rounded, color: Colors.blue),
              ),
              title: const Text("Start Session", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Join video call with student"),
              onTap: () {
                Get.back();
                VideoCallController.instance.makeCall(
                  receiverId: session.userId,
                  receiverName: session.userName,
                  callerName: session.tutorName,
                  durationInMinutes: session.duration,
                  isTutorCalling: true,
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green),
              ),
              title: const Text("Mark as Completed", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Finish session & credit earnings"),
              onTap: () {
                Get.back();
                controller.completeSession(session);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context) {
    return Obx(() {
      final user = controller.appController.user.value;
      if (controller.isEditing.value) {
        return _buildEditProfileForm();
      }
      return _buildProfileView(user);
    });
  }

  Widget _buildProfileView(dynamic user) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: GestureDetector(
            onTap: () => Get.toNamed(Routes.TUTOR_EDIT_PROFILE),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: AppTheme.maroon.withOpacity(0.1),
                  backgroundImage: (user?.profilePic != null && user!.profilePic!.isNotEmpty) ? NetworkImage(user.profilePic!) : null,
                  child: (user?.profilePic == null || user!.profilePic!.isEmpty)
                      ? const Icon(Icons.person, size: 54, color: AppTheme.maroon)
                      : null,
                ),
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.maroon,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                user?.name ?? 'Tutor Name',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(user?.email ?? 'email@example.com', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Profile Info Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection("Professional Bio", user?.bio ?? "No bio added"),
              const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
              _buildInfoSection("Experience", user?.experience ?? "Not specified"),
              const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
              _buildInfoSection("Session Price", "₹${user?.hourlyRate ?? 0} / session"),
              const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1)),
              const Text(
                "Expertise",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (user?.expertise as List<String>? ?? [])
                    .map(
                      (e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppTheme.maroon.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          e,
                          style: const TextStyle(color: AppTheme.maroon, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        ElevatedButton.icon(
          onPressed: () => Get.toNamed(Routes.MANAGE_SCHEDULE),
          icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
          label: const Text("Manage Schedule", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.maroon,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => Get.find<AuthController>().logout(),
          icon: const Icon(Icons.logout_rounded, color: Colors.red),
          label: const Text(
            "Logout",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 54),
            side: BorderSide(color: Colors.red.shade300),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImagePicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => controller.showImageSourceBottomSheet(),
            child: Obx(() {
              final user = controller.appController.user.value;
              final localPath = controller.profilePicPath.value;

              ImageProvider? imageProvider;
              if (localPath.isNotEmpty) {
                imageProvider = FileImage(File(localPath));
              } else if (user?.profilePic != null && user!.profilePic!.isNotEmpty) {
                imageProvider = NetworkImage(user.profilePic!);
              }

              return Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.maroon.withOpacity(0.08),
                      border: Border.all(color: AppTheme.maroon.withOpacity(0.2), width: 3),
                      image: imageProvider != null ? DecorationImage(image: imageProvider, fit: BoxFit.cover) : null,
                    ),
                    child: imageProvider == null ? const Icon(Icons.person, size: 60, color: AppTheme.maroon) : null,
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.maroon,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => controller.showImageSourceBottomSheet(),
            child: const Text(
              "Change Profile Photo",
              style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileForm() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildProfileImagePicker(),
        const SizedBox(height: 24),
        _buildInputField("Full Name", controller.nameController),
        const SizedBox(height: 20),
        _buildInputField("Bio", controller.bioController, maxLines: 4),
        const SizedBox(height: 20),
        _buildInputField("Experience", controller.experienceController),
        const SizedBox(height: 20),
        _buildInputField("Session Price (₹)", controller.rateController, keyboardType: TextInputType.number),
        const SizedBox(height: 24),
        const Text(
          "Expertise",
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.maroon, fontSize: 15),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ["Business English", "IELTS", "Spoken English", "Interview Prep"]
              .map(
                (e) => Obx(() {
                  bool isSelected = controller.selectedExpertise.contains(e);
                  return ChoiceChip(
                    label: Text(e),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) {
                        controller.selectedExpertise.add(e);
                      } else {
                        controller.selectedExpertise.remove(e);
                      }
                    },
                    selectedColor: AppTheme.maroon.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.maroon : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isSelected ? AppTheme.maroon : Colors.grey.shade300),
                    ),
                  );
                }),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, TextEditingController textController, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: textController,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.maroon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.3),
        ),
      ],
    );
  }
}
