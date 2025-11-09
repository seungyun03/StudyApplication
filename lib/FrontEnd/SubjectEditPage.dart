// 📄 SubjectEditPage.dart (강의실 색상 로직 수정)
// ==========================================

import 'package:flutter/material.dart';
// 💡 [추가] Provider 사용을 위한 임포트 (TimetableProvider에서 데이터를 가져올 때 필요)
import 'package:provider/provider.dart';
// 경로는 사용자의 프로젝트 구조에 맞게 수정이 필요할 수 있습니다.
import '../Providers/TimetableProvider.dart';

// ==========================================================
// 🎨 색상 팔레트 정의 (AddSubjectModalPage에서 복사)
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
// 💡 SubjectEditPage 위젯 (StatefulWidget으로 변경 및 초기 데이터 추가)
// ==========================================================
class SubjectEditPage extends StatefulWidget {
  // 기존 데이터 (Key로 사용될 Original Name을 보존)
  final String originalSubjectName;
  final String currentTimetableName;

  // 수정 가능 데이터
  final String initialSubjectName;
  final String initialRoomName;
  final Color initialBgColor;
  final Color initialTextColor;

  // 💡 SubjectEditPage를 수정 기능에 맞게 초기 속성 확장
  const SubjectEditPage({
    super.key,
    required this.originalSubjectName,
    required this.currentTimetableName,
    // 수정 필드에 필요한 초기 값
    required this.initialSubjectName,
    required this.initialRoomName,
    required this.initialBgColor,
    required this.initialTextColor,
  });

  @override
  State<SubjectEditPage> createState() => _SubjectEditPageState();
}

class _SubjectEditPageState extends State<SubjectEditPage> {
  // 💡 초기 데이터를 State 변수로 설정
  late String _subjectName;
  late String _roomName;
  late Color _selectedBgColor;
  late Color _selectedTextColor;

  @override
  void initState() {
    super.initState();
    // 💡 위젯의 초기 데이터로 상태 초기화
    _subjectName = widget.initialSubjectName;
    _roomName = widget.initialRoomName;
    _selectedBgColor = widget.initialBgColor;
    _selectedTextColor = widget.initialTextColor;
  }

  // 💡 [수정] 강의실 색상이 폰트 색상을 따르도록 변경
  Color get _selectedRoomColor => _selectedTextColor;
  // (기존 코드: _getRoomColorFromSubjectColor(_selectedBgColor))

  @override
  Widget build(BuildContext context) {
    // 💡 [추가] TimetableProvider 접근 및 현재 시간표 이름 가져오기
    final timetableProvider = Provider.of<TimetableProvider>(context);
    final currentTimetableName = timetableProvider.currentTimetable?.name ?? '시간표 선택';

    // 💡 AddSubjectModalPage와 동일한 모달 디자인 적용
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // 배경을 투명하게
      body: Center(
        child: Container(
          // 💡 모달 크기 설정
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
                    "과목 정보 수정", // 💡 제목 변경
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
              // -------------------- 현재 시간표 이름 헤더 --------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  // 💡 현재 시간표 이름
                  currentTimetableName,
                  style: const TextStyle(
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
                        initialValue: widget.initialSubjectName, // 💡 초기값 설정
                        onChanged: (value) => setState(() => _subjectName = value),
                      ),
                      const SizedBox(height: 20),

                      // --- 강의실 설정 ---
                      const _InputLabel(label: "강의실"),
                      _InputField(
                        hint: "강의실 입력 (예: B403)",
                        initialValue: widget.initialRoomName, // 💡 초기값 설정
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

                      // --- ✅ 과목 미리보기 ---
                      const _InputLabel(label: "미리보기"),
                      const SizedBox(height: 10),
                      _SubjectPreview(
                        subject: _subjectName.isEmpty ? "과목명" : _subjectName,
                        room: _roomName.isEmpty ? "강의실" : _roomName,
                        bgColor: _selectedBgColor,
                        textColor: _selectedTextColor,
                        roomColor: _selectedRoomColor, // 💡 수정된 getter가 적용됨
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // -------------------- 하단 버튼 영역 (삭제/수정) --------------------
              Row(
                children: [
                  // 🗑️ 삭제 버튼 (좌측)
                  Expanded(
                    child: _BottomButton(
                      label: "과목 삭제", // 💡 라벨 변경
                      bgColor: Colors.white,
                      textColor: Colors.red.shade600,
                      borderColor: Colors.red.shade300,
                      onTap: () {
                        // 💡 삭제 시 null을 반환하여 삭제되었음을 알림 (호출하는 곳에서 처리)
                        Navigator.pop(context, {'action': 'delete'});
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  // 💾 수정 완료 버튼 (우측)
                  Expanded(
                    child: _BottomButton(
                      label: "수정 완료", // 💡 라벨 변경
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

                        // 💡 수정된 데이터를 Map 형태로 반환 (호출하는 곳에서 처리)
                        final editedSubjectData = {
                          'action': 'edit',
                          'originalName': widget.originalSubjectName,
                          'subject': _subjectName,
                          'room': _roomName.isEmpty ? "미정" : _roomName,
                          'bgColor': _selectedBgColor.value, // Color를 int value로 전달
                          'textColor': _selectedTextColor.value,
                          'roomColor': _selectedRoomColor.value, // 💡 수정된 getter가 적용됨
                        };
                        Navigator.pop(context, editedSubjectData);
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
// 🎨 공통 위젯 (AddSubjectModelPage에서 복사 및 수정)
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

// 💡 [수정] _InputField를 StatelessWidget -> StatefulWidget으로 변경
// (텍스트 입력 시 한 글자만 입력되는 문제를 해결하기 위해)
class _InputField extends StatefulWidget {
  final String hint;
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const _InputField({
    required this.hint,
    this.initialValue,
    required this.onChanged
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  // 💡 컨트롤러를 State 내에서 선언하여 생명주기를 관리
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 💡 initState에서 컨트롤러를 딱 한 번만 초기화
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    // 💡 위젯이 사라질 때 컨트롤러를 정리 (메모리 누수 방지)
    _controller.dispose();
    super.dispose();
  }

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
        // 💡 생성된 컨트롤러 사용
        controller: _controller,
        // 💡 부모 위젯의 onChanged 콜백 연결
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
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
                color: roomColor, // 💡 수정된 로직이 여기에 반영됨
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