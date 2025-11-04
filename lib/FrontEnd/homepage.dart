// 📄 homepage.dart (더블 탭: TimeTableButton 페이지 건너뛰고 바로 파일 열기)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback 사용을 위한 import
import 'package:provider/provider.dart';
// 💡 [추가] 파일 열기 및 상태 영속성을 위한 import
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON 디코딩
import 'package:open_filex/open_filex.dart'; // 파일 열기 패키지

import 'package:study_app/FrontEnd/EditingPageParents.dart' as ep;
import 'package:study_app/FrontEnd/FullTimeTable.dart' as ft;

import 'package:study_app/FrontEnd/TimeTablebutton.dart';
import '../Providers/TimetableProvider.dart' as tp;
import 'package:study_app/FrontEnd/Settings/SettingsPage.dart' as sp;
import 'TimeTableSelectionPage.dart';

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
  }

  Future<void> _openEditingPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ep.EditingPageParents()),
    );
    if (mounted) {
      setState(() {}); // 기존 새로고침
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<tp.ScheduleProvider>();
    final allExams = scheduleProvider.allExams;
    final allAssignments = scheduleProvider.allAssignments;
    final isLoading = scheduleProvider.isLoading;

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
              _TopCardsRow(
                exams: allExams,
                assignments: allAssignments,
                isLoading: isLoading,
              ),
              const SizedBox(height: 20),
              // 💡 [수정됨] CurrentClassBanner 사용
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TimeTableSelectionPage()),
        );
      },
      child: const Row(
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
      ),
    );
  }
}

// ==================== 시험 + 과제 (데이터 전달 받도록 수정) ====================
class _TopCardsRow extends StatelessWidget {
  final List<Map<String, dynamic>> exams;
  final List<Map<String, dynamic>> assignments;
  final bool isLoading;

  const _TopCardsRow({
    super.key,
    required this.exams,
    required this.assignments,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    void handleItemTap(Map<String, dynamic> item) async {
      final String subjectName = item['subjectName'] as String? ?? '과목 정보 없음';
      if (subjectName == '과목 정보 없음' || subjectName.isEmpty) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TimeTableButton(
            subjectName: subjectName,
            initialItemData: item,
            autoOpenLatestFile: false,
          ),
        ),
      );
      if (context.mounted) {}
    }

    return Row(
      children: [
        Expanded(
          child: ExamScheduleWidget(
            exams: exams,
            isLoading: isLoading,
            onItemTap: handleItemTap,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AssignmentScheduleWidget(
            assignments: assignments,
            isLoading: isLoading,
            onItemTap: handleItemTap,
          ),
        ),
      ],
    );
  }
}

// ==================== 시험 카드 (데이터 처리 로직 추가) ====================
class ExamScheduleWidget extends StatelessWidget {
  final List<Map<String, dynamic>> exams;
  final bool isLoading;
  final void Function(Map<String, dynamic>)? onItemTap;

  const ExamScheduleWidget({
    super.key,
    required this.exams,
    required this.isLoading,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcomingExams = exams
        .where((exam) {
          final examDateStr = exam['examDate'] as String?;
          if (examDateStr == null || examDateStr.isEmpty) return false;
          final examDate = DateTime.tryParse(examDateStr.replaceAll(' ', 'T'));
          return examDate != null && !examDate.isBefore(now);
        })
        .take(3)
        .toList();

    return _CardWrapper(
      gradient: const [Color(0xFFFEE2E2), Color(0xFFFDF2F8)],
      title: "시험",
      emptyText: "등록된 시험이 없습니다",
      items: upcomingExams,
      isLoading: isLoading,
      onItemTap: onItemTap,
    );
  }
}

// ==================== 과제 카드 (데이터 처리 로직 추가) ====================
class AssignmentScheduleWidget extends StatelessWidget {
  final List<Map<String, dynamic>> assignments;
  final bool isLoading;
  final void Function(Map<String, dynamic>)? onItemTap;

  const AssignmentScheduleWidget({
    super.key,
    required this.assignments,
    required this.isLoading,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final pendingAssignments = assignments
        .where((a) {
          final isSubmitted = (a['submitted'] ?? false) == true;
          if (isSubmitted) return false;

          final dueDateStr = a['dueDate'] as String?;
          if (dueDateStr == null || dueDateStr.isEmpty) return false;
          final dueDate = DateTime.tryParse(dueDateStr.replaceAll(' ', 'T'));

          return dueDate != null && !dueDate.isBefore(now);
        })
        .take(3)
        .toList();

    return _CardWrapper(
      gradient: const [Color(0xFFF0FDF4), Color(0xFFECFDF5)],
      title: "과제",
      emptyText: "남은 미제출 과제가 없습니다",
      items: pendingAssignments,
      isLoading: isLoading,
      onItemTap: onItemTap,
    );
  }
}

// ==================== 카드 공통 디자인 ====================
class _CardWrapper extends StatelessWidget {
  final List<Color> gradient;
  final String title;
  final String emptyText;
  final List<Map<String, dynamic>> items;
  final bool isLoading;
  final void Function(Map<String, dynamic>)? onItemTap;

  const _CardWrapper({
    super.key,
    required this.gradient,
    required this.title,
    required this.emptyText,
    this.items = const [],
    this.isLoading = true,
    this.onItemTap,
  });

  String _getDDayString(String dateString, {bool isExam = false}) {
    if (dateString.isEmpty) {
      return '';
    }
    try {
      final DateTime targetDateTime =
          DateTime.parse(dateString.replaceAll(' ', 'T'));
      final DateTime now = DateTime.now();

      if (isExam && targetDateTime.isBefore(now)) {
        return '';
      }

      final DateTime nowDay = DateTime(now.year, now.month, now.day);
      final DateTime targetDay = DateTime(
          targetDateTime.year, targetDateTime.month, targetDateTime.day);

      final Duration difference = targetDay.difference(nowDay);
      final int days = difference.inDays;

      if (days == 0) {
        return 'D-Day';
      } else if (days > 0) {
        return 'D-$days';
      } else {
        if (!isExam) {
          return 'D+${days.abs()}';
        }
        return '';
      }
    } catch (_) {
      return '';
    }
  }

  Widget _buildItemRow(Map<String, dynamic> item, bool isExam, int index) {
    final String subjectName = item['subjectName'] as String? ?? '과목 정보 없음';
    final String titleText =
        isExam ? (item['examName'] ?? '제목 없음') : (item['title'] ?? '제목 없음');

    final String dateString =
        isExam ? (item['examDate'] ?? '') : (item['dueDate'] ?? '');

    final String dDayString = _getDDayString(dateString, isExam: isExam);

    String displayDate = '';
    if (dateString.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(dateString.replaceAll(' ', 'T'));
        final month = dateTime.month.toString().padLeft(2, '0');
        final day = dateTime.day.toString().padLeft(2, '0');
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');

        displayDate = '$month/$day $hour:$minute';
      } catch (_) {
        displayDate = dateString.split(' ')[0];
      }
    }

    final String dateText = displayDate;

    final String rightText = dDayString.isNotEmpty ? dDayString : dateText;
    final Color rightTextColor = dDayString.isNotEmpty
        ? (dDayString == 'D-Day'
            ? Colors.red.shade600
            : (dDayString.startsWith('D+')
                ? Colors.orange.shade600
                : const Color(0xFF1F2937)))
        : const Color(0xFF1F2937);

    final String courseName = subjectName;
    final String examLocation = isExam ? (item['examLocation'] ?? '') : '';
    final String displaySubjectText = isExam
        ? (examLocation.isNotEmpty ? '$courseName ($examLocation)' : courseName)
        : courseName;

    return GestureDetector(
      onTap: () {
        if (onItemTap != null) {
          HapticFeedback.lightImpact();
          onItemTap!(item);
        }
      },
      child: Padding(
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
                    displaySubjectText,
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
              rightText,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: rightTextColor,
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
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(color: gradient.first))
                : items.isEmpty
                    ? Center(
                        child: Text(
                          emptyText,
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 16.0),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
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

// ==================== [추가됨] 파일 열기 및 로직 ====================
class FileOpenerLogic {
  // 💡 [추가] SharedPreferences에서 최근 열었던 파일 경로를 가져오는 함수
  static Future<String?> _getLatestFilePath(String subjectName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? filesJsonString = prefs.getString('files_$subjectName');

      if (filesJsonString == null || filesJsonString.isEmpty) {
        return null;
      }

      final List<dynamic> filesList = json.decode(filesJsonString);
      if (filesList.isEmpty) {
        return null;
      }

      // 🚨 TimeTableButton.dart에서 사용했던 로직을 기반으로 'latest_access' 키를 사용하여 정렬
      final List<Map<String, dynamic>> files =
          filesList.map((e) => e as Map<String, dynamic>).toList();

      files.sort((a, b) {
        final dateA = DateTime.tryParse(a['latest_access'] ?? '');
        final dateB = DateTime.tryParse(b['latest_access'] ?? '');

        // 유효한 접근 시간으로 내림차순 정렬 (가장 최근이 앞으로)
        if (dateA != null && dateB != null) {
          return dateB.compareTo(dateA);
        } else if (dateA != null) {
          return -1; // B가 null이면 A가 더 최근으로 간주
        } else if (dateB != null) {
          return 1; // A가 null이면 B가 더 최근으로 간주
        }
        return 0;
      });

      // 가장 최근에 접근한 파일의 경로 반환
      return files.first['path'] as String?;
    } catch (e) {
      // print('Error loading latest file path: $e');
      return null;
    }
  }

  // 💡 [추가] 파일을 실제로 열고 사용자에게 피드백을 주는 함수
  static Future<void> openLatestFile(
      BuildContext context, String subjectName) async {
    HapticFeedback.mediumImpact(); // 더블 탭 피드백

    final filePath = await _getLatestFilePath(subjectName);

    if (filePath != null && filePath.isNotEmpty) {
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('파일 열기 실패: ${result.message}')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('최근 열었던 강의 자료가 없습니다.')),
        );
      }
    }
  }
}

// ==================== [수정됨] 현재 수업 배너 ====================
class CurrentClassBanner extends StatefulWidget {
  const CurrentClassBanner({super.key});

  @override
  State<CurrentClassBanner> createState() => _CurrentClassBannerState();
}

class _CurrentClassBannerState extends State<CurrentClassBanner> {
  final List<String> _times = [
    "9:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
    "18:00",
    "19:00",
    "20:00",
    "21:00",
    "22:00",
    "23:00"
  ];

  tp.SubjectInfo? _findCurrentClass(Map<String, tp.SubjectInfo?> timetable) {
    final now = DateTime.now();
    final currentDay = _getKoreanDay(now.weekday);
    final currentHour = now.hour;

    if (currentDay == '토' ||
        currentDay == '일' ||
        currentHour < 9 ||
        currentHour > 23) {
      return null;
    }

    for (final startTimeStr in _times) {
      final startHour = int.parse(startTimeStr.split(':')[0]);
      if (currentHour == startHour) {
        final key = "$currentDay-$startTimeStr";
        final subjectInfo = timetable[key];
        if (subjectInfo != null && subjectInfo.subject.isNotEmpty) {
          return subjectInfo;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<tp.TimetableProvider>().timetable;
    final currentClass =
        _findCurrentClass(timetable as Map<String, tp.SubjectInfo?>);

    // 💡 [수정] 탭 핸들러: 더블 탭 로직을 파일 바로 열기로 변경
    void _handleTap({required bool isDoubleTap}) {
      if (currentClass != null) {
        final subjectName = currentClass.subject;
        if (isDoubleTap) {
          // 🚨 [핵심 수정] 더블 탭 시 TimeTableButton 페이지 건너뛰고 바로 파일 열기
          FileOpenerLogic.openLatestFile(context, subjectName);
        } else {
          HapticFeedback.lightImpact();
          // 단일 탭: TimeTableButton 페이지로 이동
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TimeTableButton(
                subjectName: subjectName,
                initialItemData: null,
                autoOpenLatestFile: false, // 단일 탭
              ),
            ),
          );
        }
      }
    }

    return GestureDetector(
      onTap: currentClass != null ? () => _handleTap(isDoubleTap: false) : null,
      onDoubleTap:
          currentClass != null ? () => _handleTap(isDoubleTap: true) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        height: 98,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, offset: Offset(0, 1), blurRadius: 2),
          ],
        ),
        child: currentClass != null
            ? _CurrentClassInfo(subject: currentClass)
            : const _NoCurrentClassInfo(),
      ),
    );
  }
}

// 💡 [추가] 현재 강의 정보 표시 위젯
class _CurrentClassInfo extends StatelessWidget {
  final tp.SubjectInfo subject;

  const _CurrentClassInfo({required this.subject});

  String _getTimeRange() {
    final now = DateTime.now();
    final currentHour = now.hour;

    String start = '$currentHour:00';
    String end = '${currentHour}:50';

    if (currentHour == 23) {
      end = '24:00';
    }

    return '$start ~ $end';
  }

  @override
  Widget build(BuildContext context) {
    final timeRange = _getTimeRange();
    final location = subject.room;

    return Row(
      children: [
        const Icon(Icons.access_time_filled,
            color: Color(0xFF3B82F6), size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subject.subject,
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
                    timeRange,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const Text(' | ', style: TextStyle(color: Color(0xFF9CA3AF))),
                  Text(
                    location,
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
    final currentHour = now.hour;

    String message;
    if (currentDay == '토' || currentDay == '일') {
      message = "주말에는 강의가 없습니다! 🎉";
    } else if (currentHour >= 0 && currentHour < 6) {
      message = "오늘의 강의는 모두 종료되었습니다. 👍";
    } else if (currentHour >= 6 && currentHour < 9) {
      message = "아직 강의 시작 전입니다. 😴";
    } else {
      message = "현재 진행 중인 수업이 없습니다. ☕";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, color: Colors.grey.shade400, size: 28),
            const SizedBox(width: 15),
            Text(
              "현재 수업",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

// ==================== [수정됨] 주간 시간표 ====================
class _WeeklyTimetableWrapper extends StatefulWidget {
  const _WeeklyTimetableWrapper();

  @override
  State<_WeeklyTimetableWrapper> createState() =>
      _WeeklyTimetableWrapperState();
}

class _WeeklyTimetableWrapperState extends State<_WeeklyTimetableWrapper> {
  final List<String> days = ['월', '화', '수', '목', '금'];

  final List<String> _times = [
    "9:00",
    "10:00",
    "11:00",
    "12:00",
    "13:00",
    "14:00",
    "15:00",
    "16:00",
    "17:00",
    "18:00",
    "19:00",
    "20:00",
    "21:00",
    "22:00",
    "23:00"
  ];

  tp.SubjectInfo? _getSubject(
      String day, String time, Map<String, tp.SubjectInfo?> timetable) {
    return timetable['$day-$time'];
  }

  // 💡 [수정] 시간표 셀 위젯 (클릭 기능 포함)
  Widget _buildTimetableCell(
      BuildContext context, tp.SubjectInfo? cellSubject) {
    return Expanded(
      child: GestureDetector(
        // 1. [수정] 더블 탭: TimeTableButton 페이지 건너뛰고 바로 파일 열기
        onDoubleTap: () {
          if (cellSubject != null && cellSubject.subject.isNotEmpty) {
            // 🚨 [핵심 수정] 더블 탭 시 TimeTableButton 페이지 건너뛰고 바로 파일 열기
            FileOpenerLogic.openLatestFile(context, cellSubject.subject);
          }
        },
        // 2. [유지] 단일 탭: TimeTableButton 페이지로 이동 (파일 자동 열림 X)
        onTap: () {
          if (cellSubject != null && cellSubject.subject.isNotEmpty) {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TimeTableButton(
                  subjectName: cellSubject.subject,
                  autoOpenLatestFile: false, // 단일 탭
                ),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 50,
          decoration: BoxDecoration(
            color: cellSubject?.bgColor ?? const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: (cellSubject == null || cellSubject.subject.isEmpty)
              ? const SizedBox.shrink()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cellSubject.subject,
                      style: TextStyle(
                        color: cellSubject.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      cellSubject.room,
                      style: TextStyle(
                        color: cellSubject.roomColor,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<tp.TimetableProvider>().timetable;

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
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ft.FullTimeTable(),
                        ),
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
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ep.EditingPageParents(),
                        ),
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
          Row(
            children: [
              const SizedBox(width: 60),
              for (final d in days)
                Expanded(
                    child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                )),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50.0 * 5 + 32,
            child: ListView.builder(
              itemCount: _times.length,
              itemBuilder: (context, timeIndex) {
                final time = _times[timeIndex];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 60,
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      for (final day in days)
                        _buildTimetableCell(
                          context,
                          _getSubject(day, time, timetable),
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
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home,
            label: "홈",
            active: true,
            onTap: () {
              HapticFeedback.lightImpact();
            },
          ),
          _NavItem(
            icon: Icons.edit_calendar_outlined,
            label: "시간표 수정",
            active: false,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ep.EditingPageParents()),
              );
            },
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            label: "설정",
            active: false,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const sp.SettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.blue : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.blue : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
