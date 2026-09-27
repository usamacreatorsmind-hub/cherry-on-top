import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../controllers/app_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/firestore_repository.dart';
import '../../data/models/session_model.dart';

class TutorDashboardController extends GetxController {
  final appController = Get.find<AppController>();
  final FirestoreRepository _repository = FirestoreRepository();
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://cherry-on-top-8910e.firebasestorage.app');
  final ImagePicker _picker = ImagePicker();

  var currentIndex = 0.obs;
  var isEditing = false.obs;
  var sessions = <SessionModel>[].obs;
  var isLoadingSessions = true.obs;

  // Edit Controllers
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final experienceController = TextEditingController();
  final rateController = TextEditingController();
  var selectedExpertise = <String>[].obs;

  // Profile Picture State
  var profilePicPath = "".obs;
  var isSavingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    _loadSessions();
    // Also listen for changes in user data to keep controllers in sync
    ever(appController.user, (_) {
      _loadInitialData();
      _loadSessions();
    });
  }

  void _loadSessions() {
    final user = appController.user.value;
    if (user != null) {
      sessions.bindStream(_repository.getTutorSessions(user.uid));
      sessions.listen((_) => isLoadingSessions.value = false);
    } else {
      sessions.clear();
      isLoadingSessions.value = false;
    }
  }

  List<SessionModel> get upcomingSessions =>
      sessions.where((s) => s.status == 'upcoming' && s.dateTime.isAfter(DateTime.now())).toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  List<SessionModel> get pastSessions =>
      sessions.where((s) => s.status == 'past' || (s.status == 'upcoming' && s.dateTime.isBefore(DateTime.now()))).toList()
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

  double get totalEarnings => sessions.where((s) => s.status == 'past').fold(0.0, (sum, item) => sum + item.price);

  void _loadInitialData() {
    final user = appController.user.value;
    if (user != null) {
      nameController.text = user.name;
      bioController.text = user.bio ?? '';
      experienceController.text = user.experience ?? '';
      rateController.text = user.hourlyRate?.toString() ?? '0';
      selectedExpertise.assignAll(user.expertise ?? []);
      profilePicPath.value = "";
    }
  }

  void changeIndex(int index) {
    currentIndex.value = index;
    isEditing.value = false;
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.maroon),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppTheme.maroon.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.camera_alt_rounded, color: AppTheme.maroon),
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
                decoration: BoxDecoration(color: AppTheme.maroon.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.photo_library_rounded, color: AppTheme.maroon),
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

  Future<void> completeSession(SessionModel session) async {
    try {
      await _repository.completeSessionAndAddEarnings(session);
      Get.snackbar("Success", "Session marked as completed and earnings updated");
    } catch (e) {
      Get.snackbar("Error", "Failed to update session: $e");
    }
  }

  void toggleEdit() {
    if (isEditing.value) {
      saveProfile();
    }
    isEditing.value = !isEditing.value;
  }

  Future<bool> saveProfile() async {
    try {
      isSavingProfile.value = true;
      final user = appController.user.value;
      if (user != null) {
        String? newProfilePicUrl;
        if (profilePicPath.value.isNotEmpty) {
          newProfilePicUrl = await _uploadProfilePic(user.uid);
        }

        // Create a plain list from RxList to ensure Firestore compatibility
        final expertiseList = selectedExpertise.toList();

        final updatedUser = user.copyWith(
          name: nameController.text.trim(),
          bio: bioController.text.trim(),
          experience: experienceController.text.trim(),
          hourlyRate: double.tryParse(rateController.text.trim()) ?? 0.0,
          expertise: expertiseList,
          profilePic: newProfilePicUrl ?? user.profilePic,
        );

        // 1. Update user private data
        await _repository.createUser(updatedUser);

        // 2. Update tutor public data (crucial for student side)
        await _repository.updateTutorPublicProfile(updatedUser);

        // 3. Reload local data to reflect changes
        await appController.loadUserData(user.uid);
        profilePicPath.value = "";

        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar(
        "Update Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isSavingProfile.value = false;
    }
  }
}
