// 📄 TimeTableButton.dart (수정 완료: 과제 파일 처리 로직 추가)
// ===================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart'; // 💡 파일 열기 기능 활성화
import 'LectureAddPage.dart';
import 'AssignmentAddPage.dart';
import 'ExamAddPage.dart';

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
  bool lectureExpanded = true;
  bool assignmentExpanded = true;
  bool examExpanded = true;
  String activeTab = 'home';

  // 💡 강의 목록: Map 리스트 (파일 포함)
  final List<Map<String, dynamic>> lectures = [
    {'title': "1주차 강의노트", 'files': []},
    {
      'title': "함수의 극한과 연속성",
      'files': [
        {'name': "함수.pdf", 'path': "dummy_file_path_1", 'date': "2024.10.22"},
      ]
    },
  ];

  // 💡 수정: 과제 목록을 Map 리스트로 변경하여 파일 정보를 저장
  final List<Map<String, dynamic>> assignments = [
    {'title': "1주차 컴퓨터 구조", 'files': []},
    {
      'title': "연습문제 3-1 ~ 3-5",
      'files': [
        {'name': "과제_지문.hwp", 'path': "dummy_file_path_2", 'date': "2024.11.01"},
      ]
    },
  ];
  final List<String> exams = ["중간고사", "단원별 퀴즈"];


  void _openLectureAddPage() async {
    final newLectureData = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LectureAddPage()));

    // Map 데이터인지 확인 후 리스트에 추가
    if (newLectureData != null && newLectureData is Map<String, dynamic> && newLectureData['title'] != null) {
      setState(() {
        lectures.add(newLectureData);
      });
    }
  }

  // 💡 수정: AssignmentAddPage에서 Map 데이터를 받도록 변경
  void _openAssignmentAddPage() async {
    final newAssignmentData = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AssignmentAddPage()));

    // Map 데이터인지 확인 후 리스트에 추가
    if (newAssignmentData != null && newAssignmentData is Map<String, dynamic> && newAssignmentData['title'] != null) {
      setState(() {
        assignments.add(newAssignmentData);
      });
    }
  }

  void _openExamAddPage() async {
    final newExamName = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ExamAddPage()));

    if (newExamName != null && newExamName is String) {
      setState(() {
        exams.add(newExamName);
      });
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

                  // 📘 강의자료 섹션
                  _buildSection(
                    title: "강의자료",
                    expanded: lectureExpanded,
                    onToggle: () =>
                        setState(() => lectureExpanded = !lectureExpanded),
                    onAdd: _openLectureAddPage,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFEEF6FF)],
                    ),
                    accent: const Color(0xFF155DFC),
                    children: lectures
                        .map((data) => _buildItemWithFile(data, Colors.blue))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // 📗 과제 섹션
                  _buildSection(
                    title: "과제",
                    expanded: assignmentExpanded,
                    onToggle: () => setState(
                            () => assignmentExpanded = !assignmentExpanded),
                    onAdd: _openAssignmentAddPage, // 💡 Map을 받도록 변경된 함수
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEFFEF6), Color(0xFFECFDF5)],
                    ),
                    accent: const Color(0xFF00A63E),
                    // 💡 수정: 과제 리스트 항목을 파일 처리 가능한 위젯으로 빌드
                    children: assignments
                        .map((data) => _buildItemWithFile(data, Colors.green))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // 📙 시험일정 섹션
                  _buildSection(
                    title: "시험일정",
                    expanded: examExpanded,
                    onToggle: () =>
                        setState(() => examExpanded = !examExpanded),
                    onAdd: _openExamAddPage,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFAF5FF), Color(0xFFF5F3FF)],
                    ),
                    accent: const Color(0xFF9810FA),
                    children:
                    exams.map((e) => _buildSimpleItem(e, Colors.purple)).toList(),
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

  // ... (_buildSection은 동일)
  Widget _buildSection({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required VoidCallback onAdd,
    required LinearGradient gradient,
    required Color accent,
    required List<Widget> children,
  }) {
    // ... (_buildSection 코드 유지)
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


  // 💡 강의/과제 리스트 아이템 카드 (파일 처리 로직 포함)
  Widget _buildItemWithFile(Map<String, dynamic> data, MaterialColor color) {
    final String title = data['title'] ?? '제목 없음';
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
        // 항목 전체 탭 시 동작
        onTap: () {
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
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color.shade700,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasFiles) // 파일이 있을 경우 아이콘 표시
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: _showFilesModal, // 💡 클립 버튼 탭 시 모달 표시
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 2.0, bottom: 2.0),
                      child: Icon(Icons.attachment, color: color.shade500, size: 20),
                    ),
                  ),
                Icon(Icons.chevron_right, color: color.shade700),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // 📦 단순 문자열 리스트 아이템 카드 (시험 일정용)
  Widget _buildSimpleItem(String text, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: () {
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
                Text(
                  text,
                  style: TextStyle(
                    color: color.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                Icon(Icons.chevron_right, color: color.shade700),
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

// 💡 새 위젯: 파일 목록을 표시하고 파일을 열 수 있는 모달 (BottomSheet)
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

  // 💡 모달 내에서 파일을 열기 위한 함수
  void _openFile(BuildContext context, Map<String, String> file) async {
    final filePath = file["path"];

    if (filePath == null || filePath.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("파일 경로를 찾을 수 없습니다.")));
      return;
    }

    // ⚠️ 파일 열기 로직 (활성화)
    final result = await OpenFilex.open(filePath);

    // 파일 열기 후 모달 닫기
    Navigator.pop(context);

    if (result.type != ResultType.done) {
      // 파일 열기 실패 시 스낵바 표시
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
                  onTap: () => _openFile(context, file), // 💡 파일 열기 함수 호출
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