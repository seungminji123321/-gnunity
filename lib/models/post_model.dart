import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final String authorStudentId;
  final DateTime createdAt;
  final bool isAnnouncement;
  final DateTime? startDate;
  final DateTime? endDate;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorStudentId,
    required this.createdAt,
    required this.isAnnouncement,
    this.startDate,
    this.endDate,
  });

  factory Post.fromMap(Map<String, dynamic> data, String documentId) {
    return Post(
      id: documentId,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorName: data['authorName'] ?? '알 수 없음',
      authorStudentId: data['authorStudentId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isAnnouncement: data['isAnnouncement'] ?? false,
      startDate: data['startDate'] != null ? (data['startDate'] as Timestamp).toDate() : null,
      endDate: data['endDate'] != null ? (data['endDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorName': authorName,
      'authorStudentId': authorStudentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAnnouncement': isAnnouncement,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    };
  }
}