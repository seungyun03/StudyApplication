import 'package:flutter/material.dart';
import 'dart:ui'; // BackdropFilter를 위해 필요합니다.

// 💡 [추가/수정 필요] 실제 HomePage.dart 및 SignUpPage.dart 파일을 가져옵니다.
// **경로를 프로젝트 구조에 맞게 수정해주세요.**
import 'Homepage.dart'; // 예시 경로
import 'SignUpPage.dart'; // <--- 이 줄을 추가합니다. (예시 경로)

// 💡 HTML의 Tailwind 색상을 기반으로 정의됩니다. (중성적 디자인 테마로 수정됨)
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

// 💡 main 함수: 앱의 시작점
void main() {
  runApp(const MyApp());
}

// 💡 앱의 루트 위젯 (MaterialApp 설정)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyFlow 로그인',
      // Inter 폰트 사용을 가정합니다. (pubspec.yaml에 등록 필요)
      theme: ThemeData(
        fontFamily: 'Inter', // 폰트 등록 시 주석 해제
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGradientStart,
          primary: AppColors.primaryGradientStart,
        ),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false, // 디버그 배너 숨기기
    );
  }
}

// 💡 [삭제됨] 임시 HomePage 정의는 제거되었습니다.

// 💡 [삭제됨] 임시 SignUpPage 정의는 제거되었습니다.

// 💡 비밀번호 표시/숨김 아이콘 토글 위젯 (HTML의 Eye/EyeOff 아이콘)
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

// 💡 StudyFlow 텍스트에 그라데이션을 적용하는 위젯 (HTML의 .gradient-text)
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

// 💡 커스텀 텍스트 필드 위젯 (HTML의 .input-field)
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
            fillColor: AppColors.inputBackground, // bg-gray-50
            suffixIcon: suffixIcon,
            border: inputBorder,
            enabledBorder: inputBorder,
            focusedBorder: focusedBorder,
            contentPadding: const EdgeInsets.symmetric(
                vertical: 14.0, horizontal: 16.0), // p-3 근사치
          ),
        ),
      ],
    );
  }
}

// 💡 디자인에 따른 그라디언트 버튼 위젯 (HTML의 .primary-btn 및 Google 버튼)
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
                color: AppColors.border, width: 1.0), // border-gray-300
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

    // 메인 로그인 버튼 스타일 (그라데이션 배경 + 그림자)
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
          child: const Center(
            child: Text(
              '로그인',
              style: TextStyle(
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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 로그인 처리 시뮬레이션
  void _handleLogin() {
    // 1. 입력 필드 유효성 검사 (임시)
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showMessage('이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    // 2. 실제 로그인 로직 (API 호출 등)을 구현할 위치입니다.
    print('로그인 시도: ${_emailController.text}');

    // 3. HomePage로 이동 (Navigator.pushReplacement를 사용하여 뒤로 가기 버튼으로 로그인 화면으로 돌아오지 않도록 함)
    // 💡 import된 실제 HomePage 위젯을 사용합니다.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  // Google 로그인 처리 시뮬레이션
  void _handleGoogleLogin() {
    _showMessage('Google 로그인 기능은 현재 개발 중입니다.');
  }

  // 회원가입 처리 로직 (버튼 클릭 시 SignUpPage로 이동)
  void _handleSignup() {
    // 💡 [수정 사항] Navigator를 사용하여 SignUpPage로 이동합니다.
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }

  // 메시지 박스 (HTML의 커스텀 모달 대체)
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

  // Google 로고 아이콘 (HTML의 인라인 SVG)
  Widget _buildGoogleIcon() {
    // HTML의 SVG 경로를 반영합니다.
    return Image.asset(
      'assets/images/google_logo.png', // pubspec.yaml에 등록해야 함
      height: 20,
      errorBuilder: (context, error, stackTrace) {
        // 이미지 로드 실패 시 대체 위젯
        return const Icon(
          Icons.g_mobiledata, // 대체 아이콘
          color: AppColors.primaryGradientStart,
          size: 24,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // HTML의 body 스타일: bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50
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
            // **앱 기기 상관없이 화면 비율 자동 조절 (반응형 개선)**
            // 1. SingleChildScrollView: 화면이 작아도 스크롤 가능하게 함
            // 2. Center: 내용을 중앙에 배치
            // 3. ConstrainedBox(maxWidth: 600): 카드 너비를 600px로 확장하여 태블릿에서도 더 꽉 차 보이게 조정
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              // 태블릿 등 넓은 화면에서 더 많은 영역을 채우도록 600.0으로 조정
              constraints: const BoxConstraints(maxWidth: 600),
              // HTML의 카드 스타일: bg-white/80 backdrop-blur-sm rounded-3xl shadow-2xl
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0), // rounded-3xl
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5.0, sigmaY: 5.0), // backdrop-blur-sm
                  child: Container(
                    // 로고 짤림 방지 및 디자인 의도 유지를 위해 상단 패딩 유지
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
                        // 1. 로고 및 컨테이너 (.logo-container top: -40px 효과 재현)
                        Transform.translate(
                          // 상단으로 20px 이동하여 카드 위에 걸치게 함 (짤림 방지)
                          offset: const Offset(0, -20),
                          child: Container(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/logo_studyflow.png',
                              height: 180, // w-44 h-44 근사치
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // 이미지 로드 실패 시 대체 위젯
                                return Container(
                                  width: 176, // w-44 (176px)
                                  height: 176, // h-44
                                  decoration: BoxDecoration(
                                      color: AppColors.primaryGradientStart,
                                      borderRadius: BorderRadius.circular(
                                          999), // rounded-full
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.5),
                                          width: 4), // border-4 border-white/50
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ), // shadow-lg
                                      ]),
                                  child: const Center(
                                    child: Text('StudyFlow',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration
                                              .none, // 에러 빌더에서 텍스트 밑줄 제거
                                        )),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // 2. 제목 (h1) - 그라데이션 적용
                        // 로고 아래에 최대한 붙이기 위해 상단 여백 제거
                        Padding(
                          padding: EdgeInsets.zero,
                          child: GradientText(
                            'StudyFlow',
                            fontSize: 30.0, // text-3xl
                            fontWeight: FontWeight.w900, // font-extrabold 근사치
                          ),
                        ),

                        const SizedBox(height: 5), // 제목과 부제 사이의 최소 간격 유지

                        // 3. 부제목 (p)
                        const Text(
                          '계정에 로그인하여 공부를 시작하세요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: AppColors.secondaryText, // text-gray-500
                          ),
                        ),
                        const SizedBox(height: 32.0), // mt-8 근사치

                        // 4. 이메일 입력 필드
                        CustomTextField(
                          controller: _emailController,
                          labelText: '이메일 주소',
                          hintText: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20.0), // mb-5 근사치

                        // 5. 비밀번호 입력 필드
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
                        const SizedBox(height: 20.0), // mb-6 근사치

                        // 6. '로그인 유지' 체크박스 및 '비밀번호 찾기'
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: [
                                SizedBox(
                                  width: 24.0,
                                  height: 24.0,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (bool? newValue) {
                                      setState(() {
                                        _rememberMe = newValue!;
                                      });
                                    },
                                    activeColor: AppColors.primaryGradientStart,
                                    checkColor: Colors.white,
                                    // HTML 스타일과 유사하게 맞추기 위해 패딩 제거
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                const SizedBox(width: 8.0), // ml-2
                                const Text(
                                  '로그인 유지',
                                  style: TextStyle(
                                      color: Color(0xFF4B5563), // text-gray-600
                                      fontSize: 14.0 // text-sm
                                      ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () => _showMessage(
                                  '비밀번호 찾기 기능을 준비 중입니다.'), // HTML의 showMessage
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                '비밀번호를 잊으셨나요?',
                                style: TextStyle(
                                    color: AppColors
                                        .primaryGradientStart, // text-indigo-600
                                    fontWeight: FontWeight.w600, // font-medium
                                    fontSize: 14.0 // text-sm
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24.0), // mb-6 근사치

                        // 7. 메인 로그인 버튼 (그라디언트)
                        GradientButton(
                          text: '로그인',
                          onPressed: _handleLogin,
                        ),
                        const SizedBox(height: 24.0), // mb-4 + 구분선 상단 여백

                        // 8. 구분선 (HTML의 flex items-center my-6)
                        Row(
                          children: [
                            const Expanded(
                                child: Divider(
                                    color: Color(0xFFE5E7EB),
                                    thickness: 1.0)), // border-gray-200
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0), // px-3
                              child: Text('또는',
                                  style: TextStyle(
                                      color: AppColors
                                          .secondaryText, // text-gray-500
                                      fontSize: 14.0, // text-sm
                                      fontWeight: FontWeight.w500)),
                            ),
                            const Expanded(
                                child: Divider(
                                    color: Color(0xFFE5E7EB), thickness: 1.0)),
                          ],
                        ),
                        const SizedBox(height: 24.0), // my-6 근사치

                        // 9. Google 로그인 버튼
                        GradientButton(
                          text: 'Google 계정으로 로그인',
                          onPressed:
                              _handleGoogleLogin, // HTML의 handleGoogleLogin
                          isGoogleLogin: true,
                          icon: _buildGoogleIcon(),
                        ),
                        const SizedBox(height: 24.0), // mb-6 근사치

                        // 10. 회원가입 링크
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '계정이 없으신가요? ',
                              style: TextStyle(
                                  color: Color(0xFF4B5563), // text-gray-600
                                  fontSize: 14.0),
                            ),
                            TextButton(
                              // 💡 [수정 사항] Navigator를 통해 SignUpPage로 이동합니다.
                              onPressed: _handleSignup,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                '회원가입 하기',
                                style: TextStyle(
                                  color: AppColors.primaryGradientStart,
                                  fontWeight: FontWeight.bold, // font-semibold
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
