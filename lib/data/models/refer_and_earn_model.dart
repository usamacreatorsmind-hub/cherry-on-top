class ReferAndEarnModel {
  final String userId;
  final String referralCode;
  final double walletBalance;
  final int pendingInvites;
  final int successfulInvites;

  ReferAndEarnModel({
    required this.userId,
    required this.referralCode,
    required this.walletBalance,
    required this.pendingInvites,
    required this.successfulInvites,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'referralCode': referralCode,
      'walletBalance': walletBalance,
      'pendingInvites': pendingInvites,
      'successfulInvites': successfulInvites,
    };
  }

  factory ReferAndEarnModel.fromMap(Map<String, dynamic> map) {
    return ReferAndEarnModel(
      userId: map['userId'] ?? '',
      referralCode: map['referralCode'] ?? '',
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      pendingInvites: map['pendingInvites'] ?? 0,
      successfulInvites: map['successfulInvites'] ?? 0,
    );
  }
}
