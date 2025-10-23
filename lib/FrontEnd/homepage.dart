// 📄 homepage.dart (수정됨: initState 정리 및 const 추가)

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
  @override
  void initState() {
    super.initState();
    // ScheduleProvider 생성자에서 이미 loadAllSchedules()를 호출하므로,
    // 여기서의 중복 호출은 제거합니다.
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<tp.ScheduleProvider>(context, listen: false).loadAllSchedules();
    });
    */
  }

  Future<void> _openEditingPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditingPageParents()),
    );
    if (mounted) {
      setState(() {}); // 기존 새로고침
      // 💡 추가: 편집 페이지에서 돌아오면 스케줄 데이터 새로고침
      Provider.of<tp.ScheduleProvider>(context, listen: false).loadAllSchedules();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Provider 구독
    final scheduleProvider = context.watch<tp.ScheduleProvider>();

    // Provider에서 로드된 데이터 가져오기
    final allExams = scheduleProvider.allExams;
    final allAssignments = scheduleProvider.allAssignments;
    final isLoading = scheduleProvider.isLoading;

    // 기존 timetable 구독은 WeeklyTimetableWrapper에서 사용됨
    // final timetable = context.watch<tp.TimetableProvider>().timetable;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _HeaderSection(),
              const SizedBox(height: 20),
              // 💡 수정: Provider에서 로드된 데이터를 _TopCardsRow에 전달
              _TopCardsRow(
                exams: allExams,
                assignments: allAssignments,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),
              const CurrentClassBanner(),
              const SizedBox(height: 20),
              const _WeeklyTimetableWrapper(),
              const SizedBox(height: 80),
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
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        Icon(Icons.chevron_right, color: Colors.grey, size: 28),
      ],
    );
  }
}

// ==================== 시험 + 과제 (데이터 전달 받도록 수정) ====================
class _TopCardsRow extends StatelessWidget {
  // 💡 추가: 시험/과제 데이터 및 로딩 상태
  final List<Map<String, dynamic>> exams;
  final List<Map<String, dynamic>> assignments;
  final bool isLoading;

  // 💡 const 생성자로 변경
  const _TopCardsRow({
    super.key,
    required this.exams,
    required this.assignments,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 💡 데이터 전달 (왼쪽: 시험)
        Expanded(child: ExamScheduleWidget(exams: exams, isLoading: isLoading)),
        const SizedBox(width: 16),
        // 💡 데이터 전달 (오른쪽: 과제으로 변경)
        Expanded(child: AssignmentScheduleWidget(assignments: assignments, isLoading: isLoading)),
      ],
    );
  }
}

// ==================== 시험 카드 (데이터 처리 로직 추가) ====================
class ExamScheduleWidget extends StatelessWidget {
  // 💡 데이터 필드 추가
  final List<Map<String, dynamic>> exams;
  final bool isLoading;

  const ExamScheduleWidget({super.key, required this.exams, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    // 💡 현재 날짜 이후의 시험만 필터링하고 정렬된 리스트에서 최신 3개 항목만 가져오기
    final now = DateTime.now();
    final upcomingExams = exams
        .where((exam) {
      final examDateStr = exam['examDate'] as String?;
      if (examDateStr == null || examDateStr.isEmpty) return false;
      final examDate = DateTime.tryParse(examDateStr);
      // 오늘 날짜 포함 및 미래 시험만 표시
      return examDate != null && examDate.isAfter(now.subtract(const Duration(days: 1)));
    })
        .take(3)
        .toList();

    return _CardWrapper(
      gradient: const [Color(0xFFFEE2E2), Color(0xFFFDF2F8)],
      title: "시험", // 💡 제목
      emptyText: "등록된 시험이 없습니다",
      items: upcomingExams, // 필터링된 데이터 전달
      isLoading: isLoading,
    );
  }
}

// ==================== 과제 카드 (데이터 처리 로직 추가) ====================
class AssignmentScheduleWidget extends StatelessWidget {
  // 💡 데이터 필드 추가
  final List<Map<String, dynamic>> assignments;
  final bool isLoading;

  const AssignmentScheduleWidget({super.key, required this.assignments, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    // 💡 미제출(submitted: false) 항목 중 현재 날짜 이후의 과제만 필터링하고 최신 3개만 가져오기
    final now = DateTime.now();
    final pendingAssignments = assignments
        .where((a) {
      final isSubmitted = (a['submitted'] ?? false) == true;
      if (isSubmitted) return false;

      final dueDateStr = a['dueDate'] as String?;
      if (dueDateStr == null || dueDateStr.isEmpty) return false;

      final dueDate = DateTime.tryParse(dueDateStr);
      // 오늘 날짜 포함 및 미래 마감 과제만 표시
      return dueDate != null && dueDate.isAfter(now.subtract(const Duration(days: 1)));
    })
        .take(3)
        .toList();

    return _CardWrapper(
      gradient: const [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
      title: "과제", // 💡 제목
      emptyText: "남은 미제출 과제가 없습니다",
      items: pendingAssignments, // 필터링된 데이터 전달
      isLoading: isLoading,
    );
  }
}


// ==================== 카드 공통 디자인 (데이터 표시 로직 추가) ====================
class _CardWrapper extends StatelessWidget {
  final List<Color> gradient;
  final String title; // 💡 제목 필드
  final String emptyText;
  // 💡 추가: 항목 목록 및 로딩 상태
  final List<Map<String, dynamic>> items;
  final bool isLoading;

  const _CardWrapper({
    super.key,
    required this.gradient,
    required this.title,
    required this.emptyText,
    this.items = const [],
    this.isLoading = true,
  });


  // 💡 항목을 표시하는 내부 헬퍼 위젯
  Widget _buildItemRow(Map<String, dynamic> item, bool isExam) {
    // TimeTableButton.dart에서 subjectName이 저장되었다고 가정
    final String subjectName = item['subjectName'] ?? '과목 정보 없음';
    final String titleText = isExam ? (item['examName'] ?? '제목 없음') : (item['title'] ?? '제목 없음');
    // 'YYYY-MM-DD' 형식의 날짜 문자열
    final String dateText = isExam
        ? (item['examDate'] ?? '')
        : (item['dueDate'] ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(isExam ? Icons.event_note : Icons.assignment,
              color: isExam ? const Color(0xFFF87171) : const Color(0xFF4ADE80),
              size: 16
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subjectName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            dateText,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

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
          // ... (상단 헤더 유지)
          Container(
            height: 53,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row( // 💡 const 제거하고 title 사용
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 💡 title을 사용하여 동적으로 텍스트 표시
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Text( // const 유지
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
          // 💡 수정: 내용 영역 (로딩/항목 없음/항목 리스트 표시)
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: gradient.first)) // 로딩 중 표시
                : items.isEmpty
                ? Center( // 항목이 없을 경우 빈 텍스트 표시
              child: Text(
                emptyText,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
              ),
            )
                : Padding( // 항목이 있을 경우 리스트 표시
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: items.map((item) => _buildItemRow(item, title == "시험")).toList(),
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
  const _WeeklyTimetableWrapper();

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