import 'package:flutter/material.dart';

// =============================================================================
// 1. Color and Style Definitions (Mapping Tailwind/Hex to Flutter)
// =============================================================================
class AppColors {
  // Background
  static const Color background = Color(0xFFF9FAFB); // bg-[#F9FAFB]

  // Text
  static const Color primaryText = Color(0xFF111827); // Header Title
  static const Color labelText =
      Color(0xFF374151); // Label Text, Change Photo Text
  static const Color secondaryIcon = Color(0xFF4B5563); // Back Button Icon
  static const Color secondaryText = Color(0xFF6B7280); // Disabled Email Text
  static const Color placeholderText =
      Color(0xFFA9A9A9); // Textarea Placeholder
  static const Color errorText =
      Color(0xFFDC2626); // Delete Button Text (Red-600)

  // Brand/Primary
  static const Color primaryBrand =
      Color(0xFF2563EB); // Save Button BG, Avatar Text (Blue-600)
  static const Color primaryBrandBg = Color(0xFFDBEAFE); // Avatar BG (Blue-100)

  // Secondary/Disabled
  static const Color secondaryButtonBg =
      Color(0xFFF3F4F6); // Back Button BG, Disabled Input BG (Gray-100)
  static const Color inputBorder = Color(0xFFD1D5DB); // Input Border (Gray-300)
  static const Color disabledInputBorder =
      Color(0xFFE5E7EB); // Disabled Input Border (Gray-200)
}

// =============================================================================
// 2. Profile Editing Page Widget
// =============================================================================
class EditingProfilePage extends StatefulWidget {
  const EditingProfilePage({super.key});

  @override
  State<EditingProfilePage> createState() => _EditingProfilePageState();
}

class _EditingProfilePageState extends State<EditingProfilePage> {
  // State values and controllers
  String _name = '김학생';
  String _bio = '';
  final String _email = 'student@school.ac.kr'; // Fixed email

  final TextEditingController _nameController =
      TextEditingController(text: '김학생');
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bioController.text = _bio;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _handleSave() {
    // Logic to save the profile data
    setState(() {
      _name = _nameController.text;
      _bio = _bioController.text;
    });
    // print('Profile saved: Name=$_name, Bio=$_bio');
    // In a real app, you would integrate with an API/database here.
  }

  void _handleBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder ensures the page adapts correctly, especially for centering content.
    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = 1366;
        final bool isDesktop = constraints.maxWidth > maxWidth;
        // Calculate padding to center the content on large screens
        final double horizontalPadding =
            isDesktop ? (constraints.maxWidth - maxWidth) / 2 : 0;
        final double contentWidth = isDesktop ? maxWidth : constraints.maxWidth;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // --- Main Scrollable Content Area ---
              Padding(
                // Account for the fixed header height (122px)
                padding: const EdgeInsets.only(top: 122.0),
                child: SingleChildScrollView(
                  child: Container(
                    // Apply horizontal padding for centering on large screens
                    padding:
                        EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                            height:
                                16), // Top padding for Profile Picture Section

                        // 1. Profile Picture Section
                        _buildProfilePictureSection(),

                        const SizedBox(
                            height:
                                32), // Spacer between image/buttons and form

                        // 2. Profile Form Section (Constrained to 513px width)
                        Container(
                          width: contentWidth,
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 513),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildNameInput(),
                                const SizedBox(height: 24),
                                _buildEmailDisplay(),
                                const SizedBox(height: 32),
                                _buildBioInput(),
                                const SizedBox(height: 48), // Bottom padding
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Fixed Header ---
              _buildHeader(contentWidth, horizontalPadding),
            ],
          ),
        );
      },
    );
  }

  // --- Widget Builders ---

  Widget _buildHeader(double contentWidth, double horizontalPadding) {
    return Container(
      width: contentWidth + 2 * horizontalPadding,
      height: 122,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000), // shadow-sm approximation
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Padding(
        // Padding equivalent to 35px from original left/right
        padding: EdgeInsets.symmetric(horizontal: 35.0 + horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back Button (w-[35px] h-[44px] rounded-lg)
            SizedBox(
              width: 54, // Adjusted for a better touch target
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
                  minimumSize: const Size(35, 44),
                ),
                child: Icon(Icons.chevron_left,
                    color: AppColors.secondaryIcon, size: 24),
              ),
            ),

            // Title - Centered
            const Expanded(
              child: Center(
                child: Text(
                  '프로필 편집',
                  style: TextStyle(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize: 35.115,
                    height: 28 / 35.115, // Line height adjustment
                  ),
                ),
              ),
            ),

            // Save Button (w-[90px] h-[54px] bg-[#2563EB] rounded-lg)
            SizedBox(
              width: 90,
              height: 54,
              child: ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  '저장',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22.62,
                    height: 20 / 22.62, // Line height adjustment
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    final String initial = _name.isNotEmpty ? _name[0] : '';

    return Column(
      children: [
        // Avatar (w-[95px] h-[95px] bg-[#DBEAFE] rounded-full)
        Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            color: AppColors.primaryBrandBg,
            shape: BoxShape.circle,
            boxShadow: [
              // Simplified shadow for Flutter
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 4),
                blurRadius: 6,
              ),
            ],
            border: Border.all(color: Colors.white, width: 4), // White ring
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.primaryBrand,
              fontWeight: FontWeight.w500,
              fontSize: 36,
              height: 40 / 36,
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Button Group
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Change Photo Button
            _buildImageActionButton(
              '사진 변경',
              AppColors.labelText,
              () => debugPrint('Change Photo clicked'),
              width: 93,
            ),
            const SizedBox(width: 12),
            // Delete Photo Button
            _buildImageActionButton(
              '삭제',
              AppColors.errorText,
              () => debugPrint('Delete Photo clicked'),
              width: 61,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageActionButton(
      String label, Color textColor, VoidCallback onPressed,
      {double width = 0}) {
    return Container(
      width: width,
      height: 37,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.inputBorder, width: 0.53),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14.93,
            height: 20 / 14.93,
          ),
        ),
      ),
    );
  }

  Widget _buildNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          '이름',
          style: TextStyle(
            color: AppColors.labelText,
            fontWeight: FontWeight.w500,
            fontSize: 22.62,
            height: 20 / 22.62,
          ),
        ),
        const SizedBox(height: 8),

        // Input Field
        Container(
          height: 49,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder, width: 0.53),
          ),
          child: TextFormField(
            controller: _nameController,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 17.07,
              height: 25 / 17.07,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              isDense: true,
            ),
            onChanged: (value) {
              // Rebuild to update the Avatar initial if name changes
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          '이메일',
          style: TextStyle(
            color: AppColors.labelText,
            fontWeight: FontWeight.w500,
            fontSize: 22.62,
            height: 20 / 22.62,
          ),
        ),
        const SizedBox(height: 8),

        // Display Box (Disabled Input Style)
        Container(
          height: 49,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.secondaryButtonBg,
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: AppColors.disabledInputBorder, width: 0.53),
          ),
          child: Text(
            _email,
            style: const TextStyle(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w400,
              fontSize: 24.105,
              height: 24 / 24.105,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        const Text(
          '소개',
          style: TextStyle(
            color: AppColors.labelText,
            fontWeight: FontWeight.w500,
            fontSize: 22.62,
            height: 20 / 22.62,
          ),
        ),
        const SizedBox(height: 8),

        // Text Area
        Container(
          height: 121,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.inputBorder, width: 0.53),
          ),
          child: TextFormField(
            controller: _bioController,
            maxLines: null, // Makes it multiline
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w400,
              fontSize: 25.815,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
              isDense: true,
              hintText: '자신에 대해 간단히 소개해 주세요.',
              hintStyle: TextStyle(
                color: AppColors.placeholderText,
                fontWeight: FontWeight.w400,
                fontSize: 25.815,
              ),
            ),
            onChanged: (value) {
              // Update state if needed
            },
          ),
        ),
      ],
    );
  }
}
