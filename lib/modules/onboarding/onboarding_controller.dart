import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/models/tutor_model.dart';
import '../../data/models/availability_model.dart';
import '../../data/repositories/firestore_repository.dart';
import '../../routes/app_pages.dart';
import '../../controllers/app_controller.dart';

class OnboardingController extends GetxController {
  final FirestoreRepository _repository = FirestoreRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Profile Completion
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final referralController = TextEditingController();

  // Onboarding State
  var currentStep = 1.obs;
  var selectedRole = ''.obs; // 'student' or 'tutor'

  // Survey Data
  var selectedProblems = <String>[].obs;
  var otherProblem = TextEditingController();
  
  var selectedGoal = ''.obs;
  var otherGoal = TextEditingController();
  
  var selectedProfession = ''.obs;
  var otherProfession = TextEditingController();
  
  var selectedLevel = ''.obs;
  
  var selectedTime = ''.obs;

  // Tutor Onboarding State
  var tutorCurrentStep = 1.obs;
  var selectedExpertise = <String>[].obs;
  final bioController = TextEditingController();
  final experienceController = TextEditingController();
  final rateController = TextEditingController();
  
  // New: Profile Pic & Schedule
  var profilePicPath = ''.obs;
  var weeklySchedule = <String, AvailabilityModel>{}.obs;
  var isLoading = false.obs;

  final List<String> days = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  @override
  void onInit() {
    super.onInit();
    _initWeeklySchedule();
  }

  void _initWeeklySchedule() {
    for (var day in days) {
      weeklySchedule[day] = AvailabilityModel(isAvailable: false);
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      profilePicPath.value = image.path;
    }
  }

  void toggleAvailability(String day, bool value) {
    var current = weeklySchedule[day] ?? AvailabilityModel();
    weeklySchedule[day] = current.copyWith(isAvailable: value);
  }

  void updateDaySchedule(String day, String start, String end, int duration) {
    var current = weeklySchedule[day] ?? AvailabilityModel();
    weeklySchedule[day] = current.copyWith(
      startTime: start,
      endTime: end,
      slotDuration: duration,
      isAvailable: true,
    );
  }

  void setRole(String role) {
    selectedRole.value = role;
    Get.toNamed(Routes.PROFILE_COMPLETION);
  }

  void nextStep() {
    if (selectedRole.value == 'student') {
      if (currentStep.value < 5) {
        currentStep.value++;
      } else {
        completeOnboarding();
      }
    } else {
      if (tutorCurrentStep.value < 5) {
        tutorCurrentStep.value++;
      } else {
        completeTutorOnboarding();
      }
    }
  }

  void previousStep() {
    if (selectedRole.value == 'student') {
      if (currentStep.value > 1) {
        currentStep.value--;
      } else {
        Get.back();
      }
    } else {
      if (tutorCurrentStep.value > 1) {
        tutorCurrentStep.value--;
      } else {
        Get.back();
      }
    }
  }

  Future<String?> _uploadProfilePic(String uid) async {
    if (profilePicPath.value.isEmpty) return null;
    try {
      File file = File(profilePicPath.value);
      Reference ref = _storage.ref().child('profile_pics').child('$uid.jpg');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? '';
      String phone = _auth.currentUser?.phoneNumber ?? '';

      UserModel user = UserModel(
        uid: uid,
        phoneNumber: phone,
        role: 'student',
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        problems: selectedProblems,
        learningGoal: selectedGoal.value == 'Something else' ? otherGoal.text : selectedGoal.value,
        profession: selectedProfession.value == 'Something else' ? otherProfession.text : selectedProfession.value,
        englishLevel: selectedLevel.value,
        preferredTime: selectedTime.value,
      );

      await _repository.createUser(user);
      await Get.find<AppController>().loadUserData(uid);
      
      Get.offAllNamed(Routes.STUDENT_DASHBOARD);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> completeTutorOnboarding() async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? '';
      String phone = _auth.currentUser?.phoneNumber ?? '';

      // Upload profile pic if selected
      String? profilePicUrl = await _uploadProfilePic(uid);

      UserModel user = UserModel(
        uid: uid,
        phoneNumber: phone,
        role: 'tutor',
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        expertise: selectedExpertise,
        bio: bioController.text.trim(),
        experience: experienceController.text.trim(),
        hourlyRate: double.tryParse(rateController.text.trim()) ?? 0.0,
        // Set default session duration from the first active available day's slot duration if specified
        defaultSessionDuration: weeklySchedule.values
            .firstWhere((element) => element.isAvailable, orElse: () => AvailabilityModel(slotDuration: 25))
            .slotDuration,
        isApproved: false,
        profilePic: profilePicUrl,
        weeklySchedule: weeklySchedule,
      );

      // 1. Save in 'users' collection
      await _repository.createUser(user);

      // 2. Save in 'tutors' collection
      final tutorPublicData = TutorModel(
        id: uid,
        name: user.name,
        rating: 0.0,
        sessionsCount: 0,
        expertise: user.expertise ?? [],
        bio: user.bio ?? '',
        emoji: "👨‍🏫",
        nextAvailability: "New Tutor",
        profilePic: profilePicUrl,
        weeklySchedule: weeklySchedule,
      );
      await _repository.createTutor(tutorPublicData);
      
      await Get.find<AppController>().loadUserData(uid);

      Get.offAllNamed(Routes.TUTOR_DASHBOARD);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    referralController.dispose();
    otherProblem.dispose();
    otherGoal.dispose();
    otherProfession.dispose();
    bioController.dispose();
    experienceController.dispose();
    rateController.dispose();
    super.onClose();
  }
}
