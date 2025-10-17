// 📄 time_table_button.dart
// ===================================================================
// 🗓️ TimeTableButton (시간표 초기화면)
// React App 디자인 그대로 포팅 (색상/그라디언트/반응형 적용)
// 강의자료 / 과제 / 시험일정 섹션 + 하단 네비게이션
// ===================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'LectureAddPage.dart';
import 'AssignmentAddPage.dart';
import 'ExamAddPage.dart';

class TimeTableButton extends StatefulWidget {
  const TimeTableButton({super.key});

  @override
  State<TimeTableButton> createState() => _TimeTableButtonState();
}

class _TimeTableButtonState extends State<TimeTableButton> {
  bool lectureExpanded = true;
  bool assignmentExpanded = true;
  bool examExpanded = true;
  String activeTab = 'home';

  final List<String> lectures = ["1주차 강의노트", "함수의 극한과 연속성"];
  final List<String> assignments = ["1주차 컴퓨터 구조", "연습문제 3-1 ~ 3-5"];
  final List<String> exams = ["중간고사", "단원별 퀴즈"];

  void _openLectureAddPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const LectureAddPage()));
  }

  void _openAssignmentAddPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AssignmentAddPage()));
  }

  void _openExamAddPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ExamAddPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            // -------------------------------------------------------------------
            // 메인 스크롤 컨텐츠
            // -------------------------------------------------------------------
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // 제목
                  const Text(
                    "수학 - A101",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2939),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "2024년 1학기",
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 📘 강의자료 섹션
                  _buildSection(
                    title: "강의자료",
                    expanded: lectureExpanded,
                    onToggle: () =>
                        setState(() => lectureExpanded = !lectureExpanded),
                    onAdd: _openLectureAddPage,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFEEF6FF)],
                    ),
                    accent: const Color(0xFF155DFC),
                    children: lectures
                        .map((e) => _buildItem(e, Colors.blue))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // 📗 과제 섹션
                  _buildSection(
                    title: "과제",
                    expanded: assignmentExpanded,
                    onToggle: () => setState(
                        () => assignmentExpanded = !assignmentExpanded),
                    onAdd: _openAssignmentAddPage,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFFEF6), Color(0xFFECFDF5)],
                    ),
                    accent: const Color(0xFF00A63E),
                    children: assignments
                        .map((e) => _buildItem(e, Colors.green))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // 📙 시험일정 섹션
                  _buildSection(
                    title: "시험일정",
                    expanded: examExpanded,
                    onToggle: () =>
                        setState(() => examExpanded = !examExpanded),
                    onAdd: _openExamAddPage,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFAF5FF), Color(0xFFF5F3FF)],
                    ),
                    accent: const Color(0xFF9810FA),
                    children:
                        exams.map((e) => _buildItem(e, Colors.purple)).toList(),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),

            // -------------------------------------------------------------------
            // 하단 네비게이션바
            // -------------------------------------------------------------------
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem('커뮤니티', Icons.forum_outlined, 'community'),
                    _buildNavItem('홈', Icons.home_rounded, 'home'),
                    _buildNavItem('설정', Icons.settings_outlined, 'settings'),
                  ],
                ),
              ),
            ),

            // -------------------------------------------------------------------
            // 뒤로가기 버튼
            // -------------------------------------------------------------------
            Positioned(
              right: 24,
              top: 16,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 76,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.chevron_left, color: Colors.black54),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // 🧩 개별 섹션
  // -------------------------------------------------------------------
  Widget _buildSection({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required VoidCallback onAdd,
    required LinearGradient gradient,
    required Color accent,
    required List<Widget> children,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
      child: Column(
        children: [
          // 섹션 헤더
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: Color(0xFF1E293B),
                      )),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onToggle,
                        style: TextButton.styleFrom(
                          foregroundColor: accent,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: Text(expanded ? '접기' : '펼치기'),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: onAdd,
                        style: TextButton.styleFrom(
                          foregroundColor: accent,
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: const Text('추가'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // 섹션 내용
          if (expanded)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: children.isNotEmpty
                    ? Column(children: children)
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          "$title 항목이 없습니다.",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // 📦 리스트 아이템 카드
  // -------------------------------------------------------------------
  Widget _buildItem(String text, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
          HapticFeedback.selectionClick();
        },
        child: Ink(
          decoration: BoxDecoration(
            color: color.shade50,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: color.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Icon(Icons.chevron_right, color: color.shade700),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // 🧭 하단 네비게이션 아이템
  // -------------------------------------------------------------------
  Widget _buildNavItem(String label, IconData icon, String key) {
    final bool active = activeTab == key;
    final color = active ? const Color(0xFF155DFC) : Colors.grey.shade500;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() => activeTab = key);
        HapticFeedback.lightImpact();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
