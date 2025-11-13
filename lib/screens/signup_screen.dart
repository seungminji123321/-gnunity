import 'package:flutter/material.dart';
import 'package:gnunity/services/firebase_connect.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final firebaseConnect = firebase_connect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '이름')),
            const SizedBox(height: 16),
            TextField(controller: _studentIdController, decoration: const InputDecoration(labelText: '학번'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: '비밀번호')),
            const SizedBox(height: 24),
            ElevatedButton( //가입하기 버튼
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('가입하기'),
              onPressed: () async {
                final user = await firebaseConnect.signUp(
                  studentId: _studentIdController.text,
                  password: _passwordController.text,
                  name: _nameController.text,
                );
                if (user != null && mounted) { //회원가입 성공
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('회원가입에 성공했습니다!')));
                  Navigator.of(context).pop();
                } else if (mounted) {// 회원가입 실패
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미 가입된 학번입니다. 로그인해주세요.')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}