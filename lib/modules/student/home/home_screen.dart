import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../widgets/compact_tutor_card.dart';
import '../../../controllers/app_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';
import '../book_trial/book_trial_screen.dart';
import 'home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appController = Get.find<AppController>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Obx(
          () => Row(
            children: [
              Expanded(
                child: Text(
                  "Hey ${appController.userName}!",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                ),
              ),
              Text(DateFormat('d MMM, yyyy').format(DateTime.now()), style: const TextStyle(fontSize: 14, color: Colors.black)),
            ],
          ),
        ),
        const Text(
          "Chase your dream with Cherry on Top!",
          style: TextStyle(fontSize: 13, color: AppTheme.maroon, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        _buildCarouselSlider(),
        const SizedBox(height: 24),
        _buildCompactCardsSection(context),
        const SizedBox(height: 24),
        _buildSectionHeader("Our Expert Tutors"),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.topTutors.isEmpty) {
            return const Text("No tutors available yet.");
          }
          return Column(
            children: [
              ...controller.topTutors.map((tutor) => CompactTutorCard(tutor: tutor)),
              const SizedBox(height: 8),
              SizedBox(
                height: 40,
                child: OutlinedButton(
                  onPressed: () => controller.changeIndex(2),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.maroon.withOpacity(0.1),
                    side: BorderSide(
                      color: AppTheme.maroon.withOpacity(0.1), // light maroon border
                      width: 1,
                    ),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text(
                    "Find more tutors +",
                    style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 32),
        Text(
          "Specialized course for you goals",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),

        const SizedBox(height: 16),
        _buildCategoryList(),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCarouselSlider() {
    return Obx(() {
      if (controller.banners.isEmpty) {
        return const SizedBox.shrink();
      }

      return CarouselSlider(
        options: CarouselOptions(
          height: 160.0,
          autoPlay: true,
          enlargeCenterPage: true,
          aspectRatio: 16 / 9,
          autoPlayInterval: const Duration(seconds: 4),
          viewportFraction: 1.0,
        ),
        items: controller.banners.map((banner) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppTheme.maroon.withOpacity(0.05),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      banner.imageUrl.startsWith('http')
                          ? Image.network(
                              banner.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
                            )
                          : Image.asset(
                              banner.imageUrl.isNotEmpty ? banner.imageUrl : 'assets/listImages/business_english.png',
                              fit: BoxFit.cover,
                            ),
                      if (banner.title.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      if (banner.title.isNotEmpty)
                        Positioned(
                          bottom: 12,
                          left: 16,
                          child: Text(
                            banner.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      );
    });
  }

  Widget _buildCategoryList() {
    final categories = [
      {
        "title": "Business English",
        "image": "assets/listImages/business_english.png",
        "desc": "Stand out in the global business world by mastering the string spoken English for corporate success",
      },
      {
        "title": "Interview Skills",
        "image": "assets/listImages/interview.png",
        "desc": "Master your interview skills. Prepare thoroughly for any interview and secure your dream job.",
      },
      {
        "title": "Conversation",
        "image": "assets/listImages/conversation.png",
        "desc": "Develop language skills for everyday interactions. improving communication at work",
      },
      {
        "title": "Public Speaking",
        "image": "assets/listImages/public.png",
        "desc": "Perfect your public speaking skills to confidently captivate and impact the audience",
      },
      {
        "title": "IELTS Speaking",
        "image": "assets/listImages/IELTS.png",
        "desc": "Achieve a 7+ band score with fluent English and turn dream of going abroad into reality.",
      },
      {
        "title": "Personality Dev",
        "image": "assets/listImages/development.png",
        "desc": "Improve your personally with fluent English and boost your confidence to create a lasting impression.",
      },
    ];

    return SizedBox(
      height: 189,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return _buildCategoryCard(cat["title"] as String, cat["image"] as String, cat["desc"] as String);
        },
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath, String desc) {
    return Container(
      width: Get.width / 1.4,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400, width: 1.2),
        boxShadow: [BoxShadow(color: AppTheme.maroon.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(imagePath, height: 47, width: 47, fit: BoxFit.cover),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(fontSize: 13, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        const Icon(Icons.verified_outlined, color: Colors.green, size: 20),
        const Expanded(child: Divider(indent: 10, endIndent: 10, thickness: 1)),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.maroon),
        ),
        const Expanded(child: Divider(indent: 10, endIndent: 10, thickness: 1)),
        const Icon(Icons.verified_outlined, color: Colors.green, size: 20),
      ],
    );
  }



  Widget _buildCompactCardsSection(BuildContext context) {
    return Column(
      children: [
        // Card 1: Book 1-on-1 Trial
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.maroon.withOpacity(0.2), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.maroon.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppTheme.maroon.withOpacity(0.1),
                    child: const Icon(Icons.person_outline, size: 22, color: AppTheme.maroon),
                  ),
                  const Positioned(
                    top: -4,
                    left: -4,
                    child: Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Book 1-on-1 Trial",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Try for 25 minutes",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Obx(() => ElevatedButton(
                onPressed: () {
                  Get.bottomSheet(
                    const BookTrialScreen(),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.maroon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "Book Now @${controller.trialPrice.value}",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Card 2: Choose your plan (Subscription Plan)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.maroon.withOpacity(0.2), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.maroon.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.maroon.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.workspace_premium, color: AppTheme.maroon, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Choose your plan",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Practice with experts",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.SUBSCRIPTION_PLANS);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.maroon.withOpacity(0.1),
                  foregroundColor: AppTheme.maroon,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium, size: 14, color: AppTheme.maroon),
                    SizedBox(width: 3),
                    Text(
                      "Subscribe",
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
