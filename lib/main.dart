import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gnunity/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
// 앱 전체의 테마(다크/라이트 모드) 상태를 관리하는 클래스
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
//메인 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ▼▼▼ 달력 한글 설정을 위한 초기화 코드 ▼▼▼
  await initializeDateFormatting();
//엔진, 달력, firebase 초기화
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
//앱 실행
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const GNUnityApp(),
    ),
  );
}
//앱 최상위 위젯
class GNUnityApp extends StatelessWidget {
  const GNUnityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'GNUnity',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(//라이트 모드
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      darkTheme: ThemeData(// 다크모드
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      home: const LoginScreen(), //앱 첫화면
    );
  }
}