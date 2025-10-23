//과제

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';

class AssignmentAddPage extends StatefulWidget {
  // 💡 수정: 초기 데이터를 받는 생성자 추가
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
  String dueDate = ""; // 'yyyy-mm-dd' 문자열로 저장
  bool submitted = false;
  // List<Map<String, String>>으로 명시적 캐스팅을 위해 final 대신 var 사용
  var files = <Map<String, String>>[]; // 💡 수정: 초기화 시 할당 가능하도록 var로 변경

  @override
  void initState() {
    super.initState();
    // 💡 수정: initialData가 있으면 해당 값으로 상태 초기화
    if (widget.initialData != null) {
      title = widget.initialData!['title'] ?? "";
      memo = widget.initialData!['memo'] ?? "";
      dueDate = widget.initialData!['dueDate'] ?? "";
      submitted = widget.initialData!['submitted'] ?? false;
      // List<Map<String, String>>으로 타입 캐스팅
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
  // 📅 날짜 선택 함수
  // ----------------------------------------------------
  void _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dueDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      locale: const Locale('ko', 'KR'),
      helpText: '제출 기한 선택',
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

    if (picked != null) {
      setState(() {
        dueDate =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
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

  // 💡 수정: 과제 제목과 파일 목록을 Map 형태로 반환
  void _save() {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("과제 제목을 입력하세요.")));
      return;
    }

    final assignmentData = {
      'title': title,
      'memo': memo,
      'dueDate': dueDate, // 💡 저장
      'submitted': submitted, // 💡 저장
      'files': files, // 파일 목록을 포함하여 반환
    };

    // 💡 저장 시 수정된 데이터 Map을 이전 화면으로 반환
    Navigator.pop(context, assignmentData);

    // 💡 오류 수정: Text 위젯을 SnackBar의 content에 넣어 전달해야 합니다.
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade50,
        elevation: 0,
        centerTitle: true,
        // 💡 수정: 제목이 비어있으면 "과제 제목 입력" 또는 "과제 수정" 표시
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
          _buildDateSelectionField("제출 기한", _selectDueDate, dueDate),
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
          // 💡 파일 항목 빌드
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
  // 📅 날짜 선택 필드 위젯 (TextField 대체)
  // ----------------------------------------------------
  Widget _buildDateSelectionField(
      String label,
      VoidCallback onTap,
      String value,
      ) {
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
                  value.isEmpty ? "제출 기한을 선택하세요" : value,
                  style: TextStyle(
                    color: value.isEmpty ? Colors.grey.shade600 : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }
  // ----------------------------------------------------

  // 💡 수정: _buildFileItem에 탭 이벤트를 추가하여 파일을 열도록 합니다.
  Widget _buildFileItem(int index, Map<String, String> file) {
    final filePath = file["path"];

    void _openFile() async {
      if (filePath == null || filePath.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("파일 경로를 찾을 수 없습니다.")));
        return;
      }

      // ⚠️ 실제 파일 열기 기능 활성화:
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
      child: InkWell( // 탭 이벤트를 처리
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