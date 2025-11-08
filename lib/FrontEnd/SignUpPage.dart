import 'package:flutter/material.dart';
import 'dart:ui'; // BackdropFilter를 위해 필요합니다.

// 💡 [참고] LoginPage로 돌아가는 로직을 위해 이 파일은 필요하지 않지만,
// 프로젝트 구조에 따라 상호 의존성이 있을 수 있어 필요 시 import합니다.
// import 'LoginPage.dart';

// 💡 HTML의 Tailwind 색상을 기반으로 정의됩니다.
class AppColors {
  // 배경 그라디언트 (from-purple-50 via-pink-50 to-blue-50)
  static const Color backgroundStart = Color(0xFFF3E5F5); // purple-50 근사치
  static const Color backgroundMiddle = Color(0xFFFCE4EC); // pink-50 근사치
  static const Color backgroundEnd = Color(0xFFE3F2FD); // blue-50 근사치

  // Primary 버튼 및 텍스트 그라데이션 (#8C9EFF to #A0D4C5)
  static const Color primaryGradientStart = Color(0xFF8C9EFF); // 밝은 파랑/보라
  static const Color primaryGradientEnd = Color(0xFFA0D4C5); // 민트

  // 텍스트 및 기타 요소
  static const Color foreground = Color(0xFF030213); // 거의 검은색
  static const Color secondaryText = Color(0xFF6A6E82); // gray-500/600 근사치
  static const Color cardBackground = Color(0xFFFFFFFF); // 흰색
  static const Color inputBackground = Color(0xFFF3F3F5); // gray-50 근사치
}

// 💡 비밀번호 표시/숨김 아이콘 토글 위젯 (LoginPage와 동일)
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

// 💡 StudyFlow 텍스트에 그라데이션을 적용하는 위젯 (LoginPage와 동일)
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
        textAlign: TextAlign.center, // 중앙 정렬 추가
        style: TextStyle(
          color: Colors.white, // ShaderMask를 위해 임시로 흰색으로 설정
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}

// 💡 커스텀 텍스트 필드 위젯 (LoginPage와 동일)
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String hintText;
  final FormFieldValidator<String>? validator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.hintText = '',
    this.validator, // validator 추가
  });

  @override
  Widget build(BuildContext context) {
    // HTML의 .input-field 스타일
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(
          color: Color(0xFFE5E7EB), width: 1.0), // border-gray-200
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(
        color: AppColors.primaryGradientStart, // #8C9EFF
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
              fontSize: 14.0, // text-sm
              fontWeight: FontWeight.w500, // font-medium
              color: Color(0xFF374151), // text-gray-700
            ),
          ),
        ),
        TextFormField(
          // TextFormField로 변경하여 Form validation 지원
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: AppColors.foreground),
          validator: validator, // validator 적용
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0.5), // 에러 메시지 간격 조정
            isDense: true, // 내부 패딩 조정
            hintText: hintText,
            hintStyle:
                TextStyle(color: AppColors.secondaryText.withOpacity(0.7)),
            filled: true,
            fillColor: AppColors.inputBackground, // bg-gray-50
            suffixIcon: suffixIcon,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: focusedBorder,
            errorBorder: inputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 1.0)),
            focusedErrorBorder: focusedBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 2.0)),
            contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0, horizontal: 16.0), // p-3 근사치
          ),
        ),
      ],
    );
  }
}

// 💡 디자인에 따른 그라디언트 버튼 위젯 (LoginPage와 동일)
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isGoogleLogin;
  final Widget? icon;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isGoogleLogin = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0), // rounded-xl
    );

    if (isGoogleLogin) {
      // Google 로그인 버튼 스타일
      return Container(
        height: 50, // py-3 근사치
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
                color: const Color(0xFFD1D5DB), width: 1.0), // border-gray-300
            color: AppColors.cardBackground, // bg-white
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ), // shadow-sm
            ]),
        child: InkWell(
          onTap: onPressed,
          customBorder: shape,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 12.0), // space-x-3
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500, // font-medium
                    color: Color(0xFF374151), // text-gray-700
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 메인 그라데이션 버튼 스타일
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
        // HTML의 .primary-btn box-shadow 구현
        boxShadow: [
          BoxShadow(
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
              text, // 💡 [수정 사항] LoginPage와 달리, 전달받은 텍스트를 사용하도록 수정
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // 비밀번호 가시성 토글을 위한 상태 변수
  bool _showPassword1 = false;
  bool _showPassword2 = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 회원가입 처리 로직
  void _signUp() {
    if (_formKey.currentState!.validate()) {
      // FormFieldValidator가 일치 여부를 체크하지만, 버튼 클릭 시 최종 확인
      if (_passwordController.text != _confirmPasswordController.text) {
        _showMessage('비밀번호가 일치하지 않습니다.');
        return;
      }

      // TODO: 실제 서버 통신 회원가입 로직 구현
      print('회원가입 시도: ${_emailController.text}');

      _showMessage('회원가입 성공! 로그인 페이지로 이동합니다.');
      // 회원가입 성공 시 이전 페이지(로그인 페이지)로 돌아가기
      Navigator.pop(context);
    }
  }

  // 메시지 박스 (LoginPage와 동일)
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

  // 로그인 페이지로 돌아가기
  void _handleBackToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // LoginPage와 동일한 배경 그라데이션 적용
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
        appBar: null, // AppBar 제거하여 전체 화면 UI 구성
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              // LoginPage와 동일한 카드 스타일 적용
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0), // rounded-3xl
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5.0, sigmaY: 5.0), // backdrop-blur-sm
                  child: Container(
                    padding: const EdgeInsets.all(40),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          // 1. 제목 (LoginPage의 GradientText 사용)
                          const GradientText(
                            'StudyFlow',
                            fontSize: 30.0,
                            fontWeight: FontWeight.w900,
                          ),
                          const SizedBox(height: 5),

                          // 2. 부제목
                          const Text(
                            '새 계정을 만들어 학습을 시작하세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 32.0),

                          // 3. 이메일 입력 필드 (CustomTextField 사용)
                          CustomTextField(
                            controller: _emailController,
                            labelText: '이메일 주소 (아이디)',
                            hintText: 'name@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이메일을 입력해주세요.';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return '유효한 이메일 형식이 아닙니다.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),

                          // 4. 비밀번호 입력 필드 (CustomTextField + PasswordVisibilityToggle 사용)
                          CustomTextField(
                            controller: _passwordController,
                            labelText: '비밀번호',
                            hintText: '8자 이상 입력해주세요',
                            obscureText: !_showPassword1,
                            suffixIcon: PasswordVisibilityToggle(
                              isVisible: _showPassword1,
                              onTap: () {
                                setState(() {
                                  _showPassword1 = !_showPassword1;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.length < 8) {
                                return '비밀번호는 8자 이상이어야 합니다.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20.0),

                          // 5. 비밀번호 확인 필드 (CustomTextField + PasswordVisibilityToggle 사용)
                          CustomTextField(
                            controller: _confirmPasswordController,
                            labelText: '비밀번호 확인',
                            hintText: '비밀번호를 다시 입력해주세요',
                            obscureText: !_showPassword2,
                            suffixIcon: PasswordVisibilityToggle(
                              isVisible: _showPassword2,
                              onTap: () {
                                setState(() {
                                  _showPassword2 = !_showPassword2;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호 확인을 입력해주세요.';
                              }
                              if (value != _passwordController.text) {
                                return '비밀번호가 일치하지 않습니다.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40.0),

                          // 6. 회원가입 버튼 (GradientButton 사용)
                          GradientButton(
                            text: '회원가입 완료',
                            onPressed: _signUp,
                          ),
                          const SizedBox(height: 24.0),

                          // 7. 로그인 페이지로 돌아가기 링크
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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
      ),
    );
  }
}
