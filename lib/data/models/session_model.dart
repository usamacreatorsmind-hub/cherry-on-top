import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String tutorId;
  final String tutorName;
  final String userId;
  final String userName;
  final DateTime dateTime;
  final String status; // 'upcoming', 'past', 'cancelled'
  final int duration; // in minutes
  final double price;

  SessionModel({
    required this.id,
    required this.tutorId,
    required this.tutorName,
    required this.userId,
    required this.userName,
    required this.dateTime,
    required this.status,
    required this.price,
    this.duration = 25,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutorId': tutorId,
      'tutorName': tutorName,
      'userId': userId,
      'userName': userName,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'duration': duration,
      'price': price,
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    if (map['dateTime'] is Timestamp) {
      parsedDate = (map['dateTime'] as Timestamp).toDate();
    } else if (map['dateTime'] is String) {
      parsedDate = DateTime.tryParse(map['dateTime']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return SessionModel(
      id: map['id'] ?? '',
      tutorId: map['tutorId'] ?? '',
      tutorName: map['tutorName'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Student',
      dateTime: parsedDate,
      status: map['status'] ?? 'upcoming',
      duration: map['duration'] ?? 25,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }
}
