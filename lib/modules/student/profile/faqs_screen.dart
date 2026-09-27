import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';

class FAQsScreen extends StatelessWidget {
  const FAQsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          "Frequently Asked Questions",
          style: TextStyle(color: AppTheme.maroon, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFaqItem(
            question: "What can I take in a session?",
            answer:
                "You can discuss anything related to English learning, including spoken English, grammar, interview preparation, or business communication. Our tutors are here to help you achieve your specific learning goals.",
          ),
          _buildFaqItem(
            question: "How many classes will I have per week or day?",
            answer:
                "The number of classes depends entirely on your chosen plan and tutor availability. You can book as many sessions as your available credits allow each week.",
          ),
          _buildFaqItem(
            question: "How to cancel your booked session?",
            answer:
                "You can cancel a session from the 'Upcoming Sessions' tab on your dashboard. Please note that cancellations must be made at least 2 hours before the start time to receive a full credit refund.",
          ),
          _buildFaqItem(
            question: "What happens if I missed my booked session?",
            answer:
                "If you miss a session without cancelling in advance, the session will be marked as completed and the credit will be deducted. We recommend joining at least 2 minutes before the session starts.",
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ExpansionTile(
        shape: const Border(), // Removes default border when expanded
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        expandedAlignment: Alignment.topLeft,
        childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 15),
        ),
        iconColor: AppTheme.maroon,
        collapsedIconColor: Colors.grey,
        children: [Text(answer, style: TextStyle(color: Colors.grey.shade700, fontSize: 14, height: 1.5))],
      ),
    );
  }
}
