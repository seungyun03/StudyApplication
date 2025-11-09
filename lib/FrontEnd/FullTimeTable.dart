// 📄 FullTimeTable.dart (최종 수정 전체 코드 - 현재 시간표 이름 동적 반영)

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
  late var timetable = <String, tp.SubjectInfo?>{};

  // ⭐️ 핵심 추가: Provider 인스턴스를 저장할 변수
  late tp.TimetableProvider _provider;

  @override
  void initState() {
    super.initState();
    // 1. Provider 인스턴스를 저장하고 리스너를 등록합니다.
    _provider = context.read<tp.TimetableProvider>();
    _provider.addListener(_syncTimetableFromProvider); // <<< **리스너 등록**

    // 2. 초기 상태 로드
    timetable = {..._provider.timetable};
  }

  @override
  void dispose() {
    // 3. 위젯이 파괴될 때 리스너를 해제합니다.
    _provider.removeListener(_syncTimetableFromProvider); // <<< **리스너 해제**
    super.dispose();
  }

  // ⭐️ 핵심 추가: Provider의 상태가 변경될 때마다 로컬 상태를 동기화하는 함수
  void _syncTimetableFromProvider() {
    // Provider의 상태가 변경되었으므로, 로컬 상태를 업데이트하고 UI를 갱신합니다.
    if (mounted) {
      setState(() {
        timetable = {..._provider.timetable};
      });
    }
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
    // ScheduleProvider가 정의되어 있어야 합니다.
    // final scheduleProvider = context.read<tp.ScheduleProvider>();
    // 임시로 주석 처리: ScheduleProvider 임포트 상태에 따라 수정 필요

    final validSubjects = _getValidSubjects(timetable);

    timetableProvider.onTimetableUpdate = () async {
      // await scheduleProvider.removeSchedulesNotIn(validSubjects); // ScheduleProvider 정의 필요
      timetableProvider.onTimetableUpdate = null; // 콜백 사용 후 초기화
    };

    timetableProvider.setAll(timetable);
  }

  // 수동 갱신 함수 (리스너가 주 역할을 하므로, 보조적 역할)
  void _refreshTimetableFromProvider() {
    if (mounted) {
      // 리스너가 호출된 후 최신 상태를 반영했을 것입니다.
      // 여기서는 명시적으로 다시 동기화를 시도합니다.
      setState(() {
        timetable = {...context.read<tp.TimetableProvider>().timetable};
      });
    }
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
    // 🚨 [수정]: context.watch를 사용하여 Provider 상태 변경 감지
    // Provider의 상태 변경(특히 시간표 이름) 시 UI를 갱신합니다.
    final timetableProvider = context.watch<tp.TimetableProvider>();

    // 🚨 [추가]: 현재 활성화된 시간표 이름 가져오기
    final String currentTimetableName =
        timetableProvider.currentTimetable?.name ?? "시간표 로딩 중 / 선택 필요";

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
                                        // 🚨 [수정]: 시간표 이름을 동적으로 표시
                                        Text(
                                          currentTimetableName,
                                          style: const TextStyle(
                                            fontSize: 19.89,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        // ❌ 삭제: '삭제' 버튼 (GestureDetector) 제거
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
                                                        // ❌ isDeleteMode 전달 제거
                                                        onRefreshAll: _refreshTimetableFromProvider,
                                                        // ❌ isDeleteMode 검사 제거
                                                        onSubjectTap:
                                                        timetable["$d-$t"] !=
                                                            null
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
  final VoidCallback? onSubjectTap;
  final VoidCallback? onRefreshAll;

  const _SlotButton({
    required this.id,
    required this.data,
    required this.onChange,
    this.onSubjectTap,
    this.onRefreshAll,
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return GestureDetector(
        // 빈 슬롯은 탭 동작 없음 (기능 완전 제거)
        onTap: null,
        child: Container(
          width: 206,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: const Center(
            // '+' 아이콘 제거
            child: SizedBox.shrink(),
          ),
        ),
      );
    }

    // 과목이 있는 슬롯: 탭 시 무조건 onSubjectTap 실행
    return GestureDetector(
      onTap: onSubjectTap,
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
          // ❌ 삭제 모드일 때 표시되던 '삭제' 텍스트 제거
        ],
      ),
    );
  }
}