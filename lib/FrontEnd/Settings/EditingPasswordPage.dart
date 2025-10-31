import 'package:flutter/material.dart';

// 💡 [추가] homepage.dart 파일 import 및 별칭 부여 (홈 버튼에서 이동하기 위해 필요)
import 'package:study_app/FrontEnd/homepage.dart' as hp;

// =============================================================================
// 1. App Colors (Tailwind to Flutter Mapping)
// =============================================================================
class AppColors {
  static const Color background = Color(0xFFF9FAFB);
  static const Color primaryDark =
      Color(0xFF1F2937); // Header title, Save button
  static const Color inputDarkText = Color(0xFF111827); // Input text
  static const Color labelText = Color(0xFF374151); // Input label
  static const Color inputBorder = Color(0xFFD1D5DB); // Input border
  static const Color success = Color(0xFF16A34A); // Check mark green
  static const Color iconGrey = Color(0xFF6B7280); // Eye icon
  static const Color placeholderText = Color(0xFFA9A9A9); // Placeholder text
  static const Color secondaryButtonBg =
      Color(0xFFF3F4F6); // Back button background
  static const Color secondaryButtonHover =
      Color(0xFFE5E7EB); // Back button hover (used for splash)
  static const Color secondaryIcon = Color(0xFF4B5563); // Back button icon
  static const Color disabledBg =
      Color(0xFFD1D5DB); // Disabled Save button background
  static const Color disabledText =
      Color(0xFF9CA3AF); // Disabled Save button text

  // 💡 [추가] SettingsPage.dart에서 가져온 네비게이션 색상
  static const Color primaryBrand = Color(0xFF2563EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color secondaryTextNav = Color(0xFF6B7280);
  static const Color chevron = Color(0xFF9CA3AF);
}

// 💡 [추가] LucideIcons 정의 (SettingsPage.dart에서 가져옴)
class LucideIcons {
  static const IconData user = Icons.person_outline;
  static const IconData lock = Icons.lock_outline;
  static const IconData bell = Icons.notifications_none;
  static const IconData helpCircle = Icons.help_outline;
  static const IconData info = Icons.info_outline;
  static const IconData messageCircle = Icons.message_outlined;
  static const IconData home = Icons.home_outlined;
  static const IconData settings = Icons.settings_outlined;
  static const IconData chevronRight = Icons.chevron_right;
  static const IconData keyIcon = Icons.vpn_key_outlined;
}

// =============================================================================
// 2. Custom Widgets (For Reusability and Clean Code)
// =============================================================================

// 비밀번호 입력 필드 위젯
class _PasswordField extends StatelessWidget {
  final String label;
  final String placeholder;
  final String value;
  final ValueChanged<String> onChanged;
  final bool isPasswordVisible;
  final VoidCallback toggleVisibility;
  final bool isValid;
  final bool showCheckMark;

  const _PasswordField({
    required this.label,
    required this.placeholder,
    required this.value,
    required this.onChanged,
    required this.isPasswordVisible,
    required this.toggleVisibility,
    required this.isValid,
    required this.showCheckMark,
  });

  @override
  Widget build(BuildContext context) {
    // Label Style
    final TextStyle labelStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 18, // Adjusted for typical mobile size
      color: AppColors.labelText,
    );

    // Input Field Height and Text Style
    const double inputHeight = 68.0;
    const TextStyle inputTextStyle = TextStyle(
      fontSize: 20,
      color: AppColors.inputDarkText,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: labelStyle,
          ),
        ),
        Container(
          height: inputHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              TextFormField(
                initialValue: value,
                onChanged: onChanged,
                obscureText: !isPasswordVisible,
                keyboardType: TextInputType.visiblePassword,
                style: inputTextStyle,
                decoration: InputDecoration(
                  hintText: placeholder,
                  hintStyle: const TextStyle(
                      color: AppColors.placeholderText, fontSize: 20),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showCheckMark && isValid)
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.iconGrey,
                        size: 24,
                      ),
                      onPressed: toggleVisibility,
                      splashRadius: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 💡 [추가] Bottom Navigation Bar 항목 위젯 (NavItem)
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: active ? AppColors.primaryBrand : AppColors.chevron,
                size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 13.8,
                color: active
                    ? AppColors.primaryBrand
                    : AppColors.secondaryTextNav,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 💡 [추가] Bottom Navigation Bar 위젯 (BottomNavigationBarWidget)
class _BottomNavigationBarWidget extends StatelessWidget {
  const _BottomNavigationBarWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: LucideIcons.messageCircle,
            label: "커뮤니티",
            active: false,
            onTap: () {},
          ),
          // 💡 [수정] 홈 버튼 클릭 시 homepage.dart로 이동
          _NavItem(
            icon: LucideIcons.home,
            label: "홈",
            active: true, // 이 페이지에서는 홈으로 이동하는 것이 주 목적이므로 활성화된 것처럼 표시
            onTap: () {
              // 현재 스택을 모두 제거하고 (비밀번호 변경 -> 설정 페이지) 새 홈 화면을 띄움
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => hp.HomePage()),
                (Route<dynamic> route) => false, // 모든 이전 라우트 스택 제거
              );
            },
          ),
          _NavItem(
            icon: LucideIcons.settings,
            label: "설정",
            active: false,
            onTap: () {
              // 설정 페이지로 돌아가기 (뒤로가기)
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 3. Main Page Widget
// =============================================================================

class EditingPasswordPage extends StatefulWidget {
  const EditingPasswordPage({super.key});

  @override
  State<EditingPasswordPage> createState() => _EditingPasswordPageState();
}

class _EditingPasswordPageState extends State<EditingPasswordPage> {
  // State variables from React component
  String _currentPassword = '12345678'; // Default value as in React snippet
  String _newPassword = '';
  String _confirmPassword = '';

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Validation Getters
  bool get _isCurrentPasswordValid => _currentPassword.length >= 8;
  bool get _isNewPasswordValid => _newPassword.length >= 8;
  bool get _isConfirmPasswordValid =>
      _confirmPassword == _newPassword && _confirmPassword.length >= 8;
  bool get _isSaveEnabled =>
      _isCurrentPasswordValid && _isNewPasswordValid && _isConfirmPasswordValid;

  // Handlers
  void _handleSave() {
    if (_isSaveEnabled) {
      // 🚨 TODO: 나중에 Spring Boot API로 비밀번호 변경 요청을 보내는 로직을 여기에 구현하세요.
      print('--- 비밀번호 변경 요청 시작 ---');
      print('현재 비밀번호: $_currentPassword');
      print('새 비밀번호: $_newPassword');

      // 성공 시: 이전 페이지로 돌아가기 (SettingsPage)
      Navigator.pop(context);
    }
  }

  void _handleBack() {
    print('Go back (Simulation)');
    Navigator.pop(context); // 이전 화면으로 돌아가기 (SettingsPage)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main Content (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Password Field
                    _PasswordField(
                      label: "현재 비밀번호",
                      placeholder: "현재 비밀번호를 입력하세요 (자동완성된 경우 수정)",
                      value: _currentPassword,
                      onChanged: (value) =>
                          setState(() => _currentPassword = value),
                      isPasswordVisible: _showCurrentPassword,
                      toggleVisibility: () => setState(
                          () => _showCurrentPassword = !_showCurrentPassword),
                      isValid: _isCurrentPasswordValid,
                      showCheckMark: true,
                    ),
                    const SizedBox(height: 32),

                    // New Password Field
                    _PasswordField(
                      label: "새 비밀번호 (8자 이상)",
                      placeholder: "새 비밀번호를 입력하세요",
                      value: _newPassword,
                      onChanged: (value) =>
                          setState(() => _newPassword = value),
                      isPasswordVisible: _showNewPassword,
                      toggleVisibility: () =>
                          setState(() => _showNewPassword = !_showNewPassword),
                      isValid: _isNewPasswordValid,
                      showCheckMark: false,
                    ),
                    const SizedBox(height: 32),

                    // Confirm Password Field
                    _PasswordField(
                      label: "새 비밀번호 확인",
                      placeholder: "새 비밀번호를 다시 입력하세요",
                      value: _confirmPassword,
                      onChanged: (value) =>
                          setState(() => _confirmPassword = value),
                      isPasswordVisible: _showConfirmPassword,
                      toggleVisibility: () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword),
                      isValid: _isConfirmPasswordValid,
                      showCheckMark: false,
                    ),
                    const SizedBox(height: 32),
                    // 하단 네비게이션 바 공간 확보
                    const SizedBox(height: 85),
                  ],
                ),
              ),
            ),

            // Footer (Fixed at the Bottom)
            _buildFooter(),
          ],
        ),
      ),
      // 💡 [추가] 하단 네비게이션 바 추가
      bottomNavigationBar: const _BottomNavigationBarWidget(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 70, // Adjust height
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000), // Shadow-sm equivalent
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        "비밀번호 변경",
        style: TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w800,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      height: 93,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Save Button
          SizedBox(
            width: double.infinity,
            child: FractionallySizedBox(
              widthFactor: 0.8, // Adjust to fit max-width of React component
              child: ElevatedButton(
                onPressed: _isSaveEnabled ? _handleSave : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  backgroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: AppColors.disabledBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  "저장",
                  style: TextStyle(
                    color:
                        _isSaveEnabled ? Colors.white : AppColors.disabledText,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),

          // Back Button (positioned on the left)
          Positioned(
            left: 0,
            child: SizedBox(
              width: 54,
              height: 54,
              child: ElevatedButton(
                onPressed: _handleBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryButtonBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                child: const Icon(Icons.arrow_back,
                    color: AppColors.secondaryIcon, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
