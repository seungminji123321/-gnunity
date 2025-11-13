import 'package:flutter/material.dart';
import 'package:gnunity/main.dart'; // ThemeProvider가 있는 main.dart import
import 'package:gnunity/screens/login_screen.dart'; // 로그인 화면 import
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return ListView(
      children: <Widget>[
        // --- 테마 변경 메뉴 ---
        ListTile(
          leading: const Icon(Icons.brightness_6),
          title: const Text('테마 변경'),
          trailing: Consumer<ThemeProvider>(
            builder: (context, provider, child) {
              return DropdownButton<ThemeMode>(
                value: provider.themeMode,
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('시스템 설정'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('라이트 모드'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('다크 모드'),
                  ),
                ],
                onChanged: (ThemeMode? newMode) {
                  if (newMode != null) {
                    themeProvider.setTheme(newMode);
                  }
                },
              );
            },
          ),
        ),
        const Divider(),

        // --- 알림 설정 메뉴 (추가) ---
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('알림 설정'),
          onTap: () {
            // TODO: 알림 설정 화면으로 이동하는 코드 구현
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('알림 설정 기능은 준비 중입니다.')),
            );
          },
        ),
        const Divider(),

        // --- 로그아웃 버튼 (추가) ---
        ListTile(
          leading: Icon(
            Icons.logout,
            color: Colors.red.shade400,
          ),
          title: Text(
            '로그아웃',
            style: TextStyle(color: Colors.red.shade400),
          ),
          onTap: () {
            // 모든 이전 화면 기록을 지우고 로그인 화면으로 이동
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ],
    );
  }
}