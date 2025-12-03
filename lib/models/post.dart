import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;              // 게시물 고유 ID
  final String title;           // 제목
  final String content;         // 내용
  final String authorName;      // 작성자 이름
  final String authorStudentId; // 작성자 학번
  final DateTime createdAt;     // 작성 시간
  final bool isAnnouncement;    // 공지사항 여부
  final DateTime? startDate;    // 시작일 (선택)
  final DateTime? endDate;      // 종료일 (선택)

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
}
