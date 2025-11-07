// 📄 AddNewTimeTablePage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🚨 [추가] Provider 사용을 위한 import
import 'package:uuid/uuid.dart'; // 🚨 [추가] 고유 ID 생성을 위한 uuid import
import '../Providers/TimetableProvider.dart'; // 🚨 [추가] TimetableProvider 및 TimeTable 모델 import

// ==================== 새로운 시간표 추가 페이지 ====================
class AddNewTimeTablePage extends StatefulWidget {
  const AddNewTimeTablePage({super.key});

  @override
  State<AddNewTimeTablePage> createState() => _AddNewTimeTablePageState();
}

class _AddNewTimeTablePageState extends State<AddNewTimeTablePage> {
  // 💡 폼 컨트롤러 및 상태 변수
  final TextEditingController _nameController = TextEditingController(text: '새로운 시간표');

  // 🚨 [수정] 텍스트 필드의 값을 실시간 반영하기 위한 상태 변수
  String _timeTableName = '새로운 시간표';
  Color _selectedColor = const Color(0xFFFEE2E2); // 기본 선택 색상을 파스텔 톤으로 변경

  // 🚨 [수정] 더 넓은 선택을 위한 색상 팔레트
  final List<Color> _fullColorPalette = const [
    // Row 1: Light Reds/Pinks
    Color(0xFFFEE2E2), // Very Light Red
    Color(0xFFFCE7F3), // Light Pink
    Color(0xFFFBCFE8), // Soft Pink
    Color(0xFFF3E8FF), // Light Lavender

    // Row 2: Light Purples/Blues
    Color(0xFFEDE9FE), // Soft Lavender
    Color(0xFFE0E7FF), // Periwinkle
    Color(0xFFDBEAFE), // Light Blue
    Color(0xFFEEF2FF), // Very Light Blue

    // Row 3: Light Greens/Yellows
    Color(0xFFD1FAE5), // Light Mint
    Color(0xFFCCFBF1), // Light Teal
    Color(0xFFF0FDF4), // Very Light Green
    Color(0xFFFEFCE8), // Light Yellow

    // Row 4: Earth Tones/Neutrals
    Color(0xFFFFF7ED), // Light Apricot
    Color(0xFFFFEDD5), // Soft Peach
    Color(0xFFF5DEB3), // Wheat
    Color(0xFFF5F5DC), // Beige

    // Row 5: Soft Grays/Deeper Pastels
    Color(0xFFE5E7EB), // Light Gray
    Color(0xFFD1D5DB), // Mid-Light Gray
    Color(0xFFB0E0E6), // Powder Blue
    Color(0xFFDDA0DD), // Thistle (Soft Medium Purple)
  ];

  // 🚨 [추가] initState: 컨트롤러에 리스너를 연결하여 실시간 업데이트를 처리합니다.
  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateTimeTableName);
  }

  // 🚨 [추가] 리스너 콜백 함수: 텍스트 변경 시 상태 변수를 업데이트하고 UI를 다시 그립니다.
  void _updateTimeTableName() {
    if (_timeTableName != _nameController.text) {
      setState(() {
        _timeTableName = _nameController.text;
      });
    }
  }

  // 🚨 [수정] dispose: 리스너를 해제하고 컨트롤러를 해제합니다.
  @override
  void dispose() {
    _nameController.removeListener(_updateTimeTableName);
    _nameController.dispose();
    super.dispose();
  }

  // ---------------------------
  // 🚨 [구현] Provider를 사용하여 시간표를 추가하는 핵심 로직
  // ---------------------------
  void _addTimeTable() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("시간표 이름을 입력해주세요."),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    try {
      // 1. Provider에 접근 (read 사용)
      final provider = context.read<TimetableProvider>();

      // 2. 새로운 TimeTable 객체 생성 (UUID 사용)
      const Uuid uuid = Uuid();
      final newTable = TimeTable(
        id: uuid.v4(),
        name: newName,
        color: _selectedColor,
        createdAt: DateTime.now(),
      );

      // 3. Provider를 통해 추가 및 활성화
      await provider.addNewTimeTable(newTable);

      // 4. 성공 메시지 표시 및 페이지 닫기
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("'$newName' 시간표가 성공적으로 추가되었고 활성화되었습니다."),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        // 에러 처리
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("시간표 추가 중 오류가 발생했습니다: $e"),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
  // ---------------------------

  // 🚨 [수정] 컬러 피커를 `showModalBottomSheet`로 표시하는 함수
  void _showColorPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 모달 제목
                  const Text(
                    '시간표 컬러 선택',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 색상 팔레트
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // 스크롤 방지
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _fullColorPalette.length,
                    itemBuilder: (context, index) {
                      final color = _fullColorPalette[index];
                      final isSelected = color.value == _selectedColor.value;

                      return GestureDetector(
                        onTap: () {
                          // 모달 내 상태 업데이트
                          setModalState(() {
                            _selectedColor = color;
                          });
                          // 메인 위젯 상태 업데이트 및 모달 닫기
                          setState(() {
                            _selectedColor = color;
                          });
                          Navigator.pop(bottomSheetContext);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                              width: isSelected ? 4 : 1,
                            ),
                            boxShadow: isSelected
                                ? [const BoxShadow(color: Color(0x663B82F6), blurRadius: 6)]
                                : null,
                          ),
                          child: isSelected
                              ? const Center(
                            child: Icon(
                              Icons.check,
                              color: Colors.white, // 체크 아이콘을 흰색으로 변경
                              size: 20,
                            ),
                          )
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 1. 상단 헤더 (시간표 정보 제목 및 닫기 버튼)
            _CreationHeader(
              onClose: () => Navigator.pop(context), // 취소 시 이전 페이지로 이동
            ),

            // 2. 입력 폼 영역
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 시간표 이름 입력
                    const _FormLabel(text: "시간표 이름"),
                    _NameInputField(controller: _nameController),
                    const SizedBox(height: 24),

                    // 시간표 색상 선택
                    const _FormLabel(text: "시간표 컬러"),
                    // 🚨 [수정] 컬러 피커 버튼을 눌러 BottomSheet를 띄움
                    _ColorPickerButton(
                      selectedColor: _selectedColor,
                      onTap: _showColorPickerBottomSheet,
                    ),
                    const SizedBox(height: 24),

                    // 미리보기
                    const _FormLabel(text: "미리보기"),
                    _PreviewTimeTable(
                      name: _timeTableName,
                      backgroundColor: _selectedColor,
                    ),
                  ],
                ),
              ),
            ),

            // 3. 하단 취소/추가 버튼
            _ActionButtons(
              onCancel: () => Navigator.pop(context),
              onAdd: _addTimeTable, // 🚨 [연결] Provider 로직이 구현된 함수 연결
            ),
            const SizedBox(height: 10), // 하단 여백
          ],
        ),
      ),
    );
  }
}

// ==================== 상단 헤더 위젯 ====================
class _CreationHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _CreationHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "시간표 정보",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color(0xFF1F2937),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 28),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

// ==================== 폼 레이블 위젯 ====================
class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }
}

// ==================== 시간표 이름 입력 필드 위젯 ====================
class _NameInputField extends StatelessWidget {
  final TextEditingController controller;

  const _NameInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // 테두리 제거
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300), // 연한 테두리 유지
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2), // 포커스 시 파란색 테두리
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: Color(0xFF1F2937),
      ),
    );
  }
}

// ==================== 컬러 피커 버튼 위젯 (수정된 색상 선택) ====================
class _ColorPickerButton extends StatelessWidget {
  final Color selectedColor;
  final VoidCallback onTap;

  const _ColorPickerButton({
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 100, // 버튼 너비를 명시적으로 설정
        decoration: BoxDecoration(
          color: selectedColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selectedColor.computeLuminance() > 0.5 ? Colors.grey.shade400 : selectedColor, // 밝은 색상일 경우 테두리 구분
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.color_lens,
            size: 24,
            // 💡 배경색에 따라 아이콘 색상 자동 조정
            color: selectedColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70,
          ),
        ),
      ),
    );
  }
}

// ==================== 미리보기 시간표 위젯 ====================
class _PreviewTimeTable extends StatelessWidget {
  final String name;
  final Color backgroundColor;

  const _PreviewTimeTable({required this.name, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    // 💡 미리보기는 _TimeTableCard와 유사한 디자인으로 구성
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor, // 선택된 배경색 적용
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        name.isNotEmpty ? name : '시간표 이름 미리보기',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          // 💡 배경색에 따라 텍스트 색상을 자동으로 조정하여 가독성 확보
          color: backgroundColor.computeLuminance() > 0.5
              ? const Color(0xFF1F2937) // 밝은 배경 -> 어두운 글자
              : Colors.white, // 어두운 배경 -> 밝은 글자
        ),
      ),
    );
  }
}

// ==================== 하단 액션 버튼 위젯 ====================
class _ActionButtons extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onAdd;

  const _ActionButtons({required this.onCancel, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // 취소 버튼
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "취소",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 추가 버튼
          Expanded(
            child: ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: const Color(0xFF9333EA), // 이미지와 동일한 보라색 계열
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "추가",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}