import 'package:flutter/material.dart';
import 'package:gnunity/models/club_model.dart';
import 'package:gnunity/models/user_model.dart';
import 'package:gnunity/services/firebase_connect.dart';
import 'package:gnunity/widgets/custom_app_bar.dart';
//동아리 상세정보, 가입 화면
class ClubDetailScreen extends StatelessWidget {
  final Club club;
  final Map<String, dynamic> currentUser;

  const ClubDetailScreen({
    super.key,
    required this.club,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final firebaseConnect = firebase_connect();
    final passwordController = TextEditingController(); // 비밀번호 입력을 위한 컨트롤러

    return Scaffold(
      appBar: CustomAppBar(title: club.name),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(club.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(club.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              //버튼을 눌렀을 때 실행될 로직 수정
              onPressed: () {
                // 1. 모집 기간이 아니면 즉시 차단
                if (club.recruiting == false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('가입신청 기간이 아닙니다!')),
                  );
                  return;
                }

                // 2. 비밀번호 입력 팝업창 띄우기
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('가입 비밀번호 입력'),
                      content: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(hintText: "비밀번호를 입력하세요"),
                      ),

                      actions: [
                        TextButton(
                          child: const Text('취소'),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),

                        TextButton(
                          child: const Text('확인'),
                          onPressed: () async {
                            // 3. 비밀번호 확인 및 가입 처리
                            if (passwordController.text == club.joinPassword) {
                              final userDocId = currentUser['id'];
                              final clubId = club.id;

                              await firebaseConnect.joinClub(userDocId: userDocId, clubId: clubId);

                              // 모든 팝업과 화면을 닫고 이전 화면들로 돌아감
                              if (context.mounted) {
                                Navigator.of(dialogContext).pop(); // 비밀번호 팝업 닫기
                                Navigator.of(context).pop();      // 동아리 상세 화면 닫기
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${club.name}에 가입되었습니다!')),
                                );
                              }
                            } else {
                              // 비밀번호가 틀렸을 경우
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                              );
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('동아리 가입하기'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
          ],
        ),
      ),
    );
  }

}
