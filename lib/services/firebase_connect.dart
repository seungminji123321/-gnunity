import 'package:cloud_firestore/cloud_firestore.dart';

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
      if (existingUser.docs.isNotEmpty) {
        return null;
      }
      final userData = {
        'studentId': studentId,
        'password': password,
        'name': name,
        'joinedClubIds': [],
        'createdAt': Timestamp.now(),
      };
      await _db.collection('users').add(userData);
      return userData;
    } catch (e) {
      print('회원가입 중 오류 발생: $e');
      return null;
    }
  }

  // --- 로그인 ---
  Future<Map<String, dynamic>?> login(String studentId, String password) async {
    try {
      final userQuery = await _db.collection('users').where('studentId', isEqualTo: studentId).limit(1).get();
      if (userQuery.docs.isEmpty) {
        return null;
      }
      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();
      if (password == userData['password']) {
        userData['id'] = userDoc.id;
        return userData;
      } else {
        return null;
      }
    } catch (e) {
      print('로그인 중 오류 발생: $e');
      return null;
    }
  }

  // --- 동아리 가입 ---
  Future<void> joinClub({
    required String userDocId,
    required String clubId,
  }) async {
    try {
      await _db.collection('users').doc(userDocId).update({
        'joinedClubIds': FieldValue.arrayUnion([clubId]),
      });
      print('동아리 가입 처리 완료: User($userDocId) -> Club($clubId)');
    } catch (e) {
      print('동아리 가입 처리 중 오류: $e');
    }
  }

  // --- 동아리 탈퇴 ---
  Future<void> withdrawFromClub({
    required String userDocId,
    required String clubId,
  }) async {
    try {
      await _db.collection('users').doc(userDocId).update({
        'joinedClubIds': FieldValue.arrayRemove([clubId]),
      });
      print('동아리 탈퇴 처리 완료');
    } catch (e) {
      print('탈퇴 처리 중 오류: $e');
    }
  }

  // --- 동아리 게시물 삭제 ---
  Future<void> deleteClubPost({
    required String clubId,
    required String postId,
  }) async {
    try {
      await _db
          .collection('clubs')
          .doc(clubId)
          .collection('posts')
          .doc(postId)
          .delete();
      print('게시물 삭제 완료: Post($postId)');
    } catch (e) {
      print('게시물 삭제 중 오류: $e');
    }
  }

  // 동아리 게시물 생성 
  Future<void> createClubPost({
    required String clubId,
    required Map<String, dynamic> postData,
  }) async {
    try {
      await _db
          .collection('clubs')
          .doc(clubId)
          .collection('posts')
          .add(postData);
      print('게시물 생성 완료');
    } catch (e) {
      print('게시물 생성 중 오류: $e');
    }
  }
}
