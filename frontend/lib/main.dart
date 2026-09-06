import 'package:flutter/material.dart';
import 'login_screen.dart'; // 방금 만든 로그인 화면 import

void main() {
  runApp(const MoneyNoteApp());
}

class MoneyNoteApp extends StatelessWidget {
  const MoneyNoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '머니 노트',
      debugShowCheckedModeBanner: false, // 우측 상단 디버그 띠 제거
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard', // 실무에서는 예쁜 한글 폰트를 주로 적용합니다
      ),
      // 앱이 켜지면 LoginScreen을 가장 먼저 보여줍니다.
      home: const LoginScreen(),
    );
  }
}

// Backwards-compatible alias for tests expecting `MyApp`.
class MyApp extends MoneyNoteApp {
  const MyApp({super.key}) : super();
}