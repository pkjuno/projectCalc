// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/add_entry_screen.dart';
import 'package:frontend/main.dart';
import 'package:frontend/table_calendar.dart';

void main() {
  testWidgets('앱이 빌드되고 제목을 표시하는지 확인', (WidgetTester tester) async {
    // 앱 빌드
    await tester.pumpWidget(const MyApp());

    // 앱 타이틀이 보이는지 확인
    expect(find.text('머니 노트'), findsOneWidget);
  });

  testWidgets('날짜를 선택하면 플로팅 액션 버튼이 보이는지 확인', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalendarTabScreen()));

    expect(find.byType(FloatingActionButton), findsNothing);

    await tester.tap(find.text('1').first);
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('년/월 선택용 드롭다운이 보이는지 확인', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CalendarTabScreen()));

    expect(find.byType(DropdownButton<int>), findsNWidgets(2));
  });

  testWidgets('추가 화면은 전달된 날짜를 초기값으로 보여준다', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddEntryScreen(initialDate: DateTime(2024, 5, 6))));

    expect(find.text('2024년 5월 6일'), findsOneWidget);
  });
}
