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
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://cherry-on-top-8910e.firebasestorage.app');
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

  final List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

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

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 65, // Compressed quality for fast upload and low memory
        maxWidth: 512,
        maxHeight: 512,
      );
      if (image != null) {
        profilePicPath.value = image.path;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to select image: $e", snackPosition: SnackPosition.BOTTOM);
    }
  }

  void showImageSourceBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Select Profile Picture",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF800020)),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF800020).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF800020)),
              ),
              title: const Text("Camera", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Take a new photo using camera"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF800020).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFF800020)),
              ),
              title: const Text("Gallery", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Choose an existing photo from gallery"),
              onTap: () {
                Get.back();
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  void toggleAvailability(String day, bool value) {
    var current = weeklySchedule[day] ?? AvailabilityModel();
    weeklySchedule[day] = current.copyWith(isAvailable: value);
  }

  void updateDaySchedule(String day, String start, String end, int duration) {
    var current = weeklySchedule[day] ?? AvailabilityModel();
    weeklySchedule[day] = current.copyWith(startTime: start, endTime: end, slotDuration: duration, isAvailable: true);
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
      UploadTask uploadTask = ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      rethrow;
    }
  }

  Future<void> completeOnboarding() async {
    try {
      isLoading.value = true;
      String uid = _auth.currentUser?.uid ?? '';
      String phone = _auth.currentUser?.phoneNumber ?? '';

      // Upload profile pic if selected
      String? profilePicUrl = await _uploadProfilePic(uid);

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
        profilePic: profilePicUrl,
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
