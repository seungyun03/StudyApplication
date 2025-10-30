// 📄 SubjectButtonAddPage.dart (영구 저장 및 삭제 기능 추가)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider import 추가
import '../Providers/TimetableProvider.dart'; // TimetableProvider 및 SubjectInfo, ScheduleProvider 포함
import 'AddSubjectModelPage.dart'; // AddSubjectModelPage import

class SubjectButtonAddPage extends StatefulWidget {
  const SubjectButtonAddPage({super.key});

  @override
  State<SubjectButtonAddPage> createState() => _SubjectButtonAddPageState();
}

class _SubjectButtonAddPageState extends State<SubjectButtonAddPage> {
  // ⭐️ 추가: 삭제 모드 상태
  bool isDeleteMode = false;

  // 시간표에 존재하는 과목 이름 목록을 반환하는 함수 (스케줄 정리용)
  Set<String> _getValidSubjects(Map<String, SubjectInfo?> timetable) {
    return timetable.values
        .where((info) => info != null)
        .map((info) => info!.subject)
        .toSet();
  }

  // 과목 선택 함수 (삭제 모드일 때는 선택 비활성화)
  void onSubjectClick(SubjectInfo subject) {
    if (isDeleteMode) {
      return;
    }
    // 선택된 과목 정보를 이전 페이지(FullTimeTable)로 반환합니다.
    Navigator.pop(context, subject);
  }

  // ✅ 새로운 과목이 추가되면 Provider에 저장 후, 선택된 과목 정보를 반환
  void onNewSubjectAdded(SubjectInfo newSubject) {
    // 1. Provider에 과목 정보 저장 (영구 저장 트리거)
    context.read<TimetableProvider>().addSubject(newSubject);

    // 2. 현재 시간표 슬롯에 반영하기 위해 이전 페이지로 반환
    Navigator.pop(context, newSubject);
  }

  // ⭐️ 추가: 삭제 모드 토글
  void toggleDeleteMode() {
    setState(() {
      isDeleteMode = !isDeleteMode;
    });
  }

  // ⭐️ 수정: 과목 영구 삭제 실행 (Provider 호출 및 스케줄 정리)
  // TimetableProvider의 deleteSubject가 Future<void>를 반환하도록 수정되었으므로 await 사용이 가능합니다.
  void deleteSubject(SubjectInfo subject) async {
    // 1. TimetableProvider에서 과목 영구 삭제 및 시간표 정리
    await context.read<TimetableProvider>().deleteSubject(subject); // ✅ await 사용

    // 2. ScheduleProvider에서 해당 과목 관련 스케줄 정리
    // 삭제 후 업데이트된 시간표를 가져와 유효한 과목 목록을 추출합니다.
    final updatedTimetable = context.read<TimetableProvider>().timetable;
    final validSubjects = _getValidSubjects(updatedTimetable);

    // ScheduleProvider의 cleanup 함수 호출
    await context.read<ScheduleProvider>().removeSchedulesNotIn(validSubjects); // ✅ await 사용
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
                    const _TopTitle(),
                    // ⭐️ 추가: 삭제 모드 토글 버튼
                    Positioned(
                      top: 10,
                      right: 90, // 닫기 버튼과 간격 확보
                      child: GestureDetector(
                        onTap: toggleDeleteMode,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            // 삭제 모드 시 버튼 색상/아이콘 변경으로 상태를 명확히 표시
                            color: isDeleteMode
                                ? Colors.red.shade100
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Icon(Icons.delete_outline,
                              color: isDeleteMode
                                  ? Colors.red
                                  : const Color(0xFF4B5563),
                              size: 24),
                        ),
                      ),
                    ),
                    // 기존 닫기 버튼
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
                    // ✅ onNewSubjectAdded 콜백 전달 및 삭제 모드/함수 전달
                    _SubjectSelectionSection(
                      onSubjectClick: onSubjectClick,
                      onNewSubjectAdded: onNewSubjectAdded,
                      isDeleteMode: isDeleteMode,
                      onSubjectDelete: deleteSubject,
                    ),
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

// ======================= 상단 제목 위젯 (기존과 동일) =======================
class _TopTitle extends StatelessWidget {
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

// ======================= 과목 목록 및 추가 버튼 영역 (Provider 사용) =======================
class _SubjectSelectionSection extends StatelessWidget {
  final void Function(SubjectInfo subject) onSubjectClick;
  final void Function(SubjectInfo subject) onNewSubjectAdded;
  // ⭐️ 추가: 삭제 모드 상태
  final bool isDeleteMode;
  // ⭐️ 추가: 과목 삭제 콜백
  final void Function(SubjectInfo subject) onSubjectDelete;

  const _SubjectSelectionSection({
    super.key,
    required this.onSubjectClick,
    required this.onNewSubjectAdded,
    required this.isDeleteMode,
    required this.onSubjectDelete,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Provider를 통해 저장된 과목 목록을 가져옵니다.
    final List<SubjectInfo> subjects =
        context.watch<TimetableProvider>().subjectList;

    return Positioned(
      top: 120,
      left: 30,
      child: Container(
        width: 1306,
        height: 800,
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
                itemCount: subjects.length, // ✅ 저장된 과목 목록 사용
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return _SubjectCard(
                    data: subject,
                    onTap: () => onSubjectClick(subject), // 선택 시 정보 반환
                    // ⭐️ 추가: 삭제 모드 및 삭제 콜백 전달
                    isDeleteMode: isDeleteMode,
                    onDeleteTap: () => onSubjectDelete(subject),
                  );
                },
              ),
            ),
            // --- ✅ 새로운 과목 추가 버튼 ---
            // ⭐️ 삭제 모드일 때는 '새로운 과목 추가' 버튼을 표시하지 않습니다.
            if (!isDeleteMode)
              _AddSubjectButton(onNewSubjectAdd: onNewSubjectAdded),
          ],
        ),
      ),
    );
  }
}

// ======================= 과목 카드 위젯 (삭제 아이콘 추가) =======================
class _SubjectCard extends StatelessWidget {
  final SubjectInfo data;
  final VoidCallback onTap;
  // ⭐️ 추가: 삭제 모드 상태
  final bool isDeleteMode;
  // ⭐️ 추가: 삭제 버튼 탭 콜백
  final VoidCallback onDeleteTap;

  const _SubjectCard({
    super.key,
    required this.data,
    required this.onTap,
    required this.isDeleteMode,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack( // 삭제 아이콘을 띄우기 위해 Stack 사용
        children: [
          // 기존 Container (과목 카드 본체)
          Container(
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
          // ⭐️ 추가: 삭제 모드일 때만 삭제 아이콘 표시
          if (isDeleteMode)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: onDeleteTap, // 삭제 로직 실행
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2), // 흰색 테두리
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ======================= 새로운 과목 추가 버튼 (콜백 수정) =======================
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
            final newSubject = await showDialog<SubjectInfo>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext dialogContext) {
                // ✅ AddSubjectModalPage.dart 파일의 AddSubjectModalPage 위젯 호출
                return const AddSubjectModalPage();
              },
            );

            // ✅ 새로운 과목이 추가되면 콜백을 호출하여 Provider에 저장 후 반환
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
                // 🚨 오타 수정: BoxBoxShadow -> BoxShadow
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