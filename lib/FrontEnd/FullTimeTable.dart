// 📄 FullTimeTable.dart (최종 전체 코드)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/TimetableProvider.dart' as tp;
import 'SubjectButtonAddPage.dart';
import 'TimeTablebutton.dart';

class FullTimeTable extends StatefulWidget {
  const FullTimeTable({super.key});

  @override
  State<FullTimeTable> createState() => _FullTimeTableState();
}

class _FullTimeTableState extends State<FullTimeTable> {
  bool isDeleteMode = false;
  late var timetable = <String, tp.SubjectInfo?>{};

  @override
  void initState() {
    super.initState();
    timetable = {...context.read<tp.TimetableProvider>().timetable};
  }

  // 시간표에 존재하는 과목 이름 목록을 반환하는 함수
  Set<String> _getValidSubjects(Map<String, tp.SubjectInfo?> timetable) {
    return timetable.values
        .where((info) => info != null)
        .map((info) => info!.subject)
        .toSet();
  }

  // 시간표 업데이트 후 스케줄 업데이트 로직을 묶는 함수 (페이지 이탈 시 호출)
  void _updateTimetableAndSchedules(BuildContext context) {
    final timetableProvider = context.read<tp.TimetableProvider>();
    final scheduleProvider = context.read<tp.ScheduleProvider>();

    final validSubjects = _getValidSubjects(timetable);

    timetableProvider.onTimetableUpdate = () async {
      await scheduleProvider.removeSchedulesNotIn(validSubjects);
      timetableProvider.onTimetableUpdate = null; // 콜백 사용 후 초기화
    };

    timetableProvider.setAll(timetable);
  }

  // ⭐️ 핵심 수정: Provider의 최신 상태를 SharedPreferences에서 강제로 다시 로드합니다.
  void _refreshTimetableFromProvider() async { // 🚨 async 추가
    final provider = context.read<tp.TimetableProvider>();

    // 1. SharedPreferences에서 과목 목록과 시간표를 강제로 다시 로드합니다.
    await provider.loadAllData();

    // 2. 재로드된 최신 데이터로 로컬 상태를 업데이트하고 UI 갱신
    setState(() {
      timetable = {...provider.timetable};
    });
  }

  // TimeTableButton으로 이동하는 함수
  void _navigateToTimeTableButton(String subjectName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimeTableButton(subjectName: subjectName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<tp.TimetableProvider>();

    final days = ['월', '화', '수', '목', '금'];
    final times = [
      '9:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00',
      '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00', '23:00',
    ];

    return WillPopScope(
      onWillPop: () async {
        _updateTimetableAndSchedules(context);
        return true;
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
                      Positioned(
                        top: 10,
                        right: 30,
                        child: GestureDetector(
                          onTap: () {
                            _updateTimetableAndSchedules(context);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_back_ios_rounded,
                                  size: 20, color: Color(0xFF4B5563)),
                            ),
                          ),
                        ),
                      ),

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
                                                        onChange: (key, value) {
                                                          timetable[key] =
                                                              value;
                                                          setState(
                                                                  () {});
                                                        },
                                                        isDeleteMode:
                                                        isDeleteMode,
                                                        // ⭐️ 새로 추가: 전체 갱신 콜백 전달
                                                        onRefreshAll: _refreshTimetableFromProvider,
                                                        onSubjectTap:
                                                        timetable["$d-$t"] !=
                                                            null &&
                                                            !isDeleteMode
                                                            ? () => _navigateToTimeTableButton(
                                                            timetable[
                                                            "$d-$t"]!
                                                                .subject)
                                                            : null,
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

// ==================== 개별 슬롯 버튼 (FullTimeTable.dart 내부에 위치) ====================
class _SlotButton extends StatelessWidget {
  final String id;
  final tp.SubjectInfo? data;
  final void Function(String, tp.SubjectInfo?) onChange;
  final bool isDeleteMode;
  final VoidCallback? onSubjectTap;
  final VoidCallback? onRefreshAll;

  const _SlotButton({
    required this.id,
    required this.data,
    required this.onChange,
    required this.isDeleteMode,
    this.onSubjectTap,
    this.onRefreshAll,
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
              builder: (_) => const SubjectButtonAddPage(),
            ),
          );

          // ⭐️ 핵심 수정: 반환된 결과가 bool 타입의 true라면 (삭제가 발생했다는 신호)
          if (result != null && result is bool && result == true) {
            // 💡 [해결책] 전체 갱신 콜백을 한 번만 호출하여 SharedPreferences에서 재로드 후 UI 갱신
            onRefreshAll?.call();
          }
          // 새로운 과목이 추가된 경우 (기존 로직)
          else if (result != null && result is tp.SubjectInfo) {
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
      onTap: isDeleteMode ? () => onChange(id, null) : onSubjectTap,
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