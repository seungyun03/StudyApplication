//시험

import 'package:flutter/material.dart';
// 💡 추가: 파일 선택 및 열기를 위한 패키지
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class ExamAddPage extends StatefulWidget {
  // 💡 수정: 초기 데이터를 받는 생성자 추가 (수정 모드를 위해)
  final Map<String, dynamic>? initialData;
  const ExamAddPage({super.key, this.initialData});

  @override
  State<ExamAddPage> createState() => _ExamAddPageState();
}

class _ExamAddPageState extends State<ExamAddPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _dateController;
  // late final TextEditingController _durationController; // ❌ 삭제
  late final TextEditingController _locationController;
  late final TextEditingController _chaptersController;
  late final TextEditingController _notesController;

  String examName = "";
  // 💡 수정: examDate는 이제 'yyyy-MM-dd HH:mm' 형식의 문자열을 저장합니다.
  String examDate = "";
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
      examDate = widget.initialData!['examDate'] ?? "";
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

    // 💡 수정 2: initState에서 컨트롤러를 한 번만 초기화하고 리스너 추가
    _nameController = TextEditingController(text: examName)..addListener(() => examName = _nameController.text);
    _dateController = TextEditingController(text: examDate)..addListener(() => examDate = _dateController.text);
    // _durationController = TextEditingController(text: examDuration)..addListener(() => examDuration = _durationController.text); // ❌ 삭제
    _locationController = TextEditingController(text: examLocation)..addListener(() => examLocation = _locationController.text);
    _chaptersController = TextEditingController(text: chapters)..addListener(() => chapters = _chaptersController.text);
    _notesController = TextEditingController(text: notes)..addListener(() => notes = _notesController.text);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    // _durationController.dispose(); // ❌ 삭제
    _locationController.dispose();
    _chaptersController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // 📅 시각 선택 함수
  // -------------------------------------------------------------------

  // 💡 시각/분/월/일을 두 자릿수로 포맷팅하는 헬퍼 함수
  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  // 💡 수정: 날짜와 시각을 모두 선택하는 함수
  void _selectDateTime() async {
    // 1. Date Selection
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (pickedDate == null) return; // User canceled date selection

    // 2. Time Selection
    if (mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          // 24시간 형식 사용
          builder: (BuildContext context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
              child: child!,
            );
          }
      );

      if (pickedTime == null) return; // User canceled time selection

      // 3. Combine and Format
      final DateTime finalDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      // Format: 'YYYY-MM-DD HH:MM' (예: 2025-10-23 14:30)
      final String formattedDate =
          "${finalDateTime.year}-${_twoDigits(finalDateTime.month)}-${_twoDigits(finalDateTime.day)} "
          "${_twoDigits(finalDateTime.hour)}:${_twoDigits(finalDateTime.minute)}";

      setState(() {
        examDate = formattedDate;
        _dateController.text = formattedDate;
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
    // 💡 수정: Map 형태로 모든 데이터를 반환합니다.
    final resultData = {
      'examName': _nameController.text,
      'examDate': _dateController.text, // 💡 시각까지 포함된 문자열
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

            // 💡 수정: 날짜 및 시각 선택 필드
            _buildDatePickerField(),
            const SizedBox(height: 24),

            // ❌ 삭제: 시험 시간 필드
            // _buildTextField("시험 시간", _durationController,
            //     hintText: "예: 90분, 10:00~11:30"),
            // const SizedBox(height: 24),

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

  // 💡 수정: 시험 일시 (날짜 및 시간) 선택 필드 빌더
  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("시험 일시 (날짜 및 시간)",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateTime, // 💡 날짜 및 시각 선택 함수 호출
          child: AbsorbPointer(
            child: TextField(
              controller: _dateController,
              decoration: InputDecoration(
                hintText: "날짜와 시각을 선택하세요",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
                suffixIcon: const Icon(Icons.calendar_today, color: Colors.purple),
              ),
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