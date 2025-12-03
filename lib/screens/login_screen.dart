import 'package:flutter/material.dart';
import 'package:gnunity/models/user_model.dart';
import 'package:gnunity/screens/home_screen.dart';
import 'package:gnunity/screens/signup_screen.dart';
import 'package:gnunity/services/firebase_connect.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _studentIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseConnect = FirebaseConnect();

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
              const SizedBox(height: 48),
              TextField(controller: _studentIdController, decoration: const InputDecoration(labelText: '학번'), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: '비밀번호')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  // User 객체를 받음
                  final User? user = await _firebaseConnect.login(
                    _studentIdController.text,
                    _passwordController.text,
                  );
                  if (user != null && mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen(currentUser: user)),
                    );
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인 실패')));
                  }
                },
                child: const Text('로그인'),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen())),
                child: const Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}