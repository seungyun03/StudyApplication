// 📄 FullTimeTable.dart (수정됨: 시간표 셀에 GestureDetector 추가)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Providers/TimetableProvider.dart' as tp;
import 'EditingPageParents.dart';
// 💡 추가: TimeTablebutton 위젯을 사용하기 위해 import
import 'TimeTablebutton.dart';

class FullTimeTable extends StatelessWidget {
  const FullTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    final timetable = context.watch<tp.TimetableProvider>().timetable;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            const _TopHeaderBar(),
            Expanded(
              child: _MainContent(timetable: timetable),
            ),
            const _BottomNavigationBar(),
          ],
        ),
      ),
    );
  }
}

// ==================== 상단 헤더 ====================
class _TopHeaderBar extends StatefulWidget {
  const _TopHeaderBar();

  @override
  State<_TopHeaderBar> createState() => _TopHeaderBarState();
}

class _TopHeaderBarState extends State<_TopHeaderBar> {
  bool _isBackPressed = false;
  bool _isEditPressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTapDown: (_) {
              setState(() => _isBackPressed = true);
              HapticFeedback.lightImpact();
            },
            onTapUp: (_) {
              setState(() => _isBackPressed = false);
              Navigator.pop(context);
            },
            onTapCancel: () => setState(() => _isBackPressed = false),
            child: AnimatedScale(
              scale: _isBackPressed ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 130),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 18, color: Color(0xFF4B5563)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "시간표",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 23.7,
              color: Color(0xFF1F2937),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTapDown: (_) {
              setState(() => _isEditPressed = true);
              HapticFeedback.lightImpact();
            },
            onTapUp: (_) async {
              setState(() => _isEditPressed = false);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditingPageParents()),
              );

              if (result != null && result is Map<String, tp.SubjectInfo?>) {
                context.read<tp.TimetableProvider>().setAll(result);
              }
            },
            onTapCancel: () => setState(() => _isEditPressed = false),
            child: AnimatedScale(
              scale: _isEditPressed ? 0.9 : 1.0,
              duration: const Duration(milliseconds: 130),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Text(
                  "수정",
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 메인 콘텐츠 ====================
class _MainContent extends StatelessWidget {
  final Map<String, tp.SubjectInfo?> timetable;
  const _MainContent({required this.timetable});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Center(
        child: Container(
          width: size.width * 0.93,
          constraints: const BoxConstraints(maxWidth: 1320),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: _WeeklyTimetableWidget(timetable: timetable),
        ),
      ),
    );
  }
}

// ==================== 주간 시간표 ====================
class _WeeklyTimetableWidget extends StatelessWidget {
  final Map<String, tp.SubjectInfo?> timetable;
  const _WeeklyTimetableWidget({required this.timetable});

  @override
  Widget build(BuildContext context) {
    final days = ["월", "화", "수", "목", "금"];
    final times = [
      "9:00",
      "10:00",
      "11:00",
      "12:00",
      "13:00",
      "14:00",
      "15:00",
      "16:00",
      "17:00",
      "18:00"
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "2024년 1학기 시간표",
            style: TextStyle(
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 50),
              for (final d in days)
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          for (final t in times)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      t,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                  for (final d in days)
                    Builder(
                      builder: (context) {
                        final cellSubject = timetable["$d-$t"];

                        return Expanded(
                          // 💡 추가: GestureDetector로 탭 이벤트 처리
                          child: GestureDetector(
                            onTap: () {
                              if (cellSubject == null) {
                                // 빈 셀을 탭하면 EditingPageParents로 이동 (추가/수정)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const EditingPageParents()),
                                );
                              } else {
                                // 과목이 있는 셀을 탭하면 TimeTableButton으로 이동 (상세 보기)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TimeTableButton(
                                      subjectName:
                                      "${cellSubject.subject} - ${cellSubject.room}",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 60,
                              decoration: BoxDecoration(
                                color: cellSubject?.bgColor ??
                                    const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(18),
                                border:
                                Border.all(color: const Color(0xFFE5E7EB)),
                              ),
                              child: Center(
                                child: cellSubject == null
                                    ? const SizedBox.shrink()
                                    : Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      cellSubject.subject,
                                      style: TextStyle(
                                        color: cellSubject.textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      cellSubject.room,
                                      style: TextStyle(
                                        color: cellSubject.roomColor,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== 하단 네비게이션 ====================
class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(icon: Icons.forum_outlined, label: "커뮤니티", active: false),
          _NavItem(icon: Icons.home, label: "홈", active: true),
          _NavItem(icon: Icons.settings_outlined, label: "설정", active: false),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? Colors.blue : Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13.8,
            color: active ? Colors.blue : Colors.grey,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}