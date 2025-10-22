// 📄 AssignmentAddPage.dart (수정 완료: 파일 선택 및 열기 기능 추가)
// =====================================================
// 📗 과제 추가 페이지
// =====================================================

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // 💡 파일 선택 기능 추가
import 'package:open_filex/open_filex.dart'; // 💡 파일 열기 기능 추가

class AssignmentAddPage extends StatefulWidget {
  const AssignmentAddPage({super.key});

  @override
  State<AssignmentAddPage> createState() => _AssignmentAddPageState();
}

class _AssignmentAddPageState extends State<AssignmentAddPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _memoController;
  late final TextEditingController _dueDateController;

  String title = "";
  String memo = "";
  String dueDate = "";
  bool submitted = false;
  // 💡 Map<String, String> 리스트로 files 구조 유지
  final List<Map<String, String>> files = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: title);
    _memoController = TextEditingController(text: memo);
    _dueDateController = TextEditingController(text: dueDate);

    _titleController.addListener(_updateTitle);
    _memoController.addListener(_updateMemo);
    _dueDateController.addListener(_updateDueDate);
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

  void _updateDueDate() {
    if (dueDate != _dueDateController.text) {
      setState(() => dueDate = _dueDateController.text);
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateTitle);
    _memoController.removeListener(_updateMemo);
    _dueDateController.removeListener(_updateDueDate);
    _titleController.dispose();
    _memoController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  // 💡 수정: file_picker를 사용하여 실제 파일 선택 기능 구현
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
            "path": platformFile.path ?? "", // 파일 경로 저장
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
      'dueDate': dueDate,
      'submitted': submitted,
      'files': files, // 파일 목록을 포함하여 반환
    };

    Navigator.pop(context, assignmentData);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("과제 정보가 저장되었습니다!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.green.shade50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title.isEmpty ? "과제 제목 입력" : title,
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
          _buildTextField("제출 기한 (yyyy-mm-dd)", _dueDateController),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("파일 목록",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ElevatedButton.icon(
                onPressed: _addFile, // 💡 실제 파일 선택 함수 연결
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
        onTap: _openFile, // 💡 탭 시 파일 열기 함수 호출
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