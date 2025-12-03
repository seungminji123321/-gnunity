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
  final _firebaseConnect = FirebaseConnect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '이름')),
            const SizedBox(height: 16),
            TextField(controller: _studentIdController, decoration: const InputDecoration(labelText: '학번'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: '비밀번호')),
            const SizedBox(height: 24),
            ElevatedButton(
              child: const Text('가입하기'),
              onPressed: () async {
                final userMap = await _firebaseConnect.signUp(
                  studentId: _studentIdController.text,
                  password: _passwordController.text,
                  name: _nameController.text,
                );
                if (userMap != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('가입 성공!')));
                  Navigator.of(context).pop();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('이미 존재하는 학번입니다.')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}