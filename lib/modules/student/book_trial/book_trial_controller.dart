import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/repositories/firestore_repository.dart';
import '../../../routes/app_pages.dart';
import '../../../controllers/app_controller.dart';
import 'package:uuid/uuid.dart';

class BookTrialController extends GetxController {
  final appController = Get.find<AppController>();
  final FirestoreRepository _repository = FirestoreRepository();

  var isLoading = true.obs;
  var isBooking = false.obs;
  var tutors = <TutorModel>[].obs;
  var sessions = <SessionModel>[].obs;

  var selectedDate = DateTime.now().obs;
  var dates = <DateTime>[].obs;

  var selectedTimeRange = "08:00 PM - 09:00 PM".obs;
  final List<String> timeRanges = [
    "06:00 AM - 07:00 AM",
    "07:00 AM - 08:00 AM",
    "08:00 AM - 09:00 AM",
    "09:00 AM - 10:00 AM",
    "10:00 AM - 11:00 AM",
    "11:00 AM - 12:00 PM",
    "12:00 PM - 01:00 PM",
    "01:00 PM - 02:00 PM",
    "02:00 PM - 03:00 PM",
    "03:00 PM - 04:00 PM",
    "04:00 PM - 05:00 PM",
    "05:00 PM - 06:00 PM",
    "06:00 PM - 07:00 PM",
    "07:00 PM - 08:00 PM",
    "08:00 PM - 09:00 PM",
    "09:00 PM - 10:00 PM",
    "10:00 PM - 11:00 PM",
    "11:00 PM - 12:00 AM",
  ];

  var selectedFilter = "All Tutors".obs;
  final List<String> filters = ["All Tutors", "Business English", "Interview skills", "Grammar", "Fluency"];

  var selectedTutorId = "".obs;
  var selectedSlotTime = "".obs;

  @override
  void onInit() {
    super.onInit();
    _generateDates();
    _fetchData();
  }

  void _generateDates() {
    final now = DateTime.now();
    for (int i = 0; i < 14; i++) {
      dates.add(now.add(Duration(days: i)));
    }
  }

  void _fetchData() {
    isLoading.value = true;
    tutors.bindStream(_repository.getTutors());

    // Bind sessions for the selected date
    ever(selectedDate, (_) => _bindSessions());
    _bindSessions();

    tutors.listen((_) => isLoading.value = false);
  }

  void _bindSessions() {
    sessions.bindStream(_repository.getSessionsByDate(selectedDate.value));
  }

  List<TutorModel> get filteredTutors {
    List<TutorModel> list = tutors;
    if (selectedFilter.value != "All Tutors") {
      list = tutors.where((t) => t.expertise.contains(selectedFilter.value)).toList();
    }
    return list;
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
  }

  void selectTimeRange(String range) {
    selectedTimeRange.value = range;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void selectSlot(String tutorId, String time) {
    selectedTutorId.value = tutorId;
    selectedSlotTime.value = time;
  }

  void viewTutorProfile(TutorModel tutor) {
    Get.toNamed(Routes.TUTOR_DETAILS, arguments: tutor);
  }

  Future<void> bookTrial() async {
    if (selectedTutorId.value.isEmpty || selectedSlotTime.value.isEmpty) return;

    try {
      isBooking.value = true;
      final user = appController.user.value;
      if (user == null) return;

      final tutor = tutors.firstWhere((t) => t.id == selectedTutorId.value);
      
      // Parse the time from selectedSlotTime "03:00 PM - 03:25 PM"
      String timePart = selectedSlotTime.value.split(' - ')[0];
      TimeOfDay time = _parseTime(timePart);
      
      DateTime sessionDateTime = DateTime(
        selectedDate.value.year,
        selectedDate.value.month,
        selectedDate.value.day,
        time.hour,
        time.minute,
      );

      final sessionId = const Uuid().v4();
      
      final newSession = SessionModel(
        id: sessionId,
        tutorId: tutor.id,
        tutorName: tutor.name,
        userId: user.uid,
        userName: user.name,
        dateTime: sessionDateTime,
        status: 'upcoming',
        price: 0.0, // Trial is usually free
        duration: 25, 
      );

      await _repository.bookSession(newSession);
      
      Get.back();
      Get.snackbar(
        "Success", 
        "Trial session booked successfully with ${tutor.name}",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar("Error", "Failed to book session: $e");
    } finally {
      isBooking.value = false;
    }
  }

  // Generate slots for a specific tutor on the selected date within the selected time range
  List<Map<String, dynamic>> getSlotsForTutor(TutorModel tutor) {
    if (tutor.weeklySchedule == null) return [];

    String dayName = DateFormat('EEEE').format(selectedDate.value);
    final availability = tutor.weeklySchedule![dayName];

    if (availability == null || !availability.isAvailable) return [];

    List<Map<String, dynamic>> slots = [];

    // Parse start and end times
    final startTimeParts = availability.startTime.split(':');
    final endTimeParts = availability.endTime.split(':');

    DateTime startDateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      int.parse(startTimeParts[0]),
      int.parse(startTimeParts[1]),
    );

    DateTime endDateTime = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      int.parse(endTimeParts[0]),
      int.parse(endTimeParts[1]),
    );

    // Filter by selected time range
    final rangeParts = selectedTimeRange.value.split(' - ');
    final rangeStartParts = _parseTime(rangeParts[0]);
    final rangeEndParts = _parseTime(rangeParts[1]);

    DateTime rangeStart = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      rangeStartParts.hour,
      rangeStartParts.minute,
    );

    DateTime rangeEnd = DateTime(
      selectedDate.value.year,
      selectedDate.value.month,
      selectedDate.value.day,
      rangeEndParts.hour,
      rangeEndParts.minute,
    );

    // Effective range is the intersection
    DateTime effectiveStart = startDateTime.isAfter(rangeStart) ? startDateTime : rangeStart;
    DateTime effectiveEnd = endDateTime.isBefore(rangeEnd) ? endDateTime : rangeEnd;

    if (effectiveStart.isAfter(effectiveEnd)) return [];

    DateTime current = effectiveStart;
    final now = DateTime.now();

    while (current.add(Duration(minutes: availability.slotDuration)).isBefore(effectiveEnd) ||
        current.add(Duration(minutes: availability.slotDuration)).isAtSameMomentAs(effectiveEnd)) {
      // Only show slots in the future
      if (current.isAfter(now)) {
        // Check if this slot is reserved
        bool isReserved = sessions.any(
          (s) => s.tutorId == tutor.id && s.dateTime.hour == current.hour && s.dateTime.minute == current.minute && s.status != 'cancelled',
        );

        slots.add({
          'time':
              "${DateFormat('hh:mm a').format(current)} - ${DateFormat('hh:mm a').format(current.add(Duration(minutes: availability.slotDuration)))}",
          'isReserved': isReserved,
          'dateTime': current,
        });
      }

      current = current.add(Duration(minutes: availability.slotDuration));
    }

    return slots;
  }

  TimeOfDay _parseTime(String timeStr) {
    // Format: "08:00 PM"
    final parts = timeStr.split(' ');
    final timeParts = parts[0].split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    final ampm = parts[1];

    if (ampm == "PM" && hour != 12) hour += 12;
    if (ampm == "AM" && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }
}
