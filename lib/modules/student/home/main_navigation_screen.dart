import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/student_bottom_nav.dart';
import '../../../core/theme/app_theme.dart';
import '../../../controllers/app_controller.dart';
import '../../../routes/app_pages.dart';
import '../sessions/sessions_screen.dart';
import '../tutors/tutors_screen.dart';
import '../profile/profile_screen.dart';
import '../book_trial/book_trial_screen.dart';
import '../../tutor/tutor_dashboard_screen.dart';
import '../../tutor/tutor_dashboard_controller.dart';
import 'home_controller.dart';
import 'home_screen.dart';

class MainNavigationScreen extends GetView<AppController> {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final role = controller.user.value?.role;
      if (role == 'tutor') {
        return const TutorMainNavigationScreen();
      }
      return const StudentMainNavigationScreen();
    });
  }
}

// ---------------------------------------------------------------------------
// STUDENT MAIN NAVIGATION
// ---------------------------------------------------------------------------
class StudentMainNavigationScreen extends GetView<HomeController> {
  const StudentMainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    final List<Widget> screens = [const HomeScreen(), const SessionsScreen(), const TutorsScreen(), const ProfileScreen()];

    return Scaffold(
      backgroundColor: AppTheme.cream,
      extendBody: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: AppTheme.maroon.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset("assets/applogo/app_logo.png", height: 35, width: 35),
                  ),
                ),
                Text(
                  "Cherry On Top",
                  key: ValueKey(controller.currentIndex.value),
                  style: const TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ],
            ),

            actions: [
              GestureDetector(
                onTap: () => Get.toNamed(Routes.REFER_AND_EARN),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: AppTheme.maroon.withOpacity(0.08), borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.maroon, size: 16),
                      const SizedBox(width: 5),
                      Obx(
                        () => Text(
                          "₹${appController.walletBalance}",
                          style: const TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
                    icon: const Icon(Icons.notifications_none_rounded, color: AppTheme.maroon, size: 24),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8A93B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
      body: Obx(() => IndexedStack(index: controller.currentIndex.value, children: screens)),
      bottomNavigationBar: Obx(
        () => StudentBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
          onBookTap: () {
            Get.bottomSheet(const BookTrialScreen(), isScrollControlled: true, backgroundColor: Colors.transparent);
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TUTOR MAIN NAVIGATION
// ---------------------------------------------------------------------------
class TutorMainNavigationScreen extends GetView<TutorDashboardController> {
  const TutorMainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TutorDashboardScreen();
  }
}
