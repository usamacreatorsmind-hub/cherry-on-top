import 'availability_model.dart';

class TutorModel {
  final String id;
  final String name;
  final double rating;
  final int sessionsCount;
  final List<String> expertise;
  final String bio;
  final String emoji;
  final String nextAvailability;
  final String? profilePic;
  final double hourlyRate;
  final Map<String, AvailabilityModel>? weeklySchedule;

  TutorModel({
    required this.id,
    required this.name,
    required this.rating,
    required this.sessionsCount,
    required this.expertise,
    required this.bio,
    required this.emoji,
    required this.nextAvailability,
    this.hourlyRate = 0.0,
    this.profilePic,
    this.weeklySchedule,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'sessionsCount': sessionsCount,
      'expertise': expertise,
      'bio': bio,
      'emoji': emoji,
      'nextAvailability': nextAvailability,
      'hourlyRate': hourlyRate,
      'profilePic': profilePic,
      'weeklySchedule': weeklySchedule?.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  factory TutorModel.fromMap(Map<String, dynamic> map) {
    return TutorModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      sessionsCount: map['sessionsCount'] ?? 0,
      expertise: List<String>.from(map['expertise'] ?? []),
      bio: map['bio'] ?? '',
      emoji: map['emoji'] ?? '👨‍🏫',
      nextAvailability: map['nextAvailability'] ?? '',
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      profilePic: map['profilePic'],
      weeklySchedule: map['weeklySchedule'] != null
          ? (map['weeklySchedule'] as Map<String, dynamic>).map((key, value) => MapEntry(key, AvailabilityModel.fromMap(value)))
          : null,
    );
  }
}
