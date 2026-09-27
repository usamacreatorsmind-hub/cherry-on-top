part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const OTP = '/otp';
  static const HOME = '/home'; // This will remain as student home or redirect
  static const ROLE_SELECTION = '/role-selection';
  static const PROFILE_COMPLETION = '/profile-completion';
  static const STUDENT_SURVEY = '/student-survey';
  static const TUTOR_SURVEY = '/tutor-survey';

  // Role-based Dashboards
  static const STUDENT_DASHBOARD = '/student-dashboard';
  static const TUTOR_DASHBOARD = '/tutor-dashboard';
  static const TUTOR_EDIT_PROFILE = '/tutor-edit-profile';
  static const MANAGE_SCHEDULE = '/manage-schedule';
  static const TUTOR_DETAILS = '/tutor-details';
  static const BOOK_TUTOR = '/book-tutor';
  static const STUDENT_EDIT_PROFILE = '/student-edit-profile';
  static const VIDEO_CALL = '/video-call';
  static const SETTINGS_MORE = '/settings-more';
  static const FAQS = '/faqs';
  static const SUPPORT = '/support';
  static const FAVOURITE_TUTORS = '/favourite-tutors';
  static const SUBSCRIPTION_PLANS = '/subscription-plans';
  static const REFER_AND_EARN = '/refer-and-earn';
  static const NOTIFICATIONS = '/notifications';
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const OTP = '/otp';
  static const HOME = '/home';
  static const ROLE_SELECTION = '/role-selection';
  static const PROFILE_COMPLETION = '/profile-completion';
  static const STUDENT_SURVEY = '/student-survey';
  static const TUTOR_SURVEY = '/tutor-survey';
  static const STUDENT_DASHBOARD = '/student-dashboard';
  static const TUTOR_DASHBOARD = '/tutor-dashboard';
  static const TUTOR_EDIT_PROFILE = '/tutor-edit-profile';
  static const MANAGE_SCHEDULE = '/manage-schedule';
  static const TUTOR_DETAILS = '/tutor-details';
  static const BOOK_TUTOR = '/book-tutor';
  static const STUDENT_EDIT_PROFILE = '/student-edit-profile';
  static const VIDEO_CALL = '/video-call';
  static const SETTINGS_MORE = '/settings-more';
  static const FAQS = '/faqs';
  static const SUPPORT = '/support';
  static const FAVOURITE_TUTORS = '/favourite-tutors';
  static const SUBSCRIPTION_PLANS = '/subscription-plans';
  static const REFER_AND_EARN = '/refer-and-earn';
  static const NOTIFICATIONS = '/notifications';
}
