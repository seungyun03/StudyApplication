// 📄 TimeTableSelectionPage.dart
import 'package:flutter/material.dart';
// 🚨 [추가] AddNewTimeTablePage로 이동하기 위한 import
import 'AddNewTimeTablePage.dart';

// ==================== 시간표 선택 페이지 ====================
class TimeTableSelectionPage extends StatelessWidget {
  const TimeTableSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚨 [수정] 더미 데이터: 저장된 시간표 목록을 빈 리스트로 만듭니다.
    final List<Map<String, dynamic>> savedTimetables = [];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        // 상단/하단 요소가 있으므로 Padding을 제거하고 Column에만 적용합니다.
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
                  // 🚨 [수정] savedTimetables가 비어 있으므로, 이 섹션은 아무것도 표시하지 않습니다.
                  children: [
                    // 💡 저장된 시간표 목록 위젯
                    ...savedTimetables
                        .map((timetable) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _TimeTableCard(
                        name: timetable['name'] as String,
                        backgroundColor: timetable['color'] as Color,
                        // TODO: 실제 시간표 선택 로직 구현
                        onSelect: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${timetable['name']} 선택됨')),
                          );
                        },
                      ),
                    ))
                        .toList(),

                    // 💡 시간표가 없을 경우 사용자에게 추가를 유도하는 텍스트를 추가할 수 있습니다.
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

            // 3. 하단 "새로운 시간표 추가" 버튼
            _AddNewTimeTableButton(
              onTap: () {
                // AddNewTimeTablePage로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddNewTimeTablePage()),
                );
              },
            ),

            const SizedBox(height: 10), // 하단 여백

          ],
        ),
      ),
    );
  }
}

// ==================== 상단 헤더 위젯 ====================
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
            "시간표",
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

// ==================== 시간표 항목 카드 위젯 ====================
class _TimeTableCard extends StatelessWidget {
  final String name;
  final Color backgroundColor;
  final VoidCallback onSelect;

  const _TimeTableCard({
    required this.name,
    required this.backgroundColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: backgroundColor, // 배경색 동적 설정
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Color(0xFF1F2937),
            ),
          ),
          GestureDetector(
            onTap: onSelect,
            child: const Text(
              "선택",
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF3B82F6), // 선택 버튼 색상
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== "새로운 시간표 추가" 버튼 위젯 ====================
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