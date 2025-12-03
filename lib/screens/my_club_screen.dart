import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gnunity/models/user_model.dart';
import 'package:gnunity/models/club_model.dart';
import 'package:gnunity/screens/Calendar_Screen.dart';
import 'package:gnunity/screens/club_board_screen.dart';
import 'package:gnunity/services/firebase_connect.dart';

class MyClubScreen extends StatefulWidget {
  final User currentUser;
  const MyClubScreen({super.key, required this.currentUser});

  @override
  State<MyClubScreen> createState() => _MyClubScreenState();
}

class _MyClubScreenState extends State<MyClubScreen> {
  final FirebaseConnect _authService = FirebaseConnect();
  final GlobalKey<CalendarScreenState> _calendarKey = GlobalKey<CalendarScreenState>();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CalendarScreen(key: _calendarKey, currentUser: widget.currentUser),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider(thickness: 4, color: Colors.grey)),

          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('users').doc(widget.currentUser.id).snapshots(),
            builder: (context, userSnapshot) {
              if (!userSnapshot.hasData) return const Center(child: CircularProgressIndicator());

              final userData = userSnapshot.data!.data() as Map<String, dynamic>;
              final List<String> joinedClubIds = List<String>.from(userData['joinedClubIds'] ?? []).where((id) => id.isNotEmpty).toList();

              if (joinedClubIds.isEmpty) return const Center(child: Text('가입한 동아리가 없습니다.'));

              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: joinedClubIds.length,
                itemBuilder: (context, index) {
                  final clubId = joinedClubIds[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('clubs').doc(clubId).get(),
                    builder: (context, clubSnapshot) {
                      if (!clubSnapshot.hasData) return const SizedBox.shrink();

                      // Club 모델로 변환
                      final club = Club.fromMap(clubSnapshot.data!.data() as Map<String, dynamic>, clubSnapshot.data!.id);

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: ListTile(
                          leading: const Icon(Icons.people),
                          title: Text(club.name),
                          subtitle: const Text('터치하여 게시판으로 이동'),
                          trailing: IconButton(
                            icon: const Icon(Icons.exit_to_app, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('탈퇴'),
                                  content: Text('${club.name}에서 탈퇴하시겠습니까?'),
                                  actions: [
                                    TextButton(child: const Text('취소'), onPressed: () => Navigator.pop(ctx)),
                                    TextButton(
                                      child: const Text('확인'),
                                      onPressed: () {
                                        _authService.withdrawFromClub(userDocId: widget.currentUser.id, clubId: club.id);
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ClubBoardScreen(
                                  clubId: club.id,
                                  clubName: club.name,
                                  currentUser: widget.currentUser,
                                ),
                              ),
                            );
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