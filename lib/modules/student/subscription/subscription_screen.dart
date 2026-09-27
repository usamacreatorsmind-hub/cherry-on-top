import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'subscription_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes/app_pages.dart';

class SubscriptionScreen extends GetView<SubscriptionController> {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      appBar: AppBar(
        backgroundColor: AppTheme.maroon,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Subscription Plans",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: OutlinedButton(
                onPressed: () => Get.toNamed(Routes.BOOK_TUTOR),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white70),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                child: const Text(
                  "Schedule a trial",
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.maroon));
        }

        if (controller.allPlans.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.card_membership_rounded, size: 64, color: AppTheme.maroon),
                  const SizedBox(height: 16),
                  const Text(
                    "No subscription plans available.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please add subscription plans in your Firebase Firestore 'subscription_plans' collection.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("✨", style: TextStyle(fontSize: 14)),
                        const Expanded(child: Divider(indent: 10, endIndent: 10, color: AppTheme.maroon, thickness: 0.5)),
                        const Text(
                          "Select number of month",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.maroon),
                        ),
                        const Expanded(child: Divider(indent: 10, endIndent: 10, color: AppTheme.maroon, thickness: 0.5)),
                        const Text("✨", style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Horizontal Month Tabs
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.monthTabs.length,
                        itemBuilder: (context, index) {
                          final month = controller.monthTabs[index];
                          final isSelected = controller.selectedMonth.value == month;
                          return GestureDetector(
                            onTap: () => controller.changeMonth(month),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.maroon : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? AppTheme.maroon : Colors.grey.shade300,
                                  width: 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [BoxShadow(color: AppTheme.maroon.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  month,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Session Section Header
                    const Text(
                      "Select number of session",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),

                    // Session Plans List
                    Obx(() {
                      return Column(
                        children: controller.currentMonthPlans.map((plan) {
                          final isSelected = controller.selectedPlan.value?.id == plan.id;
                          return GestureDetector(
                            onTap: () => controller.selectPlan(plan),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? AppTheme.maroon : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected ? AppTheme.maroon.withOpacity(0.15) : Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Column(
                                  children: [
                                    if (plan.isRecommended)
                                      Container(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(colors: [AppTheme.maroon, AppTheme.darkMaroon]),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(12),
                                              topRight: Radius.circular(18),
                                            ),
                                          ),
                                          child: const Text(
                                            "RECOMMENDED",
                                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(16, plan.isRecommended ? 4 : 16, 16, 16),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                            color: isSelected ? AppTheme.maroon : Colors.grey,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              "${plan.sessions} Sessions",
                                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                                            ),
                                          ),
                                          Text(
                                            "₹${plan.originalPrice != null && plan.originalPrice! > plan.price ? plan.originalPrice!.toInt() : plan.price.toInt()}",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: plan.originalPrice != null && plan.originalPrice! > plan.price ? Colors.black : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (plan.discountPercentage != null && plan.discountPercentage! > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.maroon,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.card_giftcard, color: Colors.white, size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "Get it today at ₹${plan.price.toInt()} ₹${plan.originalPrice?.toInt() ?? ''}",
                                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            Text(
                                              "${plan.discountPercentage}% Off",
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }),

                    const SizedBox(height: 32),

                    // Most Asked Questions Section Header
                    const Center(
                      child: Text(
                        "Most Asked Questions",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E2C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // FAQ List (Accordion - One open, second closes automatically)
                    Obx(() {
                      return Column(
                        children: List.generate(controller.faqList.length, (index) {
                          final faq = controller.faqList[index];
                          final isExpanded = controller.expandedFaqIndex.value == index;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isExpanded ? AppTheme.maroon.withOpacity(0.5) : Colors.grey.shade200,
                                width: isExpanded ? 1.5 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => controller.toggleFaq(index),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: faq['iconColor'] as Color,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                faq['icon'] as IconData,
                                                color: faq['iconTint'] as Color,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Text(
                                                faq['question'] as String,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                              color: Colors.grey.shade600,
                                            ),
                                          ],
                                        ),
                                        if (isExpanded) ...[
                                          const SizedBox(height: 12),
                                          const Divider(height: 1, color: Colors.black12),
                                          const SizedBox(height: 12),
                                          Text(
                                            faq['answer'] as String,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                    const SizedBox(height: 16),

                    // Check our FAQ's for more queries Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEBFF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFD6CFFC)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Get.snackbar(
                              "FAQs",
                              "Redirecting to more FAQs...",
                              backgroundColor: AppTheme.maroon,
                              colorText: Colors.white,
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Check our FAQ's for more queries",
                                  style: TextStyle(
                                    color: Color(0xFF5B4683),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF5B4683),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Checkout Bar
            Obx(() {
              final plan = controller.selectedPlan.value;
              if (plan == null) return const SizedBox.shrink();

              double original = plan.originalPrice ?? plan.price;
              double finalPrice = plan.price;
              double savings = original > finalPrice ? original - finalPrice : 0;

              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5))],
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (savings > 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "Congrats! You just saved ₹${savings.toInt()}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (original > finalPrice)
                                Text(
                                  "₹${original.toInt()}",
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Row(
                                children: [
                                  Text(
                                    "₹${finalPrice.toInt()}",
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                                  ),
                                  if (plan.discountPercentage != null && plan.discountPercentage! > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.green.shade300),
                                      ),
                                      child: Text(
                                        "Save ${plan.discountPercentage}%",
                                        style: TextStyle(color: Colors.green.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const Text("Excl. of GST", style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Get.snackbar(
                                "Checkout",
                                "Proceeding with ${plan.sessions} Sessions (${plan.monthKey}) for ₹${finalPrice.toInt()}",
                                backgroundColor: AppTheme.maroon,
                                colorText: Colors.white,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.maroon,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text(
                              "Proceed to checkout",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}
