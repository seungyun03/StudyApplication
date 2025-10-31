import 'package:flutter/material.dart';

// 💡 [수정] homepage.dart 파일 import 및 별칭 부여 (홈 이동을 위해 필요)
import 'package:study_app/FrontEnd/homepage.dart' as hp;

// 💡 [추가] EditingPasswordPage 파일 import 및 별칭 부여 (비밀번호 변경 페이지 이동을 위해 필요)
import 'package:study_app/FrontEnd/Settings/EditingPasswordPage.dart' as ep;

// 💡 [핵심 수정] ProfileManagementPage 파일 import 및 별칭 부여 (Settings 폴더 제거하여 올바른 경로로 수정)
import 'package:study_app/FrontEnd/Settings/ProfileManagementPage.dart' as pmp;

// 색상 정의 (Tailwind CSS hex codes to Flutter Color)
class AppColors {
  static const Color background = Color(0xFFF9FAFB);
  static const Color primaryText = Color(0xFF111827);
  static const Color secondaryText = Color(0xFF6B7280);
  static const Color primaryBrand = Color(0xFF2563EB);
  static const Color primaryBrandBg = Color(0xFFDBEAFE);
  static const Color border = Color(0xFFF3F4F6);
  static const Color chevron = Color(0xFF9CA3AF);
}

// 아이콘 매핑 (Lucide Icons to Material Icons)
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
  // 💡 [추가] keyIcon for password change
  static const IconData keyIcon = Icons.vpn_key_outlined;
}

// NavItem 위젯 (Bottom Navigation Bar 항목)
class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap; // 💡 탭 이벤트 핸들러 추가

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 탭 가능하도록 InkWell로 감싸기
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
                color:
                    active ? AppColors.primaryBrand : AppColors.secondaryText,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom Navigation Bar 위젯
class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
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
          // 커뮤니티 (기능 없음)
          NavItem(
            icon: LucideIcons.messageCircle,
            label: "커뮤니티",
            active: false,
            onTap: () {},
          ),
          // 홈 (homepage로 이동) 💡 [수정] NavItem에 onTap 기능 추가
          NavItem(
            icon: LucideIcons.home,
            label: "홈",
            active: false,
            onTap: () {
              // 홈 버튼 클릭 시 homepage.dart로 이동
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => hp.HomePage()),
              );
            },
          ),
          // 설정 (현재 페이지)
          NavItem(
            icon: LucideIcons.settings,
            label: "설정",
            active: true,
            onTap: () {
              // 현재 페이지이므로 아무것도 하지 않음.
            },
          ),
        ],
      ),
    );
  }
}

// 설정 항목 (SettingsOption)
class SettingsOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool showChevron;
  final bool isLast;
  final VoidCallback? onTap;

  const SettingsOption({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.showChevron = false,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isLast ? 0 : 0),
            bottom: Radius.circular(isLast ? 0 : 0),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryText, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                if (value != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      value!,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                if (showChevron)
                  const Icon(LucideIcons.chevronRight,
                      color: AppColors.chevron, size: 20),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1, indent: 56, color: AppColors.border, thickness: 1),
      ],
    );
  }
}

// 설정 페이지 위젯
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _buildSection({
    required String title,
    required List<SettingsOption> options,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: options,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80 + MediaQuery.of(context).padding.top, // Padding top 포함
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      alignment: Alignment.center,
      child: const Text(
        "설정",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: false, // Custom header handles safe area
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                // 상단 헤더 공간 확보
                padding: EdgeInsets.only(
                    top: 80 + MediaQuery.of(context).padding.top),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // --- Account Section ---
                      _buildSection(
                        title: "계정",
                        options: [
                          // 💡 [수정] 프로필 수정 옵션에 onTap 기능 추가 (ProfileManagementPage로 이동)
                          SettingsOption(
                            icon: LucideIcons.user,
                            label: "프로필 수정",
                            showChevron: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const pmp.ProfileManagementPage(),
                                ),
                              );
                            },
                          ),
                          // 💡 [추가] 비밀번호 변경 옵션 (EditingPasswordPage로 이동)
                          SettingsOption(
                            icon: LucideIcons.keyIcon,
                            label: "비밀번호 변경",
                            showChevron: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ep.EditingPasswordPage()),
                              );
                            },
                          ),
                          const SettingsOption(
                            icon: LucideIcons.lock,
                            label: "로그아웃",
                            showChevron: false,
                            isLast: true,
                          ),
                        ],
                      ),
                      // --- Notification Section ---
                      _buildSection(
                        title: "알림",
                        options: [
                          const SettingsOption(
                            icon: LucideIcons.bell,
                            label: "알림 설정",
                            showChevron: true,
                            isLast: true,
                          ),
                        ],
                      ),
                      // --- Support Section ---
                      _buildSection(
                        title: "지원",
                        options: [
                          const SettingsOption(
                            icon: LucideIcons.helpCircle,
                            label: "도움말",
                            showChevron: true,
                          ),
                          const SettingsOption(
                            icon: LucideIcons.info,
                            label: "앱 정보",
                            value: "v1.2.0",
                            showChevron: true,
                            isLast: true,
                          ),
                        ],
                      ),
                      // Padding for Bottom Navigation bar clearance
                      const SizedBox(height: 85), // 하단 네비게이션 바 공간 확보
                    ],
                  ),
                ),
              ),
            ),
            // App Header (Fixed Position)
            _buildHeader(context),
            // Bottom Navigation Bar (Fixed Position)
            const Align(
              alignment: Alignment.bottomCenter,
              child: BottomNavigationBarWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
