import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import '../data/models/tutor_model.dart';
import '../routes/app_pages.dart';

class TutorCard extends StatelessWidget {
  final TutorModel tutor;

  const TutorCard({
    super.key,
    required this.tutor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(tutor.emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutor.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.maroon),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(tutor.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Text("(${tutor.sessionsCount}+ sessions)", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.favorite_border, color: AppTheme.maroon),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: tutor.expertise.map((s) => _buildChip(s.trim())).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            tutor.bio.isNotEmpty ? tutor.bio : "Certified English language trainer helping professionals speak with confidence...",
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.toNamed(Routes.TUTOR_DETAILS, arguments: tutor),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.maroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Book Now"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.toNamed(Routes.TUTOR_DETAILS, arguments: tutor),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.maroon,
                    side: const BorderSide(color: AppTheme.maroon),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("View Profile"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.pink.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppTheme.maroon, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
