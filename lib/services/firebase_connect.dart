import 'package:cloud_firestore/cloud_firestore.dart';
/// Firebase Firestore와의 모든 통신을 전담하는 서비스 클래스

class firebase_connect {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
// Firestore 데이터베이스 인스턴스에 접근
  Future<Map<String, dynamic>?> signUp({
    required String studentId,
    required String password,
    required String name,
  }) async {
    try {// 1. 이미 가입된 학번인지 확인
      final existingUser = await _db.collection('users').where('studentId', isEqualTo: studentId).get();
      if (existingUser.docs.isNotEmpty) {
        return null;// 이미 학번이 존재하면 null 반환
      }
      // 2. 저장할 사용자 데이터 생성
      final userData = {
        'studentId': studentId,
        'password': password,
        'name': name,
        'joinedClubIds': [],
        'createdAt': Timestamp.now(),
      };// 3. 'users' 컬렉션에 데이터 추가
      await _db.collection('users').add(userData);
      return userData;
    } catch (e) {
      print('회원가입 중 오류 발생: $e');
      return null;
    }
  }
//로그인
  Future<Map<String, dynamic>?> login(String studentId, String password) async {
    try {
      final userQuery = await _db.collection('users').where('studentId', isEqualTo: studentId).limit(1).get();
      if (userQuery.docs.isEmpty) {//학번
        return null;
      }
      final userDoc = userQuery.docs.first;
      final userData = userDoc.data();
      if (password == userData['password']) {//비밀번호 비교
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


//동아리 가입
  Future<void> joinClub({
    required String userDocId,
    required String clubId,
  }) async {
    try {
      await _db.collection('users').doc(userDocId).update({
        'joinedClubIds': FieldValue.arrayUnion([clubId]),
      });

    } catch (e) {
      print('동아리 가입 처리 중 오류: $e');
    }
  }
//동아리 탈퇴
  Future<void> withdrawFromClub({
    required String userDocId,
    required String clubId,
  }) async {
    try {
      await _db.collection('users').doc(userDocId).update({
        'joinedClubIds': FieldValue.arrayRemove([clubId]),
      });

    } catch (e) {
      print('탈퇴 처리 중 오류: $e');
    }
  }
//동아리 게시물 삭제
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
    } catch (e) {
      print('게시물 삭제 중 오류: $e');
    }
  }
}