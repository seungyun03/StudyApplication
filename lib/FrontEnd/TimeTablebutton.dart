// 📄 TimeTableButton.dart (수정됨: Provider 연동 및 subjectName 추가)
// ===================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'LectureAddPage.dart';
import 'AssignmentAddPage.dart';
import 'ExamAddPage.dart';
// 💡 추가: 상태 영속성을 위한 패키지
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON 인코딩/디코딩
// 💡 추가: Provider 임포트
import 'package:provider/provider.dart';
import '../Providers/TimetableProvider.dart' as tp; // ScheduleProvider가 이 파일 안에 정의되어 있습니다.

class TimeTableButton extends StatefulWidget {
  final String subjectName;

  const TimeTableButton({
    super.key,
    required this.subjectName,
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
    _loadData(); // 💡 위젯 초기화 시 저장된 데이터 로드
  }

  // -------------------------------------------------------------------
  // 💾 데이터 로드/저장 (Persistence Logic)
  // -------------------------------------------------------------------

  // 데이터 로드 함수: 저장된 JSON 문자열을 List<Map>으로 변환하여 로드
  Future<void> _loadData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 강의 자료 로드
    final String? lecturesJson = prefs.getString(_lectureKey);
    if (lecturesJson != null) {
      final List<dynamic> decodedList = jsonDecode(lecturesJson);
      lectures = decodedList.map((item) => item as Map<String, dynamic>).toList();
    }

    // 과제 목록 로드
    final String? assignmentsJson = prefs.getString(_assignmentKey);
    if (assignmentsJson != null) {
      final List<dynamic> decodedList = jsonDecode(assignmentsJson);
      assignments = decodedList.map((item) => item as Map<String, dynamic>).toList();
    }

    // 시험 목록 로드
    final String? examsJson = prefs.getString(_examKey);
    if (examsJson != null) {
      final List<dynamic> decodedList = jsonDecode(examsJson);
      exams = decodedList.map((item) => item as Map<String, dynamic>).toList();
    }

    // 로드된 데이터를 화면에 반영
    setState(() {});
  }

  // 데이터 저장 함수: List<Map>을 JSON 문자열로 인코딩하여 저장
  Future<void> _saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 강의 자료 저장
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
  // ➕ 추가/수정 함수 (Add/Edit Functions)
  // -------------------------------------------------------------------

  // 강의 자료 추가 및 수정 처리
  void _openLectureAddPage({int? index}) async {
    final Map<String, dynamic>? initialData =
    index != null ? lectures[index] : null;

    final newLectureData = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LectureAddPage(initialData: initialData)));

    if (newLectureData != null && newLectureData is Map<String, dynamic> && newLectureData['title'] != null) {
      setState(() {
        if (index != null) {
          // 수정 (Edit)
          lectures[index] = newLectureData;
        } else {
          // 추가 (Add)
          lectures.add(newLectureData);
        }
        _saveData(); // 💡 데이터 변경 후 저장
      });
    }
  }

  // 과제 추가 및 수정 처리
  void _openAssignmentAddPage({int? index}) async {
    final Map<String, dynamic>? initialData =
    index != null ? assignments[index] : null;

    final newAssignmentData = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AssignmentAddPage(initialData: initialData)));

    if (newAssignmentData != null &&
        newAssignmentData is Map<String, dynamic> &&
        newAssignmentData['title'] != null) {
      setState(() {
        // 💡 필수 추가: 과목명 추가
        newAssignmentData['subjectName'] = widget.subjectName;

        if (index != null) {
          // 수정 (Edit)
          assignments[index] = newAssignmentData;
        } else {
          // 추가 (Add)
          assignments.add(newAssignmentData);
        }
        _saveData(); // 💡 데이터 변경 후 저장

        // 💡 Provider 알림 추가: 스케줄 Provider에게 데이터 재로드를 요청
        Provider.of<tp.ScheduleProvider>(context, listen: false).loadAllSchedules();
      });
    }
  }

  // 시험 일정 추가 및 수정 처리
  void _openExamAddPage({int? index}) async {
    final Map<String, dynamic>? initialData =
    index != null ? exams[index] : null;

    final newExamData = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => ExamAddPage(initialData: initialData)));

    if (newExamData != null && newExamData is Map<String, dynamic>) { // 💡 newExamData가 Map인지 확인
      setState(() {
        // 💡 필수 추가: 과목명 추가
        newExamData['subjectName'] = widget.subjectName;

        if (index != null) {
          // 수정 (Edit)
          exams[index] = newExamData;
        } else {
          // 추가 (Add)
          exams.add(newExamData);
        }
        _saveData(); // 💡 데이터 변경 후 저장

        // 💡 Provider 알림 추가: 스케줄 Provider에게 데이터 재로드를 요청
        Provider.of<tp.ScheduleProvider>(context, listen: false).loadAllSchedules();
      });
    }
  }

  // -------------------------------------------------------------------
  // 🗑️ 삭제 함수 (Delete Functions)
  // -------------------------------------------------------------------

  void _deleteLecture(int index) {
    setState(() {
      lectures.removeAt(index);
      _saveData(); // 💡 데이터 변경 후 저장
    });
  }

  void _deleteAssignment(int index) {
    setState(() {
      assignments.removeAt(index);
      _saveData(); // 💡 데이터 변경 후 저장
      // 💡 Provider 알림 추가: 스케줄 Provider에게 데이터 재로드를 요청
      Provider.of<tp.ScheduleProvider>(context, listen: false).loadAllSchedules();
    });
  }

  void _deleteExam(int index) {
    setState(() {
      exams.removeAt(index);
      _saveData(); // 💡 데이터 변경 후 저장
      // 💡 Provider 알림 추가: 스케줄 Provider에게 데이터 재로드를 요청
      Provider.of<tp.ScheduleProvider>(context, listen: false).loadAllSchedules();
    });
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

                  // 📘 강의자료 섹션
                  _buildSection(
                    title: "강의자료",
                    expanded: lectureExpanded,
                    onToggle: () =>
                        setState(() => lectureExpanded = !lectureExpanded),
                    onAdd: () => _openLectureAddPage(), // 💡 추가 기능 (index: null)
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
                    onAdd: () => _openAssignmentAddPage(), // 💡 과제 추가 (index: null)
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

                  // 📙 시험일정 섹션
                  _buildSection(
                    title: "시험일정",
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
  // 📄 파일 첨부 항목 빌드 (강의/과제용) - 동일
  // -------------------------------------------------------------------

  // 💡 강의/과제 리스트 아이템 카드 (파일 처리 로직 포함)
  Widget _buildItemWithFile(
      Map<String, dynamic> data,
      MaterialColor color,
      {required VoidCallback onDelete, VoidCallback? onTap} // 💡 onTap 콜백 유지
      ) {
    final String title = data['title'] ?? '제목 없음';

    // 💡 'submitted' 키가 있을 경우에만 과제로 간주하여 상태를 추출합니다.
    final bool isAssignment = data.containsKey('submitted');
    final bool submitted = isAssignment ? (data['submitted'] ?? false) : false; // 과제일 때만 상태 추출
    final String dueDate = isAssignment ? (data['dueDate'] ?? '') : ''; // 과제일 때만 기한 추출

    // List<Map<String, String>>으로 타입 캐스팅
    final List<Map<String, String>> files = (data['files'] as List?)
        ?.map((item) => Map<String, String>.from(item))
        .toList() ?? [];
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
        onTap: onTap ?? () {
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: submitted ? Colors.green.shade400 : Colors.red.shade400,
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
                            // 💡 제출 기한 표시
                            if (dueDate.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '기한: $dueDate',
                                  style: TextStyle(
                                    color: color.shade600,
                                    fontSize: 13,
                                  ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                          child: Icon(Icons.attachment, color: color.shade500, size: 20),
                        ),
                      ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onDelete, // 💡 삭제 버튼
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 24), // 쓰레기통 아이콘
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


  // 💡 수정: 시험 일정 항목 빌드 (Map 데이터 사용 및 파일 첨부 표시)
  Widget _buildExamItem(
      Map<String, dynamic> data,
      MaterialColor color,
      {required VoidCallback onDelete, VoidCallback? onTap}
      ) {
    final String title = data['examName'] ?? '제목 없음';
    final String date = data['examDate'] ?? '';
    // 💡 필수 수정: 시험 장소 키(examLocation)를 사용하여 데이터 추출
    final String location = data['examLocation'] ?? '';

    // 💡 날짜와 장소 정보가 있을 경우 조합하여 표시할 문자열 생성
    String displayInfo = '';

    if (date.isNotEmpty) {
      displayInfo += '일시: $date';
    }

    if (location.isNotEmpty) {
      if (date.isNotEmpty) {
        // 날짜가 있으면 괄호 안에 장소 추가
        displayInfo += ' (장소: $location)';
      } else {
        // 날짜가 없으면 "장소: [장소명]"만 표시
        displayInfo += '장소: $location';
      }
    }


    // List<Map<String, String>>으로 타입 캐스팅
    final List<Map<String, String>> files = (data['materials'] as List?)
        ?.map((item) => Map<String, String>.from(item))
        .toList() ?? [];
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
        onTap: onTap ?? () {
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
                      // 💡 수정: 날짜와 장소를 조합한 문자열을 표시
                      if (displayInfo.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            displayInfo, // 조합된 정보 표시
                            style: TextStyle(
                              color: color.shade600,
                              fontSize: 13,
                            ),
                          ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                          child: Icon(Icons.attachment, color: color.shade500, size: 20),
                        ),
                      ),
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onDelete, // 💡 삭제 버튼
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 24), // 쓰레기통 아이콘
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
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("파일 경로를 찾을 수 없습니다.")));
      return;
    }

    final result = await OpenFilex.open(filePath);

    Navigator.pop(context);

    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("파일 열기 실패: ${result.message}")));
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