// 📄 TimeTableSelectionPage.dart (수정된 전체 코드 - 활성화된 시간표 수정 허용)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 🚨 [추가] AddNewTimeTablePage 및 TimetableProvider import
import 'AddNewTimeTablePage.dart';
import '../Providers/TimetableProvider.dart'; // TimeTable 모델 포함

// ==================== 시간표 선택 페이지 ====================
class TimeTableSelectionPage extends StatelessWidget {
  const TimeTableSelectionPage({super.key});

  // 🚨 [추가] AddNewTimeTablePage와 동일한 색상 팔레트 정의
  final List<Color> _fullColorPalette = const [
    // Row 1: Light Reds/Pinks
    Color(0xFFFEE2E2), // Very Light Red
    Color(0xFFFCE7F3), // Light Pink
    Color(0xFFFBCFE8), // Soft Pink
    Color(0xFFF3E8FF), // Light Lavender

    // Row 2: Light Purples/Blues
    Color(0xFFEDE9FE), // Soft Lavender
    Color(0xFFE0E7FF), // Periwinkle
    Color(0xFFDBEAFE), // Light Blue
    Color(0xFFEEF2FF), // Very Light Blue

    // Row 3: Light Greens/Yellows
    Color(0xFFD1FAE5), // Light Mint
    Color(0xFFCCFBF1), // Light Teal
    Color(0xFFF0FDF4), // Very Light Green
    Color(0xFFFEFCE8), // Light Yellow

    // Row 4: Earth Tones/Neutrals
    Color(0xFFFFF7ED), // Light Apricot
    Color(0xFFFFEDD5), // Soft Peach
    Color(0xFFF5DEB3), // Wheat
    Color(0xFFF5F5DC), // Beige

    // Row 5: Soft Grays/Deeper Pastels
    Color(0xFFE5E7EB), // Light Gray
    Color(0xFFD1D5DB), // Mid-Light Gray
    Color(0xFFB0E0E6), // Powder Blue
    Color(0xFFDDA0DD), // Thistle (Soft Medium Purple)
  ];

  @override
  Widget build(BuildContext context) {
    // 🚨 [수정] Provider를 통해 TimeTableProvider의 상태 변화를 감지하고 UI를 다시 그립니다.
    return Consumer<TimetableProvider>(
      builder: (context, provider, child) {
        // Provider에서 현재 저장된 시간표 목록과 활성화된 시간표 ID를 가져옵니다.
        final List<TimeTable> savedTimetables = provider.allTimeTables;
        final String? currentTimetableId = provider.currentTimetableId;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: SafeArea(
            child: Column(
              children: [
                // 1. 상단 헤더 (시간표 제목 및 닫기 버튼)
                _SelectionHeader(
                  onClose: () => Navigator.pop(context),
                ),

                // 2. 시간표 목록 (스크롤 가능)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (savedTimetables.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '저장된 시간표 (${savedTimetables.length}개)',
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        // 💡 저장된 시간표 목록 위젯
                        ...savedTimetables.map((timetable) {
                          final bool isSelected =
                              timetable.id == currentTimetableId;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _TimeTableCard(
                              id: timetable.id,
                              name: timetable.name,
                              backgroundColor: timetable.color,
                              isSelected: isSelected,
                              // 🚨 [구현] 선택 로직: Provider의 selectTimeTable 함수 호출
                              onSelect: () async {
                                if (!isSelected) {
                                  // 선택된 시간표를 활성화하고 데이터 로드
                                  await provider.selectTimeTable(timetable.id);
                                }
                                // 선택 후 페이지 닫기
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              },
                              // 🚨 [추가] 수정 로직: 수정 Bottom Sheet 표시
                              onEdit: () async {
                                final result = await _showEditTimeTableBottomSheet(
                                  context,
                                  timetable,
                                  _fullColorPalette, // 팔레트 전달
                                );
                                if (result != null) {
                                  await provider.updateTimeTableInfo(
                                    timeTableId: timetable.id,
                                    newName: result['name'] as String,
                                    newColor: result['color'] as Color,
                                  );
                                }
                              },
                              // 🚨 [추가] 삭제 로직: 경고 다이얼로그 표시 및 삭제
                              onDelete: () async {
                                final bool confirm = await _showDeleteConfirmationDialog(
                                  context,
                                  timetable.name,
                                );
                                if (confirm) {
                                  await provider.deleteTimeTable(timetable.id);
                                }
                              },
                            ),
                          );
                        }).toList(),

                        // 💡 시간표가 없을 경우 안내 텍스트
                        if (savedTimetables.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 50.0),
                            child: Text(
                              "저장된 시간표가 없습니다.\n아래 '새로운 시간표 추가' 버튼을 눌러주세요.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 16,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // 3. 새로운 시간표 추가 버튼
                _AddNewTimeTableButton(
                  onTap: () {
                    // AddNewTimeTablePage로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddNewTimeTablePage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10), // 하단 여백
              ],
            ),
          ),
        );
      },
    );
  }

  // 🚨 [수정] 시간표 수정 Bottom Sheet 함수 (로직을 _EditTimeTableForm으로 위임)
  Future<Map<String, dynamic>?> _showEditTimeTableBottomSheet(
      BuildContext context, TimeTable currentTable, List<Color> palette) async {

    final result = await showModalBottomSheet<Map<String, dynamic>?>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // 🚨 [수정] 로직을 _EditTimeTableForm으로 위임하여 컨트롤러 라이프사이클 관리
      builder: (BuildContext bottomSheetContext) {
        return _EditTimeTableForm(
          currentTable: currentTable,
          fullColorPalette: palette,
        );
      },
    );

    return result;
  }

  // 🚨 [추가] 삭제 확인 다이얼로그 함수 (기존 로직 유지)
  Future<bool> _showDeleteConfirmationDialog(BuildContext context, String tableName) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('시간표 삭제 확인'),
          content: Text('**$tableName** 시간표와 모든 과목, 시간표 정보가 영구적으로 삭제됩니다. 계속하시겠습니까?',
            style: const TextStyle(height: 1.5),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // 취소
              child: const Text('취소', style: TextStyle(color: Color(0xFF6B7280))),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // 확인 및 삭제 진행
              child: const Text('삭제', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    ) ?? false; // null 방지
  }
}

// 🚨 [추가] 오류를 해결하기 위한 Stateful Widget 분리
class _EditTimeTableForm extends StatefulWidget {
  final TimeTable currentTable;
  final List<Color> fullColorPalette;

  const _EditTimeTableForm({
    required this.currentTable,
    required this.fullColorPalette,
  });

  @override
  State<_EditTimeTableForm> createState() => _EditTimeTableFormState();
}

class _EditTimeTableFormState extends State<_EditTimeTableForm> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  late String _currentName;

  @override
  void initState() {
    super.initState();
    // 💡 [수정] initState에서 Controller 생성 및 초기화
    _nameController = TextEditingController(text: widget.currentTable.name);
    _selectedColor = widget.currentTable.color;
    _currentName = widget.currentTable.name;

    // 💡 [수정] 리스너는 여기서만 추가하고, dispose에서 안전하게 제거됩니다.
    _nameController.addListener(_updateCurrentName);
  }

  @override
  void dispose() {
    // 💡 [수정] dispose에서 Controller 및 리스너 안전하게 해제
    _nameController.removeListener(_updateCurrentName);
    _nameController.dispose();
    super.dispose();
  }

  // 텍스트 필드 값이 변경될 때 상태를 업데이트하는 함수
  void _updateCurrentName() {
    // 텍스트 필드가 변경될 때마다 미리보기를 갱신하기 위해 setState 호출
    setState(() {
      _currentName = _nameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // 키보드가 올라올 때 Bottom Sheet가 함께 올라가도록 패딩 추가
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 모달 제목
            const Text(
              '시간표 정보 수정',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 24),

            // 1. 이름 입력 필드
            const _FormLabel(text: '시간표 이름'),
            _NameInputField(
              controller: _nameController,
              // onChanged는 _EditTimeTableFormState에서 리스너로 처리
            ),
            const SizedBox(height: 24),

            // 2. 색상 선택
            const _FormLabel(text: '시간표 컬러'),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // 스크롤 방지
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: widget.fullColorPalette.length,
              itemBuilder: (context, index) {
                final color = widget.fullColorPalette[index];
                final bool isSelected = color.value == _selectedColor.value;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                        width: isSelected ? 4 : 1,
                      ),
                      boxShadow: isSelected
                          ? [const BoxShadow(color: Color(0x663B82F6), blurRadius: 6)]
                          : null,
                    ),
                    child: isSelected
                        ? Center(
                      child: Icon(
                        Icons.check,
                        // 배경색에 따라 아이콘 색상 자동 조정
                        color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                        size: 20,
                      ),
                    )
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 3. 미리보기
            const _FormLabel(text: '미리보기'),
            _PreviewTimeTable(
              name: _currentName, // 💡 State로 관리되는 현재 이름 사용
              backgroundColor: _selectedColor,
            ),
            const SizedBox(height: 24),

            // 4. 액션 버튼
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null), // 취소
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('취소',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF6B7280))),
                  ),
                ),
                const SizedBox(width: 16),
                // 수정 완료 버튼
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final trimmedName = _nameController.text.trim();
                      if (trimmedName.isEmpty) {
                        // 유효성 검사
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("시간표 이름을 입력해주세요."),
                              duration: Duration(seconds: 1)),
                        );
                        return;
                      }
                      // 결과 반환
                      Navigator.of(context).pop({
                        'name': trimmedName,
                        'color': _selectedColor,
                      });
                    }, // 확인 및 수정 진행
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: const Color(0xFF9333EA), // 보라색 계열
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('수정 완료',
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== 상단 헤더 위젯 (기존 로직 유지) ====================
class _SelectionHeader extends StatelessWidget {
  final VoidCallback onClose;

  const _SelectionHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "시간표 선택", // 제목
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Color(0xFF1F2937),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF9CA3AF), size: 28),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

// 🚨 [추가] 폼 레이블 위젯 (AddNewTimeTablePage에서 가져옴)
class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF1F2937),
        ),
      ),
    );
  }
}

// 🚨 [추가] 시간표 이름 입력 필드 위젯 (onChanged 콜백 제거, 컨트롤러만 받도록 수정)
class _NameInputField extends StatelessWidget {
  final TextEditingController controller;

  const _NameInputField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      // onChanged는 _EditTimeTableFormState에서 리스너로 처리
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // 테두리 제거
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300), // 연한 테두리 유지
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2), // 포커스 시 파란색 테두리
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: Color(0xFF1F2937),
      ),
    );
  }
}

// 🚨 [추가] 미리보기 시간표 위젯 (AddNewTimeTablePage에서 가져옴)
class _PreviewTimeTable extends StatelessWidget {
  final String name;
  final Color backgroundColor;

  const _PreviewTimeTable({required this.name, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    // 💡 미리보기는 _TimeTableCard와 유사한 디자인으로 구성
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor, // 선택된 배경색 적용
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        name.isNotEmpty ? name : '시간표 이름 미리보기',
        style: TextStyle(
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          fontSize: 16,
          // 💡 배경색에 따라 텍스트 색상을 자동으로 조정하여 가독성 확보
          color: backgroundColor.computeLuminance() > 0.5
              ? const Color(0xFF1F2937) // 밝은 배경 -> 어두운 글자
              : Colors.white, // 어두운 배경 -> 밝은 글자
        ),
      ),
    );
  }
}


// ==================== 시간표 항목 카드 위젯 (수정 로직 변경) ====================
class _TimeTableCard extends StatelessWidget {
  final String id;
  final String name;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onSelect;
  // 🚨 [추가] 수정 콜백 함수
  final VoidCallback onEdit;
  // 🚨 [추가] 삭제 콜백 함수
  final VoidCallback onDelete;

  const _TimeTableCard({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.isSelected,
    required this.onSelect,
    // 🚨 [추가]
    required this.onEdit,
    // 🚨 [추가]
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 배경색에 따라 텍스트 색상을 자동으로 조정
    final Color textColor = backgroundColor.computeLuminance() > 0.5
        ? const Color(0xFF1F2937) // 밝은 배경 -> 어두운 글자
        : Colors.white; // 어두운 배경 -> 밝은 글자

    final Color primaryColor = const Color(0xFF9333EA); // 보라색

    // 🚨 [수정] 현재 활성화된 시간표의 수정 및 삭제 버튼 상태 정의
    final bool canDelete = !isSelected;
    // 🚨 [수정] 수정은 항상 가능하도록 설정
    // final bool canEdit = true; // 주석 처리하고 아래에서 항상 표시되도록 로직 변경

    return Container(
      // 🚨 [수정] 패딩을 줄여 삭제/수정 버튼 공간 확보
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
      decoration: BoxDecoration(
        color: backgroundColor, // 배경색 동적 설정
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(
          color: primaryColor, // 선택된 경우 보라색 테두리
          width: 2,
        )
            : Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 시간표 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // 현재 활성화 상태 표시
                if (isSelected)
                  Text(
                    '현재 활성화된 시간표',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: primaryColor,
                    ),
                  ),

                // 🚨 [수정] 수정/삭제 버튼을 항상 표시하되, 삭제는 활성화되지 않은 경우에만 활성화
                Row(
                  children: [
                    // 수정 버튼 (항상 활성화)
                    _TimeTableActionButton(
                      text: '수정',
                      color: const Color(0xFF3B82F6),
                      onPressed: onEdit, // 🚨 [연결] 수정 콜백
                    ),
                    const SizedBox(width: 12),
                    // 삭제 버튼 (활성화되지 않은 경우에만 표시/활성화)
                    if (canDelete)
                      _TimeTableActionButton(
                        text: '삭제',
                        color: const Color(0xFFEF4444),
                        onPressed: onDelete, // 🚨 [연결] 삭제 콜백
                      )
                    else
                    // 비활성화된 경우를 위한 빈 공간 (레이아웃 유지)
                      _TimeTableActionButton(
                        text: '삭제',
                        color: Colors.grey.shade400, // 비활성화된 색상
                        onPressed: () {}, // 아무것도 하지 않음
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 선택/활성화 버튼
          if (!isSelected)
            TextButton(
              onPressed: onSelect,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '선택',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF3B82F6), // 선택 버튼 색상
                ),
              ),
            )
          else
          // 선택된 경우 체크 아이콘
            Icon(Icons.check_circle, color: primaryColor, size: 24),
        ],
      ),
    );
  }
}

// 🚨 [추가] 시간표 카드 내의 액션 버튼 (수정/삭제) 위젯
class _TimeTableActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const _TimeTableActionButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24, // 버튼 높이 제한
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerLeft,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: color,
          ),
        ),
      ),
    );
  }
}


// ==================== "새로운 시간표 추가" 버튼 위젯 (기존 로직 유지) ====================
class _AddNewTimeTableButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewTimeTableButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, offset: Offset(0, 2), blurRadius: 4),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "새로운 시간표 추가",
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.add, color: Color(0xFF1F2937), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}