import 'package:flutter/material.dart';

class TimeTableSubjectButtonOnClick extends StatefulWidget {
  const TimeTableSubjectButtonOnClick({super.key});

  @override
  State<TimeTableSubjectButtonOnClick> createState() =>
      _TimeTableSubjectButtonOnClickState();
}

class _TimeTableSubjectButtonOnClickState
    extends State<TimeTableSubjectButtonOnClick> {
  bool lectureCollapsed = false;
  bool assignmentCollapsed = false;
  bool examCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "수학 - A101",
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "2024년 1학기",
                          style: TextStyle(fontSize: 20, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.menu, color: Colors.grey),
                  )
                ],
              ),
            ),

            // 콘텐츠
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ===== 강의자료 =====
                    CollapsibleSection(
                      title: "강의자료",
                      bgColor: Colors.blue.shade50,
                      textColor: Colors.black87,
                      collapsed: lectureCollapsed,
                      onToggle: () {
                        setState(() {
                          lectureCollapsed = !lectureCollapsed;
                        });
                      },
                      children: const [
                        LectureItem(
                          title: "강의 제목 (예: 1주차 강의노트)",
                          date: "업로드 날짜 (예: 2024.03.04)",
                        ),
                      ],
                    ),

                    // ===== 과제 =====
                    CollapsibleSection(
                      title: "과제",
                      bgColor: Colors.green.shade50,
                      textColor: Colors.black87,
                      collapsed: assignmentCollapsed,
                      onToggle: () {
                        setState(() {
                          assignmentCollapsed = !assignmentCollapsed;
                        });
                      },
                      children: const [
                        AssignmentItem(
                          title: "과제 제목 (예: 1주차 과제)",
                          deadline: "제출 기한 (예: 2024.03.25)",
                          status: "pending",
                        ),
                      ],
                    ),

                    // ===== 시험일정 =====
                    CollapsibleSection(
                      title: "시험일정",
                      bgColor: Colors.purple.shade50,
                      textColor: Colors.black87,
                      collapsed: examCollapsed,
                      onToggle: () {
                        setState(() {
                          examCollapsed = !examCollapsed;
                        });
                      },
                      children: const [
                        ExamItem(
                          title: "시험명 (예: 중간고사)",
                          date: "시험일시 (예: 2024.04.15 10:00)",
                          dDay: "D-00",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 하단 네비게이션
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.forum_outlined), label: "커뮤니티"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: "설정"),
        ],
      ),
    );
  }
}

// ==================== Collapsible Section ====================
class CollapsibleSection extends StatelessWidget {
  final String title;
  final Color bgColor;
  final Color textColor;
  final bool collapsed;
  final VoidCallback onToggle;
  final List<Widget> children;

  const CollapsibleSection({
    super.key,
    required this.title,
    required this.bgColor,
    required this.textColor,
    required this.collapsed,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // 상단 헤더
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: onToggle,
                      child: Text(collapsed ? "펼치기" : "접기",
                          style: TextStyle(color: textColor, fontSize: 14)),
                    ),
                    TextButton(
                      onPressed: () {}, // 나중에 추가 기능 연결
                      child: Text("추가",
                          style: TextStyle(color: textColor, fontSize: 14)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 접기/펼치기 애니메이션
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: collapsed ? 0 : null,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: collapsed
                ? null
                : Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(children: children),
                  ),
          ),
        ],
      ),
    );
  }
}

// ==================== Lecture Item ====================
class LectureItem extends StatelessWidget {
  final String title;
  final String date;

  const LectureItem({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    return _card(
      color: Colors.blue.shade50,
      icon: Icons.description_outlined,
      iconColor: Colors.blue,
      title: title,
      subtitle: "업로드: $date",
    );
  }
}

// ==================== Assignment Item ====================
class AssignmentItem extends StatelessWidget {
  final String title;
  final String deadline;
  final String status;

  const AssignmentItem({
    super.key,
    required this.title,
    required this.deadline,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return _card(
      color: Colors.green.shade50,
      icon: Icons.assignment_outlined,
      iconColor: Colors.green,
      title: title,
      subtitle: "마감: $deadline",
      trailing: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: status == "completed" ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}

// ==================== Exam Item ====================
class ExamItem extends StatelessWidget {
  final String title;
  final String date;
  final String dDay;

  const ExamItem({
    super.key,
    required this.title,
    required this.date,
    required this.dDay,
  });

  @override
  Widget build(BuildContext context) {
    return _card(
      color: Colors.purple.shade50,
      icon: Icons.edit_calendar_outlined,
      iconColor: Colors.purple,
      title: title,
      subtitle: date,
      trailing: Text(
        dDay,
        style: const TextStyle(
          color: Colors.purple,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ==================== 공통 카드 위젯 ====================
Widget _card({
  required Color color,
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  Widget? trailing,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text(subtitle,
                    style: TextStyle(color: iconColor, fontSize: 12)),
              ],
            ),
          ],
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}
