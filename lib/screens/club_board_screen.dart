import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/screens/club_post_create_screen.dart';
import 'package:gnunity/screens/club_post_detail_screen.dart';
import 'package:gnunity/services/firebase_connect.dart';

class ClubBoardScreen extends StatelessWidget {
  final String clubId;
  final String clubName;
  final Map<String, dynamic> currentUser;

  const ClubBoardScreen({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseConnect = firebase_connect();

    return Scaffold(
      appBar: AppBar(
        title: Text(clubName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('clubs')
            .doc(clubId)
            .collection('posts')
            .orderBy('isAnnouncement', descending: true)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('게시글이 없습니다.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var postDoc = snapshot.data!.docs[index];
              var postData = postDoc.data() as Map<String, dynamic>;
              bool isAnnouncement = postData['isAnnouncement'] ?? false;

              // Card를 GestureDetector로 감싸서 '꾹 누르기' 이벤트를 감지
              return GestureDetector(
                onLongPress: () {
                  //  2초 꾹 눌렀을 때 실행될 삭제 로직
                  final authorStudentId = postData['authorStudentId'] ?? '';
                  final currentUserStudentId = currentUser['studentId'] ?? '';

                  // 작성자의 학번과 현재 사용자의 학번이 일치하는지 확인
                  if (authorStudentId == currentUserStudentId) {
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('게시글 삭제'),
                        content: const Text('이 게시물을 정말 삭제하시겠습니까?'),
                        actions: [
                          TextButton(
                            child: const Text('취소'),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                          TextButton(
                            child: const Text('삭제', style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              firebaseConnect.deleteClubPost(
                                clubId: clubId,
                                postId: postDoc.id,
                              );
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isAnnouncement ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
                  child: ListTile(
                    leading: isAnnouncement ? Icon(Icons.error_outline, color: Theme.of(context).colorScheme.primary) : null,
                    title: Text(postData['title'] ?? '제목 없음', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(postData['authorName'] ?? '작성자 미상'),

                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ClubPostDetailScreen(
                            clubId: clubId,
                            postId: postDoc.id,
                            postData: postData,
                            currentUser: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateClubPostScreen(
                clubId: clubId,
                currentUser: currentUser,
              ),
            ),
          );
        },
      ),
    );
  }
}