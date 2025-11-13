import 'package:flutter/material.dart';
import 'package:gnunity/screens/home_screen.dart';
import 'package:gnunity/screens/signup_screen.dart';
import 'package:gnunity/services/firebase_connect.dart';
// import 'package:firebase_messaging/firebase_messaging.dart'; // 이 줄을 삭제합니다.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _studentIdController = TextEditingController(); //학번 컨트롤러
  final _passwordController = TextEditingController();// 비밀번호 컨트롤러
  final firebaseConnect = firebase_connect(); // Firebase 연결 서비스 객체

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('GNUnity', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('대학생 동아리 커뮤니케이션 및 관리 플랫폼', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 48),
              TextField(controller: _studentIdController, decoration: const InputDecoration(labelText: '학번'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: '비밀번호')),
              const SizedBox(height: 24),
              ElevatedButton( //로그인버튼
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('로그인'),
                onPressed: () async {
                  final user = await firebaseConnect.login(
                    _studentIdController.text,
                    _passwordController.text,
                  );
                  if (user != null && mounted) {
                    // 로그인성공
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen(currentUser: user)),
                    );
                  } else if (mounted) { //로그인 실패
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('학번 또는 비밀번호가 잘못되었습니다.')));
                  }
                },
              ),
              TextButton( //회원가입 버튼
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                },
                child: const Text('계정이 없으신가요? 회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}