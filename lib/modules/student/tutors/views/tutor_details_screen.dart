import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../tutor_details_controller.dart';
import '../../../../routes/app_pages.dart';
import '../../../../data/repositories/firestore_repository.dart';
import '../../../../controllers/app_controller.dart';

class TutorDetailsScreen extends GetView<TutorDetailsController> {
  const TutorDetailsScreen({super.key});

  double _avgRating(TutorDetailsController c, double fallback) {
    if (c.reviewsList.isEmpty) return fallback;
    final total = c.reviewsList.map((e) => (e['rating'] ?? 0).toDouble()).reduce((a, b) => a + b);
    return total / c.reviewsList.length;
  }

  void _openAllReviewsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AllReviewsSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tutor = controller.tutor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            expandedHeight: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.maroon),
              onPressed: () => Get.back(),
            ),
            title: Text(
              tutor.name,
              style: const TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold),
            ),
            actions: [
              StreamBuilder<bool>(
                stream: FirestoreRepository().isFavourite(Get.find<AppController>().user.value?.uid ?? '', tutor.id),
                builder: (context, snapshot) {
                  bool isFav = snapshot.data ?? false;
                  return IconButton(
                    onPressed: () => FirestoreRepository().toggleFavouriteTutor(Get.find<AppController>().user.value?.uid ?? '', tutor),
                    icon: Icon(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: isFav ? Colors.red : AppTheme.maroon),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white, AppTheme.maroon.withOpacity(0.04)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: [AppTheme.maroon, AppTheme.maroon.withOpacity(0.4)]),
                        ),
                        child: CircleAvatar(
                          radius: 56,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 52,
                            backgroundColor: AppTheme.maroon.withOpacity(0.08),
                            backgroundImage: (tutor.profilePic != null && tutor.profilePic!.isNotEmpty)
                                ? NetworkImage(tutor.profilePic!)
                                : null,
                            child: (tutor.profilePic == null || tutor.profilePic!.isEmpty)
                                ? const Icon(Icons.person, color: AppTheme.maroon, size: 52)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tutor.name,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Obx(() {
                        final avg = _avgRating(controller, tutor.rating);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: Colors.amber.withOpacity(0.12), borderRadius: BorderRadius.circular(24)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                avg.toStringAsFixed(1),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "(${controller.totalReviewsCount.value} reviews)",
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Expertise
                _SectionCard(
                  title: "Expertise",
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tutor.expertise
                        .map(
                          (e) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.maroon.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.maroon.withOpacity(0.15)),
                            ),
                            child: Text(
                              e,
                              style: const TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),

                // Bio
                _SectionCard(
                  title: "About Me",
                  child: Text(tutor.bio, style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.6)),
                ),

                // Ratings & Reviews summary
                _SectionCard(
                  title: "Ratings & Reviews",
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() {
                        final avg = _avgRating(controller, tutor.rating);
                        return Column(
                          children: [
                            Text(
                              avg.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(Icons.star_rounded, size: 18, color: i < avg.round() ? Colors.amber : Colors.grey.shade200),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${controller.totalReviewsCount.value} ratings",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Column(
                          children: List.generate(5, (index) {
                            final starLevel = 5 - index;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    child: Text(
                                      "$starLevel",
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.star_rounded, size: 13, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Obx(() {
                                        final total = controller.totalReviewsCount.value;
                                        final count = controller.ratingCounts[starLevel] ?? 0;
                                        final ratio = total > 0 ? count / total : 0.0;
                                        return TweenAnimationBuilder<double>(
                                          tween: Tween(begin: 0, end: ratio),
                                          duration: const Duration(milliseconds: 500),
                                          builder: (_, value, __) => LinearProgressIndicator(
                                            value: value,
                                            backgroundColor: Colors.grey.shade100,
                                            valueColor: AlwaysStoppedAnimation(
                                              starLevel >= 4
                                                  ? Colors.green.shade400
                                                  : (starLevel >= 3 ? Colors.amber.shade400 : Colors.orange.shade400),
                                            ),
                                            minHeight: 7,
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 22,
                                    child: Obx(
                                      () => Text(
                                        "${controller.ratingCounts[starLevel] ?? 0}",
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),

                // Reviews list — top 5 only, rest in bottom sheet
                _SectionCard(
                  title: "Student Feedback",
                  padded: false,
                  child: Obx(() {
                    final validReviews = controller.reviewsList.where((review) {
                      final comment = review['comment'] ?? '';
                      return comment.trim().isNotEmpty;
                    }).toList();

                    if (validReviews.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(Icons.chat_bubble_outline, color: Colors.grey.shade400, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              "No written reviews yet for this tutor.",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      );
                    }

                    final visibleReviews = validReviews.take(5).toList();
                    final remaining = validReviews.length - visibleReviews.length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: visibleReviews.length,
                          separatorBuilder: (context, index) => Divider(height: 28, color: Colors.grey.shade200),
                          itemBuilder: (context, index) => _ReviewTile(review: visibleReviews[index]),
                        ),
                        if (remaining > 0) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () => _openAllReviewsSheet(context),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.maroon,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "View all $remaining more reviews",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_rounded, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ),

                const SizedBox(height: 110),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: ElevatedButton(
            onPressed: () => Get.toNamed(Routes.BOOK_TUTOR, arguments: tutor),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.maroon,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text("Book Now", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
          ),
        ),
      ),
    );
  }
}

/// Full-screen-ish draggable bottom sheet showing every review.
class _AllReviewsSheet extends StatelessWidget {
  final TutorDetailsController controller;

  const _AllReviewsSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        "All Reviews (${controller.totalReviewsCount.value})",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(Icons.close, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: Obx(() {
                  final validReviews = controller.reviewsList.where((review) {
                    final comment = review['comment'] ?? '';
                    return comment.trim().isNotEmpty;
                  }).toList();

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    itemCount: validReviews.length,
                    separatorBuilder: (context, index) => Divider(height: 28, color: Colors.grey.shade200),
                    itemBuilder: (context, index) => _ReviewTile(review: validReviews[index]),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shared review row widget used both on the main screen and inside the sheet.
class _ReviewTile extends StatelessWidget {
  final dynamic review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final rScore = (review['rating'] ?? 5.0).toDouble();
    final sName = review['studentName'] ?? 'Anonymous';
    final textComment = review['comment'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.maroon.withOpacity(0.1),
              child: Text(
                sName.isNotEmpty ? sName[0].toUpperCase() : 'S',
                style: const TextStyle(fontSize: 13, color: AppTheme.maroon, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                sName,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    rScore.toStringAsFixed(1),
                    style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.star_rounded, size: 12, color: Colors.green.shade700),
                ],
              ),
            ),
          ],
        ),
        if (textComment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 44.0),
            child: Text(textComment, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
          ),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool padded;

  const _SectionCard({required this.title, required this.child, this.padded = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.maroon),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
