import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/firestore_repository.dart';

class ReviewFeedbackSheet extends StatefulWidget {
  final String sessionId;
  final String tutorId;
  final String tutorName;
  final String studentId;
  final String studentName;

  const ReviewFeedbackSheet({
    super.key,
    required this.sessionId,
    required this.tutorId,
    required this.tutorName,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<ReviewFeedbackSheet> createState() => _ReviewFeedbackSheetState();
}

class _ReviewFeedbackSheetState extends State<ReviewFeedbackSheet> {
  final FirestoreRepository _repository = FirestoreRepository();
  double _selectedRating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    try {
      await _repository.submitTutorReview(
        sessionId: widget.sessionId,
        tutorId: widget.tutorId,
        studentId: widget.studentId,
        studentName: widget.studentName,
        rating: _selectedRating,
        comment: _commentController.text.trim(),
      );

      Get.back(); // Dismiss bottom sheet
      Get.snackbar(
        "Feedback Submitted",
        "Thank you! Your feedback helps maintain high-quality sessions.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Submission Failed",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final keyboardHeight = mediaQuery.viewInsets.bottom;
        final screenHeight = mediaQuery.size.height;

        // Available height when keyboard is visible
        final availableHeight = screenHeight - keyboardHeight;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,

            // Don't allow the sheet to go behind keyboard
            constraints: BoxConstraints(maxHeight: keyboardHeight > 0 ? availableHeight : screenHeight * 0.80),

            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),

            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,

                // Small bottom spacing only
                bottom: 20,
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),

                  const SizedBox(height: 22),

                  // Title
                  const Text(
                    "Rate Your Session",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.maroon),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "How was your learning experience with ${widget.tutorName}?",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Rating Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.amber.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Tap a star to rate",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final starValue = index + 1.0;

                            final isSelected = _selectedRating >= starValue;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRating = starValue;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: AnimatedScale(
                                  scale: isSelected ? 1.12 : 1.0,
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeOutBack,
                                  child: Icon(
                                    isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                    color: isSelected ? Colors.amber.shade600 : Colors.grey.shade300,
                                    size: 42,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 10),

                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _getRatingDescription(_selectedRating),
                            key: ValueKey(_selectedRating),
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.amber.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Feedback Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Share your feedback",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.grey.shade800),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Text Field
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _commentController,
                      minLines: 3,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: "Write your review here... (Optional)",
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        contentPadding: const EdgeInsets.all(16),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.maroon,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text("Submit Review", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getRatingDescription(double rating) {
    if (rating >= 5.0) return "Excellent! Loved it.";
    if (rating >= 4.0) return "Very Good session.";
    if (rating >= 3.0) return "Average experience.";
    if (rating >= 2.0) return "Below expectations.";
    return "Poor experience.";
  }
}
