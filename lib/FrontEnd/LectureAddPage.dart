// 📄 LectureAddPage.dart (수정 완료: 수정 모드(initialData) 지원)
// =====================================================

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart'; // 💡 파일 열기 기능 활성화 (pubspec.yaml에 추가 필수)

class LectureAddPage extends StatefulWidget {
  // 💡 수정: 초기 데이터를 받는 생성자 추가
  final Map<String, dynamic>? initialData;
  const LectureAddPage({super.key, this.initialData});

  @override
  State<LectureAddPage> createState() => _LectureAddPageState();
}

class _LectureAddPageState extends State<LectureAddPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _memoController;

  String title = "";
  String memo = "";
  // List<Map<String, String>>으로 명시적 캐스팅을 위해 final 대신 var 사용
  var files = <Map<String, String>>[]; // 💡 수정: 초기화 시 할당 가능하도록 var로 변경

  @override
  void initState() {
    super.initState();
    // 💡 수정: initialData가 있으면 해당 값으로 상태 초기화
    if (widget.initialData != null) {
      title = widget.initialData!['title'] ?? "";
      memo = widget.initialData!['memo'] ?? "";
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

  void _save() {
    if (title.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("강의 자료 제목을 입력하세요.")));
      return;
    }

    final lectureData = {
      'title': title,
      'memo': memo, // 💡 추가: 메모 저장
      'files': files,
    };

    Navigator.pop(context, lectureData);

    // 💡 수정: 스낵바 메시지
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(
        widget.initialData != null ? "강의 자료가 수정되었습니다!" : "강의 자료가 저장되었습니다!"
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.indigo.shade50,
        elevation: 0,
        centerTitle: true,
        // 💡 수정: 앱 바 제목
        title: Text(
          // 💡 수정: 수정 모드에 따른 제목 표시
          title.isEmpty ? (widget.initialData != null ? "강의 자료 수정" : "강의 자료 추가") : title,
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
          // 💡 수정: 텍스트 필드 라벨
          _buildTextField("강의 자료 제목", _titleController),
          const SizedBox(height: 20),
          _buildTextField("메모", _memoController, maxLines: 3),
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

  // 💡 파일 항목 위젯: 항목을 탭하면 _openFile을 호출하여 파일을 엽니다.
  Widget _buildFileItem(int index, Map<String, String> file) {
    final filePath = file["path"];

    void _openFile() async {
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
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.shade100),
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
                child: Text("${file["name"]}\n업로드: ${file["date"]}",
                    style: const TextStyle(color: Colors.indigo, fontSize: 13)),
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