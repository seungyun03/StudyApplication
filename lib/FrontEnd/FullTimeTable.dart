// 📄 EditingPageParents.dart (수정 완료 버전)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/TimetableProvider.dart' as tp;
import 'SubjectButtonAddPage.dart';

class EditingPageParents extends StatefulWidget {
  const EditingPageParents({super.key});

  @override
  State<EditingPageParents> createState() => _EditingPageParentsState();
}

class _EditingPageParentsState extends State<EditingPageParents> {
  bool isDeleteMode = false;
  // 💡 수정: late var를 사용하여 initState에서 provider의 timetable을 복사
  late var timetable = <String, tp.SubjectInfo?>{};

  @override
  void initState() {
    super.initState();
    // 💡 추가: initState에서 현재 시간표를 복사하여 임시 맵으로 사용
    // BuildContext가 안전하게 사용될 수 있도록 Future.microtask으로 감싸는 것이 더 안전할 수 있습니다.
    // 여기서는 간단하게 initState 내에서 read합니다.
    timetable = {...context.read<tp.TimetableProvider>().timetable};
  }

  // 시간표에 존재하는 과목 이름 목록을 반환하는 함수
  Set<String> _getValidSubjects(Map<String, tp.SubjectInfo?> timetable) {
    // SubjectInfo가 null이 아닌 경우만 필터링하여 과목 이름(subject)을 추출
    return timetable.values
        .where((info) => info != null)
        .map((info) => info!.subject)
        .toSet(); // 중복 제거를 위해 Set으로 반환합니다.
  }

  // 💡 수정: 시간표 업데이트 후 스케줄 업데이트 로직을 묶는 함수 (페이지 이탈 시 호출)
  void _updateTimetableAndSchedules(BuildContext context) {
    // 💡 수정 시작: ScheduleProvider를 read만 합니다.
    final timetableProvider = context.read<tp.TimetableProvider>();
    final scheduleProvider = context.read<tp.ScheduleProvider>();

    // 1. 현재 임시 시간표 맵에서 유효한 과목 목록을 추출합니다.
    final validSubjects = _getValidSubjects(timetable);

    // 2. TimetableProvider에 스케줄 업데이트 콜백 함수를 설정합니다.
    //    콜백이 실행될 때 scheduleProvider를 통해 스케줄 데이터를 정리합니다.
    timetableProvider.onTimetableUpdate = () async {
      // setAll 내부에서 호출되며, 이 함수가 유효 과목 목록에 없는 시험/과제 데이터만 삭제합니다.
      await scheduleProvider.removeSchedulesNotIn(validSubjects);
      timetableProvider.onTimetableUpdate = null; // 콜백 사용 후 초기화
    };

    // 3. 임시 맵을 TimetableProvider에 setAll로 반영하고 저장합니다.
    //    이때 TimetableProvider.setAll 내부에서 onTimetableUpdate 콜백이 실행됩니다.
    timetableProvider.setAll(timetable);
    // 💡 수정 끝
  }

  @override
  Widget build(BuildContext context) {
    // build 함수에서는 timetableProvider를 watch하지 않습니다. (임시 맵 timetable 사용)
    // final provider = context.read<tp.TimetableProvider>(); // ❌ 사용 안함

    final days = ['월', '화', '수', '목', '금'];
    final times = [
      '9:00',
      '10:00',
      '11:00',
      '12:00',
      '13:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
      '19:00',
      '20:00',
      '21:00',
      '22:00',
      '23:00',
    ];

    return WillPopScope(
      // 💡 추가: 뒤로가기 버튼(하드웨어 또는 시스템)으로 나갈 때도 로직 실행
      onWillPop: () async {
        _updateTimetableAndSchedules(context);
        return true; // 페이지 팝 허용
      },
      child: Scaffold(
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
                      // ✅ 오른쪽 상단 뒤로가기 버튼
                      Positioned(
                        top: 10,
                        right: 30,
                        child: GestureDetector(
                          onTap: () {
                            // ✅ 최종 업데이트 로직 호출
                            _updateTimetableAndSchedules(context);
                            Navigator.pop(context);
                          },
                          // ... (Container 및 Icon 코드는 기존과 동일)
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              // 💡 수정 완료: Icons.arrow_forward_ios_rounded -> Icons.arrow_back_ios_rounded
                              child: Icon(Icons.arrow_back_ios_rounded,
                                  size: 20, color: Color(0xFF4B5563)),
                            ),
                          ),
                        ),
                      ),

                      // ... (시간표 영역 시작)
                      Positioned(
                        left: 24,
                        top: 87,
                        child: Container(
                          width: 1318,
                          height: 849,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0D000000),
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // 상단 헤더 (삭제/삭제 중 버튼 포함) ... (코드 생략) ...
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  height: 53,
                                  width: 1318,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFEFF6FF),
                                        Color(0xFFEEF2FF)
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "2024년 1학기 시간표",
                                          style: TextStyle(
                                            fontSize: 19.89,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isDeleteMode = !isDeleteMode;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: isDeleteMode
                                                  ? Colors.red.shade100
                                                  : const Color(0xFFF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              isDeleteMode ? "삭제 중" : "삭제",
                                              style: TextStyle(
                                                color: isDeleteMode
                                                    ? Colors.red.shade700
                                                    : const Color(0xFF4B5563),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // ✅ 시간표 본문
                              Positioned(
                                top: 53,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 70),
                                          for (final d in days)
                                            SizedBox(
                                              width: 206,
                                              child: Center(
                                                child: Text(
                                                  d,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                    color: Color(0xFF4B5563),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: times.length,
                                          itemBuilder: (context, i) {
                                            final t = times[i];
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: Row(
                                                children: [
                                                  SizedBox(
                                                    width: 70,
                                                    child: Center(
                                                      child: Text(
                                                        t,
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF9CA3AF),
                                                          fontSize: 13.95,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  for (final d in days)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 8.3),
                                                      child: _SlotButton(
                                                        id: "$d-$t",
                                                        data:
                                                            timetable["$d-$t"],
                                                        // 💡 수정: onChange 함수를 사용하여 임시 맵만 업데이트하고 화면 갱신
                                                        onChange: (key, value) {
                                                          timetable[key] =
                                                              value;
                                                          // 💡 핵심 수정: 개별 삭제 시 provider.update 호출 제거
                                                          setState(
                                                              () {}); // 변경사항 즉시 화면 반영
                                                        },
                                                        isDeleteMode:
                                                            isDeleteMode,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ==================== 개별 슬롯 버튼 ====================
class _SlotButton extends StatelessWidget {
  final String id;
  final tp.SubjectInfo? data;
  final void Function(String, tp.SubjectInfo?) onChange;
  final bool isDeleteMode;

  const _SlotButton({
    required this.id,
    required this.data,
    required this.onChange,
    required this.isDeleteMode,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return GestureDetector(
        onTap: isDeleteMode
            ? null
            : () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SubjectButtonAddPage()),
                );
                if (result != null && result is tp.SubjectInfo) {
                  onChange(id, result);
                }
              },
        child: Container(
          width: 206,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Center(
            child: Icon(Icons.add, color: Color(0xFF4B5563), size: 22),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: isDeleteMode ? () => onChange(id, null) : null,
      child: Stack(
        children: [
          Container(
            width: 206,
            height: 60,
            decoration: BoxDecoration(
              color: data!.bgColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x20000000),
                    offset: Offset(0, 2),
                    blurRadius: 3)
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data!.subject,
                  style: TextStyle(
                    color: data!.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  data!.room,
                  style: TextStyle(
                    color: data!.roomColor,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          if (isDeleteMode)
            const Positioned(
              right: 8,
              top: 6,
              child: Text(
                "삭제",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
