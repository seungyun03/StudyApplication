import 'package:flutter/material.dart';

// 💡 [참고] 네비게이션을 위한 임시 import (실제 프로젝트 구조에 따라 수정 필요)
import 'package:study_app/FrontEnd/homepage.dart' as hp;
import 'package:study_app/FrontEnd/Settings/SettingsPage.dart' as sp;

// 💡 [추가] EditingProfilePage.dart 파일 import (프로필 편집 이동을 위해)
import 'package:study_app/FrontEnd/Settings/EditingProfilePage.dart' as epp;

// =============================================================================
// 1. Color and Style Definitions
// =============================================================================
class AppColors {
  static const Color background = Color(0xFFF9FAFB);
  static const Color primaryText = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color primaryBrand = Color(0xFF2563EB); // Active blue
  static const Color primaryBrandBg = Color(0xFFDBEAFE); // Light blue avatar
  static const Color secondaryButtonBg = Color(0xFFF3F4F6); // Grey Button
  static const Color secondaryIcon = Color(0xFF4B5563); // Dark Grey Icon (Back)
  static const Color successBg = Color(0xFFDCFCE7); // Light Green (Professor)
  static const Color successText = Color(0xFF16A34A); // Dark Green
  static const Color purpleBg = Color(0xFFF3E8FF); // Light Purple (Admin)
  static const Color purpleText = Color(0xFF9333EA); // Dark Purple
  static const Color dangerBg = Color(0xFFFEF2F2); // Light Red
  static const Color dangerBorder = Color(0xFFFECACA); // Red Border
  static const Color dangerText = Color(0xFFDC2626); // Dark Red
  static const Color divider =
      Color(0xFFF3F4F6); // Gray-100 equivalent for divider
  static const Color chevron = Color(0xFF9CA3AF); // Chevron/Refresh icon
  static const Color lightBlueBg = Color(0xFFEFF6FF); // Active badge background
}

// 아이콘 매핑 (Lucide Icons to Material Icons)
class AppIcons {
  static const IconData messageSquare = Icons.message_outlined;
  static const IconData home = Icons.home_outlined;
  static const IconData settings = Icons.settings_outlined;
  static const IconData arrowLeft = Icons.arrow_back;
  static const IconData arrowRightLeft =
      Icons.refresh; // ArrowRightLeft in Lucide
  static const IconData edit = Icons.edit_outlined;
  static const IconData logOut = Icons.logout;
  static const IconData chevronRight = Icons.chevron_right;
  static const IconData plus = Icons.add;
}

// =============================================================================
// 2. Bottom Navigation Bar Components (Replicating the React structure/style)
// =============================================================================

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
    final Color color = active ? AppColors.primaryBrand : AppColors.chevron;
    final FontWeight fontWeight = active ? FontWeight.w500 : FontWeight.w400;

    // The React component uses a simple flex container for the button content
    return Expanded(
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          // Replicating the button structure from the React component
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: fontWeight,
                    fontSize: 13.87, // Matching the font size/line height
                    height: 20 / 13.87,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationBarWidget extends StatelessWidget {
  const _BottomNavigationBarWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: AppIcons.messageSquare, // React used Users/messageSquare
              label: "커뮤니티",
              active: false,
              onTap: () {
                debugPrint("Navigate to Community");
              },
            ),
            _NavItem(
              icon: AppIcons.home,
              label: "홈",
              active: false,
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const hp.HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            _NavItem(
              icon: AppIcons.settings,
              label: "설정",
              active: true, // Active item
              onTap: () {
                // Navigate back to Settings Page or replace if it's not in stack
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const sp.SettingsPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 3. Profile Item Widgets
// =============================================================================

// Widget for the profile's first initial avatar
class _Avatar extends StatelessWidget {
  final String initial;
  final Color bgColor;
  final Color textColor;
  final double size;
  final double fontSize;

  const _Avatar({
    required this.initial,
    required this.bgColor,
    required this.textColor,
    this.size = 48.0,
    this.fontSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
          height: 28 / fontSize,
          color: textColor,
        ),
      ),
    );
  }
}

// Current Active Profile Card
class _CurrentProfileCard extends StatelessWidget {
  const _CurrentProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0), // rounded-2xl
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Info
          Expanded(
            child: Row(
              children: [
                const _Avatar(
                  initial: '김',
                  bgColor: AppColors.primaryBrandBg,
                  textColor: AppColors.primaryBrand,
                  size: 48.0,
                  fontSize: 18.0,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '김학생',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: 17.0,
                          height: 24 / 17.0,
                          color: AppColors.primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'student@school.ac.kr',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0,
                          height: 20 / 14.0,
                          color: AppColors.secondaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Active Badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(999.0), // rounded-full
            ),
            child: const Text(
              '활성',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
                height: 16 / 12.5,
                color: AppColors.primaryBrand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Switchable Account Item
class _AccountItem extends StatelessWidget {
  final String initial;
  final Color bgColor;
  final Color textColor;
  final String name;
  final String email;
  final bool isAddAccount;
  final bool isLast;

  const _AccountItem({
    required this.initial,
    required this.bgColor,
    required this.textColor,
    required this.name,
    required this.email,
    this.isAddAccount = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    // Border is handled by the parent Column's Divider/ClipRRect
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          debugPrint("Switch/Add Account Tapped: $name");
        },
        hoverColor: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Avatar or Plus Icon
                    isAddAccount
                        ? Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryButtonBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(AppIcons.plus,
                                size: 20.0, color: AppColors.secondaryText),
                          )
                        : _Avatar(
                            initial: initial,
                            bgColor: bgColor,
                            textColor: textColor,
                            size: 40.0,
                            fontSize: 16.0,
                          ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 15.0,
                              height: 20 / 15.0,
                              color: isAddAccount
                                  ? const Color(0xFF374151)
                                  : AppColors.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 12.9,
                              height: 16 / 12.9,
                              color: AppColors.secondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                // ArrowRightLeft icon
                AppIcons.arrowRightLeft,
                size: 16.0,
                color: AppColors.chevron,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Action Item (e.g., Edit Profile)
class _ActionItem extends StatelessWidget {
  const _ActionItem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // 💡 [수정] 프로필 편집 페이지로 이동하는 기능 추가
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const epp.EditingProfilePage()),
            );
          },
          borderRadius: BorderRadius.circular(16.0),
          hoverColor: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(AppIcons.edit,
                        size: 20.0, color: AppColors.secondaryText),
                    const SizedBox(width: 8.0), // gap-2 in tailwind
                    Text(
                      '프로필 편집',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 15.0,
                        height: 20 / 15.0,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                const Icon(AppIcons.chevronRight,
                    size: 16.0, color: AppColors.chevron),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Logout Button
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          54.0, // py-4 (16*2) + line height (20) = 52.0, adjusted to look right
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.dangerBorder),
      ),
      child: Material(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(16.0),
        child: InkWell(
          onTap: () {
            // Placeholder for logout logic
            debugPrint("Logout Tapped");
          },
          borderRadius: BorderRadius.circular(16.0),
          hoverColor: const Color(0xFFFEE2E2), // Tailwind hover:bg-red-100
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(AppIcons.logOut,
                    size: 20.0, color: AppColors.dangerText),
                const SizedBox(width: 8.0), // gap-2
                Text(
                  '현재 계정에서 로그아웃',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                    fontSize: 15.0,
                    height: 20 / 15.0,
                    color: AppColors.dangerText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// 4. Main Page Widget
// =============================================================================

class ProfileManagementPage extends StatelessWidget {
  const ProfileManagementPage({super.key});

  // Custom Header
  Widget _buildHeader(BuildContext context, double horizontalPadding) {
    return Container(
      width: double.infinity,
      // px-[46px] in React code, using horizontalPadding here for responsiveness
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 12.0), // Adjusted to match 122px height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button (positioned on the right in React, moving it to left for standard UX)
              SizedBox(
                width: 48.0,
                height: 48.0,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to SettingsPage
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryButtonBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: const Icon(AppIcons.arrowLeft,
                      color: AppColors.secondaryIcon, size: 20.0),
                ),
              ),

              // Title (centered left relative to back button)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0), // Adjusted margin
                  child: Text(
                    '프로필 관리',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: 24.0,
                      height: 28 / 24.0,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Section Titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 13.0,
          height: 16 / 13.0,
          letterSpacing: 0.3,
          color: AppColors.secondaryText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive Padding Logic
          final double horizontalPadding =
              constraints.maxWidth > 768 ? 48.0 : 24.0; // md:px-12 vs px-6

          // The max width for the content is 1366px (mx-auto container)
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1366),
              child: Stack(
                children: [
                  // Scrollable Content
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                          left: horizontalPadding,
                          right: horizontalPadding,
                          top: 122 +
                              43, // Header height (approx 122) + top margin (43)
                          bottom: 65 +
                              43 // Bottom nav height (65) + bottom margin (43)
                          ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Current Profile Section ---
                          _buildSectionTitle('현재 계정'),
                          const _CurrentProfileCard(),
                          const SizedBox(height: 32.0), // mb-[43px] adjusted

                          // --- Account Switching Section ---
                          _buildSectionTitle('다른 계정'),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.05),
                                  spreadRadius: 0,
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16.0),
                              child: Column(
                                children: [
                                  // Account Item 1 - 박교수
                                  const _AccountItem(
                                    initial: '박',
                                    bgColor: AppColors.successBg,
                                    textColor: AppColors.successText,
                                    name: '박교수',
                                    email: 'professor@school.ac.kr',
                                    isLast: false,
                                  ),
                                  // Divider (handled by a separator or explicit Divider)
                                  const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.divider),
                                  // Account Item 2 - 관리자
                                  const _AccountItem(
                                    initial: '이',
                                    bgColor: AppColors.purpleBg,
                                    textColor: AppColors.purpleText,
                                    name: '관리자',
                                    email: 'admin@school.ac.kr',
                                    isLast: false,
                                  ),
                                  const Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.divider),
                                  // Add Account Item
                                  const _AccountItem(
                                    initial: '+',
                                    bgColor: Colors
                                        .transparent, // Avatar handled internally
                                    textColor: Colors.transparent,
                                    name: '다른 계정 추가',
                                    email: '새 계정으로 로그인하기',
                                    isAddAccount: true,
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32.0),

                          // --- Account Actions Section ---
                          _buildSectionTitle('계정 관리'),
                          const _ActionItem(),
                          const SizedBox(height: 32.0),

                          // --- Logout Section ---
                          const _LogoutButton(),
                        ],
                      ),
                    ),
                  ),

                  // App Header (Fixed Position)
                  _buildHeader(context, horizontalPadding),

                  // Bottom Navigation Bar (Fixed Position)
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: _BottomNavigationBarWidget(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
