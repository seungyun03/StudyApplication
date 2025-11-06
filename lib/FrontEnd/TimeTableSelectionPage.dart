// 📄 TimeTableSelectionPage.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 🚨 [추가] Provider 사용을 위한 import
// 🚨 [추가] AddNewTimeTablePage 및 TimetableProvider import
import 'AddNewTimeTablePage.dart';
import '../Providers/TimetableProvider.dart';

// ==================== 시간표 선택 페이지 ====================
class TimeTableSelectionPage extends StatelessWidget {
  const TimeTableSelectionPage({super.key});

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
            "시간표 선택", // 🚨 [수정] 제목을 '시간표 선택'으로 변경
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
  final String id;
  final String name;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onSelect;

  const _TimeTableCard({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 배경색에 따라 텍스트 색상을 자동으로 조정
    final Color textColor = backgroundColor.computeLuminance() > 0.5
        ? const Color(0xFF1F2937) // 밝은 배경 -> 어두운 글자
        : Colors.white; // 어두운 배경 -> 밝은 글자

    final Color primaryColor = const Color(0xFF9333EA); // 보라색

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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