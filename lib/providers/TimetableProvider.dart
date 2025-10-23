// 📄 TimetableProvider.dart (ScheduleProvider 전체 로직 복원)

import 'package:flutter/material.dart';
// 💡 추가: SharedPreferences 및 JSON 인코딩/디코딩
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// ---------------------------
/// 📘 과목 정보 모델
/// ---------------------------
class SubjectInfo extends ChangeNotifier {
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


/// ---------------------------
/// 📘 시험/과제 스케줄 Provider (전체 로직 복원)
/// ---------------------------
class ScheduleProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _allExams = [];
  List<Map<String, dynamic>> _allAssignments = [];
  bool _isLoading = true;

  // 💡 Getter 정의 (HomePage와 TimeTableButton이 사용)
  List<Map<String, dynamic>> get allExams => _allExams;
  List<Map<String, dynamic>> get allAssignments => _allAssignments;
  List<Map<String, dynamic>> get allSchedules => [..._allExams, ..._allAssignments];
  bool get isLoading => _isLoading;

  ScheduleProvider() {
    loadAllSchedules(); // Provider 생성 시 데이터 로드 시작
  }

  /// ✅ 모든 과목의 스케줄을 SharedPreferences에서 로드 (HomePage와 TimeTableButton이 사용)
  Future<void> loadAllSchedules() async {
    _isLoading = true;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    final List<Map<String, dynamic>> loadedExams = [];
    final List<Map<String, dynamic>> loadedAssignments = [];

    // 모든 키를 순회하며 시험 및 과제 키를 찾아 데이터 로드
    for (final key in allKeys) {
      final jsonString = prefs.getString(key);
      if (jsonString != null) {
        try {
          final List<dynamic> decodedList = jsonDecode(jsonString);

          if (key.startsWith('exams_')) {
            loadedExams.addAll(
                decodedList.map((item) => item as Map<String, dynamic>));
          } else if (key.startsWith('assignments_')) {
            loadedAssignments.addAll(
                decodedList.map((item) => item as Map<String, dynamic>));
          }
        } catch (e) {
          // JSON 파싱 오류 무시
        }
      }
    }

    // 날짜별로 정렬 (미래 일정이 먼저 오도록)
    loadedExams.sort((a, b) {
      final dateA = DateTime.tryParse(a['examDate'] ?? '9999-12-31') ?? DateTime(9999);
      final dateB = DateTime.tryParse(b['examDate'] ?? '9999-12-31') ?? DateTime(9999);
      return dateA.compareTo(dateB);
    });
    loadedAssignments.sort((a, b) {
      final dateA = DateTime.tryParse(a['dueDate'] ?? '9999-12-31') ?? DateTime(9999);
      final dateB = DateTime.tryParse(b['dueDate'] ?? '9999-12-31') ?? DateTime(9999);
      return dateA.compareTo(dateB);
    });

    // 상태 업데이트
    _allExams = loadedExams;
    _allAssignments = loadedAssignments;
    _isLoading = false;

    notifyListeners();
  }
}