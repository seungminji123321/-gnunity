import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/screens/club_board_screen.dart';
import 'package:gnunity/services/firebase_connect.dart';
import 'package:gnunity/screens/Calendar_screen.dart';
// '내 동아리' 탭 메인 화면 (달력 + 동아리 목록
class MyClubScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const MyClubScreen({super.key, required this.currentUser});

  @override
  State<MyClubScreen> createState() => _MyClubScreenState();
}

class _MyClubScreenState extends State<MyClubScreen> {
  final firebase_connect _firebase_connect = firebase_connect();
  // 달력 위젯을 새로고침하기 위한 GlobalKey
  final GlobalKey<CalendarScreenState> _calendarKey = GlobalKey<CalendarScreenState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // --- 상단: 새로 만든 달력 위젯 ---
          CalendarScreen(
              key: _calendarKey, // 위젯에 Key를 부여
              currentUser: widget.currentUser
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(thickness: 4, color: Colors.grey),
          ),

          // --- 하단: 가입한 동아리 목록 ---
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(widget.currentUser['id']).snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Center(child: Text('사용자 정보를 찾을 수 없습니다.'));
              }

              final updatedUserData = userSnapshot.data!.data() as Map<String, dynamic>;
              final List<String> joinedClubIds = List<String>.from(updatedUserData['joinedClubIds'] ?? []).where((id) => id.isNotEmpty).toList();

              if (joinedClubIds.isEmpty) {
                return const Center(child: Text('가입한 동아리가 없습니다.'));
              }

              return ListView.builder(// 가입한 동아리 ID 목록으로 ListView 생성
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: joinedClubIds.length,
                itemBuilder: (context, index) {
                  final clubId = joinedClubIds[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('clubs').doc(clubId).get(),
                    builder: (context, clubSnapshot) {
                      if (!clubSnapshot.hasData || !clubSnapshot.data!.exists) {
                        return const SizedBox.shrink();
                      }
                      var clubData = clubSnapshot.data!.data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: ListTile(
                          leading: const Icon(Icons.people),
                          title: Text(clubData['name'] ?? '이름 없음'),
                          subtitle: const Text('터치하여 게시판으로 이동'),
                          trailing: IconButton(// 탈퇴 버튼
                            icon: Icon(Icons.exit_to_app, color: Colors.red.shade400),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('동아리 탈퇴'),
                                  content: Text('${clubData['name']} 동아리에서 정말 탈퇴하시겠습니까?'),
                                  actions: [
                                    TextButton(child: const Text('취소'), onPressed: () => Navigator.of(dialogContext).pop()),
                                    TextButton(
                                      child: const Text('확인', style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        _firebase_connect.withdrawFromClub(userDocId: widget.currentUser['id'], clubId: clubId);
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          onTap: () async {
                            // 1. 게시판 화면으로 이동하고, 돌아올 때까지 기다림
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ClubBoardScreen(
                                  clubId: clubId,
                                  clubName: clubData['name'] ?? '동아리',
                                  currentUser: widget.currentUser,
                                ),
                              ),
                            );

                            // 2. 돌아온 후에 달력 데이터를 새로고침
                            _calendarKey.currentState?.loadFirestoreEvents();
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}