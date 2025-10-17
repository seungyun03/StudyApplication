// 📄 exam_add_page.dart
// =====================================================
// 📙 시험 일정 추가 페이지
// TimeTableButton에서 '시험일정' 추가 버튼 클릭 시 이동
// React 버전 UI 유지 + Flutter 포팅
// =====================================================

import 'package:flutter/material.dart';

class ExamAddPage extends StatefulWidget {
  const ExamAddPage({super.key});

  @override
  State<ExamAddPage> createState() => _ExamAddPageState();
}

class _ExamAddPageState extends State<ExamAddPage> {
  String examName = "";
  String examDate = "";
  String examDuration = "";
  String examLocation = "";
  String chapters = "";
  String notes = "";
  final List<Map<String, String>> materials = [];

  void _addMaterial() {
    setState(() {
      materials.add({
        "name": "새 시험자료 ${materials.length + 1}.pdf",
        "date":
            "${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')}"
      });
    });
  }

  void _deleteMaterial(int index) {
    setState(() => materials.removeAt(index));
  }

  void _save() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("시험 정보가 저장되었습니다!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade50,
        elevation: 0,
        centerTitle: true,
        title: Text(
          examName.isEmpty ? "시험명을 입력하세요" : examName,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text("저장",
                style: TextStyle(color: Colors.purple, fontSize: 16)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildTextField("시험명", examName, (v) => setState(() => examName = v)),
          const SizedBox(height: 20),
          _buildTextField("시험 일시 (yyyy-mm-dd)", examDate,
              (v) => setState(() => examDate = v)),
          const SizedBox(height: 20),
          _buildTextField("시험 시간 (예: 60분)", examDuration,
              (v) => setState(() => examDuration = v)),
          const SizedBox(height: 20),
          _buildTextField(
              "시험 장소", examLocation, (v) => setState(() => examLocation = v)),
          const SizedBox(height: 30),
          const Text("시험 범위",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          _buildTextField(
              "출제 범위", chapters, (v) => setState(() => chapters = v),
              maxLines: 2),
          const SizedBox(height: 20),
          _buildTextField("특이사항", notes, (v) => setState(() => notes = v),
              maxLines: 2),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("시험 자료",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ElevatedButton.icon(
                onPressed: _addMaterial,
                icon: const Icon(Icons.add),
                label: const Text("추가"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...materials
              .asMap()
              .entries
              .map((e) => _buildMaterialItem(e.key, e.value))
              .toList(),
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

  Widget _buildMaterialItem(int index, Map<String, String> material) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${material["name"]}\n업로드: ${material["date"]}",
              style: const TextStyle(color: Colors.purple, fontSize: 13)),
          IconButton(
            onPressed: () => _deleteMaterial(index),
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
          )
        ],
      ),
    );
  }
}
