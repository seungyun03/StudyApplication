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

  @override
  Widget build(BuildContext context) {
    final provider = context.read<tp.TimetableProvider>();
    final timetable = {...provider.timetable};

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
    ];

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
                    // ✅ 오른쪽 상단 뒤로가기 버튼
                    Positioned(
                      top: 10,
                      right: 30,
                      child: GestureDetector(
                        onTap: () {
                          // ✅ Provider 업데이트 반영
                          provider.setAll(timetable);
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
                            child: Icon(Icons.arrow_forward_ios_rounded,
                                size: 20, color: Color(0xFF4B5563)),
                          ),
                        ),
                      ),
                    ),

                    // ✅ 시간표 영역
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
                            // 상단 헤더
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
                                                      data: timetable["$d-$t"],
                                                      onChange: (key, value) {
                                                        timetable[key] = value;
                                                        provider.update(
                                                            key, value);
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
