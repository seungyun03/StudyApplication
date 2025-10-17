import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullTimeTable extends StatelessWidget {
  const FullTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: const [
            _TopHeaderBar(),
            Expanded(child: _MainContent()),
            _BottomNavigationBar(),
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
        ],
      ),
    );
  }
}

// ==================== 메인 콘텐츠 ====================
class _MainContent extends StatelessWidget {
  const _MainContent();

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
          child: const _WeeklyTimetableWidget(),
        ),
      ),
    );
  }
}

// ==================== 주간 시간표 위젯 ====================
class _WeeklyTimetableWidget extends StatefulWidget {
  const _WeeklyTimetableWidget();

  @override
  State<_WeeklyTimetableWidget> createState() => _WeeklyTimetableWidgetState();
}

class _WeeklyTimetableWidgetState extends State<_WeeklyTimetableWidget> {
  bool _editPressed = false;

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
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              // 수정 버튼만 남김
              GestureDetector(
                onTapDown: (_) {
                  setState(() => _editPressed = true);
                  HapticFeedback.lightImpact();
                },
                onTapUp: (_) {
                  setState(() => _editPressed = false);
                  // TODO: 수정 기능 구현
                },
                onTapCancel: () => setState(() => _editPressed = false),
                child: AnimatedScale(
                  scale: _editPressed ? 0.9 : 1.0,
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

          const SizedBox(height: 20),

          // 요일 헤더
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

          // 시간표 셀들
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
                  for (final d in days) const Expanded(child: _TimetableCell()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== 시간표 셀 ====================
class _TimetableCell extends StatefulWidget {
  const _TimetableCell();

  @override
  State<_TimetableCell> createState() => _TimetableCellState();
}

class _TimetableCellState extends State<_TimetableCell> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        // TODO: 셀 클릭 동작
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        transform: Matrix4.identity()..scale(_pressed ? 0.93 : 1.0),
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFE0E7FF) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
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
