// 📄 TimeTablebutton.dart (사용자 요청 사항 및 모든 수정 사항 반영된 전체 코드)
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
  // 💡 [추가] 더블 탭 시 자동 파일 열림 플래그
  final bool autoOpenLatestFile;

  const TimeTableButton({
    super.key,
    required this.subjectName,
    // 💡 필드 초기화
    this.initialItemData,
    // 💡 [추가] 필드 초기화
    this.autoOpenLatestFile = false,
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
      // 💡 [추가] autoOpenLatestFile이 true인 경우, 가장 최근 파일 열기 시도
      if (widget.autoOpenLatestFile && lectures.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _openLatestFile();
        });
      }
    }); // 💡 위젯 초기화 시 저장된 데이터 로드
  }

  // 💡 [추가] 파일 'lastOpened' 시각 업데이트 및 저장 로직

  void _updateFileLastOpened(String filePath) async {
    bool found = false;
    // 현재 시각을 ISO 8601 문자열로 저장
    final nowString = DateTime.now().toIso8601String();

    for (var lecture in lectures) {
      // files 리스트를 Map<String, dynamic> 타입으로 안전하게 변환
      final files = (lecture['files'] as List?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList() ??
          [];

      // 파일 리스트를 순회하며 해당 filePath를 가진 파일을 찾음
      for (int i = 0; i < files.length; i++) {
        if (files[i]['path'] == filePath) {
          // 'lastOpened' 필드를 현재 시각으로 업데이트
          files[i]['lastOpened'] = nowString;
          // 변경된 files 리스트를 lecture 맵에 다시 할당
          lecture['files'] = files;
          found = true;
          break;
        }
      }
      if (found) break;
    }

    if (found) {
      // 업데이트된 데이터를 SharedPreferences에 저장
      await _saveData();
      setState(() {});
    }
  }

  // 💡 [수정] 파일 열기 로직: async/await으로 변경 및 mounted 체크 적용
  void _openLatestFile() async {
    // 1. 모든 강의 항목에서 파일 목록을 추출
    final List<Map<String, dynamic>> allFiles = lectures
        .expand((lecture) =>
    (lecture['files'] as List?)
        ?.map((item) => Map<String, dynamic>.from(item))
        .toList() ??
        <Map<String, dynamic>>[])
        .toList();

    if (allFiles.isEmpty) return;

    // 2. 파일 목록을 'lastOpened' 기준으로 정렬
    allFiles.sort((a, b) {
      final String aLastOpenedStr = a['lastOpened'] ?? a['date'] ?? '';
      final String bLastOpenedStr = b['lastOpened'] ?? b['date'] ?? '';

      final DateTime aDate =
          DateTime.tryParse(aLastOpenedStr) ?? DateTime(1900);
      final DateTime bDate =
          DateTime.tryParse(bLastOpenedStr) ?? DateTime(1900);

      // 내림차순 정렬: 최신 날짜/시각(값이 큰)가 앞으로
      return bDate.compareTo(aDate);
    });

    // 3. 가장 최근 파일 열기
    final latestFile = allFiles.first;
    final filePath = latestFile['path'];

    if (filePath != null && filePath.isNotEmpty) {
      // 💡 파일 열기 전 'lastOpened' 시간 업데이트
      _updateFileLastOpened(filePath);

      // 💡 [수정] open_filex를 await으로 호출하고 mounted 체크로 안전하게 context 사용
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        // 파일 열기 실패 시 스낵바 표시
        // 💡 [Fix: use_build_context_synchronously] mounted 체크
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("최근 파일 열기 실패: ${result.message}")));
        }
      }
    }
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
      // 💡 Map<String, dynamic>으로 변환하여 'lastOpened' 필드 등을 처리할 수 있도록 함
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

      // 💡 [Fix: use_build_context_synchronously] mounted 체크
      if (mounted) {
        // ScheduleProvider는 TimetableProvider 파일에 별칭으로 임포트되어 있음
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

      // 💡 [Fix: use_build_context_synchronously] mounted 체크
      if (mounted) {
        // ScheduleProvider는 TimetableProvider 파일에 별칭으로 임포트되어 있음
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

    // 💡 [Fix: use_build_context_synchronously] mounted 체크
    if (mounted) {
      // ScheduleProvider는 TimetableProvider 파일에 별칭으로 임포트되어 있음
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

    // 💡 [Fix: use_build_context_synchronously] mounted 체크
    if (mounted) {
      // ScheduleProvider는 TimetableProvider 파일에 별칭으로 임포트되어 있음
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

      // 시험 (checkPassed: true)인 경우, 이미 지난 일시는 계산하지 않음
      if (checkPassed && targetDateTime.isBefore(now)) {
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
    // 💡 [추가] TimetableProvider 접근
    final timetableProvider = Provider.of<tp.TimetableProvider>(context);
    // 💡 [수정] 현재 시간표 이름 가져오기. 없으면 '시간표 선택'으로 표시
    final currentTimetableName =
        timetableProvider.currentTimetable?.name ?? '시간표 선택';

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
                  // ✨ [사용자 요청 사항 반영] 하드코딩된 '2024년 1학기'를 Provider의 이름으로 대체
                  Text(
                    currentTimetableName,
                    style: const TextStyle(
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
                      colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    accent: Colors.blue, // MaterialColor
                    children: lectures
                        .asMap()
                        .entries
                        .map((e) => _buildLectureItem(
                      e.value,
                      Colors.blue, // MaterialColor
                      onDelete: () => _deleteLecture(e.key),
                      // 💡 항목 전체 탭 시 수정 페이지로 이동
                      onTap: () => _openLectureAddPage(index: e.key),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // 📝 과제 섹션
                  _buildSection(
                    title: "과제",
                    expanded: assignmentExpanded,
                    onToggle: () => setState(
                            () => assignmentExpanded = !assignmentExpanded),
                    onAdd: () =>
                        _openAssignmentAddPage(), // 💡 추가 기능 (index: null)
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0FDF4), Color(0xFFD1FAE5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    accent: Colors.green, // MaterialColor
                    children: assignments
                        .asMap()
                        .entries
                        .map((e) => _buildAssignmentItem(
                      e.value,
                      Colors.green, // MaterialColor
                      onToggleSubmitted: () async {
                        setState(() {
                          // 제출 상태를 토글
                          e.value['submitted'] =
                          !(e.value['submitted'] ?? false);
                          // 토글 후 정렬
                          _sortData();
                        });
                        // 💡 수정: 데이터 저장 및 Provider 업데이트
                        await _saveData();
                        // 💡 [Fix: use_build_context_synchronously] mounted 체크
                        if (mounted) {
                          await Provider.of<tp.ScheduleProvider>(
                              context,
                              listen: false)
                              .loadAllSchedules();
                        }
                      },
                      onDelete: () => _deleteAssignment(e.key),
                      // 💡 항목 전체 탭 시 수정 페이지로 이동
                      onTap: () => _openAssignmentAddPage(index: e.key),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // 💡 시험 섹션
                  _buildSection(
                    title: "시험",
                    expanded: examExpanded,
                    onToggle: () =>
                        setState(() => examExpanded = !examExpanded),
                    onAdd: () => _openExamAddPage(), // 💡 추가 기능 (index: null)
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    accent: Colors.red, // MaterialColor
                    children: exams
                        .asMap()
                        .entries
                        .map((e) => _buildExamItem(
                      e.value,
                      Colors.red, // MaterialColor
                      onDelete: () => _deleteExam(e.key),
                      // 💡 항목 전체 탭 시 수정 페이지로 이동
                      onTap: () => _openExamAddPage(index: e.key),
                    ))
                        .toList(),
                  ),

                  // 💡 [수정] 고정 하단 네비게이션바(높이 80)를 고려한 충분한 스크롤 마진 추가
                  const SizedBox(height: 100),
                ],
              ),
            ),

            // -------------------------------------------------------------------
            // 하단 네비게이션바 및 뒤로가기 버튼은 동일
            // -------------------------------------------------------------------
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                // 💡 [수정] Bottom Padding을 포함한 높이 설정 (하단 시스템 바 간섭 해결)
                height: 80 + MediaQuery.of(context).padding.bottom,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Padding(
                  // 💡 [추가] 콘텐츠(Row)에만 Bottom Padding 적용
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
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
                      child: Icon(Icons.chevron_left, color: Colors.black54)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // 🏗️ 빌드 섹션 (Build Sections) - MaterialColor로 타입 수정 (구조 확인 완료)
  // -------------------------------------------------------------------
  Widget _buildSection({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required VoidCallback onAdd,
    required LinearGradient gradient,
    required MaterialColor accent, // 💡 [수정] MaterialColor로 타입 변경
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
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20), bottom: Radius.circular(0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: accent.shade900), // 💡 오류 해결
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                        Icon(Icons.add, color: accent.shade800), // 💡 오류 해결
                      ),
                    ),
                    InkWell(
                      onTap: onToggle,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: accent.shade800, // 💡 오류 해결
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20), top: Radius.circular(0)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              // 💡 아이템당 할당 높이를 72.0으로 적용 (짤림 현상 해결)
              height: expanded ? children.length * 72.0 + 10.0 : 0,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: children,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // 📚 강의 아이템 (Lecture Item) - MaterialColor로 타입 수정 (교수 변수 제거)
  // -------------------------------------------------------------------
  Widget _buildLectureItem(Map<String, dynamic> data,
      MaterialColor color, // 💡 [수정] MaterialColor로 타입 변경
          {required VoidCallback onDelete,
        required VoidCallback onTap}) {
    final String title = data['title'] ?? '제목 없음';
    // 💡 [수정] 사용되지 않는 'professor' 변수 선언 제거
    final String date = data['date'] ?? ''; // 'YYYY-MM-DD' 형식의 문자열
    final String location = data['location'] ?? '장소 정보 없음';

    // List<Map<String, dynamic>>으로 타입 캐스팅 (lastOpened 필드 처리를 위해)
    final List<Map<String, dynamic>> files = (data['files'] as List?)
        ?.map((item) => Map<String, dynamic>.from(item))
        .toList() ??
        [];
    final bool hasFiles = files.isNotEmpty;

    // 클립 버튼 탭 시 파일 목록 모달을 띄우는 함수
    void showFilesModal() {
      // 💡 [Fix: no_leading_underscores_for_local_identifiers] 함수 이름 변경
      if (!hasFiles) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FileListModal(
          lectureTitle: title,
          files: files,
          color: color,
          onFileOpened: _updateFileLastOpened, // 💡 [추가] 파일 열림 시 상태 업데이트 콜백 전달
        ),
      );
    }

    // 💡 최종적으로 표시할 날짜 문자열 포맷팅
    String displayDate = '';
    if (date.isNotEmpty) {
      try {
        final dateTime = DateTime.parse(date);
        // MM/DD 형식으로 표시
        final month = dateTime.month.toString().padLeft(2, '0');
        final day = dateTime.day.toString().padLeft(2, '0');
        displayDate = '$month/$day';
      } catch (_) {
        displayDate = date; // 파싱 실패 시 원본 문자열 사용
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap, // 💡 항목 탭 시 수정 페이지로 이동
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 💡 정보 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E2939),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // 💡 날짜 표시
                        if (displayDate.isNotEmpty)
                          Text(
                            displayDate,
                            style: TextStyle(
                                color: color.shade600,
                                fontSize: 13), // 💡 오류 해결
                          ),
                        if (displayDate.isNotEmpty && location.isNotEmpty)
                          const Text(' | ',
                              style: TextStyle(color: Color(0xFF9CA3AF))),
                        // 💡 장소 표시
                        if (location.isNotEmpty)
                          Text(
                            location,
                            style: const TextStyle(
                                color: Color(0xFF6A7282), fontSize: 13),
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
                      onTap: showFilesModal, // 💡 [수정] 함수 이름 변경
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        child: Icon(Icons.attachment,
                            color: color.shade500, size: 20), // 💡 오류 해결
                      ),
                    ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onDelete, // 💡 삭제 버튼
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 2.0),
                      child: Icon(Icons.delete_outline,
                          color: Colors.red.shade400, size: 20),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // 📝 과제 아이템 (Assignment Item) - MaterialColor로 타입 수정
  // -------------------------------------------------------------------
  Widget _buildAssignmentItem(
      Map<String, dynamic> data,
      MaterialColor color, // 💡 [수정] MaterialColor로 타입 변경
          {
        required VoidCallback onToggleSubmitted,
        required VoidCallback onDelete,
        required VoidCallback onTap,
      }) {
    final String title = data['title'] ?? '제목 없음';
    // 💡 'submitted' 키가 있을 경우에만 과제로 간주하여 상태를 추출합니다.
    final bool isAssignment = data.containsKey('submitted');
    final bool submitted =
    isAssignment ? (data['submitted'] ?? false) : false; // 과제일 때만 상태 추출
    // 💡 수정: dueDate를 포맷팅된 문자열로 변경
    final String dateString = isAssignment ? (data['dueDate'] ?? '') : '';
    String displayDueDate = '';
    // 💡 D-Day 계산 (미제출일 경우만 D-Day 표시)
    final String dDayString =
    isAssignment && dateString.isNotEmpty && !submitted
        ? _getDDayString(dateString)
        : '';
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

    // List<Map<String, dynamic>>으로 타입 캐스팅 (lastOpened 필드 처리를 위해)
    final List<Map<String, dynamic>> files = (data['files'] as List?)
        ?.map((item) => Map<String, dynamic>.from(item))
        .toList() ??
        [];
    final bool hasFiles = files.isNotEmpty;

    // 클립 버튼 탭 시 파일 목록 모달을 띄우는 함수
    void showFilesModal() {
      // 💡 [Fix: no_leading_underscores_for_local_identifiers] 함수 이름 변경
      if (!hasFiles) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FileListModal(
            lectureTitle: title,
            files: files,
            color: color,
            onFileOpened: (filePath) {
              // 과제 자료는 '가장 최근 열린 파일' 추적 로직에서 제외되므로 빈 함수 전달
            }),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap, // 💡 항목 탭 시 수정 페이지로 이동
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 💡 정보 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E2939),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // 💡 제출 상태 태그
                        InkWell(
                          onTap: onToggleSubmitted,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
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
                                  : color.shade600), // 💡 오류 해결
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
                              color: color.shade600, // 💡 오류 해결
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
                      onTap: showFilesModal, // 💡 [수정] 함수 이름 변경
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        child: Icon(Icons.attachment,
                            color: color.shade500, size: 20), // 💡 오류 해결
                      ),
                    ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onDelete, // 💡 삭제 버튼
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 2.0),
                      child: Icon(Icons.delete_outline,
                          color: Colors.red.shade400, size: 20),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 💥 시험 아이템 (Exam Item) - MaterialColor로 타입 수정
  Widget _buildExamItem(
      Map<String, dynamic> data,
      MaterialColor color, // 💡 [수정] MaterialColor로 타입 변경
          {
        required VoidCallback onDelete,
        required VoidCallback onTap,
      }) {
    final String title = data['examName'] ?? '제목 없음';
    final String location = data['examLocation'] ?? '';
    final String date = data['examDate'] ?? ''; // 'YYYY-MM-DD HH:mm' 형식의 문자열

    String displayDate = '';
    String dDayString = '';
    String displayInfo = '';

    if (date.isNotEmpty) {
      try {
        // 'YYYY-MM-DD HH:mm' 형식의 문자열을 파싱하기 위해 ' '를 'T'로 대체
        final examDateTime = DateTime.parse(date.replaceAll(' ', 'T'));
        // 시험이 종료되지 않았는지 확인 후 D-Day 계산
        dDayString = _getDDayString(date, checkPassed: true);

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
      }
    }

    // 💡 날짜와 장소 정보가 있을 경우 조합하여 표시할 문자열 생성
    if (displayDate.isNotEmpty) {
      displayInfo += displayDate; // 날짜/시각만 먼저 표시
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

    // List<Map<String, dynamic>>으로 타입 캐스팅 (lastOpened 필드 처리를 위해)
    final List<Map<String, dynamic>> files = (data['materials'] as List?)
        ?.map((item) => Map<String, dynamic>.from(item))
        .toList() ??
        [];
    final bool hasFiles = files.isNotEmpty;

    // 클립 버튼 탭 시 파일 목록 모달을 띄우는 함수 (FileListModal 재사용)
    void showFilesModal() {
      // 💡 [Fix: no_leading_underscores_for_local_identifiers] 함수 이름 변경
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
          onFileOpened: (filePath) {
            // 시험 자료는 '가장 최근 열린 파일' 추적 로직에서 제외되므로 빈 함수 전달
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap, // 💡 항목 탭 시 수정 페이지로 이동
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 💡 정보 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1E2939),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // 💡 D-Day 태그 (시험이 종료되지 않았을 경우만 표시)
                        if (dDayString.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: dDayString == 'D-Day'
                                  ? Colors.red.shade600
                                  : color.shade600, // 💡 오류 해결
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
                              color: color.shade600, // 💡 오류 해결
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
                      onTap: showFilesModal, // 💡 [수정] 함수 이름 변경
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4.0, vertical: 2.0),
                        child: Icon(Icons.attachment,
                            color: color.shade500, size: 20), // 💡 오류 해결
                      ),
                    ),
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: onDelete, // 💡 삭제 버튼
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0, vertical: 2.0),
                      child: Icon(Icons.delete_outline,
                          color: Colors.red.shade400, size: 20),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // 🧭 네비게이션 아이템 (Navigation Item) - 수정된 부분: 끝에 붙은 세미콜론 제거
  // -------------------------------------------------------------------
  Widget _buildNavItem(String label, IconData icon, String tab) {
    // 💡 InkWell 대신 GestureDetector 사용
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          activeTab = tab;
        });
        // 💡 탭 이동 로직 (현재는 단순히 상태만 변경)
        if (tab == 'community' || tab == 'settings') {
          // Navigator.pop(context); // 임시
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: activeTab == tab ? Colors.blue : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: activeTab == tab ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

// ===================================================================
// 📎 파일 목록 모달 (FileListModal) - MaterialColor로 타입 수정
// ===================================================================
class FileListModal extends StatelessWidget {
  final String lectureTitle;
  // 💡 수정: Map<String, dynamic>으로 변경
  final List<Map<String, dynamic>> files;
  final MaterialColor color; // 💡 [수정] MaterialColor로 타입 변경
  // 💡 [추가] 파일 열림 시 호출할 콜백
  final void Function(String filePath) onFileOpened;

  const FileListModal({
    super.key,
    required this.lectureTitle,
    // 💡 수정: Map<String, dynamic> 타입
    required this.files,
    required this.color,
    // 💡 [추가] 콜백 초기화
    required this.onFileOpened,
  });

  // 💡 [수정] 파일 열기 로직: async/await으로 변경 및 context.mounted 체크 적용
  void _openFile(BuildContext context, Map<String, dynamic> file) async {
    final filePath = file['path'];

    if (filePath != null && filePath.isNotEmpty) {
      // 💡 파일 열기 전에 'lastOpened' 시간 업데이트
      onFileOpened(filePath);

      // 💡 [수정] open_filex를 await으로 호출
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        // 💡 [Fix: use_build_context_synchronously] context.mounted 체크
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("파일 열기 실패: ${result.message}")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 [수정] 파일 목록을 'lastOpened' 기준으로 정렬 (최근 열림 시각이 없으면 'date' 기준으로 대체)
    final List<Map<String, dynamic>> sortedFiles = List.from(files);

    sortedFiles.sort((a, b) {
      final String aLastOpenedStr = a['lastOpened'] ?? a['date'] ?? '';
      final String bLastOpenedStr = b['lastOpened'] ?? b['date'] ?? '';

      // 날짜 파싱 (실패 시 1900년으로 간주하여 정렬에서 밀려나게 함)
      final DateTime aDate =
          DateTime.tryParse(aLastOpenedStr) ?? DateTime(1900);
      final DateTime bDate =
          DateTime.tryParse(bLastOpenedStr) ?? DateTime(1900);

      // 내림차순 정렬: 최신 날짜/시각(값이 큰)가 앞으로
      return bDate.compareTo(aDate);
    });

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
                color: color.shade800, // 💡 오류 해결
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: sortedFiles.length,
              itemBuilder: (context, index) {
                final file = sortedFiles[index]; // 💡 정렬된 목록 사용
                return ListTile(
                  leading: Icon(Icons.attach_file,
                      color: color.shade500), // 💡 오류 해결
                  title: Text(file["name"] ?? '이름 없음'),
                  subtitle: Text("업로드: ${file["date"]}"),
                  trailing:
                  Icon(Icons.launch, color: color.shade500), // 💡 오류 해결
                  onTap: () => _openFile(context, file),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
