import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../controllers/app_controller.dart';
import '../../../controllers/auth_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/firestore_repository.dart';

class ProfileController extends GetxController {
  final appController = Get.find<AppController>();
  final _authController = Get.find<AuthController>();
  final _repository = FirestoreRepository();
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'gs://cherry-on-top-8910e.firebasestorage.app');
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Dropdown Values
  var selectedProfession = "".obs;
  var selectedGoal = "".obs;
  var selectedLevel = "".obs;

  // Profile Picture State
  var profilePicPath = "".obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initValues();
    ever(appController.user, (_) => initValues());
  }

  void initValues() {
    final user = appController.user.value;
    if (user != null) {
      nameController.text = user.name;
      emailController.text = user.email;
      selectedProfession.value = user.profession ?? "Working Professional";
      selectedGoal.value = user.learningGoal ?? "Daily Conversational Skills";
      selectedLevel.value = user.englishLevel ?? "Intermediate";
      profilePicPath.value = "";
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

  Future<bool> saveProfile() async {
    try {
      isLoading.value = true;
      final user = appController.user.value;
      if (user != null) {
        String? newProfilePicUrl;
        if (profilePicPath.value.isNotEmpty) {
          newProfilePicUrl = await _uploadProfilePic(user.uid);
        }

        final updatedUser = user.copyWith(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          profession: selectedProfession.value,
          learningGoal: selectedGoal.value,
          englishLevel: selectedLevel.value,
          profilePic: newProfilePicUrl ?? user.profilePic,
        );

        await _repository.createUser(updatedUser);
        await appController.loadUserData(user.uid);
        profilePicPath.value = "";
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _authController.logout();
  }
}
