import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart'; // share_plus 패키지 import

class ClubPostDetailScreen extends StatefulWidget {
  final String clubId;
  final String postId;
  final Map<String, dynamic> postData;
  final Map<String, dynamic> currentUser;

  const ClubPostDetailScreen({
    super.key,
    required this.clubId,
    required this.postId,
    required this.postData,
    required this.currentUser,
  });

  @override
  State<ClubPostDetailScreen> createState() => _ClubPostDetailScreenState();
}

class _ClubPostDetailScreenState extends State<ClubPostDetailScreen> {
  final _commentController = TextEditingController();

  Future<void> _addComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('clubs').doc(widget.clubId)
        .collection('posts').doc(widget.postId)
        .collection('comments').add({
      'text': commentText,
      'authorName': widget.currentUser['name'],
      'createdAt': Timestamp.now(),
    });

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  Widget buildPeriodWidget() {
    if (widget.postData['startDate'] != null) {
      final startDate = (widget.postData['startDate'] as Timestamp).toDate();
      final endDate = widget.postData['endDate'] != null
          ? (widget.postData['endDate'] as Timestamp).toDate()
          : startDate;

      final periodString = '기간: ${startDate.month}/${startDate.day} ~ ${endDate.month}/${endDate.day}';

      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        child: Text(
          periodString,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.postData['title'] ?? '게시물'),
        // --- ▼▼▼ 공유 버튼 추가 ▼▼▼ ---
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: '공유하기',
            onPressed: () {
              // 공유할 텍스트를 만듭니다.
              final String textToShare =
                  "[GNUnity 공지]\n"
                  "제목: ${widget.postData['title'] ?? '제목 없음'}\n"
                  "내용: ${widget.postData['content'] ?? '내용 없음'}\n\n"
                  "앱에서 확인하기: https://GNUntiyboard.com/post/${widget.postId}"; // 여기에 실제 앱 URL을 넣으면 좋습니다.

              // 휴대폰의 기본 공유 기능을 실행합니다.
              Share.share(textToShare);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 게시물 내용 ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.postData['title'] ?? '제목 없음',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('작성자: ${widget.postData['authorName'] ?? '알 수 없음'}'),
                const Divider(height: 32),
                buildPeriodWidget(),
                Text(widget.postData['content'] ?? '내용 없음'),
              ],
            ),
          ),
          const Divider(thickness: 8),

          // --- 댓글 목록 ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clubs').doc(widget.clubId)
                  .collection('posts').doc(widget.postId)
                  .collection('comments').orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('아직 댓글이 없습니다.'));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var comment = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(comment['text'] ?? ''),
                      subtitle: Text(comment['authorName'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),

          // --- 댓글 입력창 ---
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addComment,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}