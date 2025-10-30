// 📄 AddSubjectModelPage.dart (올바른 파일명: Model)

import 'package:flutter/material.dart';
// 경로는 사용자의 프로젝트 구조에 맞게 수정이 필요할 수 있습니다.
import '../Providers/TimetableProvider.dart';

// ==========================================================
// 🎨 색상 팔레트 정의 (예시 이미지 및 흔히 사용되는 색상 기반)
// ==========================================================
final List<Color> subjectColors = [
  const Color(0xFFDBEAFE), // 연한 파랑
  const Color(0xFFD1FAE5), // 연한 초록
  const Color(0xFFFECACA), // 연한 빨강
  const Color(0xFFEDE9FE), // 연한 보라
  const Color(0xFFFFEDD5), // 연한 주황
  const Color(0xFFF3F4F6), // 연한 회색
  const Color(0xFFFEE2E2), // 연한 핑크
  const Color(0xFFFAF5FF), // 연한 자주
];

final List<Color> fontColors = [
  const Color(0xFF1E3A8A), // 진한 파랑
  const Color(0xFF065F46), // 진한 초록
  const Color(0xFF991B1B), // 진한 빨강
  const Color(0xFF4C1D95), // 진한 보라
  const Color(0xFF9A3412), // 진한 주황
  const Color(0xFF4B5563), // 진한 회색
  const Color(0xFFBE123C), // 진한 핑크
  const Color(0xFF7E22CE), // 진한 자주
];

// 강의실 색상은 과목색상과 대비되는 톤으로 선택
Color _getRoomColorFromSubjectColor(Color subjectColor) {
  if (subjectColor == const Color(0xFFDBEAFE)) return const Color(0xFF2563EB); // 파랑
  if (subjectColor == const Color(0xFFD1FAE5)) return const Color(0xFF059669); // 초록
  if (subjectColor == const Color(0xFFFECACA)) return const Color(0xFFDC2626); // 빨강
  if (subjectColor == const Color(0xFFEDE9FE)) return const Color(0xFF6D28D9); // 보라
  if (subjectColor == const Color(0xFFFFEDD5)) return const Color(0xFFEA580C); // 주황
  if (subjectColor == const Color(0xFFF3F4F6)) return const Color(0xFF6B7280); // 진한 회색
  if (subjectColor == const Color(0xFFFEE2E2)) return const Color(0xFFB91C1C); // 진한 핑크
  if (subjectColor == const Color(0xFFFAF5FF)) return const Color(0xFF7E22CE); // 진한 자주
  return const Color(0xFF4B5563); // 기본값
}

// ==========================================================
// 💡 AddSubjectModelPage 위젯
// ==========================================================
// ✅ 클래스 이름은 Modal 기능의 페이지이므로 AddSubjectModalPage를 그대로 사용하고
// ✅ 파일명만 AddSubjectModelPage.dart로 처리합니다.
class AddSubjectModalPage extends StatefulWidget {
  const AddSubjectModalPage({super.key});

  @override
  State<AddSubjectModalPage> createState() => _AddSubjectModalPageState();
}

class _AddSubjectModalPageState extends State<AddSubjectModalPage> {
  String _subjectName = '';
  String _roomName = '';
  late Color _selectedBgColor;
  late Color _selectedTextColor;

  @override
  void initState() {
    super.initState();
    _selectedBgColor = subjectColors[0];
    _selectedTextColor = fontColors[0];
  }

  Color get _selectedRoomColor =>
      _getRoomColorFromSubjectColor(_selectedBgColor);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          width: 700,
          height: 850,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x33000000), offset: Offset(0, 8), blurRadius: 20)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------- 상단 제목 및 닫기 버튼 --------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "과목 추가",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, color: Color(0xFF4B5563)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // -------------------- 2024년 1학기 시간표 헤더 --------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "2024년 1학기 시간표",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // -------------------- 입력 필드 및 컬러 선택 --------------------
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 과목명 설정 ---
                      const _InputLabel(label: "과목명"),
                      _InputField(
                        hint: "과목명 입력",
                        onChanged: (value) => setState(() => _subjectName = value),
                      ),
                      const SizedBox(height: 20),

                      // --- 강의실 설정 ---
                      const _InputLabel(label: "강의실"),
                      _InputField(
                        hint: "강의실 입력 (예: B403)",
                        onChanged: (value) => setState(() => _roomName = value),
                      ),
                      const SizedBox(height: 30),

                      // --- 과목/폰트 컬러 선택 영역 ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 과목 컬러 설정
                          Expanded(
                            child: _ColorSelector(
                              title: "과목 컬러",
                              colors: subjectColors,
                              selectedColor: _selectedBgColor,
                              onColorSelected: (color) =>
                                  setState(() => _selectedBgColor = color),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // 폰트 컬러 설정
                          Expanded(
                            child: _ColorSelector(
                              title: "폰트 컬러",
                              colors: fontColors,
                              selectedColor: _selectedTextColor,
                              onColorSelected: (color) =>
                                  setState(() => _selectedTextColor = color),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // --- ✅ 기능 5: 과목 미리보기 ---
                      const _InputLabel(label: "미리보기"),
                      const SizedBox(height: 10),
                      _SubjectPreview(
                        subject: _subjectName.isEmpty ? "과목명" : _subjectName,
                        room: _roomName.isEmpty ? "강의실" : _roomName,
                        bgColor: _selectedBgColor,
                        textColor: _selectedTextColor,
                        roomColor: _selectedRoomColor,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // -------------------- 하단 버튼 영역 --------------------
              Row(
                children: [
                  // 취소 버튼
                  Expanded(
                    child: _BottomButton(
                      label: "취소",
                      bgColor: Colors.white,
                      textColor: const Color(0xFF4B5563),
                      borderColor: const Color(0xFFE5E7EB),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // 추가 버튼
                  Expanded(
                    child: _BottomButton(
                      label: "추가",
                      bgColor: const Color(0xFF8B5CF6), // 보라색
                      textColor: Colors.white,
                      borderColor: const Color(0xFF8B5CF6),
                      onTap: () {
                        if (_subjectName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('과목명을 입력해 주세요.')),
                          );
                          return;
                        }

                        final newSubject = SubjectInfo(
                          subject: _subjectName,
                          room: _roomName.isEmpty ? "미정" : _roomName,
                          bgColor: _selectedBgColor,
                          textColor: _selectedTextColor,
                          roomColor: _selectedRoomColor,
                        );
                        Navigator.pop(context, newSubject);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================
// 🎨 공통 위젯 (AddSubjectModelPage의 구성 요소)
// ==========================================================

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const _InputField({required this.hint, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
        ),
        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
      ),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final String title;
  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorSelector({
    required this.title,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InputLabel(label: title),
        Container(
          height: 50,
          width: double.infinity,
          decoration: BoxDecoration(
            color: selectedColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selectedColor == Colors.white
                    ? const Color(0xFFE5E7EB)
                    : selectedColor,
                width: 2),
          ),
          child: const Center(),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 30, // 색상 팔레트 높이
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Container(
                    width: 30,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color
                          ? Border.all(color: Colors.black, width: 2.5)
                          : Border.all(color: Colors.transparent, width: 2.5),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SubjectPreview extends StatelessWidget {
  final String subject;
  final String room;
  final Color bgColor;
  final Color textColor;
  final Color roomColor;

  const _SubjectPreview({
    required this.subject,
    required this.room,
    required this.bgColor,
    required this.textColor,
    required this.roomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 150, // 예시 이미지와 유사한 크기
        height: 80,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
                color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 4)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              subject,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              room,
              style: TextStyle(
                color: roomColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _BottomButton({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}