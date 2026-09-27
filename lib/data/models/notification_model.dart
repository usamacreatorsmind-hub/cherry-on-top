import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String target; // 'student', 'tutor', 'all'

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.target = 'all',
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    Timestamp? ts = map['timestamp'] as Timestamp?;
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      timestamp: ts?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      target: map['target'] ?? 'all',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'body': body,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'target': target,
    };
  }
}
