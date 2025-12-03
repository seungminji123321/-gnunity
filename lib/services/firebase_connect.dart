import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/models/user_model.dart';
import 'package:gnunity/models/post_model.dart';

class FirebaseConnect {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 회원가입 ---
  Future<Map<String, dynamic>?> signUp({
    required String studentId,
    required String password,
    required String name,
  }) async {
    try {
      final existingUser = await _db.collection('users').where('studentId', isEqualTo: studentId).get();
      if (existingUser.docs.isNotEmpty) return null;

      // User 객체 생성 후 toMap()으로 저장
      final newUser = User(
        id: '', // 저장 전이라 ID 없음
        studentId: studentId,
        password: password,
        name: name,
        joinedClubIds: [],
        createdAt: DateTime.now(),
      );

      await _db.collection('users').add(newUser.toMap());
      return newUser.toMap(); // 편의상 Map 반환
    } catch (e) {
      print('회원가입 오류: $e');
      return null;
    }
  }

  // --- 로그인 (User 객체 반환) ---
  Future<User?> login(String studentId, String password) async {
    try {
      final userQuery = await _db.collection('users').where('studentId', isEqualTo: studentId).limit(1).get();
      if (userQuery.docs.isEmpty) return null;

      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();

      if (password == userData['password']) {
        // Map을 User 객체로 변환하여 반환
        return User.fromMap(userData, userDoc.id);
      } else {
        return null;
      }
    } catch (e) {
      print('로그인 오류: $e');
      return null;
    }
  }

  // --- 동아리 가입 ---
  Future<void> joinClub({required String userDocId, required String clubId}) async {
    try {
      await _db.collection('users').doc(userDocId).update({
        'joinedClubIds': FieldValue.arrayUnion([clubId]),
      });
    } catch (e) { print('오류: $e'); }
  }

  // --- 동아리 탈퇴 ---
  Future<void> withdrawFromClub({required String userDocId, required String clubId}) async {
    try {
      await _db.collection('users').doc(userDocId).update({
        'joinedClubIds': FieldValue.arrayRemove([clubId]),
      });
    } catch (e) { print('오류: $e'); }
  }

  // --- 게시물 삭제 ---
  Future<void> deleteClubPost({required String clubId, required String postId}) async {
    try {
      await _db.collection('clubs').doc(clubId).collection('posts').doc(postId).delete();
    } catch (e) { print('오류: $e'); }
  }

  // --- 게시물 생성 (Post 객체 사용) ---
  Future<void> createClubPost({required String clubId, required Post post}) async {
    try {
      await _db.collection('clubs').doc(clubId).collection('posts').add(post.toMap());
    } catch (e) { print('오류: $e'); }
  }
}