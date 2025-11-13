import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/screens/post_create_screen.dart'; // 글쓰기 화면 import
//홍보게시판
class BoardScreen extends StatelessWidget {
  final String boardTitle;

  const BoardScreen({super.key, required this.boardTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('promotions')
            .orderBy('createdAt', descending: false)//최근에 만든 게시물이 맨 위로
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
              var postData = snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return Card(// 누르면 글이 펼쳐짐
                margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  title: Text(
                    postData['title'] ?? '제목 없음',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: const Icon(Icons.campaign),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(postData['content'] ?? '내용 없음'),
                            const SizedBox(height: 8),
                            Text(postData['contact'] ?? '연락처 정보 없음'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton( //홍보게시물 작성 버튼
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}