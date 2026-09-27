import 'package:get/get.dart';
import '../modules/splash/splash_screen.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_screen.dart';
import '../modules/otp/otp_binding.dart';
import '../modules/otp/otp_screen.dart';
import '../modules/student/home/home_binding.dart';
import '../modules/student/home/main_navigation_screen.dart';
import '../modules/student/tutors/views/tutor_details_screen.dart';
import '../modules/student/tutors/views/tutor_booking_screen.dart';
import '../modules/student/tutors/tutor_details_controller.dart';
import '../modules/student/profile/student_edit_profile_screen.dart';
import '../modules/student/profile/profile_controller.dart';
import '../modules/student/profile/more_settings_screen.dart';
import '../modules/student/profile/faqs_screen.dart';
import '../modules/student/profile/support_screen.dart';
import '../modules/student/profile/favourite_tutors_screen.dart';
import '../modules/student/subscription/subscription_screen.dart';
import '../modules/student/subscription/subscription_binding.dart';
import '../modules/student/refer_earn/refer_and_earn_screen.dart';
import '../modules/student/refer_earn/refer_and_earn_binding.dart';
import '../modules/student/notifications/notification_screen.dart';
import '../modules/student/notifications/notification_binding.dart';
import '../modules/student/refer_earn/refer_and_earn_binding.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/role_selection_screen.dart';
import '../modules/onboarding/profile_completion_screen.dart';
import '../modules/onboarding/student_survey_screen.dart';
import '../modules/onboarding/tutor_survey_screen.dart';
import '../modules/tutor/tutor_dashboard_binding.dart';
import '../modules/tutor/tutor_edit_profile_screen.dart';
import '../modules/tutor/views/manage_schedule_screen.dart';
import '../modules/tutor/bindings/tutor_schedule_binding.dart';
import '../modules/video_call/video_call_screen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => OTPScreen(phoneNumber: Get.arguments?.toString()),
      binding: OTPBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const MainNavigationScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_DASHBOARD,
      page: () => const MainNavigationScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.TUTOR_DASHBOARD,
      page: () => const MainNavigationScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.TUTOR_EDIT_PROFILE,
      page: () => const TutorEditProfileScreen(),
      binding: TutorDashboardBinding(),
    ),
    GetPage(
      name: _Paths.MANAGE_SCHEDULE,
      page: () => const ManageScheduleScreen(),
      binding: TutorScheduleBinding(),
    ),
    GetPage(
      name: _Paths.TUTOR_DETAILS,
      page: () => const TutorDetailsScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TutorDetailsController>(() => TutorDetailsController());
      }),
    ),
    GetPage(
      name: _Paths.BOOK_TUTOR,
      page: () => const TutorBookingScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<TutorDetailsController>(() => TutorDetailsController());
      }),
    ),
    GetPage(
      name: _Paths.STUDENT_EDIT_PROFILE,
      page: () => const StudentEditProfileScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProfileController>(() => ProfileController());
      }),
    ),
    GetPage(
      name: _Paths.SETTINGS_MORE,
      page: () => const MoreSettingsScreen(),
    ),
    GetPage(
      name: _Paths.FAQS,
      page: () => const FAQsScreen(),
    ),
    GetPage(
      name: _Paths.SUPPORT,
      page: () => const SupportScreen(),
    ),
    GetPage(
      name: _Paths.FAVOURITE_TUTORS,
      page: () => const FavouriteTutorsScreen(),
    ),
    GetPage(
      name: _Paths.SUBSCRIPTION_PLANS,
      page: () => const SubscriptionScreen(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: _Paths.REFER_AND_EARN,
      page: () => const ReferAndEarnScreen(),
      binding: ReferAndEarnBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.ROLE_SELECTION,
      page: () => const RoleSelectionScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_COMPLETION,
      page: () => const ProfileCompletionScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.STUDENT_SURVEY,
      page: () => const StudentSurveyScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.TUTOR_SURVEY,
      page: () => const TutorSurveyScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.VIDEO_CALL,
      page: () => const VideoCallScreen(),
    ),
  ];
}
