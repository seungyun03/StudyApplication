import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart'; // 💡 날짜/시간 포맷을 위해 추가 (pubspec.yaml에 intl: ^0.19.0 등 추가 필요)

class AssignmentAddPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const AssignmentAddPage({super.key, this.initialData});

  @override
  State<AssignmentAddPage> createState() => _AssignmentAddPageState();
}

class _AssignmentAddPageState extends State<AssignmentAddPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _memoController;

  String title = "";
  String memo = "";
  // 💡 수정: 마감일시를 DateTime 객체로 저장
  DateTime? _selectedDueDate;
  bool submitted = false;
  var files = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();

    // 💡 초기 데이터 로딩
    if (widget.initialData != null) {
      title = widget.initialData!['title'] ?? "";
      memo = widget.initialData!['memo'] ?? "";
      submitted = widget.initialData!['submitted'] ?? false;

      // 💡 수정: 초기 dueDate 문자열을 DateTime으로 파싱 (시간 포함 가능성 고려)
      final String initialDueDateStr = widget.initialData!['dueDate'] ?? '';
      if (initialDueDateStr.isNotEmpty) {
        try {
          // 'yyyy-MM-dd' 또는 'yyyy-MM-dd HH:mm' 형식을 파싱하기 위해 공백을 'T'로 대체
          _selectedDueDate = DateTime.parse(initialDueDateStr.replaceAll(' ', 'T'));
        } catch (_) {
          _selectedDueDate = null;
        }
      }

      final List<dynamic>? initialFiles = widget.initialData!['files'];
      if (initialFiles != null) {
        files = initialFiles.map((item) => Map<String, String>.from(item)).toList();
      }
    }

    _titleController = TextEditingController(text: title);
    _memoController = TextEditingController(text: memo);

    _titleController.addListener(_updateTitle);
    _memoController.addListener(_updateMemo);
  }

  void _updateTitle() {
    if (title != _titleController.text) {
      setState(() => title = _titleController.text);
    }
  }

  void _updateMemo() {
    if (memo != _memoController.text) {
      setState(() => memo = _memoController.text);
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateTitle);
    _memoController.removeListener(_updateMemo);
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------
  // 📅 날짜/시각 선택 함수 (기존 로직 유지)
  // ----------------------------------------------------
  void _selectDueDate() async {
    // 1. 날짜 선택
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      locale: const Locale('ko', 'KR'),
      helpText: '제출 기한 날짜 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade400,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // 2. 날짜가 선택되면, 기존 시간 또는 기본 시간(23:59)으로 초기 설정
      final TimeOfDay initialTime = _selectedDueDate != null
          ? TimeOfDay.fromDateTime(_selectedDueDate!)
          : const TimeOfDay(hour: 23, minute: 59);

      setState(() {
        _selectedDueDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          initialTime.hour,
          initialTime.minute,
        );
      });

      // 3. 시각 선택기로 자동 이동
      await _selectTime();
    }
  }

  // 🕒 시각 선택 함수
  Future<void> _selectTime() async {
    // 날짜가 먼저 선택되어 있어야 함
    if (_selectedDueDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      // 현재 _selectedDueDate에 설정된 시간을 초기값으로 사용
      initialTime: TimeOfDay.fromDateTime(_selectedDueDate!),
      helpText: '제출 기한 시각 선택',
      cancelText: '취소',
      confirmText: '확인',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade400,
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
        _selectedDueDate = DateTime(
          _selectedDueDate!.year,
          _selectedDueDate!.month,
          _selectedDueDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }
  // ----------------------------------------------------


  // 💡 file_picker를 사용하여 실제 파일 선택 기능 구현
  void _addFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        for (var platformFile in result.files) {
          files.add({
            "name": platformFile.name,
            "path": platformFile.path ?? "",
            "date":
            "${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')}"
          });
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${result.files.length}개의 파일을 추가했습니다.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("파일 선택이 취소되었습니다.")));
    }
  }

  void _deleteFile(int index) {
    setState(() => files.removeAt(index));
  }

  // 💡 수정: 시각이 포함된 마감 일시 저장
  void _save() {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("과제 제목을 입력하세요.")));
      return;
    }

    // 💡 수정: _selectedDueDate를 'yyyy-MM-dd HH:mm' 형식으로 포맷
    String dueDateString = '';
    if (_selectedDueDate != null) {
      dueDateString = DateFormat('yyyy-MM-dd HH:mm').format(_selectedDueDate!);
    }

    final assignmentData = {
      'title': title,
      'memo': memo,
      'dueDate': dueDateString, // 💡 시각이 포함된 마감 일시 저장
      'submitted': submitted,
      'files': files,
    };

    Navigator.pop(context, assignmentData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.initialData != null ? "과제 정보가 수정되었습니다!" : "과제 정보가 저장되었습니다!",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 수정: 표시용으로 포맷된 날짜/시각 문자열 (플레이스홀더 통일)
    final String displayDueDate = _selectedDueDate != null
        ? DateFormat('yyyy년 MM월 dd일 HH:mm').format(_selectedDueDate!)
        : "날짜와 시각을 선택하세요";

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title.isEmpty
              ? (widget.initialData != null ? "과제 수정" : "과제 제목 입력")
              : title,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text("저장",
                style: TextStyle(color: Colors.green, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTextField("과제 제목", _titleController),
          const SizedBox(height: 20),
          _buildTextField("과제 메모", _memoController, maxLines: 3),
          const SizedBox(height: 20),
          // 💡 수정: _selectDueDate 함수와 포맷된 displayDueDate 문자열 전달
          _buildDateSelectionField("제출 기한", _selectDueDate, displayDueDate),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("파일 목록",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ElevatedButton.icon(
                onPressed: _addFile,
                icon: const Icon(Icons.add),
                label: const Text("추가"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...files.asMap().entries.map((e) => _buildFileItem(e.key, e.value)),
          const SizedBox(height: 20),
          Row(
            children: [
              Switch(
                  value: submitted,
                  activeColor: Colors.green,
                  onChanged: (v) => setState(() => submitted = v)),
              Text(submitted ? "제출 완료" : "미제출",
                  style: TextStyle(
                      color: submitted
                          ? Colors.green.shade700
                          : Colors.red.shade400,
                      fontWeight: FontWeight.bold))
            ],
          )
        ]),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: "$label을 입력하세요",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    ]);
  }

  // ----------------------------------------------------
  // 📅 날짜/시각 선택 필드 위젯
  // ----------------------------------------------------
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
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
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
                const Icon(Icons.calendar_today, color: Colors.green), // 과제 테마 색상 유지
              ],
            ),
          ),
        ),
      ],
    );
  }
  // ----------------------------------------------------

  Widget _buildFileItem(int index, Map<String, String> file) {
    final filePath = file["path"];

    void _openFile() async {
      if (filePath == null || filePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("파일 경로를 찾을 수 없습니다.")));
        return;
      }

      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("파일 열기 실패: ${result.message}")));
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: InkWell(
        onTap: _openFile,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text("${file["name"]}\n업로드: ${file["date"]}",
                    style: const TextStyle(color: Colors.green, fontSize: 13)),
              ),
              IconButton(
                onPressed: () => _deleteFile(index),
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
              )
            ],
          ),
        ),
      ),
    );
  }
}