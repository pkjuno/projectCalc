import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: SvgPicture.asset(
                  'assets/back_arrow.svg',
                  width: 22,
                  height: 22,
                ),
                tooltip: '뒤로가기',
              )
            : const Icon(Icons.menu, color: Colors.black, size: 24),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 1. 환영 문구 및 총 자산 섹션
                Text(
                  '안녕하세요, 홍길동님',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 6),
                const Text(
                  '이번 달 쓸 수 있는 돈',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  '₩ 1,245,000',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 32),

                // 2. 미니멀 지출 통계 그래프 섹션 (Custom 바 차트)
                const Text(
                  '주간 지출 추이',
                  style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Container(
                  height: 160,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f9fa),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBarChart('6월 1주', 0.4),
                      _buildBarChart('6월 2주', 0.8),
                      _buildBarChart('6월 3주', 0.3),
                      _buildBarChart('이번주', 0.6, isCurrent: true),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // 3. 최근 내역 타이틀 및 필터
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '최근 소비 내역',
                      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '전체보기',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13, decoration: TextDecoration.underline),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. 최근 소비 내역 리스트 리스트
                _buildTransactionItem('애플 온라인스토어', '06.20', '- ₩ 15,000', '쇼핑'),
                _buildTransactionItem('스타벅스 인천점', '06.19', '- ₩ 6,300', '식비'),
                _buildTransactionItem('네이버페이 충전', '06.18', '+ ₩ 50,000', '이체', isIncome: true),
                _buildTransactionItem('GS25 편의점', '06.17', '- ₩ 4,500', '식비'),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 📊 미니멀 바 차트 빌더
  Widget _buildBarChart(String label, double heightPercentage, {bool isCurrent = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Container(
            width: 32,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              heightFactor: heightPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: isCurrent ? Colors.black : Colors.grey[600],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isCurrent ? Colors.black : Colors.grey[500],
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // 💸 소비 내역 아이템 빌더
  Widget _buildTransactionItem(String title, String date, String amount, String category, {bool isIncome = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // 카테고리 심플 아이콘 배경
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isIncome ? const Color(0xffe9ecef) : const Color(0xfff1f3f5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.add_card_outlined : Icons.credit_card_outlined,
                  size: 18,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$date • $category',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              color: isIncome ? Colors.blue[700] : Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}