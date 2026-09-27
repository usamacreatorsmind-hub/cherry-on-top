import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tutor_model.dart';
import '../../../data/repositories/firestore_repository.dart';
import '../../../controllers/app_controller.dart';
import '../../../widgets/detailed_tutor_card.dart';

class FavouriteTutorsScreen extends StatefulWidget {
  const FavouriteTutorsScreen({super.key});

  @override
  State<FavouriteTutorsScreen> createState() => _FavouriteTutorsScreenState();
}

class _FavouriteTutorsScreenState extends State<FavouriteTutorsScreen> {
  final FirestoreRepository _repository = FirestoreRepository();
  final AppController _appController = Get.find<AppController>();

  @override
  Widget build(BuildContext context) {
    String studentId = _appController.user.value?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.maroon),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Favourite Tutors",
          style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<TutorModel>>(
        stream: _repository.getFavouriteTutors(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.maroon));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final tutors = snapshot.data ?? [];

          if (tutors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border_rounded, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 20),
                  Text(
                    "No favourite tutors yet",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Save your preferred tutors here for quick access.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tutors.length,
            itemBuilder: (context, index) {
              return DetailedTutorCard(tutor: tutors[index]);
            },
          );
        },
      ),
    );
  }
}
