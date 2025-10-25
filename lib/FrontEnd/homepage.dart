// 📄 homepage.dart (D-Day 표시 기능 추가)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_app/FrontEnd/EditingPageParents.dart';
import 'package:study_app/FrontEnd/FullTimeTable.dart';
import 'package:study_app/FrontEnd/TimeTablebutton.dart';
import '../Providers/TimetableProvider.dart' as tp;

// 💡 [추가 시작] ISO weekday를 한국어 요일로 변환하는 헬퍼 함수
String _getKoreanDay(int weekday) {
  switch (weekday) {
    case 1:
      return '월';
    case 2:
      return '화';
    case 3:
      return '수';
    case 4:
      return '목';
    case 5:
      return '금';
    case 6:
      return '토';
    case 7:
      return '일';
    default:
      return '';
  }
}
// 💡 [추가 끝]

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
      // 💡 수정: EditingPageParents에서 setAll을 통해 스케줄 업데이트가 트리거됩니다.
      // Provider.of<tp.ScheduleProvider>(context, listen: false)
      //     .loadAllSchedules();
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
              // 💡 수정: 현재 수업 배너 위젯을 기능이 구현된 위젯으로 교체
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
    // 💡 항목 탭 시 처리 로직
    void handleItemTap(Map<String, dynamic> item) async {
      // 💡 핵심 수정: subjectName을 명시적으로 'subjectName' 키에서 가져옵니다.
      final String subjectName = item['subjectName'] as String? ?? '과목 정보 없음';
      if (subjectName == '과목 정보 없음' || subjectName.isEmpty)
        return; // 과목명이 없거나 비어있으면 동작하지 않음

      // TimeTableButton으로 이동하며 데이터 전달
      // 💡 수정: subjectName은 이미 TimetableProvider.dart에서 '과목명'만 저장되도록 처리되었습니다.
      // 💡 따라서 TimeTableButton의 요구사항에 맞춰 '과목명'만 전달합니다.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TimeTableButton(
            subjectName: subjectName, // 💡 과목명만 전달
            // 💡 추가: 탭된 항목의 상세 데이터와 타입을 전달하여 TimeTableButton에서 처리하도록 합니다.
            initialItemData: item,
          ),
        ),
      );
      // 돌아왔을 때 새로고침 (homepage의 기존 로직)
      if (context.mounted) {
        // 기존 새로고침 로직
        // 💡 수정: EditingPageParents에서 setAll 호출 후 콜백을 통해 로드되므로 명시적 호출 대신 wait
        // Provider.of<tp.ScheduleProvider>(context, listen: false)
        //     .loadAllSchedules();
      }
    }

    return Row(
      children: [
        // 💡 데이터 전달 및 onItemTap 콜백 전달 (왼쪽: 시험)
        Expanded(
          child: ExamScheduleWidget(
            exams: exams,
            isLoading: isLoading,
            onItemTap: handleItemTap, // 💡 콜백 전달
          ),
        ),
        const SizedBox(width: 16),
        // 💡 데이터 전달 및 onItemTap 콜백 전달 (오른쪽: 과제)
        Expanded(
          child: AssignmentScheduleWidget(
            assignments: assignments,
            isLoading: isLoading,
            onItemTap: handleItemTap, // 💡 콜백 전달
          ),
        ),
      ],
    );
  }
}

// ==================== 시험 카드 (데이터 처리 로직 추가) ====================
class ExamScheduleWidget extends StatelessWidget {
  // 💡 데이터 필드 추가
  final List<Map<String, dynamic>> exams;
  final bool isLoading;
  // 💡 추가: onItemTap 콜백
  final void Function(Map<String, dynamic>)? onItemTap;

  const ExamScheduleWidget({
    super.key,
    required this.exams,
    required this.isLoading,
    this.onItemTap, // 💡 필드 초기화
  });

  @override
  Widget build(BuildContext context) {
    // 💡 현재 날짜 이후의 시험만 필터링하고 정렬된 리스트에서 최신 3개 항목만 가져오기
    final now = DateTime.now();
    final upcomingExams = exams
        .where((exam) {
          final examDateStr = exam['examDate'] as String?;
          if (examDateStr == null || examDateStr.isEmpty) return false;

          // 💡 수정: 'YYYY-MM-DD HH:mm' 형식의 문자열을 파싱하기 위해 ' '를 'T'로 대체
          final examDate = DateTime.tryParse(examDateStr.replaceAll(' ', 'T'));

          // 오늘 날짜 포함 및 미래 시험만 표시 (종료되지 않은 항목)
          return examDate != null && !examDate.isBefore(now);
        })
        .take(3) // 💡 시험 항목도 3개까지만 표시
        .toList();

    return _CardWrapper(
      gradient: const [Color(0xFFFEE2E2), Color(0xFFFDF2F8)],
      title: "시험", // 💡 제목
      emptyText: "등록된 시험이 없습니다",
      items: upcomingExams, // 필터링된 데이터 전달
      isLoading: isLoading,
      onItemTap: onItemTap, // 💡 콜백 전달
    );
  }
}

// ==================== 과제 카드 (데이터 처리 로직 추가) ====================
class AssignmentScheduleWidget extends StatelessWidget {
  // 💡 데이터 필드 추가
  final List<Map<String, dynamic>> assignments;
  final bool isLoading;
  // 💡 추가: onItemTap 콜백
  final void Function(Map<String, dynamic>)? onItemTap;

  const AssignmentScheduleWidget({
    super.key,
    required this.assignments,
    required this.isLoading,
    this.onItemTap, // 💡 필드 초기화
  });

  @override
  Widget build(BuildContext context) {
    // 💡 미제출(submitted: false) 항목 중 현재 날짜 이후의 과제만 필터링하고 최신 3개만 가져오기
    final now = DateTime.now();
    final pendingAssignments = assignments
        .where((a) {
          final isSubmitted = (a['submitted'] ?? false) == true;
          if (isSubmitted) return false; // 제출 완료 항목은 제외

          final dueDateStr = a['dueDate'] as String?;
          if (dueDateStr == null || dueDateStr.isEmpty) return false;

          // 💡 수정: 'YYYY-MM-DD HH:mm' 형식의 문자열을 파싱하기 위해 ' '를 'T'로 대체
          final dueDate = DateTime.tryParse(dueDateStr.replaceAll(' ', 'T'));

          // D+ 표시를 위해 기한이 지난 과제도 필터링하지 않고, D-Day 계산 함수에 맡깁니다.
          // 하지만 homepage에서는 *남은* 항목을 보여주는 것이 목적이므로, 과거는 제외합니다.
          // 💡 수정:dueDate가 null이 아니고, 마감일이 현재 시간보다 이후인 경우만 필터링하여 '다가오는' 과제만 표시
          return dueDate != null && !dueDate.isBefore(now);
        })
        .take(3)
        .toList();

    return _CardWrapper(
      gradient: const [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
      title: "과제", // 💡 제목
      emptyText: "남은 미제출 과제가 없습니다",
      items: pendingAssignments, // 필터링된 데이터 전달
      isLoading: isLoading,
      onItemTap: onItemTap, // 💡 콜백 전달
    );
  }
}

// ==================== 카드 공통 디자인 (데이터 표시 로직 수정 및 스크롤 가능하게 변경) ====================
class _CardWrapper extends StatelessWidget {
  final List<Color> gradient;
  final String title; // 💡 제목 필드
  final String emptyText;
  // 💡 추가: 항목 목록 및 로딩 상태
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  // 💡 추가: 항목 탭 시 실행할 콜백 (item 데이터 전달)
  final void Function(Map<String, dynamic>)? onItemTap;

  const _CardWrapper({
    super.key,
    required this.gradient,
    required this.title,
    required this.emptyText,
    this.items = const [],
    this.isLoading = true,
    this.onItemTap, // 💡 콜백 초기화
  });

  // 💡 추가: D-Day 계산 헬퍼 함수
  String _getDDayString(String dateString, {bool isExam = false}) {
    if (dateString.isEmpty) {
      return '';
    }
    try {
      // 'YYYY-MM-DD HH:mm' 형식의 문자열을 파싱하기 위해 ' '를 'T'로 대체
      final DateTime targetDateTime =
          DateTime.parse(dateString.replaceAll(' ', 'T'));
      final DateTime now = DateTime.now();

      // 시험 (isExam)이면서 이미 시간이 지난 경우
      if (isExam && targetDateTime.isBefore(now)) {
        return '';
      }

      // 현재 날짜 (시/분/초 무시)
      final DateTime nowDay = DateTime(now.year, now.month, now.day);
      // 목표 날짜 (시/분/초 무시)
      final DateTime targetDay = DateTime(
          targetDateTime.year, targetDateTime.month, targetDateTime.day);

      final Duration difference = targetDay.difference(nowDay);
      final int days = difference.inDays;

      if (days == 0) {
        return 'D-Day';
      } else if (days > 0) {
        return 'D-$days';
      } else {
        // days < 0 (과제의 경우 D+ 표시)
        if (!isExam) {
          return 'D+${days.abs()}';
        }
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  // 💡 항목을 표시하는 내부 헬퍼 위젯 (D-Day 로직 추가)
  Widget _buildItemRow(Map<String, dynamic> item, bool isExam, int index) {
    // 💡 수정: TimeTableButton.dart에서 subjectName이 저장되었다고 가정
    final String subjectName = item['subjectName'] as String? ?? '과목 정보 없음';
    final String titleText =
        isExam ? (item['examName'] ?? '제목 없음') : (item['title'] ?? '제목 없음');

    // 'YYYY-MM-DD HH:mm' 형식의 날짜/시간 문자열
    final String dateString =
        isExam ? (item['examDate'] ?? '') : (item['dueDate'] ?? '');

    // 💡 추가: D-Day 계산
    final String dDayString = _getDDayString(dateString, isExam: isExam);

    // 💡 수정: 날짜/시간 포맷팅 로직 추가 (MM/DD HH:mm)
    String displayDate = '';
    if (dateString.isNotEmpty) {
      try {
        // 'YYYY-MM-DD HH:mm' 형식의 문자열을 파싱하기 위해 ' '를 'T'로 대체
        final dateTime = DateTime.parse(dateString.replaceAll(' ', 'T'));

        // MM/DD HH:mm 형식으로 표시
        final month = dateTime.month.toString().padLeft(2, '0');
        final day = dateTime.day.toString().padLeft(2, '0');
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');

        displayDate = '$month/$day $hour:$minute';
      } catch (_) {
        // 파싱 실패 시 원본 문자열의 날짜 부분만 표시
        displayDate = dateString.split(' ')[0];
      }
    }

    final String dateText = displayDate;

    // 💡 표시할 최종 텍스트: D-Day가 있으면 D-Day를, 없으면 포맷된 날짜/시간을 표시
    final String rightText = dDayString.isNotEmpty ? dDayString : dateText;
    // 💡 D-Day 색상 결정
    final Color rightTextColor = dDayString.isNotEmpty
        ? (dDayString == 'D-Day'
            ? Colors.red.shade600 // D-Day는 빨간색
            : (dDayString.startsWith('D+')
                ? Colors.orange.shade600 // D+는 주황색 (지연된 과제)
                : const Color(0xFF1F2937))) // D-N은 일반 텍스트 색상
        : const Color(0xFF1F2937); // 날짜/시간은 일반 텍스트 색상

    // 💡 수정 시작: 과목명 및 시험 장소 정보 추출 및 표시 방식 결정
    // subjectName은 ScheduleProvider에서 '과목명'만 저장하도록 처리되었음.
    final String courseName = subjectName;

    // 💡 수정: 'examLocation' 키에서 실제 시험 장소를 가져옵니다.
    // 과제(isExam: false)일 경우 빈 문자열을 유지합니다.
    final String examLocation = isExam ? (item['examLocation'] ?? '') : '';

    // 시험(isExam: true)인 경우: '과목명 (시험 장소)' 형식으로 표시
    final String displaySubjectText = isExam
        ? (examLocation.isNotEmpty ? '$courseName ($examLocation)' : courseName)
        : courseName;
    // 💡 수정 끝

    // 💡 항목 전체를 GestureDetector로 감싸서 onTap을 처리
    return GestureDetector(
      // 💡 탭 이벤트 처리: onItemTap 콜백 실행
      onTap: () {
        if (onItemTap != null) {
          onItemTap!(item);
        }
      },
      child: Padding(
        // 🚨 수정: 수직 패딩을 8.0으로 늘려 터치 영역 확장 및 항목 간 간격 확보
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(isExam ? Icons.event_note : Icons.assignment,
                color:
                    isExam ? const Color(0xFFF87171) : const Color(0xFF4ADE80),
                size: 16),
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
                    displaySubjectText, // 수정된 텍스트 사용
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 💡 수정: D-Day 또는 날짜/시간을 표시
            Text(
              rightText, // D-Day 또는 날짜/시간
              style: TextStyle(
                fontWeight: FontWeight.w700, // D-Day 강조
                fontSize: 14,
                color: rightTextColor, // D-Day에 따라 색상 변경
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 💡 높이 고정 (스크롤을 허용하므로 높이 고정 필요)
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
            child: Row(
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
                // ❌ 삭제: "전체보기" 텍스트 제거됨
              ],
            ),
          ),
          // 💡 수정: 내용 영역 (로딩/항목 없음/항목 리스트 표시)
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        color: gradient.first)) // 로딩 중 표시
                : items.isEmpty
                    ? Center(
                        // 항목이 없을 경우 빈 텍스트 표시
                        child: Text(
                          emptyText,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    : // 💡 수정: 항목이 있을 경우 ListView.builder로 변경 (RenderFlex Overflow 방지)
                    ListView.builder(
                        // padding을 ListView에 적용
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          // 💡 ListView 내에서 아이템 하나씩 빌드
                          return _buildItemRow(
                            items[index],
                            title == "시험",
                            index,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ==================== [수정됨] 현재 수업 배너 (기능 구현) ====================
// 💡 [수정 시작] StatefulWidget으로 변경 및 기능 구현
class CurrentClassBanner extends StatefulWidget {
  const CurrentClassBanner({super.key});

  @override
  State<CurrentClassBanner> createState() => _CurrentClassBannerState();
}

class _CurrentClassBannerState extends State<CurrentClassBanner> {
  // FullTimeTable.dart를 참고하여 23시 수업(24시 종료)까지 반영
  final List<String> _times = const [
    "9:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00", // 💡 추가
    "16:00", // 💡 추가
    "17:00", // 💡 추가
    "18:00", // 💡 추가
    "19:00", // 💡 추가
    "20:00", // 💡 추가
    "21:00", // 💡 추가
    "22:00", // 💡 추가
    "23:00" // 💡 추가 (24:00까지 반영)
  ];

  // 현재 시간과 요일을 기준으로 진행 중인 강의를 찾는 함수
  tp.SubjectInfo? _findCurrentClass(Map<String, tp.SubjectInfo?> timetable) {
    final now = DateTime.now();
    final currentDay = _getKoreanDay(now.weekday);
    final currentHour = now.hour;

    // 1. 주말 체크
    if (currentDay == '토' || currentDay == '일') {
      return null;
    }

    // 2. 운영 시간 체크 (9시 이전 또는 24시 이후)
    // 23시 수업은 23:00부터 23:59까지 진행되므로, currentHour > 23은 종료를 의미합니다.
    if (currentHour < 9 || currentHour > 23) {
      // 💡 18 -> 24(23:59) 반영을 위해 23 초과로 변경
      return null;
    }

    // 3. 현재 시간에 맞는 수업 슬롯 검색
    for (final startTimeStr in _times) {
      final startHour = int.parse(startTimeStr.split(':')[0]);

      // 현재 시간이 강의 시작 시간과 일치하는 경우 (예: 현재 10시 -> 10:00 수업 확인)
      if (currentHour == startHour) {
        // 시간표 키는 "요일-시간" 형식 (예: "월-9:00")
        final key = "$currentDay-$startTimeStr";

        final subjectInfo = timetable[key];

        // 과목 정보가 있고, 과목명이 비어있지 않은 경우
        if (subjectInfo != null && subjectInfo.subject.isNotEmpty) {
          return subjectInfo;
        }
      }
    }
    return null; // 진행 중인 강의가 없음
  }

  @override
  Widget build(BuildContext context) {
    // TimetableProvider에서 시간표 데이터를 가져옵니다.
    final timetable = context.watch<tp.TimetableProvider>().timetable;
    final currentClass = _findCurrentClass(timetable);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      height: 98, // 높이 고정 유지
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬 대신 내용 정렬에 집중
        children: [
          // 현재 진행 중인 강의 헤더는 생략하고 내용만 간결하게 표시 (기존 위젯 높이 유지)
          if (currentClass != null)
            _CurrentClassInfo(
                subject: currentClass, currentHour: DateTime.now().hour)
          else
            const _NoCurrentClassInfo(),
        ],
      ),
    );
  }
}

// 💡 [추가] 현재 강의 정보 표시 위젯
class _CurrentClassInfo extends StatelessWidget {
  final tp.SubjectInfo subject;
  final int currentHour;

  const _CurrentClassInfo({required this.subject, required this.currentHour});

  @override
  Widget build(BuildContext context) {
    final nextHour = currentHour + 1; // 수업 종료 시간
    final timeRange =
        '${currentHour.toString().padLeft(2, '0')}:00 - ${nextHour.toString().padLeft(2, '0')}:00';
    final location = subject.room.isNotEmpty ? subject.room : '강의실 정보 없음';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.school, color: Color(0xFF3B82F6), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  subject.subject, // 과목명
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFF1F2937),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timeRange, // 시간대
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const Text(' | ',
                        style: TextStyle(color: Color(0xFF9CA3AF))),
                    Text(
                      location, // 강의실
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 💡 [추가] 현재 강의 없음 표시 위젯
class _NoCurrentClassInfo extends StatelessWidget {
  const _NoCurrentClassInfo();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentDay = _getKoreanDay(now.weekday);
    final currentHour = now.hour; // 💡 currentHour 추가

    String message;
    if (currentDay == '토' || currentDay == '일') {
      message = "주말에는 강의가 없습니다! 🎉";
      // 💡 24시까지 연장된 시간표에 맞춰 00:00 ~ 08:59는 '종료'로, 09:00 ~ 23:59는 '수업 없음'으로 분리
    } else if (currentHour >= 0 && currentHour < 6) {
      // 00:00 ~ 05:59 (자정이 지났으므로 강의 종료)
      message = "오늘의 강의는 모두 종료되었습니다. 👍";
    } else if (currentHour >= 6 && currentHour < 9) {
      // 06:00 ~ 08:59 (수업 시작 전)
      message = "아직 강의 시작 전입니다. 😴";
    } else {
      // 09:00 ~ 23:59 (수업 시간이지만 등록된 강의가 없음)
      message = "현재 진행 중인 수업이 없습니다. ☕";
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
// 💡 [수정 끝]

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
    // 💡 수정: 24시까지 반영을 위해 시간표 범위 23:00까지 확장 (스크롤 가능)
    final times = [
      "9:00",
      "10:00",
      "11:00",
      "12:00",
      "13:00",
      "14:00",
      "15:00", // 💡 추가
      "16:00", // 💡 추가
      "17:00", // 💡 추가
      "18:00", // 💡 추가
      "19:00", // 💡 추가
      "20:00", // 💡 추가
      "21:00", // 💡 추가
      "22:00", // 💡 추가
      "23:00" // 💡 추가
    ];

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

          // 💡 수정: Expanded와 ListView.builder를 사용하여 스크롤 가능하도록 변경
          SizedBox(
            height: 340, // 적절한 높이 설정
            child: ListView.builder(
              physics: const ClampingScrollPhysics(), // 스크롤 물리 효과
              itemCount: times.length,
              itemBuilder: (context, index) {
                final t = times[index];
                return Padding(
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
                                    // 💡 수정: TimeTableButton에 과목명만 전달하도록 수정
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TimeTableButton(
                                          subjectName: cellSubject.subject,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: cellSubject?.bgColor ??
                                        const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(20),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
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
                );
              },
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
