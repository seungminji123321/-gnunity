import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/models/post_model.dart';
import 'package:gnunity/models/user_model.dart'; // User 모델
import 'package:gnunity/services/firebase_connect.dart';

class CreateClubPostScreen extends StatefulWidget {
  final String clubId;
  final User currentUser; // User 객체 사용
  const CreateClubPostScreen({super.key, required this.clubId, required this.currentUser});

  @override
  State<CreateClubPostScreen> createState() => _CreateClubPostScreenState();
}

class _CreateClubPostScreenState extends State<CreateClubPostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isAnnouncement = false;
  DateTimeRange? _selectedDateRange;
  bool _isLoading = false;
  final FirebaseConnect _firebaseConnect = FirebaseConnect();

  Future<void> _presentDateRangePicker() async {
    final now = DateTime.now();
    final newDateRange = await showDateRangePicker(context: context, firstDate: now, lastDate: DateTime(now.year + 1));
    if (newDateRange != null) setState(() => _selectedDateRange = newDateRange);
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) return;
    setState(() { _isLoading = true; });

    try {
      final newPost = Post(
        id: '',
        title: _titleController.text,
        content: _contentController.text,
        authorName: widget.currentUser.name, // User 객체 사용
        authorStudentId: widget.currentUser.studentId, // User 객체 사용
        createdAt: DateTime.now(),
        isAnnouncement: _isAnnouncement,
        startDate: _isAnnouncement ? _selectedDateRange?.start : null,
        endDate: _isAnnouncement ? _selectedDateRange?.end : null,
      );

      await _firebaseConnect.createClubPost(clubId: widget.clubId, post: newPost);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('동아리 게시물 작성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: '제목')),
            const SizedBox(height: 16),
            TextField(controller: _contentController, decoration: const InputDecoration(labelText: '내용', alignLabelWithHint: true), maxLines: 8),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('공지사항으로 등록'),
              value: _isAnnouncement,
              onChanged: (bool value) {
                setState(() {
                  _isAnnouncement = value;
                  if (!_isAnnouncement) _selectedDateRange = null;
                });
              },
            ),
            if (_isAnnouncement)
              ListTile(
                title: const Text('기간 설정 (선택)'),
                subtitle: Text(_selectedDateRange == null ? '설정 안 함' : '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} ~ ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}'),
                trailing: IconButton(icon: const Icon(Icons.calendar_month), onPressed: _presentDateRangePicker),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitPost,
              child: _isLoading ? const CircularProgressIndicator() : const Text('게시하기'),
            )
          ],
        ),
      ),
    );
  }
}