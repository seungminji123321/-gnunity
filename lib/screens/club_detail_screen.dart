import 'package:flutter/material.dart';
import 'package:gnunity/models/club_model.dart';
import 'package:gnunity/models/user_model.dart';
import 'package:gnunity/services/firebase_connect.dart';
import 'package:gnunity/widgets/custom_app_bar.dart';

class ClubDetailScreen extends StatelessWidget {
  final Club club;
  final User currentUser;

  const ClubDetailScreen({super.key, required this.club, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseConnect();
    final passwordController = TextEditingController();

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
              onPressed: () {
                if (!club.recruiting) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('모집 기간이 아닙니다.')));
                  return;
                }
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('가입 비밀번호'),
                    content: TextField(controller: passwordController, obscureText: true),
                    actions: [
                      TextButton(child: const Text('취소'), onPressed: () => Navigator.pop(ctx)),
                      TextButton(
                        child: const Text('확인'),
                        onPressed: () async {
                          if (passwordController.text == club.joinPassword) {
                            await authService.joinClub(userDocId: currentUser.id, clubId: club.id);
                            if (context.mounted) {
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('가입 완료!')));
                            }
                          } else {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호 불일치')));
                          }
                        },
                      ),
                    ],
                  ),
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