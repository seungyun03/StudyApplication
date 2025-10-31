// 📄 EditingPageParents.dart (로그 추가 최종 전체 코드)

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
  late var timetable = <String, tp.SubjectInfo?>{};

  @override
  void initState() {
    super.initState();
    // 💡 초기 상태: initState에서 현재 시간표를 복사하여 임시 맵으로 사용
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

  // 시간표 업데이트 후 스케줄 업데이트 로직을 묶는 함수 (페이지 이탈 시 호출)
  void _updateTimetableAndSchedules(BuildContext context) {
    final timetableProvider = context.read<tp.TimetableProvider>();
    final scheduleProvider = context.read<tp.ScheduleProvider>();

    // 1. 현재 임시 시간표 맵에서 유효한 과목 목록을 추출합니다.
    final validSubjects = _getValidSubjects(timetable);

    // 2. TimetableProvider에 스케줄 업데이트 콜백 함수를 설정합니다.
    timetableProvider.onTimetableUpdate = () async {
      await scheduleProvider.removeSchedulesNotIn(validSubjects);
      timetableProvider.onTimetableUpdate = null; // 콜백 사용 후 초기화
    };

    // 3. 임시 맵을 TimetableProvider에 setAll로 반영하고 저장합니다.
    timetableProvider.setAll(timetable);
  }

  @override
  Widget build(BuildContext context) {
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
                                                        // ⭐️ 핵심 수정 1: 전체 갱신 신호 처리 로직 추가
                                                        onChange: (key, value) {
                                                          if (key == "REFRESH_ALL") {
                                                            // ⭐️ 로그 추가: REFRESH_ALL 신호 수신 확인
                                                            print("✅ [DEL_SIGNAL] REFRESH_ALL received. Syncing local timetable.");

                                                            // 'REFRESH_ALL' 신호가 오면, Provider의 최신 맵으로 로컬 맵을 동기화합니다.
                                                            timetable = {...context.read<tp.TimetableProvider>().timetable};
                                                          } else {
                                                            // 단일 슬롯 업데이트인 경우 (기존 로직)
                                                            timetable[key] = value;
                                                          }
                                                          // 변경사항 즉시 화면 반영 (setState)
                                                          setState(() {});
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

          // ⭐️ 핵심 수정 2: SubjectButtonAddPage의 반환 값을 처리합니다.
          if (result != null) {
            if (result is tp.SubjectInfo) {
              // 1. 새 과목이 선택된 경우 (SubjectInfo 반환)
              onChange(id, result);
            } else if (result is bool && result == true) {
              // 2. 과목 영구 삭제가 발생한 경우 (true 반환)

              // 💡 핵심 추가: Provider의 상태를 저장소에서 강제로 다시 로드하여 최신 상태 보장
              await context.read<tp.TimetableProvider>().loadAllData();

              // ⭐️ 로그 추가: REFRESH_ALL 신호 전달 직전
              print("✅ [DEL_SIGNAL] Subject deletion detected. Sending REFRESH_ALL.");

              // 상위 위젯(_EditingPageParentsState)에 전체 갱신을 요청하는 특별한 키를 전달합니다.
              onChange("REFRESH_ALL", null);
            }
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