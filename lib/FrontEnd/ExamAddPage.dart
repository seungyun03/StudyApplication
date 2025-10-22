// 📄 ExamAddPage.dart (수정 완료)
// =====================================================
// 📙 시험 일정 추가 페이지
// =====================================================

import 'package:flutter/material.dart';

class ExamAddPage extends StatefulWidget {
  const ExamAddPage({super.key});

  @override
  State<ExamAddPage> createState() => _ExamAddPageState();
}

class _ExamAddPageState extends State<ExamAddPage> {
  // 💡 수정 1: 모든 입력 필드에 대해 TextEditingController를 선언합니다.
  late final TextEditingController _nameController;
  late final TextEditingController _dateController;
  late final TextEditingController _durationController;
  late final TextEditingController _locationController;
  late final TextEditingController _chaptersController;
  late final TextEditingController _notesController;

  String examName = "";
  String examDate = "";
  String examDuration = "";
  String examLocation = "";
  String chapters = "";
  String notes = "";
  final List<Map<String, String>> materials = [];

  @override
  void initState() {
    super.initState();
    // 💡 수정 2: initState에서 컨트롤러를 한 번만 초기화합니다.
    _nameController = TextEditingController(text: examName);
    _dateController = TextEditingController(text: examDate);
    _durationController = TextEditingController(text: examDuration);
    _locationController = TextEditingController(text: examLocation);
    _chaptersController = TextEditingController(text: chapters);
    _notesController = TextEditingController(text: notes);

    // 💡 수정 3: 컨트롤러의 리스너를 추가하여 상태 변수를 업데이트합니다.
    _nameController.addListener(() => setState(() => examName = _nameController.text));
    _dateController.addListener(() => setState(() => examDate = _dateController.text));
    _durationController.addListener(() => setState(() => examDuration = _durationController.text));
    _locationController.addListener(() => setState(() => examLocation = _locationController.text));
    _chaptersController.addListener(() => setState(() => chapters = _chaptersController.text));
    _notesController.addListener(() => setState(() => notes = _notesController.text));
  }

  @override
  void dispose() {
    // 💡 수정 4: 위젯이 사라질 때 컨트롤러를 정리합니다.
    _nameController.dispose();
    _dateController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _chaptersController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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
    // 시험명이 비어있으면 저장하지 않고 사용자에게 메시지 표시
    if (examName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("시험명을 입력하세요.")));
      return;
    }

    // 💡 수정 5: 현재 페이지를 닫고 examName 변수 값을 이전 페이지로 반환
    Navigator.pop(context, examName);

    // 이 스낵바는 페이지가 닫히면서 보이지 않을 수 있습니다.
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
          // 💡 수정 6: 컨트롤러를 전달하도록 변경
          _buildTextField("시험명", _nameController),
          const SizedBox(height: 20),
          _buildTextField("시험 일시 (yyyy-mm-dd)", _dateController),
          const SizedBox(height: 20),
          _buildTextField("시험 시간 (예: 60분)", _durationController),
          const SizedBox(height: 20),
          _buildTextField("시험 장소", _locationController),
          const SizedBox(height: 30),
          const Text("시험 범위",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 10),
          _buildTextField("출제 범위", _chaptersController, maxLines: 2),
          const SizedBox(height: 20),
          _buildTextField("특이사항", _notesController, maxLines: 2),
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
              .map((e) => _buildMaterialItem(e.key, e.value)),
        ]),
      ),
    );
  }

  // 💡 수정 7: _buildTextField 메소드의 시그니처와 구현을 변경했습니다.
  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      const SizedBox(height: 8),
      TextField(
        controller: controller, // 💡 컨트롤러를 사용합니다.
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