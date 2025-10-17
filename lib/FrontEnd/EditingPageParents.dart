import 'package:flutter/material.dart';

class EditingPageParents extends StatefulWidget {
  const EditingPageParents({super.key});

  @override
  State<EditingPageParents> createState() => _EditingPageParentsState();
}

class _EditingPageParentsState extends State<EditingPageParents> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // 상단 헤더
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            height: 54,
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  const Positioned(
                    left: 30,
                    top: 11,
                    child: Text(
                      "시간표",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 30,
                    top: 10,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 우측 버튼 클릭 시 동작
                      },
                      child: Container(
                        width: 76,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: const Icon(Icons.arrow_forward_ios,
                            color: Color(0xFF4B5563)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 주간 시간표
          Positioned(
            top: 87,
            left: 24,
            width: 1318,
            height: 849,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 헤더
                  Container(
                    height: 53,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFEFF6FF), Color(0xFFEEF2FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF3F4F6)),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 20, top: 12),
                      child: Text(
                        "2024년 1학기 시간표",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),

                  // 시간표 본문
                  Positioned.fill(
                    top: 53,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            buildSubjectBox("수학", "A101", Colors.blue),
                            buildSubjectBox("영어", "B203", Colors.green),
                            buildSubjectBox("과학", "C105", Colors.purple),
                            buildSubjectBox("역사", "D301", Colors.orange),
                            buildSubjectBox("국어", "E102", Colors.red),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 네비게이션 바
          Positioned(
            bottom: 0,
            left: 0,
            width: 1366,
            height: 65,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 210,
                    top: 0,
                    width: 52,
                    height: 64,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 커뮤니티 클릭
                      },
                      child: navItem(Icons.groups, "커뮤니티", false),
                    ),
                  ),
                  Positioned(
                    left: 683,
                    top: 0,
                    width: 52,
                    height: 64,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 홈 클릭
                      },
                      child: navItem(Icons.home, "홈", true),
                    ),
                  ),
                  Positioned(
                    left: 1129,
                    top: 0,
                    width: 52,
                    height: 64,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 설정 클릭
                      },
                      child: navItem(Icons.settings, "설정", false),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 개별 과목 박스
  Widget buildSubjectBox(String title, String room, MaterialColor color) {
    return GestureDetector(
      onTap: () {
        // TODO: 과목 클릭 시 이동 or 상세 페이지 로직
      },
      child: Container(
        width: 200,
        height: 60,
        decoration: BoxDecoration(
          color: color.shade100.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: color.shade800),
              ),
              Text(
                room,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                    color: color.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 네비게이션 아이템
  Widget navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: active ? Colors.blue : Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.blue : Colors.grey,
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
