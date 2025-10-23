// 📄 TimetableProvider.dart (SharedPreferences를 이용한 영구 저장 로직 추가)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// ---------------------------
/// 📘 과목 정보 모델 (JSON 직렬화/역직렬화 기능 추가)
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

  // ✨ JSON 변환 (저장 시 사용)
  Map<String, dynamic> toJson() => {
    'subject': subject,
    'room': room,
    'bgColor': bgColor.value,    // Color를 int 값으로 저장
    'textColor': textColor.value,
    'roomColor': roomColor.value,
  };

  // ✨ JSON으로부터 객체 생성 (로드 시 사용)
  factory SubjectInfo.fromJson(Map<String, dynamic> json) {
    return SubjectInfo(
      subject: json['subject'] as String,
      room: json['room'] as String,
      bgColor: Color(json['bgColor'] as int),
      textColor: Color(json['textColor'] as int),
      roomColor: Color(json['roomColor'] as int),
    );
  }
}

/// ---------------------------
/// 📘 시간표 Provider (영구 저장/로드 기능 추가)
/// ---------------------------
class TimetableProvider extends ChangeNotifier {
  static const String _timetableKey = 'full_timetable_data';
  Map<String, SubjectInfo?> _timetable = {};
  bool _isTimetableLoading = true;

  Map<String, SubjectInfo?> get timetable => _timetable;
  bool get isTimetableLoading => _isTimetableLoading;

  TimetableProvider() {
    loadTimetable(); // Provider 생성 시 시간표 로드 시작
  }

  /// ✅ 시간표 로드
  Future<void> loadTimetable() async {
    _isTimetableLoading = true;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_timetableKey);

    if (jsonString != null) {
      try {
        final Map<String, dynamic> decodedMap = jsonDecode(jsonString);
        final Map<String, SubjectInfo?> loadedTimetable = {};

        decodedMap.forEach((key, value) {
          if (value != null) {
            // value가 SubjectInfo의 JSON 맵인 경우
            loadedTimetable[key] = SubjectInfo.fromJson(value as Map<String, dynamic>);
          } else {
            // null 값 처리 (비어있는 칸)
            loadedTimetable[key] = null;
          }
        });
        _timetable = loadedTimetable;
      } catch (e) {
        // 로드 오류 발생 시 빈 시간표로 초기화
        _timetable = {};
      }
    } else {
      _timetable = {}; // 저장된 데이터가 없으면 빈 시간표
    }

    _isTimetableLoading = false;
    notifyListeners();
  }

  /// ✅ 시간표 저장
  Future<void> saveTimetable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // SubjectInfo?를 JSON으로 변환
    final Map<String, dynamic> jsonToEncode = {};
    _timetable.forEach((key, info) {
      jsonToEncode[key] = info?.toJson(); // SubjectInfo가 null이면 null로 저장
    });

    final String jsonString = jsonEncode(jsonToEncode);
    await prefs.setString(_timetableKey, jsonString);
  }

  /// ✅ 개별 업데이트 (저장 로직 추가)
  void update(String key, SubjectInfo? info) {
    _timetable = {..._timetable, key: info};
    saveTimetable(); // ✨ 변경 시 저장
    notifyListeners();
  }

  /// ✅ 전체 덮어쓰기 (저장 로직 추가)
  void setAll(Map<String, SubjectInfo?> newTable) {
    _timetable = {...newTable};
    saveTimetable(); // ✨ 변경 시 저장
    notifyListeners();
  }

  /// ✅ 초기화 (저장 로직 추가)
  void clear() {
    _timetable.clear();
    saveTimetable(); // ✨ 변경 시 저장
    notifyListeners();
  }
}


/// ---------------------------
/// 📘 시험/과제 스케줄 Provider (원래 로직 유지)
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