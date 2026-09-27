import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/subscription_plan_model.dart';
import '../../../data/repositories/firestore_repository.dart';

class SubscriptionController extends GetxController {
  final FirestoreRepository _repository = FirestoreRepository();
  
  var isLoading = true.obs;
  var allPlans = <SubscriptionPlanModel>[].obs;
  
  var monthTabs = <String>[].obs;
  var selectedMonth = '3 Month'.obs;
  var currentMonthPlans = <SubscriptionPlanModel>[].obs;
  
  Rxn<SubscriptionPlanModel> selectedPlan = Rxn<SubscriptionPlanModel>();

  var expandedFaqIndex = RxnInt();

  final List<Map<String, dynamic>> faqList = [
    {
      "icon": Icons.access_time_rounded,
      "iconColor": Color(0xFFFFF8E1),
      "iconTint": Color(0xFFF57F17),
      "question": "When can I take the sessions?",
      "answer": "You can schedule your sessions at your flexible timings with your preferred tutors according to your active subscription plan."
    },
    {
      "icon": Icons.people_outline_rounded,
      "iconColor": Color(0xFFFCE4EC),
      "iconTint": Color(0xFF800000),
      "question": "Will I have access to multiple tutor?",
      "answer": "Yes, you have access to multiple expert tutors on EnglishYaari to practice conversation and improve fluency."
    },
    {
      "icon": Icons.calendar_today_rounded,
      "iconColor": Color(0xFFE3F2FD),
      "iconTint": Color(0xFF1565C0),
      "question": "How many classes will I have per week or day?",
      "answer": "Class frequency depends on your selected subscription plan and daily limits. You can book sessions accordingly."
    },
    {
      "icon": Icons.card_giftcard,
      "iconColor": Color(0xFFF3E5F5),
      "iconTint": Color(0xFF7B1FA2),
      "question": "Which subscription plans would be best for me?",
      "answer": "Longer duration plans (like 3 or 6 months) are recommended for consistent practice and faster fluency at the best value."
    },
    {
      "icon": Icons.payment_rounded,
      "iconColor": Color(0xFFE8F5E9),
      "iconTint": Color(0xFF2E7D32),
      "question": "Do you have monthly payment plans or EMI options?",
      "answer": "Yes, we offer flexible payment options and monthly plans so you can choose what fits your budget best."
    },
  ];

  void toggleFaq(int index) {
    if (expandedFaqIndex.value == index) {
      expandedFaqIndex.value = null;
    } else {
      expandedFaqIndex.value = index;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  void fetchPlans() {
    _repository.getSubscriptionPlans().listen((plans) {
      allPlans.assignAll(plans);
      
      final months = plans.map((p) => p.monthKey).toSet().toList();
      months.sort();
      monthTabs.assignAll(months);

      if (months.isNotEmpty && !months.contains(selectedMonth.value)) {
        selectedMonth.value = months.contains('3 Month') ? '3 Month' : months.last;
      }
      
      updateFilteredPlans();
      isLoading.value = false;
    }, onError: (e) {
      isLoading.value = false;
    });
  }

  void changeMonth(String month) {
    selectedMonth.value = month;
    updateFilteredPlans();
  }

  void updateFilteredPlans() {
    final filtered = allPlans.where((p) => p.monthKey == selectedMonth.value).toList();
    currentMonthPlans.assignAll(filtered);
    
    if (filtered.isNotEmpty) {
      final recommended = filtered.firstWhereOrNull((p) => p.isRecommended) ?? filtered.first;
      selectedPlan.value = recommended;
    } else {
      selectedPlan.value = null;
    }
  }

  void selectPlan(SubscriptionPlanModel plan) {
    selectedPlan.value = plan;
  }
}
