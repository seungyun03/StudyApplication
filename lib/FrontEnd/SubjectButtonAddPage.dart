import 'package:flutter/material.dart';
import '../Providers/TimetableProvider.dart'; // ✅ SubjectInfo import

class SubjectButtonAddPage extends StatefulWidget {
  const SubjectButtonAddPage({super.key});

  @override
  State<SubjectButtonAddPage> createState() => _SubjectButtonAddPageState();
}

class _SubjectButtonAddPageState extends State<SubjectButtonAddPage> {
  void onSubjectClick(SubjectInfo subject) {
    Navigator.pop(context, subject);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1366,
                height: 1024,
                child: Stack(
                  children: [
                    const _TopTitle(),
                    _WeeklyTimetableWidget(onSubjectClick: onSubjectClick),
                    _BottomNavigationBar(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================= 상단 제목 =======================
class _TopTitle extends StatelessWidget {
  const _TopTitle();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 30,
      child: const Text(
        "과목 선택",
        style: TextStyle(
          fontSize: 23.7,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }
}

// ======================= 과목 카드 위젯 =======================
class _WeeklyTimetableWidget extends StatelessWidget {
  final void Function(SubjectInfo subject) onSubjectClick;
  const _WeeklyTimetableWidget({required this.onSubjectClick});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 24,
      top: 87,
      child: Container(
        width: 1318,
        height: 849,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
          ],
        ),
        child: Stack(
          children: [
            const _TimetableHeader(),
            _SubjectSelectionSection(onSubjectClick: onSubjectClick),
          ],
        ),
      ),
    );
  }
}

class _TimetableHeader extends StatelessWidget {
  const _TimetableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 20, top: 12),
        child: Text(
          "2024년 1학기 시간표",
          style: TextStyle(
            fontSize: 19.89,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}

// ======================= 과목 선택 영역 =======================
class _SubjectSelectionSection extends StatelessWidget {
  final void Function(SubjectInfo subject) onSubjectClick;
  const _SubjectSelectionSection({required this.onSubjectClick});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 53,
      left: 0,
      child: Container(
        width: 1318,
        height: 796,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            const Positioned(
              left: 17,
              top: 17,
              child: Text(
                "과목을 선택하세요",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            _SubjectCard(
              subject: SubjectInfo(
                subject: "수학",
                room: "A101",
                bgColor: const Color(0xFFDBEAFE),
                textColor: const Color(0xFF1E3A8A),
                roomColor: const Color(0xFF2563EB),
              ),
              left: 26,
              top: 73,
              onClick: onSubjectClick,
            ),
            _SubjectCard(
              subject: SubjectInfo(
                subject: "영어",
                room: "B203",
                bgColor: const Color(0xFFD1FAE5),
                textColor: const Color(0xFF065F46),
                roomColor: const Color(0xFF059669),
              ),
              left: 26,
              top: 182,
              onClick: onSubjectClick,
            ),
            _SubjectCard(
              subject: SubjectInfo(
                subject: "국어",
                room: "E102",
                bgColor: const Color(0xFFFECACA),
                textColor: const Color(0xFF991B1B),
                roomColor: const Color(0xFFDC2626),
              ),
              left: 732,
              top: 73,
              onClick: onSubjectClick,
            ),
            _SubjectCard(
              subject: SubjectInfo(
                subject: "과학",
                room: "C105",
                bgColor: const Color(0xFFEDE9FE),
                textColor: const Color(0xFF4C1D95),
                roomColor: const Color(0xFF6D28D9),
              ),
              left: 1085,
              top: 73,
              onClick: onSubjectClick,
            ),
            _SubjectCard(
              subject: SubjectInfo(
                subject: "역사",
                room: "D301",
                bgColor: const Color(0xFFFFEDD5),
                textColor: const Color(0xFF9A3412),
                roomColor: const Color(0xFFEA580C),
              ),
              left: 379,
              top: 73,
              onClick: onSubjectClick,
            ),
            _SubjectCard(
              subject: SubjectInfo(
                subject: "점심시간",
                room: "",
                bgColor: const Color(0xFFEEEEEE),
                textColor: const Color(0xFF4B5563),
                roomColor: const Color(0xFF4B5563),
              ),
              left: 379,
              top: 182,
              onClick: onSubjectClick,
            ),
          ],
        ),
      ),
    );
  }
}

// ======================= 과목 카드 =======================
class _SubjectCard extends StatelessWidget {
  final SubjectInfo subject;
  final double left;
  final double top;
  final void Function(SubjectInfo subject) onClick;

  const _SubjectCard({
    required this.subject,
    required this.left,
    required this.top,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => onClick(subject),
        child: Container(
          width: 206,
          height: 60,
          decoration: BoxDecoration(
            color: subject.bgColor,
            borderRadius: BorderRadius.circular(25),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subject.subject,
                style: TextStyle(
                  color: subject.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.8,
                ),
              ),
              Text(
                subject.room,
                style: TextStyle(
                  color: subject.roomColor,
                  fontSize: 13.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================= 하단 네비게이션 =======================
class _BottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      child: Container(
        width: 1366,
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            _NavItem(icon: Icons.people_outline, label: "커뮤니티", active: false),
            _NavItem(icon: Icons.home, label: "홈", active: true),
            _NavItem(icon: Icons.settings_outlined, label: "설정", active: false),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? Colors.blue : Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.8,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }
}
