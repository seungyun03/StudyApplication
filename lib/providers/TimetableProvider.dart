import 'package:flutter/material.dart';

/// ---------------------------
/// 📘 과목 정보 모델
/// ---------------------------
class SubjectInfo {
  final String subject;
  final String room;
  final Color bgColor;
  final Color textColor;
  final Color roomColor;

  SubjectInfo({
    required this.subject,
    required this.room,
    required this.bgColor,
    required this.textColor,
    required this.roomColor,
  });
}

/// ---------------------------
/// 📘 시간표 Provider
/// ---------------------------
class TimetableProvider extends ChangeNotifier {
  Map<String, SubjectInfo?> _timetable = {};

  Map<String, SubjectInfo?> get timetable => _timetable;

  /// ✅ 개별 업데이트
  void update(String key, SubjectInfo? info) {
    _timetable = {..._timetable, key: info};
    notifyListeners();
  }

  /// ✅ 전체 덮어쓰기
  void setAll(Map<String, SubjectInfo?> newTable) {
    _timetable = {...newTable};
    notifyListeners();
  }

  /// ✅ 초기화
  void clear() {
    _timetable.clear();
    notifyListeners();
  }
}
