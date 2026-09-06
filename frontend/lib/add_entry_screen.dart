import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// API 서비스의 Mock 클래스입니다.
/// 실제 서버와 통신하는 로직으로 수정되었습니다.
class ApiService {
  // Android 에뮬레이터는 'http://10.0.2.2:3000', iOS 시뮬레이터는 'http://localhost:3000'를 사용합니다.
  // 실행 환경에 맞는 백엔드 서버 주소로 수정해주세요.
  static final String _baseUrl =
      Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';

  /// mst_code를 기반으로 code_dtl 테이블에서 카테고리 목록을 가져옵니다.
  Future<List<String>> fetchCategories(String mstCode) async {
    final uri =
        Uri.parse('$_baseUrl/api/common-codes').replace(queryParameters: {'mst_code': mstCode});

    // 디버깅을 위해 실제 호출되는 URL을 출력합니다.
    debugPrint('Requesting URL: $uri');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      // UTF-8로 디코딩하여 한글 깨짐을 방지합니다.
      final body = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> details = body['details'];
      return details.map((item) => item['DTL_CODE_NM'] as String).toList();
    } else {
      throw Exception('카테고리 로딩에 실패했습니다: ${response.statusCode}');
    }
  }
}

/// 입력된 숫자를 천 단위로 콤마로 구분하는 `TextInputFormatter`입니다.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final String newString = NumberFormat('#,###').format(int.parse(digitsOnly));

    return TextEditingValue(text: newString, selection: TextSelection.collapsed(offset: newString.length));
  }
}

class AddEntryScreen extends StatefulWidget {
  final DateTime? initialDate;

  const AddEntryScreen({super.key, this.initialDate});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late DateTime _selectedDate;
  String _type = 'TRX_EXPENSE';
  String? _category;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _isCategoryLoading = false;
  List<String> _currentCategories = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _fetchAndSetCategories(_type);
  }

  Future<void> _fetchAndSetCategories(String type) async {
    setState(() {
      _isCategoryLoading = true;
      _category = null; // 카테고리 선택 초기화
      _currentCategories = []; // 기존 목록 지우기
    });

    try {
      final categories = await _apiService.fetchCategories(type);
      setState(() {
        _currentCategories = categories;
      });
    } catch (e) {
      // 에러 처리 (예: 스낵바 표시)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카테고리를 불러오는데 실패했습니다: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isCategoryLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2039, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          '추가하기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '새 기록 추가',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _formatDate(_selectedDate),
                        style: const TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _type,
                      items: const [
                        DropdownMenuItem(
                            value: 'TRX_INCOME', child: Text('수입')),
                        DropdownMenuItem(
                            value: 'TRX_EXPENSE', child: Text('지출')),
                      ],
                      onChanged: (value) {
                        if (value != null && value != _type) {
                          setState(() {
                            _type = value; // UI 즉시 업데이트
                          });
                          _fetchAndSetCategories(value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _isCategoryLoading
                        ? const Center(
                            child: SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2.0)))
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _category,
                              hint: const Text('카테고리'),
                              isExpanded: true,
                              items: _currentCategories
                                  .map((e) => DropdownMenuItem(
                                      value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _category = value;
                                });
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                ThousandsSeparatorInputFormatter(),
              ],
              decoration: const InputDecoration(
                labelText: '금액',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _memoController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '메모',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
