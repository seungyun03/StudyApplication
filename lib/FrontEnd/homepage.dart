import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/FrontEnd/EditingPageParents.dart';
import 'package:study_app/FrontEnd/FullTimeTable.dart';
import 'package:study_app/FrontEnd/TimeTablebutton.dart';
import '../Providers/TimetableProvider.dart' as tp;

// ==================== TimetableSlot 모델 ====================
class TimetableSlot {
  final String day;
  final String time;
  final tp.SubjectInfo? subjectInfo;

  TimetableSlot({
    required this.day,
    required this.time,
    this.subjectInfo,
  });
}

// ==================== 홈 페이지 ====================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _openEditingPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditingPageParents()),
    );
    if (mounted) setState(() {}); // 돌아오면 새로고침
  }

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<tp.TimetableProvider>().timetable;

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
              _WeeklyTimetableWrapper(),
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
class _CardWrapper extends StatelessWidget {
  final List<Color> gradient;
  final String title;
  final String emptyText;

  const _CardWrapper({
    required this.gradient,
    required this.title,
    required this.emptyText,
  });

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
              gradient: LinearGradient(colors: gradient),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Text(
                  "전체보기",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFFEA580C),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                emptyText,
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

// ==================== 주간 시간표 (Provider 적용) ====================
class _WeeklyTimetableWrapper extends StatelessWidget {
  const _WeeklyTimetableWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<tp.TimetableProvider>().timetable;
    return WeeklyTimetableWidget(timetable: timetable);
  }
}

// ==================== 주간 시간표 ====================
class WeeklyTimetableWidget extends StatelessWidget {
  final Map<String, tp.SubjectInfo?> timetable;

  const WeeklyTimetableWidget({super.key, required this.timetable});

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
          // ✅ 헤더 복원 (전체보기 + 수정)
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const FullTimeTable()),
                      );
                    },
                    child: const Text(
                      "전체보기",
                      style: TextStyle(
                        fontSize: 13.8,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditingPageParents()),
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

          // 시간표 셀
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
                    Builder(
                      builder: (context) {
                        final cellSubject = timetable["$d-$t"];
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (cellSubject == null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const EditingPageParents()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TimeTableButton(
                                      subjectName:
                                          "${cellSubject.subject} - ${cellSubject.room}",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 50,
                              decoration: BoxDecoration(
                                color: cellSubject?.bgColor ??
                                    const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              alignment: Alignment.center,
                              child: cellSubject == null
                                  ? const SizedBox.shrink()
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          cellSubject.subject,
                                          style: TextStyle(
                                            color: cellSubject.textColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          cellSubject.room,
                                          style: TextStyle(
                                            color: cellSubject.roomColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
        ],
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
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
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
