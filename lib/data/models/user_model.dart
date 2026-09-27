import 'availability_model.dart';

class UserModel {
  final String uid;
  final String? role; // 'student' or 'tutor'
  final String name;
  final String email;
  final String phoneNumber;
  
  // Student Onboarding Data
  final List<String>? problems;
  final String? learningGoal;
  final String? profession;
  final String? englishLevel;
  final String? preferredTime;
  
  final int walletBalance;
  final int completedSessions;
  final int availableSessions;
  final int remainingDays;
  final String? profilePic;

  // Tutor Specific Data
  final List<String>? expertise;
  final String? bio;
  final String? experience;
  final double? hourlyRate;
  final int defaultSessionDuration; // in minutes (e.g. 25, 30, 45, 60)
  final bool isApproved;
  final double totalEarnings;
  final Map<String, AvailabilityModel>? weeklySchedule;

  UserModel({
    required this.uid,
    this.role,
    this.name = '',
    this.email = '',
    required this.phoneNumber,
    this.problems,
    this.learningGoal,
    this.profession,
    this.englishLevel,
    this.preferredTime,
    this.expertise,
    this.bio,
    this.experience,
    this.hourlyRate,
    this.defaultSessionDuration = 25,
    this.isApproved = false,
    this.totalEarnings = 0.0,
    this.walletBalance = 0,
    this.completedSessions = 0,
    this.availableSessions = 0,
    this.remainingDays = 0,
    this.profilePic,
    this.weeklySchedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'problems': problems,
      'learningGoal': learningGoal,
      'profession': profession,
      'englishLevel': englishLevel,
      'preferredTime': preferredTime,
      'expertise': expertise,
      'bio': bio,
      'experience': experience,
      'hourlyRate': hourlyRate,
      'defaultSessionDuration': defaultSessionDuration,
      'isApproved': isApproved,
      'totalEarnings': totalEarnings,
      'walletBalance': walletBalance,
      'completedSessions': completedSessions,
      'availableSessions': availableSessions,
      'remainingDays': remainingDays,
      'profilePic': profilePic,
      'weeklySchedule': weeklySchedule?.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      role: map['role'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      problems: List<String>.from(map['problems'] ?? []),
      learningGoal: map['learningGoal'],
      profession: map['profession'],
      englishLevel: map['englishLevel'],
      preferredTime: map['preferredTime'],
      expertise: List<String>.from(map['expertise'] ?? []),
      bio: map['bio'],
      experience: map['experience'],
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      defaultSessionDuration: map['defaultSessionDuration'] ?? 25,
      isApproved: map['isApproved'] ?? false,
      totalEarnings: (map['totalEarnings'] ?? 0.0).toDouble(),
      walletBalance: map['walletBalance'] ?? 0,
      completedSessions: map['completedSessions'] ?? 0,
      availableSessions: map['availableSessions'] ?? 0,
      remainingDays: map['remainingDays'] ?? 0,
      profilePic: map['profilePic'],
      weeklySchedule: map['weeklySchedule'] != null
          ? (map['weeklySchedule'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, AvailabilityModel.fromMap(value)),
            )
          : null,
    );
  }

  UserModel copyWith({
    String? role,
    String? name,
    String? email,
    List<String>? problems,
    String? learningGoal,
    String? profession,
    String? englishLevel,
    String? preferredTime,
    List<String>? expertise,
    String? bio,
    String? experience,
    double? hourlyRate,
    int? defaultSessionDuration,
    bool? isApproved,
    double? totalEarnings,
    Map<String, AvailabilityModel>? weeklySchedule,
    String? profilePic,
  }) {
    return UserModel(
      uid: uid,
      phoneNumber: phoneNumber,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      problems: problems ?? this.problems,
      learningGoal: learningGoal ?? this.learningGoal,
      profession: profession ?? this.profession,
      englishLevel: englishLevel ?? this.englishLevel,
      preferredTime: preferredTime ?? this.preferredTime,
      expertise: expertise ?? this.expertise,
      bio: bio ?? this.bio,
      experience: experience ?? this.experience,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      defaultSessionDuration: defaultSessionDuration ?? this.defaultSessionDuration,
      isApproved: isApproved ?? this.isApproved,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      walletBalance: walletBalance,
      completedSessions: completedSessions,
      availableSessions: availableSessions,
      remainingDays: remainingDays,
      profilePic: profilePic ?? this.profilePic,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
    );
  }
}
