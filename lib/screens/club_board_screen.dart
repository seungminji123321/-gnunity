import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/models/post_model.dart';
import 'package:gnunity/models/user_model.dart'; // User 모델
import 'package:gnunity/screens/club_post_create_screen.dart';
import 'package:gnunity/screens/club_post_detail_screen.dart';
import 'package:gnunity/services/firebase_connect.dart';

class ClubBoardScreen extends StatelessWidget {
  final String clubId;
  final String clubName;
  final User currentUser;

  const ClubBoardScreen({super.key, required this.clubId, required this.clubName, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseConnect();

    return Scaffold(
      appBar: AppBar(title: Text(clubName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clubs').doc(clubId).collection('posts').orderBy('isAnnouncement', descending: true).orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('게시글이 없습니다.'));

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var postDoc = snapshot.data!.docs[index];
              // Post 모델로 변환
              var post = Post.fromMap(postDoc.data() as Map<String, dynamic>, postDoc.id);

              return GestureDetector(
                onLongPress: () {
                  // currentUser.studentId 사용
                  if (post.authorStudentId == currentUser.studentId) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('삭제'),
                        content: const Text('삭제하시겠습니까?'),
                        actions: [
                          TextButton(child: const Text('취소'), onPressed: () => Navigator.pop(ctx)),
                          TextButton(
                            child: const Text('삭제', style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              authService.deleteClubPost(clubId: clubId, postId: post.id);
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: post.isAnnouncement ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3) : null,
                  child: ListTile(
                    leading: post.isAnnouncement ? Icon(Icons.error_outline, color: Theme.of(context).colorScheme.primary) : null,
                    title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(post.authorName),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubPostDetailScreen(
                            clubId: clubId,
                            post: post, // Post 객체 전달
                            currentUser: currentUser, // User 객체 전달
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateClubPostScreen(
                clubId: clubId,
                currentUser: currentUser, // User 객체 전달
              ),
            ),
          );
        },
      ),
    );
  }
}