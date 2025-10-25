// 📄 TimeTableButton.dart (수정 완료 버전: D-Day 표시 추가)
// ===================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'AddOfSubject/LectureAddPage.dart';
import 'AddOfSubject/AssignmentAddPage.dart';
import 'AddOfSubject/ExamAddPage.dart';
// 💡 추가: 상태 영속성을 위한 패키지
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON 인코딩/디코딩
// 💡 추가: Provider 임포트
import 'package:provider/provider.dart';
import '../Providers/TimetableProvider.dart'
    as tp; // ScheduleProvider가 이 파일 안에 정의되어 있습니다.

class TimeTableButton extends StatefulWidget {
  final String subjectName;
  // 💡 추가: homepage에서 전달받은 시험/과제 데이터
  final Map<String, dynamic>? initialItemData;

  const TimeTableButton({
    super.key,
    required this.subjectName,
    // 💡 필드 초기화
    this.initialItemData,
  });

  @override
  State<TimeTableButton> createState() => _TimeTableButtonState();
}

class _TimeTableButtonState extends State<TimeTableButton> {
  // 💡 SharedPreferences Key 정의 (각 과목별로 저장하기 위해 subjectName 사용)
  late final String _lectureKey = 'lectures_${widget.subjectName}';
  late final String _assignmentKey = 'assignments_${widget.subjectName}';
  late final String _examKey = 'exams_${widget.subjectName}';

  bool lectureExpanded = true;
  bool assignmentExpanded = true;
  bool examExpanded = true;
  String activeTab = 'home';

  // 💡 List를 재할당 가능하도록 final 키워드 제거
  List<Map<String, dynamic>> lectures = [];
  List<Map<String, dynamic>> assignments = [];
  List<Map<String, dynamic>> exams = [];

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      // 💡 추가: 데이터 로드 후, 초기 항목 데이터가 있다면 수정 페이지로 이동
      if (widget.initialItemData != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleInitialItemTap(widget.initialItemData!);
        });
      }
    }); // 💡 위젯 초기화 시 저장된 데이터 로드
  }

  // 💡 초기 항목 탭 처리 함수: homepage에서 넘어온 항목을 찾아 수정 페이지를 띄움
  void _handleInitialItemTap(Map<String, dynamic> itemData) {
    // 💡 itemData에 'dueDate' (과제) 또는 'examDate' (시험) 키가 있는지 확인하여 종류를 판단
    if (itemData.containsKey('dueDate')) {
      // 1. 과제: 기존 목록에서 해당 항목의 인덱스를 찾음
      final index = assignments.indexWhere((a) =>
          a['title'] == itemData['title'] &&
          a['dueDate'] == itemData['dueDate']);

      if (index != -1) {
        // 찾았으면 수정 페이지로 이동
        _openAssignmentAddPage(index: index);
      } else {
        // 못 찾았으면 추가 페이지로 이동 (예외 처리)
        _openAssignmentAddPage();
      }
    } else if (itemData.containsKey('examDate')) {
      // 2. 시험: 기존 목록에서 해당 항목의 인덱스를 찾음
      final index = exams.indexWhere((e) =>
          e['examName'] == itemData['examName'] &&
          e['examDate'] == itemData['examDate']);

      if (index != -1) {
        // 찾았으면 수정 페이지로 이동
        _openExamAddPage(index: index);
      } else {
        // 못 찾았으면 추가 페이지로 이동 (예외 처리)
        _openExamAddPage();
      }
    }
  }

  // -------------------------------------------------------------------
  // 💾 데이터 로드/저장 (Persistence Logic)
  // -------------------------------------------------------------------

  // 데이터 로드 함수: 저장된 JSON 문자열을 List<Map>으로 변환하여 로드
  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 강의 로드
    final String? lecturesJson = prefs.getString(_lectureKey);
    if (lecturesJson != null) {
      final List<dynamic> decodedList = jsonDecode(lecturesJson);
      lectures =
          decodedList.map((item) => item as Map<String, dynamic>).toList();
    }

    // 과제 목록 로드
    final String? assignmentsJson = prefs.getString(_assignmentKey);
    if (assignmentsJson != null) {
      final List<dynamic> decodedList = jsonDecode(assignmentsJson);
      assignments =
          decodedList.map((item) => item as Map<String, dynamic>).toList();
    }

    // 시험 목록 로드
    final String? examsJson = prefs.getString(_examKey);
    if (examsJson != null) {
      final List<dynamic> decodedList = jsonDecode(examsJson);
      exams = decodedList.map((item) => item as Map<String, dynamic>).toList();
    }

    // 💡 추가: 로드 후 정렬 로직 적용
    _sortData();

    // 로드된 데이터를 화면에 반영
    setState(() {});

    // 💡 추가: 정렬된 상태를 SharedPreferences에 반영 (다음에 로드할 때 정렬된 순서 유지)
    await _saveData();
  }

  // 데이터 저장 함수: List<Map>을 JSON 문자열로 인코딩하여 저장
  Future<void> _saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 강의 저장
    final String lecturesJson = jsonEncode(lectures);
    await prefs.setString(_lectureKey, lecturesJson);

    // 과제 목록 저장
    final String assignmentsJson = jsonEncode(assignments);
    await prefs.setString(_assignmentKey, assignmentsJson);

    // 시험 목록 저장
    final String examsJson = jsonEncode(exams);
    await prefs.setString(_examKey, examsJson);
  }

  // -------------------------------------------------------------------
  // 📊 데이터 정렬 함수 (Sorting Logic)
  // -------------------------------------------------------------------

  void _sortData() {
    // 1. 강의 정렬: 추가한 순서대로 (현재 List<Map>의 기본 순서 유지)
    // 별도의 정렬 로직 없음.

    // 2. 과제 정렬:
    //   1) 미제출이 제출보다 위로 (false(미제출)가 true(제출)보다 작음)
    //   2) 기한이 빠른 순서대로 위로 (오름차순)
    assignments.sort((a, b) {
      final bool aSubmitted = a['submitted'] ?? false;
      final bool bSubmitted = b['submitted'] ?? false;

      // 1. 제출 상태 비교 (미제출(false) < 제출(true))
      // 💡 수정: bool.compareTo 대신 int로 변환하여 비교 (false=0, true=1)
      final int aSubmittedValue = aSubmitted ? 1 : 0;
      final int bSubmittedValue = bSubmitted ? 1 : 0;
      final int submittedComparison =
          aSubmittedValue.compareTo(bSubmittedValue);

      if (submittedComparison != 0) {
        return submittedComparison;
      }

      // 2. 기한 비교 (오름차순: 빠른 날짜가 위로)
      final String aDueDateStr = a['dueDate'] ?? '';
      final String bDueDateStr = b['dueDate'] ?? '';

      if (aDueDateStr.isNotEmpty && bDueDateStr.isNotEmpty) {
        try {
          // 'YYYY-MM-DD HH:mm' 형식의 문자열을 파싱하기 위해 ' '를 'T'로 대체
          final DateTime aDate =
              DateTime.parse(aDueDateStr.replaceAll(' ', 'T'));
          final DateTime bDate =
              DateTime.parse(bDueDateStr.replaceAll(' ', 'T'));
          return aDate.compareTo(bDate); // 빠른 날짜가 더 작음
        } catch (_) {
          // 날짜 파싱 오류 시 문자열로 비교
          return aDueDateStr.compareTo(bDueDateStr);
        }
      } else if (aDueDateStr.isNotEmpty) {
        return -1; // a만 기한이 있으면 a가 위로
      } else if (bDueDateStr.isNotEmpty) {
        return 1; // b만 기한이 있으면 b가 위로
      }

      return 0; // 모두 기한이 없으면 순서 유지
    });

    // 3. 시험 정렬:
    //   1) 종료되지 않은 시험이 종료된 시험보다 위로
    //   2) 일시가 빠른 순서대로 위로 (오름차순)
    exams.sort((a, b) {
      final String aDateStr = a['examDate'] ?? '';
      final String bDateStr = b['examDate'] ?? '';
      final DateTime now = DateTime.now();

      // DateTime 객체로 변환 (변환 실패 시 null)
      DateTime? aDateTime;
      DateTime? bDateTime;
      try {
        if (aDateStr.isNotEmpty) {
          aDateTime = DateTime.parse(aDateStr.replaceAll(' ', 'T'));
        }
        if (bDateStr.isNotEmpty) {
          bDateTime = DateTime.parse(bDateStr.replaceAll(' ', 'T'));
        }
      } catch (_) {
        // 파싱 오류 발생 시 null 유지
      }

      // 1. 시험 종료 상태 비교 (미종료(false) < 종료(true))
      // 날짜가 없거나 파싱 오류가 나면 이미 종료된 것으로 간주 (정렬 기준에서 뒤로 보냄)
      final bool aPassed = aDateTime?.isBefore(now) ?? true;
      final bool bPassed = bDateTime?.isBefore(now) ?? true;

      // 💡 수정: bool.compareTo 대신 int로 변환하여 비교 (false=0, true=1)
      final int aPassedValue = aPassed ? 1 : 0;
      final int bPassedValue = bPassed ? 1 : 0;
      final int passedComparison = aPassedValue.compareTo(bPassedValue);

      if (passedComparison != 0) {
        return passedComparison;
      }

      // 2. 일시 비교 (오름차순: 빠른 날짜가 위로)
      if (aDateTime != null && bDateTime != null) {
        return aDateTime.compareTo(bDateTime);
      } else if (aDateTime != null) {
        return -1; // a만 유효한 날짜가 있으면 a가 위로
      } else if (bDateTime != null) {
        return 1; // b만 유효한 날짜가 있으면 b가 위로
      }

      // 유효한 날짜가 없으면 문자열로 비교하거나 기본 순서 유지
      return aDateStr.compareTo(bDateStr);
    });
  }

  // -------------------------------------------------------------------
  // ➕ 추가/수정 함수 (Add/Edit Functions)
  // -------------------------------------------------------------------

  // 강의 추가 및 수정 처리
  void _openLectureAddPage({int? index}) async {
    // ✅ async 유지
    final Map<String, dynamic>? initialData =
        index != null ? lectures[index] : null;

    final newLectureData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => LectureAddPage(initialData: initialData)));

    if (newLectureData != null &&
        newLectureData is Map<String, dynamic> &&
        newLectureData['title'] != null) {
      setState(() {
        if (index != null) {
          // 수정 (Edit)
          lectures[index] = newLectureData;
        } else {
          // 추가 (Add)
          lectures.add(newLectureData);
        }
        // 💡 추가/수정 후 정렬 적용 (강의는 추가 순서이므로 사실상 영향 없음)
        _sortData();
      });
      // 💡 수정: setState 밖에서 await로 저장 호출
      await _saveData();
    }
  }

  // 과제 추가 및 수정 처리
  void _openAssignmentAddPage({int? index}) async {
    // ✅ async 유지
    final Map<String, dynamic>? initialData =
        index != null ? assignments[index] : null;

    final newAssignmentData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AssignmentAddPage(initialData: initialData)));

    if (newAssignmentData != null &&
        newAssignmentData is Map<String, dynamic> &&
        newAssignmentData['title'] != null) {
      newAssignmentData['subjectName'] = widget.subjectName; // 과목명 추가

      setState(() {
        if (index != null) {
          // 수정 (Edit)
          assignments[index] = newAssignmentData;
        } else {
          // 추가 (Add)
          assignments.add(newAssignmentData);
        }
        // 💡 추가/수정 후 정렬 적용
        _sortData();
      });

      // 💡 수정: 데이터 저장이 완료될 때까지 기다립니다.
      await _saveData();

      // 💡 수정: 저장이 완료된 후 Provider 데이터 재로드를 요청하고 기다립니다.
      if (mounted) {
        await Provider.of<tp.ScheduleProvider>(context, listen: false)
            .loadAllSchedules();
      }
    }
  }

  // 시험 추가 및 수정 처리
  void _openExamAddPage({int? index}) async {
    // ✅ async 유지
    final Map<String, dynamic>? initialData =
        index != null ? exams[index] : null;

    final newExamData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ExamAddPage(initialData: initialData)));

    if (newExamData != null && newExamData is Map<String, dynamic>) {
      // 💡 newExamData가 Map인지 확인

      newExamData['subjectName'] = widget.subjectName; // 과목명 추가

      setState(() {
        if (index != null) {
          // 수정 (Edit)
          exams[index] = newExamData;
        } else {
          // 추가 (Add)
          exams.add(newExamData);
        }
        // 💡 추가/수정 후 정렬 적용
        _sortData();
      });

      // 💡 수정: 데이터 저장이 완료될 때까지 기다립니다.
      await _saveData();

      // 💡 수정: 저장이 완료된 후 Provider 데이터 재로드를 요청하고 기다립니다.
      if (mounted) {
        await Provider.of<tp.ScheduleProvider>(context, listen: false)
            .loadAllSchedules();
      }
    }
  }

  // -------------------------------------------------------------------
  // 🗑️ 삭제 함수 (Delete Functions)
  // -------------------------------------------------------------------

  void _deleteLecture(int index) async {
    // ✅ async 추가
    setState(() {
      lectures.removeAt(index);
      // 💡 삭제 후 정렬 적용 (강의는 추가 순서이므로 사실상 영향 없음)
      _sortData();
    });
    // 💡 수정: setState 밖에서 await로 저장 호출
    await _saveData();
  }

  void _deleteAssignment(int index) async {
    // ✅ async 추가
    setState(() {
      assignments.removeAt(index);
      // 💡 삭제 후 정렬 적용
      _sortData();
    });

    // 💡 수정: 데이터 저장이 완료될 때까지 기다립니다.
    await _saveData();

    // 💡 수정: 저장이 완료된 후 Provider 데이터 재로드를 요청하고 기다립니다.
    if (mounted) {
      await Provider.of<tp.ScheduleProvider>(context, listen: false)
          .loadAllSchedules();
    }
  }

  void _deleteExam(int index) async {
    // ✅ async 추가
    setState(() {
      exams.removeAt(index);
      // 💡 삭제 후 정렬 적용
      _sortData();
    });

    // 💡 수정: 데이터 저장이 완료될 때까지 기다립니다.
    await _saveData();

    // 💡 수정: 저장이 완료된 후 Provider 데이터 재로드를 요청하고 기다립니다.
    if (mounted) {
      await Provider.of<tp.ScheduleProvider>(context, listen: false)
          .loadAllSchedules();
    }
  }

  // -------------------------------------------------------------------
  // ✨ D-Day 계산 헬퍼 함수
  // -------------------------------------------------------------------
  String _getDDayString(String dateString, {bool checkPassed = false}) {
    if (dateString.isEmpty) {
      return '';
    }
    try {
      // 'YYYY-MM-DD HH:mm' 형식의 문자열을 파싱하기 위해 ' '를 'T'로 대체
      final DateTime targetDateTime =
          DateTime.parse(dateString.replaceAll(' ', 'T'));
      final DateTime now = DateTime.now();

      // 💡 checkPassed가 true인 경우 (시험), 시간이 지났으면 '종료' 표시
      if (checkPassed && targetDateTime.isBefore(now)) {
        return ''; // 이미 종료된 경우, D-Day 표시 대신 '시험 종료' 태그 사용
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
        // days < 0 (과제의 경우, 기한이 지났지만 미제출이면 D+ 표시)
        // 시험의 경우, checkPassed 로직에서 걸러지므로, 과제에만 해당
        if (!checkPassed) {
          return 'D+${days.abs()}';
        }
        return ''; // 시험의 경우, 이미 종료된 것으로 간주하고 빈 문자열 반환
      }
    } catch (_) {
      return ''; // 날짜 파싱 오류 시 빈 문자열 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    widget.subjectName,
                    style: const TextStyle(
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

                  // 📘 강의 섹션
                  _buildSection(
                    title: "강의",
                    expanded: lectureExpanded,
                    onToggle: () =>
                        setState(() => lectureExpanded = !lectureExpanded),
                    onAdd: () =>
                        _openLectureAddPage(), // 💡 추가 기능 (index: null)
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFEEF6FF)],
                    ),
                    accent: const Color(0xFF155DFC),
                    children: List.generate(lectures.length, (index) {
                      return _buildItemWithFile(
                        lectures[index],
                        Colors.blue,
                        onDelete: () => _deleteLecture(index),
                        // 💡 항목 전체 탭 시 수정 페이지로 이동
                        onTap: () => _openLectureAddPage(index: index),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // 📗 과제 섹션
                  _buildSection(
                    title: "과제",
                    expanded: assignmentExpanded,
                    onToggle: () => setState(
                        () => assignmentExpanded = !assignmentExpanded),
                    onAdd: () =>
                        _openAssignmentAddPage(), // 💡 과제 추가 (index: null)
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFFEF6), Color(0xFFECFDF5)],
                    ),
                    accent: const Color(0xFF00A63E),
                    children: List.generate(assignments.length, (index) {
                      return _buildItemWithFile(
                        assignments[index],
                        Colors.green,
                        onDelete: () => _deleteAssignment(index),
                        // 항목 전체 탭 시 수정 페이지로 이동
                        onTap: () => _openAssignmentAddPage(index: index),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // 📙 시험 섹션
                  _buildSection(
                    title: "시험",
                    expanded: examExpanded,
                    onToggle: () =>
                        setState(() => examExpanded = !examExpanded),
                    onAdd: () => _openExamAddPage(), // 💡 수정: 인덱스 없이 추가 호출
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFAF5FF), Color(0xFFF5F3FF)],
                    ),
                    accent: const Color(0xFF9810FA),
                    children: List.generate(exams.length, (index) {
                      // 💡 Map 데이터를 넘겨줌
                      return _buildExamItem(
                        exams[index],
                        Colors.purple,
                        onDelete: () => _deleteExam(index),
                        // 💡 항목 전체 탭 시 수정 페이지로 이동
                        onTap: () => _openExamAddPage(index: index),
                      );
                    }),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),

            // -------------------------------------------------------------------
            // 하단 네비게이션바 및 뒤로가기 버튼은 동일
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
  // 🏗️ 빌드 섹션 (Build Sections) - 동일
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Color(0xFF1E293B),
                    ),
                  ),
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
                  ),
                ],
              ),
            ),
          ),
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
  // 📄 파일 첨부 항목 빌드 (강의/과제용) - 기한 포맷팅 및 D-Day 로직 수정
  // -------------------------------------------------------------------

  // 💡 강의/과제 리스트 아이템 카드 (파일 처리 로직 포함)
  Widget _buildItemWithFile(Map<String, dynamic> data, MaterialColor color,
      {required VoidCallback onDelete, VoidCallback? onTap} // 💡 onTap 콜백 유지
      ) {
    final String title = data['title'] ?? '제목 없음';

    // 💡 'submitted' 키가 있을 경우에만 과제로 간주하여 상태를 추출합니다.
    final bool isAssignment = data.containsKey('submitted');
    final bool submitted =
        isAssignment ? (data['submitted'] ?? false) : false; // 과제일 때만 상태 추출

    // 💡 수정: dueDate를 포맷팅된 문자열로 변경
    final String dateString = isAssignment ? (data['dueDate'] ?? '') : '';
    String displayDueDate = '';
    // 💡 D-Day 계산
    final String dDayString =
        isAssignment && dateString.isNotEmpty && !submitted
            ? _getDDayString(dateString)
            : ''; // 미제출 과제에만 D-Day 표시

    if (dateString.isNotEmpty) {
      try {
        // 'YYYY-MM-DD HH:mm' 형식의 문자열을 파싱하기 위해 ' '를 'T'로 대체
        final dateTime = DateTime.parse(dateString.replaceAll(' ', 'T'));

        // YYYY/MM/DD HH:mm 형식으로 표시 (상세 페이지이므로 연도 포함)
        final year = dateTime.year.toString();
        final month = dateTime.month.toString().padLeft(2, '0');
        final day = dateTime.day.toString().padLeft(2, '0');
        final hour = dateTime.hour.toString().padLeft(2, '0');
        final minute = dateTime.minute.toString().padLeft(2, '0');

        displayDueDate = '$year/$month/$day $hour:$minute';
      } catch (_) {
        displayDueDate = dateString; // 파싱 실패 시 원본 문자열 사용
      }
    }
    final String dueDate = displayDueDate;

    // List<Map<String, String>>으로 타입 캐스팅
    final List<Map<String, String>> files = (data['files'] as List?)
            ?.map((item) => Map<String, String>.from(item))
            .toList() ??
        [];
    final bool hasFiles = files.isNotEmpty;

    // 클립 버튼 탭 시 파일 목록 모달을 띄우는 함수
    void _showFilesModal() {
      if (!hasFiles) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FileListModal(
          lectureTitle: title,
          files: files,
          color: color,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        // 항목 전체 탭 시 동작 (수정 페이지 이동)
        onTap: onTap ??
            () {
              HapticFeedback.selectionClick();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("$title 항목을 선택했습니다. (상세 페이지 이동 가정)")));
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  // 💡 Column으로 감싸서 제목, 상태, 제출일을 세로로 표시
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: color.shade700,
                          fontWeight: FontWeight.w700, // 제목을 좀 더 굵게
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 💡 과제(isAssignment)일 때만 상태 및 기한 표시
                      if (isAssignment) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            // 💡 제출 상태 태그
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              margin:
                                  const EdgeInsets.only(right: 8), // 우측 여백 추가
                              decoration: BoxDecoration(
                                color: submitted
                                    ? Colors.green.shade400
                                    : Colors.red.shade400,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                submitted ? '제출 완료' : '미제출',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // 💡 D-Day 태그 (미제출일 경우만 표시)
                            if (dDayString.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: dDayString == 'D-Day'
                                      ? Colors.red.shade600
                                      : (dDayString.startsWith('D+')
                                          ? Colors.orange.shade600
                                          : color.shade600),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  dDayString,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                            // 💡 제출 기한 표시
                            if (dueDate.isNotEmpty)
                              Text(
                                dueDate, // 포맷된 날짜/시각 표시
                                style: TextStyle(
                                  color: color.shade600,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // ---------------------------------------------------
                // 💡 아이콘 위젯 목록 (클립, 삭제, 꺾쇠)
                // ---------------------------------------------------
                Row(
                  children: [
                    if (hasFiles) // 파일이 있을 경우 클립 아이콘 표시
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _showFilesModal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 2.0),
                          child: Icon(Icons.attachment,
                              color: color.shade500, size: 20),
                        ),
                      ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onDelete, // 💡 삭제 버튼
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        child: Icon(Icons.delete_outline,
                            color: Colors.red.shade400, size: 24), // 쓰레기통 아이콘
                      ),
                    ),
                    Icon(Icons.chevron_right, color: color.shade700), // 꺾쇠 아이콘
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 💡 수정: 시험 항목 빌드 (Map 데이터 사용 및 파일 첨부 표시) - 시험 종료/D-Day 태그 로직 추가
  Widget _buildExamItem(Map<String, dynamic> data, MaterialColor color,
      {required VoidCallback onDelete, VoidCallback? onTap}) {
    final String title = data['examName'] ?? '제목 없음';
    final String date = data['examDate'] ?? ''; // 예: 2024-10-23 14:00
    // 💡 필수 수정: 시험 장소 키(examLocation)를 사용하여 데이터 추출
    final String location = data['examLocation'] ?? '';

    // ---------------------------------------------------
    // 💡 추가 로직: 시험 종료 태그 및 D-Day 계산
    // ---------------------------------------------------
    bool isExamPassed = false;
    // 💡 수정: 시험 일시 포맷팅 로직
    String displayDate = '';
    // 💡 D-Day 계산 (종료 여부 체크 포함)
    String dDayString = '';

    if (date.isNotEmpty) {
      try {
        // 💡 'YYYY-MM-DD HH:mm' 형식의 문자열을 DateTime 객체로 파싱합니다.
        DateTime examDateTime = DateTime.parse(date.replaceAll(' ', 'T'));
        final DateTime now = DateTime.now();

        // 현재 시간이 시험 시간보다 늦다면 시험 종료
        isExamPassed = examDateTime.isBefore(now);

        // 종료되지 않은 경우에만 D-Day를 계산합니다.
        if (!isExamPassed) {
          dDayString = _getDDayString(date, checkPassed: true);
        }

        // YYYY/MM/DD HH:mm 형식으로 표시 (상세 페이지이므로 연도 포함)
        final year = examDateTime.year.toString();
        final month = examDateTime.month.toString().padLeft(2, '0');
        final day = examDateTime.day.toString().padLeft(2, '0');
        final hour = examDateTime.hour.toString().padLeft(2, '0');
        final minute = examDateTime.minute.toString().padLeft(2, '0');

        displayDate = '$year/$month/$day $hour:$minute';
      } catch (e) {
        // 파싱 실패 시 원본 문자열 사용
        displayDate = date;
        print("Error parsing exam date: $e");
      }
    }

    // 💡 날짜와 장소 정보가 있을 경우 조합하여 표시할 문자열 생성
    String displayInfo = '';

    if (displayDate.isNotEmpty) {
      displayInfo += '$displayDate'; // 날짜/시각만 먼저 표시
    }

    if (location.isNotEmpty) {
      if (displayDate.isNotEmpty) {
        // 날짜가 있으면 괄호 안에 장소 추가
        displayInfo += ' ($location)';
      } else {
        // 날짜가 없으면 "장소: [장소명]"만 표시
        displayInfo += '장소: $location';
      }
    }

    // List<Map<String, String>>으로 타입 캐스팅
    final List<Map<String, String>> files = (data['materials'] as List?)
            ?.map((item) => Map<String, String>.from(item))
            .toList() ??
        [];
    final bool hasFiles = files.isNotEmpty;

    // 클립 버튼 탭 시 파일 목록 모달을 띄우는 함수 (FileListModal 재사용)
    void _showFilesModal() {
      if (!hasFiles) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        // FileListModal은 'lectureTitle' 필드를 사용하므로 '시험명'을 넘겨줍니다.
        builder: (context) => FileListModal(
          lectureTitle: "$title 자료",
          files: files,
          color: color,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: onTap ??
            () {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: color.shade700,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      // 💡 추가: 시험 종료/D-Day 태그 및 날짜/장소 정보 표시
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // 💡 시험 종료 상태 태그
                          if (isExamPassed)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade500, // 종료된 시험은 회색으로
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '시험 종료',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          // 💡 D-Day 태그 (미종료된 경우만 표시)
                          if (!isExamPassed && dDayString.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: dDayString == 'D-Day'
                                    ? Colors.red.shade600
                                    : color.shade600,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                dDayString,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          // 💡 날짜와 장소를 조합한 문자열을 표시
                          if (displayInfo.isNotEmpty)
                            Text(
                              displayInfo, // 조합된 정보 표시
                              style: TextStyle(
                                color: color.shade600,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ---------------------------------------------------
                // 💡 아이콘 위젯 목록 (클립, 삭제, 꺾쇠)
                // ---------------------------------------------------
                Row(
                  children: [
                    if (hasFiles) // 파일이 있을 경우 클립 아이콘 표시
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: _showFilesModal,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 2.0),
                          child: Icon(Icons.attachment,
                              color: color.shade500, size: 20),
                        ),
                      ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onDelete, // 💡 삭제 버튼
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        child: Icon(Icons.delete_outline,
                            color: Colors.red.shade400, size: 24), // 쓰레기통 아이콘
                      ),
                    ),
                    Icon(Icons.chevron_right, color: color.shade700), // 꺾쇠 아이콘
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // 🧭 하단 네비게이션 아이템은 동일
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

// -------------------------------------------------------------------
// 💡 FileListModal은 변경 없음 (파일 목록 모달)
// -------------------------------------------------------------------

class FileListModal extends StatelessWidget {
  final String lectureTitle;
  final List<Map<String, String>> files;
  final MaterialColor color;

  const FileListModal({
    super.key,
    required this.lectureTitle,
    required this.files,
    required this.color,
  });

  void _openFile(BuildContext context, Map<String, String> file) async {
    final filePath = file["path"];

    if (filePath == null || filePath.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("파일 경로를 찾을 수 없습니다.")));
      return;
    }

    final result = await OpenFilex.open(filePath);

    Navigator.pop(context);

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("파일 열기 실패: ${result.message}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "$lectureTitle 첨부 파일 (${files.length}개)",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color.shade800,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  leading: Icon(Icons.attach_file, color: color.shade500),
                  title: Text(file["name"] ?? '이름 없음'),
                  subtitle: Text("업로드: ${file["date"]}"),
                  trailing: Icon(Icons.launch, color: color.shade500),
                  onTap: () => _openFile(context, file),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
