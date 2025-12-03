import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/models/post_model.dart';
import 'package:gnunity/models/user_model.dart'; // User 모델
import 'package:share_plus/share_plus.dart';

class ClubPostDetailScreen extends StatefulWidget {
  final String clubId;
  final Post post;
  final User currentUser;

  const ClubPostDetailScreen({super.key, required this.clubId, required this.post, required this.currentUser});

  @override
  State<ClubPostDetailScreen> createState() => _ClubPostDetailScreenState();
}

class _ClubPostDetailScreenState extends State<ClubPostDetailScreen> {
  final _commentController = TextEditingController();

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('posts').doc(widget.post.id).collection('comments').add({
      'text': text,
      'authorName': widget.currentUser.name, // User 객체 사용
      'createdAt': Timestamp.now(),
    });
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  Widget buildPeriodWidget() {
    if (widget.post.startDate != null) {
      final startDate = widget.post.startDate!;
      final endDate = widget.post.endDate ?? startDate;
      final periodString = '기간: ${startDate.month}/${startDate.day} ~ ${endDate.month}/${endDate.day}';
      return Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        child: Text(periodString, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share("[GNUnity] ${widget.post.title}\n${widget.post.content}");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.post.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('작성자: ${widget.post.authorName}'),
                const Divider(),
                buildPeriodWidget(),
                Text(widget.post.content),
              ],
            ),
          ),
          const Divider(thickness: 8),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('clubs').doc(widget.clubId).collection('posts').doc(widget.post.id).collection('comments').orderBy('createdAt').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var c = snapshot.data!.docs[index];
                    return ListTile(title: Text(c['text']), subtitle: Text(c['authorName']));
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [Expanded(child: TextField(controller: _commentController)), IconButton(icon: const Icon(Icons.send), onPressed: _addComment)]),
          ),
        ],
      ),
    );
  }
}