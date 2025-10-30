// 📄 SubjectButtonAddPage.dart (수정본: const 생성자 적용)

import 'package:flutter/material.dart';
import '../Providers/TimetableProvider.dart'; // ✅ SubjectInfo import
import 'AddSubjectModelPage.dart'; // ✅ 올바른 파일명 (Model) import

class SubjectButtonAddPage extends StatefulWidget {
  const SubjectButtonAddPage({super.key});

  @override
  State<SubjectButtonAddPage> createState() => _SubjectButtonAddPageState();
}

class _SubjectButtonAddPageState extends State<SubjectButtonAddPage> {
  // 사용자가 과목을 선택하거나 새로운 과목을 추가했을 때 호출됩니다.
  void onSubjectClick(SubjectInfo subject) {
    // 선택된 과목 정보를 이전 페이지(FullTimeTable)로 반환합니다.
    Navigator.pop(context, subject);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1366,
                height: 1024,
                child: Stack(
                  children: [
                    // ✅ const 생성자 적용
                    const _TopTitle(),
                    // 💡 오른쪽 상단에 FullTimeTable 스타일의 뒤로가기 버튼 추가
                    Positioned(
                      top: 10,
                      right: 30,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(Icons.close,
                              color: Color(0xFF4B5563), size: 24),
                        ),
                      ),
                    ),
                    _SubjectSelectionSection(onSubjectClick: onSubjectClick),
                    // ✅ const 생성자 적용 (오류 해결)
                    const _BottomNavigationBar(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================= 상단 제목 위젯 =======================
class _TopTitle extends StatelessWidget {
  // ✅ const 생성자 추가
  const _TopTitle();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30,
      left: 30,
      child: Container(
        width: 1306,
        height: 60,
        alignment: Alignment.centerLeft,
        child: const Text(
          "과목 선택",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}

// ======================= 과목 목록 및 추가 버튼 영역 =======================
class _SubjectSelectionSection extends StatelessWidget {
  final void Function(SubjectInfo subject) onSubjectClick;

  // ✅ const 생성자 추가
  const _SubjectSelectionSection({super.key, required this.onSubjectClick});

  // 임시 과목 데이터는 삭제되어 빈 리스트입니다.
  final List<SubjectInfo> _sampleSubjects = const [];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 120,
      left: 30,
      child: Container(
        width: 1306,
        height: 800, // 임시 높이
        child: Stack(
          children: [
            // --- 과목 목록 (스크롤 가능 영역) ---
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0), // 하단 버튼 공간 확보
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6, // 한 줄에 6개 (예시)
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 206 / 60, // 카드 크기 비율 (너비 206, 높이 60)
                ),
                itemCount: _sampleSubjects.length,
                itemBuilder: (context, index) {
                  final subject = _sampleSubjects[index];
                  return _SubjectCard(
                    data: subject,
                    onTap: () => onSubjectClick(subject), // 선택 시 정보 반환
                  );
                },
              ),
            ),
            // --- ✅ 새로운 과목 추가 버튼 ---
            _AddSubjectButton(onNewSubjectAdd: onSubjectClick),
          ],
        ),
      ),
    );
  }
}

// ======================= 과목 카드 위젯 =======================
class _SubjectCard extends StatelessWidget {
  final SubjectInfo data;
  final VoidCallback onTap;

  const _SubjectCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 206,
        height: 60,
        decoration: BoxDecoration(
          color: data.bgColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
                color: Color(0x20000000), offset: Offset(0, 2), blurRadius: 3)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data.subject,
              style: TextStyle(
                color: data.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              data.room,
              style: TextStyle(
                color: data.roomColor,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ======================= 새로운 과목 추가 버튼 =======================
class _AddSubjectButton extends StatelessWidget {
  final void Function(SubjectInfo subject) onNewSubjectAdd;

  const _AddSubjectButton({super.key, required this.onNewSubjectAdd});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () async {
            // ✅ AddSubjectModalPage 위젯을 호출합니다.
            final newSubject = await showDialog<SubjectInfo>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                // ✅ AddSubjectModelPage.dart 파일의 AddSubjectModalPage 위젯 호출
                return const AddSubjectModalPage();
              },
            );

            if (newSubject != null && newSubject is SubjectInfo) {
              onNewSubjectAdd(newSubject);
            }
          },
          child: Container(
            width: 367,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x10000000), offset: Offset(0, 2), blurRadius: 4)
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "새로운 과목 추가",
                  style: TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4B5563),
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.add,
                  size: 24,
                  color: Color(0xFF9CA3AF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================= 하단 네비게이션 바 위젯 (기존 코드 유지) =======================
class _BottomNavigationBar extends StatelessWidget {
  // ✅ const 생성자 추가 (오류 해결)
  const _BottomNavigationBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      bottom: 0,
      child: Container(
        width: 1366,
        height: 65,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(icon: Icons.people_outline, label: "커뮤니티", active: false),
            _NavItem(icon: Icons.home, label: "홈", active: true),
            _NavItem(icon: Icons.settings_outlined, label: "설정", active: false),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    super.key,
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
            fontSize: 12,
            color: active ? Colors.blue : Colors.grey,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}