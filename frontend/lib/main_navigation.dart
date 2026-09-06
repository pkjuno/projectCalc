import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'add_entry_screen.dart';
import 'my_page.dart';
import 'table_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Pretendard',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  // 네비게이션 바 메뉴에 대응하는 5개의 샘플 화면들
  final List<Widget> _screens = [
    const Center(child: Text('홈 화면', style: TextStyle(fontSize: 20, color: Colors.black))),
    const CalendarTabScreen(),
    const AddEntryScreen(),
    const Center(child: Text('알림 화면', style: TextStyle(fontSize: 20, color: Colors.black))),
    const MyPageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey[200]!,
              width: 1.0,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // 5개 항목 고정 정렬을 위해 필수 설정
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black, // 선택된 아이콘/라벨: 블랙
          unselectedItemColor: Colors.grey[400], // 선택 안 된 아이콘/라벨: 연한 회색
          selectedFontSize: 11,
          unselectedFontSize: 11,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0, // 기본 섀도우 제거하여 플랫한 미니멀 스타일 유지
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_home.svg', width: 24, height: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_home_active.svg', width: 24, height: 24),
              ),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_calendar.svg', width: 24, height: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_calendar_active.svg', width: 24, height: 24),
              ),
              label: '캘린더',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_add.svg', width: 24, height: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_add_active.svg', width: 24, height: 24),
              ),
              label: '추가하기',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_notifications.svg', width: 24, height: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_notifications_active.svg', width: 24, height: 24),
              ),
              label: '알림',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_profile.svg', width: 24, height: 24),
              ),
              activeIcon: Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: SvgPicture.asset('assets/nav_profile_active.svg', width: 24, height: 24),
              ),
              label: '마이페이지',
            ),
          ],
        ),
      ),
    );
  }
}