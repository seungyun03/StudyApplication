// 📄 assignment_add_page.dart
// =====================================================
// 📗 과제 추가 페이지
// TimeTableButton에서 '과제' 추가 버튼 클릭 시 이동
// React 디자인 그대로 Flutter로 포팅
// =====================================================

import 'package:flutter/material.dart';

class AssignmentAddPage extends StatefulWidget {
  const AssignmentAddPage({super.key});

  @override
  State<AssignmentAddPage> createState() => _AssignmentAddPageState();
}

class _AssignmentAddPageState extends State<AssignmentAddPage> {
  String title = "";
  String memo = "";
  String dueDate = "";
  bool submitted = false;
  final List<Map<String, String>> files = [];

  void _addFile() {
    setState(() {
      files.add({
        "name": "새 과제 파일 ${files.length + 1}.pdf",
        "date":
            "${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')}"
      });
    });
  }

  void _deleteFile(int index) {
    setState(() => files.removeAt(index));
  }

  void _save() {
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
          _buildTextField("과제 제목", title, (v) => setState(() => title = v)),
          const SizedBox(height: 20),
          _buildTextField("과제 메모", memo, (v) => setState(() => memo = v),
              maxLines: 3),
          const SizedBox(height: 20),
          _buildTextField("제출 기한 (yyyy-mm-dd)", dueDate,
              (v) => setState(() => dueDate = v)),
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
          ...files
              .asMap()
              .entries
              .map((e) => _buildFileItem(e.key, e.value))
              .toList(),
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

  Widget _buildTextField(
      String label, String value, ValueChanged<String> onChanged,
      {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        onChanged: onChanged,
        controller: TextEditingController(text: value),
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

  Widget _buildFileItem(int index, Map<String, String> file) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${file["name"]}\n업로드: ${file["date"]}",
              style: const TextStyle(color: Colors.green, fontSize: 13)),
          IconButton(
            onPressed: () => _deleteFile(index),
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
