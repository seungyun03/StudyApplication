import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study_app/FrontEnd/EditingPageParents.dart';
import 'package:study_app/FrontEnd/FullTimeTable.dart';
import 'package:study_app/FrontEnd/TimeTablebutton.dart';

// ==================== TimetableSlot 모델 ====================
class TimetableSlot {
  final String day;
  final String time;
  final String? subject;
  final Color color;

  TimetableSlot({
    required this.day,
    required this.time,
    this.subject,
    this.color = const Color(0xFFF9FAFB),
  });
}

// ==================== 홈 페이지 ====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HeaderSection(),
              SizedBox(height: 20),
              _TopCardsRow(),
              SizedBox(height: 20),
              CurrentClassBanner(),
              SizedBox(height: 20),
              WeeklyTimetableWidget(),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(),
    );
  }
}

// ==================== 상단 헤더 ====================
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "시간표",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 6),
            Text(
              "2024년 1학기",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.normal,
                fontSize: 15.8,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
      ],
    );
  }
}

// ==================== 시험 + 과제 일정 ====================
class _TopCardsRow extends StatelessWidget {
  const _TopCardsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: ExamScheduleWidget()),
        SizedBox(width: 16),
        Expanded(child: AssignmentScheduleWidget()),
      ],
    );
  }
}

// ==================== 시험 일정 카드 ====================
class ExamScheduleWidget extends StatelessWidget {
  const ExamScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      gradient: const [Color(0xFFFEE2E2), Color(0xFFFDF2F8)],
      title: "시험 일정",
      emptyText: "등록된 시험 일정이 없습니다",
    );
  }
}

// ==================== 과제 일정 카드 ====================
class AssignmentScheduleWidget extends StatelessWidget {
  const AssignmentScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return _CardWrapper(
      gradient: const [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
      title: "과제 일정",
      emptyText: "등록된 과제 일정이 없습니다",
    );
  }
}

// ==================== 카드 공통 디자인 ====================
class _CardWrapper extends StatefulWidget {
  final List<Color> gradient;
  final String title;
  final String emptyText;

  const _CardWrapper({
    required this.gradient,
    required this.title,
    required this.emptyText,
  });

  @override
  State<_CardWrapper> createState() => _CardWrapperState();
}

class _CardWrapperState extends State<_CardWrapper> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 193,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 53,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.gradient),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFF1F2937),
                  ),
                ),
                GestureDetector(
                  onTapDown: (_) {
                    setState(() => _isPressed = true);
                    HapticFeedback.lightImpact();
                  },
                  onTapUp: (_) {
                    setState(() => _isPressed = false);

                    // ✅ 구분 로직
                    if (widget.title == "시험 일정") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ExamPage()),
                      );
                    } else if (widget.title == "과제 일정") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AssignmentPage()),
                      );
                    }
                  },
                  onTapCancel: () => setState(() => _isPressed = false),
                  child: AnimatedScale(
                    scale: _isPressed ? 0.9 : 1.0,
                    duration: const Duration(milliseconds: 130),
                    child: Text(
                      "전체보기",
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: _isPressed
                            ? const Color(0xFFEA580C).withOpacity(0.5)
                            : const Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                widget.emptyText,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 현재 수업 배너 ====================
class CurrentClassBanner extends StatelessWidget {
  const CurrentClassBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        "현재 진행 중인 수업이 없습니다",
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

// ==================== 주간 시간표 ====================
class WeeklyTimetableWidget extends StatelessWidget {
  const WeeklyTimetableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ["월", "화", "수", "목", "금"];
    final times = ["9:00", "10:00", "11:00", "12:00", "13:00", "14:00"];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "이번 주 시간표",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF1F2937),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      print("전체 보기 클릭");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FullTimeTable()),
                      );
                    },
                    child: const Text(
                      "전체 보기",
                      style: TextStyle(
                        fontSize: 13.8,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      print("수정 클릭");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EditingPageParents()),
                      );
                    },
                    child: const Text(
                      "수정",
                      style: TextStyle(
                        fontSize: 13.8,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 요일 헤더
          Row(
            children: [
              const SizedBox(width: 60),
              for (final d in days)
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // 시간표 표 구조
          for (final t in times)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      t,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13.8,
                      ),
                    ),
                  ),
                  for (final d in days)
                    Expanded(
                      child: _TimetableSlotButton(day: d, time: t),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== 시간표 버튼 ====================
class _TimetableSlotButton extends StatefulWidget {
  final String day;
  final String time;

  const _TimetableSlotButton({required this.day, required this.time});

  @override
  State<_TimetableSlotButton> createState() => _TimetableSlotButtonState();
}

class _TimetableSlotButtonState extends State<_TimetableSlotButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        print("클릭 → ${widget.day} ${widget.time}");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const TimeTableButton()), //시간표 버튼 누르면 그 시간표에 맞는 페이지로 이동
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        transform: Matrix4.identity()..scale(_pressed ? 0.9 : 1.0),
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFE0E7FF) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                      color: Colors.indigo.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          "+",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _pressed ? const Color(0xFF4338CA) : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

// ==================== 하단 네비게이션 ====================
class BottomNavigationBarWidget extends StatelessWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _NavItem(icon: Icons.forum_outlined, label: "커뮤니티", active: false),
          _NavItem(icon: Icons.home, label: "홈", active: true),
          _NavItem(icon: Icons.settings_outlined, label: "설정", active: false),
        ],
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
            fontFamily: 'Roboto',
            fontSize: 13.8,
            color: active ? Colors.blue : Colors.grey,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ==================== 예시 페이지 ====================
class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("시험 일정 전체보기")),
      body: const Center(child: Text("시험 일정 페이지 내용")),
    );
  }
}

class AssignmentPage extends StatelessWidget {
  const AssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("과제 일정 전체보기")),
      body: const Center(child: Text("과제 일정 페이지 내용")),
    );
  }
}
