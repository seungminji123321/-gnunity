import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id; // Firestore 문서 ID
  final String studentId;
  final String password;
  final String name;
  final List<String> joinedClubIds;
  final DateTime createdAt;
  final String? fcmToken;

  User({
    required this.id,
    required this.studentId,
    required this.password,
    required this.name,
    required this.joinedClubIds,
    required this.createdAt,
    this.fcmToken,
  });


  factory User.fromMap(Map<String, dynamic> data, String documentId) {
    return User(
      id: documentId,
      studentId: data['studentId'] ?? '',
      password: data['password'] ?? '',
      name: data['name'] ?? '',
      joinedClubIds: List<String>.from(data['joinedClubIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      fcmToken: data['fcmToken'],
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'password': password,
      'name': name,
      'joinedClubIds': joinedClubIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'fcmToken': fcmToken,
    };
  }
}