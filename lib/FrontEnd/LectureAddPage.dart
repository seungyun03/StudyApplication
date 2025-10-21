// 📄 lecture_add_page.dart
// =====================================================
// 🧾 강의 추가 페이지 (강의 위젯의 '추가' 버튼 클릭 시 열림)
// 디자인은 React 버전 동일, Flutter 맞게 포팅
// =====================================================

import 'package:flutter/material.dart';

class LectureAddPage extends StatefulWidget {
  const LectureAddPage({super.key});

  @override
  State<LectureAddPage> createState() => _LectureAddPageState();
}

class _LectureAddPageState extends State<LectureAddPage> {
  String title = "";
  String memo = "";
  final List<Map<String, String>> files = [];

  void _addFile() {
    setState(() {
      files.add({
        "name": "새 강의자료 ${files.length + 1}.pdf",
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
        .showSnackBar(const SnackBar(content: Text("강의정보가 저장되었습니다!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title.isEmpty ? "제목을 입력하세요" : title,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text("저장",
                style: TextStyle(color: Colors.indigo, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTextField("강의 제목", title, (v) => setState(() => title = v)),
          const SizedBox(height: 20),
          _buildTextField("메모", memo, (v) => setState(() => memo = v),
              maxLines: 3),
          const SizedBox(height: 30),
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
                    backgroundColor: Colors.indigo.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...files.asMap().entries.map((e) => _buildFileItem(e.key, e.value)),
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
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${file["name"]}\n업로드: ${file["date"]}",
              style: const TextStyle(color: Colors.indigo, fontSize: 13)),
          IconButton(
            onPressed: () => _deleteFile(index),
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
