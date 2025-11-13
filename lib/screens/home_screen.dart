import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/screens/board_screen.dart';
import 'package:gnunity/screens/my_club_screen.dart';
import 'package:gnunity/screens/club_search_screen.dart';
import 'package:gnunity/screens/settings_screen.dart';
import 'package:gnunity/widgets/custom_app_bar.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget { //하단 바 4개
  final Map<String, dynamic> currentUser; //로그인시 받아온 회원정보
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  final List<StreamSubscription> _subscriptions = [];
  //각 동아리별로 첫 로딩인지 아닌지를 기억하기 위한 지도(Map)
  final Map<String, bool> _isFirstLoadMap = {};

  @override
  void initState() {
    super.initState();
    _pages = [
      BoardScreen(boardTitle: '홍보 게시판'),
      SearchScreen(currentUser: widget.currentUser),
      MyClubScreen(currentUser: widget.currentUser),
      SettingsScreen(),
    ];
    _setupNotificationListeners();
  }
//공지사항 알람 배너
  void _showTopBanner(BuildContext context, String clubName, String postTitle) {
    ScaffoldMessenger.of(context).clearMaterialBanners();
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        padding: const EdgeInsets.all(12),
        content: Text('$clubName에서 새 공지사항이 등록되었습니다: $postTitle'),
        leading: Icon(Icons.campaign, color: Theme.of(context).primaryColor),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 2.0,
        actions: const [SizedBox.shrink()],
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }

  void _setupNotificationListeners() async {//공지사항, 게시물 실시간 연동(감시)
    final List<String> joinedClubIds = List<String>.from(widget.currentUser['joinedClubIds'] ?? []);

    for (String clubId in joinedClubIds) {
      if (clubId.isEmpty) continue;

      final clubDoc = await FirebaseFirestore.instance.collection('clubs').doc(clubId).get();
      final clubName = clubDoc.data()?['name'] ?? '알 수 없는 동아리';

      final subscription = FirebaseFirestore.instance
          .collection('clubs')
          .doc(clubId)
          .collection('posts')
          .snapshots()
          .listen((snapshot) {


        if (_isFirstLoadMap[clubId] ?? true) {

          _isFirstLoadMap[clubId] = false;
          return;
        }


        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final postData = change.doc.data();
            if (postData != null && postData['isAnnouncement'] == true) {

              final authorStudentId = postData['authorStudentId'] ?? '';
              final currentUserStudentId = widget.currentUser['studentId'] ?? '';

              if (authorStudentId != currentUserStudentId) {
                print("다른 사람이 쓴 새 공지사항 감지! 알림 배너를 띄웁니다.");
                if (mounted) {
                  _showTopBanner(context, clubName, postData['title'] ?? '');
                }
              }
            }
          }
        }
      });
      _subscriptions.add(subscription);
    }
  }

  @override
  void dispose() {//메모리 누수 방지
    for (var sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'GNUnity'),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [//하단바 내용
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: '홍보'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: '내 동아리'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}