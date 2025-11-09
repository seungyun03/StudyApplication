import 'package:flutter/material.dart';
import 'dart:ui'; // BackdropFilter를 위해 필요합니다.

// 💡 [참고] 프로젝트 구조에 따라 LoginPage.dart 파일을 가져와야 합니다.
import 'LoginPage.dart'; // 예시 경로: LoginPage로 돌아가기 위해 필요

// ==================== [수정] AppColors (LoginPage.dart와 동일) ====================
// 💡 HTML의 Tailwind 색상을 기반으로 정의됩니다. (중성적 디자인 테마)
class AppColors {
  // 💡 [수정] 배경 그라디언트 (파스텔 노랑, 민트, 파랑 계열로 변경: Neutral/Pastel Theme)
  static const Color backgroundStart =
      Color(0xFFFEF9C3); // Yellow-100 근사치 (은은한 노랑)
  static const Color backgroundMiddle =
      Color(0xFFDCFCE7); // Emerald-100 근사치 (은은한 민트/연두)
  static const Color backgroundEnd =
      Color(0xFFD0E0FB); // Sky-100/Blue-100 근사치 (은은한 파랑)

  // 💡 [수정] Primary 버튼 및 텍스트 그라데이션 (차분한 파랑/민트 계열: Indigo/Emerald)
  static const Color primaryGradientStart = Color(0xFF6366F1); // indigo-500 근사치
  static const Color primaryGradientEnd = Color(0xFF34D399); // emerald-400 근사치

  // 텍스트 및 기타 요소
  static const Color foreground = Color(0xFF1F2937); // gray-800 근사치 (더 차분한 검은색)
  static const Color secondaryText = Color(0xFF6B7280); // gray-500 근사치
  static const Color cardBackground = Color(0xFFFFFFFF); // 흰색
  static const Color inputBackground = Color(0xFFF9FAFB); // gray-50 근사치 (약간 밝은)
  // 💡 [추가] 기타 요소에 사용될 색상 (HomePage 테마 일관성 유지)
  static const Color border = Color(0xFFE5E7EB); // gray-200
}

// ==================== [추가] 공통 위젯 (LoginPage.dart에서 복사) ====================

// 💡 비밀번호 표시/숨김 아이콘 토글 위젯
class PasswordVisibilityToggle extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onTap;

  const PasswordVisibilityToggle({
    super.key,
    required this.isVisible,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.secondaryText.withOpacity(0.8),
        size: 20,
      ),
    );
  }
}

// 💡 StudyFlow 텍스트에 그라데이션을 적용하는 위젯
class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;

  const GradientText(this.text,
      {super.key, required this.fontSize, required this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

// 💡 커스텀 텍스트 필드 위젯
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String hintText;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.hintText = '',
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.border, width: 1.0),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(
        color: AppColors.primaryGradientStart,
        width: 2.0,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            labelText,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: AppColors.foreground),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                TextStyle(color: AppColors.secondaryText.withOpacity(0.7)),
            filled: true,
            fillColor: AppColors.inputBackground,
            suffixIcon: suffixIcon,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: focusedBorder,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          ),
        ),
      ],
    );
  }
}

// 💡 디자인에 따른 그라디언트 버튼 위젯 (회원가입 버튼)
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0), // rounded-xl
    );

    // 메인 회원가입 버튼 스타일 (그라데이션 배경 + 그림자)
    return Container(
      height: 50, // py-3 근사치
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryGradientStart,
            AppColors.primaryGradientEnd
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            // 💡 [수정] 그림자 색상을 변경된 primary 색상에 맞춤
            color: AppColors.primaryGradientStart.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: Center(
            child: Text(
              text, // '회원가입 완료'
              style: const TextStyle(
                fontSize: 18.0, // text-lg
                fontWeight: FontWeight.w600, // font-semibold
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// ==================== [추가 끝] ====================

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // 메시지 박스
  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)), // rounded-xl
          title: const Text('알림'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인',
                  style: TextStyle(color: AppColors.primaryGradientStart)),
            ),
          ],
        );
      },
    );
  }

  // 💡 [수정] 회원가입 완료 처리 로직
  void _handleSignUpComplete() {
    // 1. 유효성 검사 (간단화)
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showMessage('모든 정보를 입력해주세요.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('비밀번호가 일치하지 않습니다.');
      return;
    }

    // 2. 실제 회원가입 로직 (API 호출 등)을 구현할 위치입니다.
    print('회원가입 완료: ${_emailController.text}');

    // 3. [핵심 수정] 회원가입 성공 후 **로그인 페이지로 돌아가기**
    // pushReplacement를 사용하여 회원가입 스택을 제거하고 로그인 페이지로 대체합니다.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    // 4. 로그인 페이지로 돌아간 후, 성공 메시지를 표시하고 싶다면 아래와 같이 수정 필요:
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const LoginPage(showSuccess: true)),
    // );
  }

  // [유지] 로그인 페이지로 돌아가기 (하단 링크 클릭 시)
  void _handleBackToLogin() {
    Navigator.pop(context); // 현재 페이지를 스택에서 제거하고 이전 페이지 (LoginPage)로 돌아갑니다.
  }

  @override
  Widget build(BuildContext context) {
    // 💡 [수정] LoginPage의 배경 그라데이션 적용
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.backgroundStart,
            AppColors.backgroundMiddle,
            AppColors.backgroundEnd
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // 배경 투명 처리
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              // 💡 [수정] LoginPage의 카드 스타일 적용
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0), // rounded-3xl
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5.0, sigmaY: 5.0), // backdrop-blur-sm
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
                    decoration: BoxDecoration(
                        color: AppColors.cardBackground
                            .withOpacity(0.8), // bg-white/80
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ), // shadow-2xl
                        ]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // 1. 로고 (SignUp 페이지에서는 로고를 더 작게 배치)
                        Container(
                          alignment: Alignment.center,
                          child: Image.asset(
                            'assets/images/logo_studyflow.png', // 로고 이미지 경로
                            height: 120, // 로그인 페이지보다 작게 (w-32 h-32 근사치)
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              // 이미지 로드 실패 시 대체 위젯
                              return Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryGradientStart,
                                    borderRadius: BorderRadius.circular(
                                        999), // rounded-full
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]),
                                child: const Center(
                                  child: Text('SF',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      )),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10), // 로고와 제목 사이 간격 조정

                        // 2. 제목 (h1) - 그라데이션 적용
                        GradientText(
                          '회원가입',
                          fontSize: 28.0, // text-2xl
                          fontWeight: FontWeight.w900,
                        ),

                        const SizedBox(height: 5),

                        // 3. 부제목 (p)
                        const Text(
                          '새 계정을 만들고 StudyFlow를 시작하세요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(height: 32.0),

                        // 4. 이름 입력 필드
                        CustomTextField(
                          controller: _nameController,
                          labelText: '이름',
                          hintText: '김스터디',
                        ),
                        const SizedBox(height: 20.0),

                        // 5. 이메일 입력 필드
                        CustomTextField(
                          controller: _emailController,
                          labelText: '이메일 주소',
                          hintText: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20.0),

                        // 6. 비밀번호 입력 필드
                        CustomTextField(
                          controller: _passwordController,
                          labelText: '비밀번호',
                          hintText: '••••••••',
                          obscureText: !_showPassword,
                          suffixIcon: PasswordVisibilityToggle(
                            isVisible: _showPassword,
                            onTap: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20.0),

                        // 7. 비밀번호 확인 입력 필드
                        CustomTextField(
                          controller: _confirmPasswordController,
                          labelText: '비밀번호 확인',
                          hintText: '••••••••',
                          obscureText: !_showConfirmPassword,
                          suffixIcon: PasswordVisibilityToggle(
                            isVisible: _showConfirmPassword,
                            onTap: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30.0),

                        // 8. 회원가입 완료 버튼 (그라디언트)
                        GradientButton(
                          text: '회원가입 완료',
                          onPressed: _handleSignUpComplete, // 💡 수정된 함수 연결
                        ),
                        const SizedBox(height: 24.0),

                        // 9. 로그인 페이지로 돌아가기 링크
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '이미 계정이 있으신가요? ',
                              style: TextStyle(
                                  color: Color(0xFF4B5563), fontSize: 14.0),
                            ),
                            TextButton(
                              onPressed: _handleBackToLogin,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                '로그인으로 돌아가기',
                                style: TextStyle(
                                  color: AppColors.primaryGradientStart,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
