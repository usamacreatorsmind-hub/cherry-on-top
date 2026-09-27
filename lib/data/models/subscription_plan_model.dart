class SubscriptionPlanModel {
  final String id;
  final String monthKey; // "1 Month", "2 Month", "3 Month"
  final int months;
  final int sessions;
  final double price;
  final double? originalPrice;
  final int? discountPercentage;
  final bool isRecommended;
  final int order;

  SubscriptionPlanModel({
    required this.id,
    required this.monthKey,
    required this.months,
    required this.sessions,
    required this.price,
    this.originalPrice,
    this.discountPercentage,
    this.isRecommended = false,
    this.order = 0,
  });

  factory SubscriptionPlanModel.fromMap(Map<String, dynamic> map, String id) {
    return SubscriptionPlanModel(
      id: id,
      monthKey: map['monthKey'] ?? '1 Month',
      months: map['months'] ?? 1,
      sessions: map['sessions'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      originalPrice: map['originalPrice'] != null ? (map['originalPrice'] as num).toDouble() : null,
      discountPercentage: map['discountPercentage'],
      isRecommended: map['isRecommended'] ?? false,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'monthKey': monthKey,
      'months': months,
      'sessions': sessions,
      'price': price,
      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'isRecommended': isRecommended,
      'order': order,
    };
  }
}
