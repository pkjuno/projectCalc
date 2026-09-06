import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final String? initialEmail;

  const SignupScreen({super.key, this.initialEmail});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final TextEditingController _emailController;
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordValid = false;
  bool _isPasswordMatch = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validatePassword);
  }

  Future<void> _handleSignup() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String nickname = _nicknameController.text.trim();

    if (email.isEmpty || password.isEmpty || nickname.isEmpty) {
      _showSnackBar('모든 필드를 입력해주세요.');
      return;
    }

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) {
      _showSnackBar('유효한 이메일을 입력해주세요.');
      return;
    }

    if (!_isPasswordValid) {
      _showSnackBar('비밀번호는 영문, 숫자 조합 8자 이상이어야 합니다.');
      return;
    }

    if (!_isPasswordMatch) {
      _showSnackBar('비밀번호가 일치하지 않습니다.');
      return;
    }

    final String host = Platform.isIOS ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
    final String apiUrl = '$host/user/register-email';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nickname': nickname,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        _showSnackBar(responseData['message'] ?? '회원가입에 성공했습니다.');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      } else {
        _showSnackBar(responseData['message'] ?? '회원가입에 실패했습니다.');
      }
    } catch (e) {
      debugPrint('회원가입 오류: $e');
      _showSnackBar('서버와 통신할 수 없습니다.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
      final hasNumber = password.contains(RegExp(r'[0-9]'));

      _isPasswordValid = password.length >= 8 && hasLetter && hasNumber;
      _isPasswordMatch = password == confirmPassword;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildValidationText() {
    final bool isPasswordEmpty = _passwordController.text.isEmpty;
    final bool isConfirmEmpty = _confirmPasswordController.text.isEmpty;

    if (isPasswordEmpty && isConfirmEmpty) {
      return Text(
        '비밀번호는 영문, 숫자 조합 8자 이상이어야 합니다.',
        style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5),
        textAlign: TextAlign.center,
      );
    } else if (!_isPasswordValid) {
      return const Text(
        '비밀번호는 영문, 숫자 조합 8자 이상이어야 합니다.',
        style: TextStyle(color: Colors.redAccent, fontSize: 13, height: 1.5),
        textAlign: TextAlign.center,
      );
    } else if (!_isPasswordMatch && !isConfirmEmpty) {
      return const Text(
        '비밀번호가 일치하지 않습니다.',
        style: TextStyle(color: Colors.redAccent, fontSize: 13, height: 1.5),
        textAlign: TextAlign.center,
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (Navigator.canPop(context))
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: SvgPicture.asset(
                      'assets/back_arrow.svg',
                      width: 22,
                      height: 22,
                    ),
                    tooltip: '뒤로가기',
                  ),
                ),
              )
            else
              const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      '머니 노트',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      '계정 만들기',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '비밀번호와 닉네임을 입력하세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: '이메일',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nicknameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: '닉네임',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '비밀번호',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '비밀번호 확인',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(child: _buildValidationText()),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        if (_emailController.text.trim().isEmpty ||
                            _nicknameController.text.trim().isEmpty ||
                            _passwordController.text.isEmpty ||
                            _confirmPasswordController.text.isEmpty) {
                          _showSnackBar('모든 필드를 입력해주세요.');
                          return;
                        }

                        if (!_isPasswordValid) {
                          _showSnackBar('비밀번호는 영문, 숫자 조합 8자 이상이어야 합니다.');
                          return;
                        }

                        if (!_isPasswordMatch) {
                          _showSnackBar('비밀번호가 일치하지 않습니다.');
                          return;
                        }

                        _handleSignup();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '완료',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '계속을 클릭하면 당사의 서비스 이용 약관 및 개인정보 처리방침에\n동의하는 것으로 간주됩니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
