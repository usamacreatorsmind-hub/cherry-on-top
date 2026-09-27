import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/models/availability_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/repositories/firestore_repository.dart';
import '../../../controllers/app_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorDetailsController extends GetxController {
  final FirestoreRepository _repository = FirestoreRepository();
  final appController = Get.find<AppController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TutorModel tutor;
  var selectedDateIndex = 0.obs;
  var selectedSlot = ''.obs;
  var isLoading = false.obs;
  var isFetchingSessions = true.obs;

  List<DateTime> next7Days = [];
  var availableSlots = <String>[].obs;
  var bookedSessions = <SessionModel>[].obs;
  
  // Realtime lists for tutor reviews feedback items mapping
  var reviewsList = <Map<String, dynamic>>[].obs;
  var ratingCounts = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0}.obs;
  var totalReviewsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    tutor = Get.arguments as TutorModel;
    _generateNext7Days();
    _fetchBookedSessions();
    _fetchTutorReviewsList();
  }

  void _fetchTutorReviewsList() {
    _firestore
        .collection('reviews')
        .where('tutorId', isEqualTo: tutor.id)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      var rawReviews = snapshot.docs.map((doc) => doc.data()).toList();
      reviewsList.assignAll(rawReviews);
      totalReviewsCount.value = rawReviews.length;

      // Reset counters metrics
      var temporaryCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (var review in rawReviews) {
        int r = (review['rating'] ?? 5.0).toInt().clamp(1, 5);
        temporaryCounts[r] = (temporaryCounts[r] ?? 0) + 1;
      }
      ratingCounts.value = temporaryCounts;
    });
  }

  void _fetchBookedSessions() {
    _repository.getTutorSessions(tutor.id).listen((sessions) {
      bookedSessions.assignAll(sessions);
      isFetchingSessions.value = false;
      _selectFirstAvailableDate();
    });
  }

  void _generateNext7Days() {
    DateTime now = DateTime.now();
    next7Days.clear();
    for (int i = 0; i < 7; i++) {
      next7Days.add(DateTime(now.year, now.month, now.day).add(Duration(days: i)));
    }
  }

  void _selectFirstAvailableDate() {
    for (int i = 0; i < next7Days.length; i++) {
      if (hasAvailableSlotsForDate(next7Days[i])) {
        selectedDateIndex.value = i;
        _generateSlotsForDate(next7Days[i]);
        return;
      }
    }
    // Default to today if no slots found across next 7 days
    selectedDateIndex.value = 0;
    _generateSlotsForDate(next7Days[0]);
  }

  bool hasAvailableSlotsForDate(DateTime date) {
    String dayName = DateFormat('EEEE').format(date);
    AvailabilityModel? availability = tutor.weeklySchedule?[dayName];

    if (availability == null || !availability.isAvailable) return false;

    DateTime start = _parseTime(date, availability.startTime);
    DateTime end = _parseTime(date, availability.endTime);
    int duration = availability.slotDuration;
    DateTime now = DateTime.now();

    DateTime current = start;
    while (current.add(Duration(minutes: duration)).isBefore(end) || current.add(Duration(minutes: duration)).isAtSameMomentAs(end)) {
      if (current.isAfter(now)) {
        if (!isSlotBooked(current)) {
          return true;
        }
      }
      current = current.add(Duration(minutes: duration));
    }
    return false;
  }

  void onDateSelected(int index) {
    selectedDateIndex.value = index;
    selectedSlot.value = '';
    _generateSlotsForDate(next7Days[index]);
  }

  bool isSlotBooked(DateTime slotTime) {
    return bookedSessions.any(
      (session) =>
          session.dateTime.year == slotTime.year &&
          session.dateTime.month == slotTime.month &&
          session.dateTime.day == slotTime.day &&
          session.dateTime.hour == slotTime.hour &&
          session.dateTime.minute == slotTime.minute &&
          session.status == 'upcoming',
    );
  }

  bool isSlotStringBooked(String slotStr, DateTime date) {
    try {
      String startTimePart = slotStr.split(' - ')[0];
      DateTime startTime = _parseTime12h(date, startTimePart);
      return isSlotBooked(startTime);
    } catch (e) {
      return false;
    }
  }

  void _generateSlotsForDate(DateTime date) {
    availableSlots.clear();
    String dayName = DateFormat('EEEE').format(date);
    AvailabilityModel? availability = tutor.weeklySchedule?[dayName];

    if (availability == null || !availability.isAvailable) return;

    DateTime start = _parseTime(date, availability.startTime);
    DateTime end = _parseTime(date, availability.endTime);
    int duration = availability.slotDuration;
    DateTime now = DateTime.now();

    DateTime current = start;
    while (current.add(Duration(minutes: duration)).isBefore(end) || current.add(Duration(minutes: duration)).isAtSameMomentAs(end)) {
      if (current.isAfter(now)) {
        String startTimeStr = _formatTime12h(DateFormat('HH:mm').format(current));
        String endTimeStr = _formatTime12h(DateFormat('HH:mm').format(current.add(Duration(minutes: duration))));
        availableSlots.add("$startTimeStr - $endTimeStr");
      }

      current = current.add(Duration(minutes: duration));
    }
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

  DateTime _parseTime(DateTime date, String timeStr) {
    final parts = timeStr.split(':');
    return DateTime(date.year, date.month, date.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  DateTime _parseTime12h(DateTime date, String time12h) {
    final parts = time12h.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    final period = parts[1];

    if (period == 'PM' && hour < 12) hour += 12;
    if (period == 'AM' && hour == 12) hour = 0;

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future<void> bookSession() async {
    if (selectedSlot.value.isEmpty) {
      Get.snackbar("Error", "Please select a time slot");
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Get.snackbar("Error", "User not logged in");
      return;
    }

    try {
      isLoading.value = true;
      DateTime selectedDate = next7Days[selectedDateIndex.value];
      String startTimePart = selectedSlot.value.split(' - ')[0];
      DateTime startTime = _parseTime12h(selectedDate, startTimePart);

      if (isSlotBooked(startTime)) {
        Get.snackbar("Slot Unavailable", "This slot has already been booked by another student.");
        isLoading.value = false;
        return;
      }

      final session = SessionModel(
        id: const Uuid().v4(),
        tutorId: tutor.id,
        tutorName: tutor.name,
        userId: currentUser.uid,
        userName: appController.user.value?.name ?? currentUser.displayName ?? 'Student',
        dateTime: startTime,
        status: 'upcoming',
        price: tutor.hourlyRate,
        duration: tutor.weeklySchedule?[DateFormat('EEEE').format(selectedDate)]?.slotDuration ?? 25,
      );

      await _repository.bookSession(session);
      appController.updateWallet(-0);
      
      Get.back();
      Get.snackbar("Success", "Session booked successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
