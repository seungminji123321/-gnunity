import 'package:flutter/material.dart';
import 'package:gnunity/models/user_model.dart';
import 'package:gnunity/screens/board_screen.dart';
import 'package:gnunity/screens/my_club_screen.dart';
import 'package:gnunity/screens/club_search_screen.dart';
import 'package:gnunity/screens/settings_screen.dart';
import 'package:gnunity/widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser; // User 객체 사용
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const BoardScreen(boardTitle: '홍보 게시판'),
      SearchScreen(currentUser: widget.currentUser),
      MyClubScreen(currentUser: widget.currentUser),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'GNUnity'),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: '홍보'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '검색'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: '내 동아리'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}