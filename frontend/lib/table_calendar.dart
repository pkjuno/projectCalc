import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_entry_screen.dart';

class CalendarTabScreen extends StatefulWidget {
  const CalendarTabScreen({super.key});

  @override
  State<CalendarTabScreen> createState() => _CalendarTabScreenState();
}

class _CalendarTabScreenState extends State<CalendarTabScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  int get _incomeAmount => 120000;
  int get _expenseAmount => 85000;
  int get _netAmount => _incomeAmount - _expenseAmount;

  void _changeMonth(int delta) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + delta, 1);
    });
  }

  void _updateFocusedDate({int? year, int? month}) {
    setState(() {
      final newYear = year ?? _focusedDay.year;
      final newMonth = month ?? _focusedDay.month;
      _focusedDay = DateTime(newYear, newMonth, 1);
    });
  }

  String _formatSelectedDate(DateTime? date) {
    if (date == null) {
      return '날짜를 선택해주세요';
    }
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 머니 노트의 기본 화이트 테마 적용
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 년/월 헤더와 좌우 화살표
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      icon: SvgPicture.asset(
                        'assets/calendar_prev.svg',
                        width: 22,
                        height: 22,
                      ),
                      tooltip: '이전 달',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<int>(
                            value: _focusedDay.year,
                            underline: const SizedBox(),
                            icon: const SizedBox.shrink(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            items: List.generate(21, (index) {
                              final year = DateTime.now().year - 10 + index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text('$year년'),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) {
                                _updateFocusedDate(year: value);
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<int>(
                            value: _focusedDay.month,
                            underline: const SizedBox(),
                            icon: const SizedBox.shrink(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            items: List.generate(12, (index) {
                              final month = index + 1;
                              return DropdownMenuItem(
                                value: month,
                                child: Text('$month월'),
                              );
                            }),
                            onChanged: (value) {
                              if (value != null) {
                                _updateFocusedDate(month: value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeMonth(1),
                      icon: SvgPicture.asset(
                        'assets/calendar_next.svg',
                        width: 22,
                        height: 22,
                      ),
                      tooltip: '다음 달',
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. 머니 노트 스타일 달력 위젯
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2039, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        headerVisible: false,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarStyle: const CalendarStyle(
                          defaultTextStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                          weekendTextStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
                          outsideTextStyle: TextStyle(color: Colors.grey),
                          selectedDecoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color(0xFFE5E5E5),
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                          weekendStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatSelectedDate(_selectedDay),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '수입',
                                      style: TextStyle(color: Colors.black54, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '+${_incomeAmount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',') }원',
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '지출',
                                      style: TextStyle(color: Colors.black54, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '-${_expenseAmount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',') }원',
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.grey, height: 1),
                          const SizedBox(height: 10),
                          Text(
                            '현재 ${_netAmount.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}원',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _selectedDay != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEntryScreen(initialDate: _selectedDay),
                  ),
                );
              },
              backgroundColor: Colors.black,
              shape: const CircleBorder(),
              elevation: 0,
              child: SvgPicture.asset(
                'assets/add_icon.svg',
                width: 24,
                height: 24,
              ),
            )
          : null,
    );
  }
}