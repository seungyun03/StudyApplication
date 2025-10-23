//시험

import 'package:flutter/material.dart';
// 💡 추가: 파일 선택 및 열기를 위한 패키지
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart'; // 💡 intl 패키지 추가

class ExamAddPage extends StatefulWidget {
  // 💡 수정: 초기 데이터를 받는 생성자 추가 (수정 모드를 위해)
  final Map<String, dynamic>? initialData;
  const ExamAddPage({super.key, this.initialData});

  @override
  State<ExamAddPage> createState() => _ExamAddPageState();
}

class _ExamAddPageState extends State<ExamAddPage> {
  late final TextEditingController _nameController;
  // ❌ 삭제: late final TextEditingController _dateController;
  // late final TextEditingController _durationController; // ❌ 삭제
  late final TextEditingController _locationController;
  late final TextEditingController _chaptersController;
  late final TextEditingController _notesController;

  String examName = "";
  // 💡 변경: String examDate 대신 DateTime? 사용
  DateTime? _selectedExamDate;
  // String examDuration = ""; // ❌ 삭제
  String examLocation = "";
  String chapters = "";
  String notes = "";
  // 💡 수정: materials는 files와 같이 Map<String, String> 리스트로 처리
  var materials = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    // 💡 수정 3: initialData가 있으면 해당 값으로 상태 초기화
    if (widget.initialData != null) {
      examName = widget.initialData!['examName'] ?? "";
      // 💡 수정: examDate 문자열을 DateTime으로 파싱
      final String initialExamDateStr = widget.initialData!['examDate'] ?? '';
      if (initialExamDateStr.isNotEmpty) {
        try {
          // 'yyyy-MM-dd HH:mm' 형식을 파싱하기 위해 공백을 'T'로 대체
          _selectedExamDate = DateTime.parse(initialExamDateStr.replaceAll(' ', 'T'));
        } catch (_) {
          _selectedExamDate = null;
        }
      }
      // examDuration = widget.initialData!['examDuration'] ?? ""; // ❌ 삭제
      examLocation = widget.initialData!['examLocation'] ?? "";
      chapters = widget.initialData!['chapters'] ?? "";
      notes = widget.initialData!['notes'] ?? "";
      // List<Map<String, String>>으로 타입 캐스팅
      final dynamic initialMaterials = widget.initialData!['materials'];
      if (initialMaterials is List) {
        materials = initialMaterials
            .map((item) => Map<String, String>.from(item))
            .toList();
      }
    }

    // 💡 수정 2: _dateController 초기화 및 리스너 제거
    _nameController = TextEditingController(text: examName)..addListener(() => examName = _nameController.text);
    // ❌ _dateController 제거
    // _durationController = TextEditingController(text: examDuration)..addListener(() => examDuration = _durationController.text); // ❌ 삭제
    _locationController = TextEditingController(text: examLocation)..addListener(() => examLocation = _locationController.text);
    _chaptersController = TextEditingController(text: chapters)..addListener(() => chapters = _chaptersController.text);
    _notesController = TextEditingController(text: notes)..addListener(() => notes = _notesController.text);
  }

  @override
  void dispose() {
    _nameController.dispose();
    // ❌ _dateController.dispose();
    // _durationController.dispose(); // ❌ 삭제
    _locationController.dispose();
    _chaptersController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // 📅 시각 선택 함수 (AssignmentAddPage.dart와 동일하게 변경)
  // -------------------------------------------------------------------

  // 💡 _selectDateTime 이름을 _selectExamDate로 변경
  void _selectExamDate() async {
    final DateTime now = DateTime.now();
    // 1. 날짜 선택
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedExamDate ?? now, // 현재 선택된 날짜 또는 현재 날짜
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      locale: const Locale('ko', 'KR'),
      helpText: '시험 날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple.shade400, // 시험 테마 색상으로 변경
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return; // User canceled date selection

    // 2. 날짜가 선택되면, 기존 시간 또는 기본 시간(09:00)으로 초기 설정
    // 시험은 보통 아침에 있으므로 09:00를 기본 시간으로 설정
    final TimeOfDay initialTime = _selectedExamDate != null
        ? TimeOfDay.fromDateTime(_selectedExamDate!)
        : const TimeOfDay(hour: 9, minute: 0);


    setState(() {
      _selectedExamDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        initialTime.hour,
        initialTime.minute,
      );
    });

    // 3. 시각 선택기로 자동 이동
    await _selectExamTime();
  }

  // 🕒 시각 선택 함수 (AssignmentAddPage.dart와 동일하게 추가)
  Future<void> _selectExamTime() async {
    // 날짜가 먼저 선택되어 있어야 함
    if (_selectedExamDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      // 현재 _selectedExamDate에 설정된 시간을 초기값으로 사용
      initialTime: TimeOfDay.fromDateTime(_selectedExamDate!),
      helpText: '시험 시각 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.purple.shade400, // 시험 테마 색상으로 변경
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        // 기존 날짜에 새로운 시간 설정
        _selectedExamDate = DateTime(
          _selectedExamDate!.year,
          _selectedExamDate!.month,
          _selectedExamDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // -------------------------------------------------------------------
  // 📎 파일 첨부 함수
  // -------------------------------------------------------------------

  void _pickMaterials() async {
    // 💡 파일 선택 기능 (FilePicker 패키지 사용 가정)
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // 다중 파일 선택 허용
    );

    if (result != null) {
      setState(() {
        for (var platformFile in result.files) {
          if (platformFile.path != null) {
            materials.add({
              "name": platformFile.name,
              "path": platformFile.path!,
              "date": DateTime.now().toIso8601String().split('T')[0], // 현재 날짜 저장
            });
          }
        }
      });
    }
  }

  void _deleteMaterial(int index) {
    setState(() {
      materials.removeAt(index);
    });
  }

  // -------------------------------------------------------------------
  // 💾 저장 및 닫기
  // -------------------------------------------------------------------

  void _saveAndClose() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("시험명을 입력하세요.")));
      return;
    }

    // 💡 수정: _selectedExamDate를 'yyyy-MM-dd HH:mm' 형식으로 포맷
    String examDateString = '';
    if (_selectedExamDate != null) {
      examDateString = DateFormat('yyyy-MM-dd HH:mm').format(_selectedExamDate!);
    }

    // 💡 수정: Map 형태로 모든 데이터를 반환합니다.
    final resultData = {
      'examName': _nameController.text,
      'examDate': examDateString, // 💡 시각까지 포함된 문자열
      // 'examDuration': _durationController.text, // ❌ 삭제
      'examLocation': _locationController.text,
      'chapters': _chaptersController.text,
      'notes': _notesController.text,
      'materials': materials,
    };
    Navigator.pop(context, resultData);
  }

  @override
  Widget build(BuildContext context) {
    // 💡 추가: 표시용으로 포맷된 날짜/시각 문자열
    final String displayExamDate = _selectedExamDate != null
        ? DateFormat('yyyy년 MM월 dd일 HH:mm').format(_selectedExamDate!)
        : "날짜와 시각을 선택하세요"; // AssignmentAddPage와 유사하게 변경

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(widget.initialData == null ? '시험 추가' : '시험 수정'),
        backgroundColor: const Color(0xFFF9FAFB),
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveAndClose,
            child: const Text(
              '저장',
              style: TextStyle(
                color: Color(0xFF9810FA),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("시험명", _nameController),
            const SizedBox(height: 24),

            // 💡 수정: 날짜 및 시각 선택 필드 (AssignmentAddPage와 동일한 스타일로 변경)
            _buildDateSelectionField("시험 일시 (날짜 및 시간)", _selectExamDate, displayExamDate),
            const SizedBox(height: 24),

            _buildTextField("시험 장소", _locationController),
            const SizedBox(height: 24),

            _buildTextField("시험 범위", _chaptersController,
                maxLines: 3),
            const SizedBox(height: 24),

            _buildTextField("참고 사항", _notesController,
                maxLines: 5),
            const SizedBox(height: 24),

            // ---------------------------------------------------
            // 시험 자료 첨부 섹션
            // ---------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("시험 자료 첨부",
                    style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                TextButton(
                  onPressed: _pickMaterials,
                  child: const Text('파일 추가',
                      style: TextStyle(color: Colors.purple)),
                )
              ],
            ),
            const SizedBox(height: 8),

            materials.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text("첨부된 자료가 없습니다.",
                  style: TextStyle(color: Colors.grey)),
            )
                : Column(
              children: List.generate(
                  materials.length,
                      (index) => _buildMaterialItem(
                      index, materials[index])),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // 🏗️ 빌더 위젯
  // -------------------------------------------------------------------

  // 일반 텍스트 필드 빌더 (재사용성을 위해 수정했습니다.)
  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, String? hintText}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText ?? "$label을 입력하세요",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    ]);
  }

  // 💡 수정: 날짜/시각 선택 필드 빌더 (AssignmentAddPage.dart와 동일)
  Widget _buildDateSelectionField(
      String label,
      VoidCallback onTap,
      String value, // 포맷된 날짜/시각 문자열
      ) {
    // 💡 수정: 플레이스홀더 텍스트 통일
    bool isPlaceholder = value == "날짜와 시각을 선택하세요";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap, // 💡 날짜 및 시각 선택 함수 호출
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isPlaceholder ? Colors.grey.shade600 : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.purple), // 시험 테마 색상 유지
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 파일 목록 항목 빌더
  Widget _buildMaterialItem(int index, Map<String, String> material) {
    // 파일 열기 로직 추가
    void _openFile() async {
      final filePath = material["path"];
      if (filePath == null || filePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("파일 경로를 찾을 수 없습니다.")));
        return;
      }

      // ⚠️ 실제 파일 열기 기능 활성화 (open_filex 패키지 사용):
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("파일 열기 실패: ${result.message}")));
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: InkWell( // 탭 이벤트를 처리하기 위해 InkWell로 감쌉니다.
        onTap: _openFile, // 💡 탭 시 파일 열기 함수 호출
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("${material["name"]}\n업로드: ${material["date"]}",
                    style: const TextStyle(color: Colors.purple, fontSize: 13)),
              ),
              IconButton(
                onPressed: () => _deleteMaterial(index),
                icon: Icon(Icons.close, color: Colors.red.shade400, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}