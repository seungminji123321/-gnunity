import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/services/firebase_connect.dart';

class CreateClubPostScreen extends StatefulWidget {
  final String clubId;
  final Map<String, dynamic> currentUser;
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

  final firebase_connect firebaseconnect = firebase_connect();

  Future<void> _presentDateRangePicker() async {
    final now = DateTime.now();
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  Future<void> _submitPost() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('제목은 필수입니다.')));
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final Map<String, dynamic> postData = {
        'title': _titleController.text,
        'content': _contentController.text,
        'authorName': widget.currentUser['name'],
        'authorStudentId': widget.currentUser['studentId'],
        'createdAt': Timestamp.now(),
        'isAnnouncement': _isAnnouncement,
        // 삼항 연산자로 null 처리 로직도 여기서 수행
        'startDate': _isAnnouncement && _selectedDateRange != null
            ? Timestamp.fromDate(_selectedDateRange!.start)
            : null,
        'endDate': _isAnnouncement && _selectedDateRange != null
            ? Timestamp.fromDate(_selectedDateRange!.end)
            : null,
      };

      
      await firebaseconnect.createClubPost(
        clubId: widget.clubId,
        postData: postData,
      );

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      print("게시물 생성 오류: $e");
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
                  if (!_isAnnouncement) {
                    _selectedDateRange = null;
                  }
                });
              },
            ),

            if (_isAnnouncement)
              ListTile(
                title: const Text('기간 설정 (선택)'),
                subtitle: Text(_selectedDateRange == null
                    ? '설정 안 함'
                    : '${_selectedDateRange!.start.month}/${_selectedDateRange!.start.day} ~ ${_selectedDateRange!.end.month}/${_selectedDateRange!.end.day}'
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: _presentDateRangePicker,
                ),
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

