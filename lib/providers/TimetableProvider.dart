// 📄 TimetableProvider.dart (SharedPreferences를 이용한 영구 저장 로직 포함)
// 🚨 수정: deleteSubject 함수의 반환 타입을 Future<void>로 변경

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart'; // import 추가

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
        'bgColor': bgColor.value, // Color를 int 값으로 저장
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

  // 두 SubjectInfo 객체가 동일한 과목을 나타내는지 확인 (과목 이름 기반)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubjectInfo && other.subject == subject;
  }

  @override
  int get hashCode => subject.hashCode;
}

/// ---------------------------
/// 📘 시간표 Provider (영구 저장/로드 기능 추가)
/// ---------------------------
class TimetableProvider extends ChangeNotifier {
  static const String _timetableKey = 'full_timetable_data';
  // ✅ [추가] 영구 저장될 과목 목록의 키
  static const String _subjectListKey = 'all_subjects_data';

  Map<String, SubjectInfo?> _timetable = {};
  // ✅ [추가] 영구 저장될 과목 목록
  List<SubjectInfo> _subjectList = [];
  bool _isTimetableLoading = true;

  Future<void> Function()? onTimetableUpdate; // EditingPageParents에서 설정할 예정

  Map<String, SubjectInfo?> get timetable => _timetable;
  bool get isTimetableLoading => _isTimetableLoading;
  // ✅ [추가] subjectList getter 정의
  List<SubjectInfo> get subjectList => _subjectList;

  TimetableProvider() {
    // 💡 수정: loadTimetable 대신 loadAllData 호출
    loadAllData(); // Provider 생성 시 시간표 로드 시작
  }

  // ✅ [추가] 모든 데이터 로드 (SubjectList와 Timetable)
  Future<void> loadAllData() async {
    _isTimetableLoading = true;
    notifyListeners();

    await Future.wait([
      loadSubjectList(),
      loadTimetable(),
    ]);

    _isTimetableLoading = false;
    notifyListeners();
  }

  /// ✅ [추가] 과목 목록 로드
  Future<void> loadSubjectList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_subjectListKey);

    if (jsonString != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        _subjectList = decodedList
            .map((item) => SubjectInfo.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _subjectList = [];
      }
    } else {
      _subjectList = [];
    }
  }

  /// ✅ [추가] 과목 목록 저장
  Future<void> saveSubjectList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonToEncode =
        _subjectList.map((info) => info.toJson()).toList();
    final String jsonString = jsonEncode(jsonToEncode);
    await prefs.setString(_subjectListKey, jsonString);
  }

  /// ✅ [추가] 과목 영구 추가 (subjectList에서 사용)
  void addSubject(SubjectInfo newSubject) async {
    // 중복 방지 (SubjectInfo의 == 연산자 사용)
    if (!_subjectList.contains(newSubject)) {
      _subjectList.add(newSubject);
      await saveSubjectList(); // 과목 목록 저장
      notifyListeners();
    }
  }

  // 🚨 수정: void -> Future<void>
  /// ✅ [추가] 과목 영구 삭제 (subjectList에서 사용)
  Future<void> deleteSubject(SubjectInfo subjectToDelete) async {
    // 1. 과목 목록에서 제거
    _subjectList.remove(subjectToDelete);

    // 2. 시간표 슬롯에서 해당 과목을 null로 설정하여 시간표에서 제거
    final keysToRemove = _timetable.keys
        .where((key) =>
            _timetable[key] != null &&
            _timetable[key]!.subject == subjectToDelete.subject)
        .toList();

    for (final key in keysToRemove) {
      _timetable[key] = null;
    }

    // 3. 두 데이터 모두 저장
    await saveSubjectList();
    await saveTimetable();

    notifyListeners();

    // 💡 시간표 변경 로직 호출 (스케줄 정리 목적)
    if (onTimetableUpdate != null) {
      await onTimetableUpdate!();
    }
  }

  /// ✅ 시간표 로드 (loadAllData에서 호출되도록 수정)
  Future<void> loadTimetable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_timetableKey);

    if (jsonString != null) {
      try {
        final Map<String, dynamic> decodedMap = jsonDecode(jsonString);
        final Map<String, SubjectInfo?> loadedTimetable = {};

        decodedMap.forEach((key, value) {
          if (value != null) {
            // value가 SubjectInfo의 JSON 맵인 경우
            loadedTimetable[key] =
                SubjectInfo.fromJson(value as Map<String, dynamic>);
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
  void setAll(Map<String, SubjectInfo?> newTable) async {
    _timetable = {...newTable};
    await saveTimetable(); // ✨ 변경 시 저장
    notifyListeners();
    // 💡 추가: setAll이 호출되면 스케줄 업데이트 로직 호출 (FullTimeTable의 pop 시점)
    if (onTimetableUpdate != null) {
      await onTimetableUpdate!();
    }
  }

  /// ✅ 초기화 (저장 로직 추가)
  void clear() async {
    _timetable.clear();
    // 💡 추가: 시간표 초기화 시 과목 목록도 초기화
    _subjectList.clear();

    await saveTimetable(); // ✨ 변경 시 저장
    await saveSubjectList(); // ✨ 과목 목록 저장

    notifyListeners();
    // 💡 추가: 시간표 초기화 시 스케줄 업데이트 로직 호출
    if (onTimetableUpdate != null) {
      await onTimetableUpdate!();
    }
  }
}

/// ---------------------------
/// 📘 시험/과제 스케줄 Provider (원래 로직 유지 + 과목 스케줄 삭제/업데이트 기능 추가)
/// ---------------------------
class ScheduleProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _allExams = [];
  List<Map<String, dynamic>> _allAssignments = [];
  bool _isLoading = true;

  // 💡 Getter 정의 (HomePage와 TimeTableButton이 사용)
  List<Map<String, dynamic>> get allExams => _allExams;
  List<Map<String, dynamic>> get allAssignments => _allAssignments;
  List<Map<String, dynamic>> get allSchedules =>
      [..._allExams, ..._allAssignments];
  bool get isLoading => _isLoading;

  ScheduleProvider() {
    loadAllSchedules(); // Provider 생성 시 데이터 로드 시작
  }

  /// ✅ 과목 이름 목록을 기반으로 해당 과목과 관련 없는 스케줄만 유지하고 새로 로드하는 함수
  Future<void> removeSchedulesNotIn(Set<String> validSubjects) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();

    // 시간표에 없는 과목에 대한 스케줄 키 삭제
    for (final key in allKeys) {
      String? subjectNamePart;
      const examsPrefix = 'exams_';
      const assignmentsPrefix = 'assignments_';

      if (key.startsWith(examsPrefix)) {
        subjectNamePart = key.substring(examsPrefix.length);
      } else if (key.startsWith(assignmentsPrefix)) {
        subjectNamePart = key.substring(assignmentsPrefix.length);
      }

      if (subjectNamePart != null && !validSubjects.contains(subjectNamePart)) {
        await prefs.remove(key);
      }
    }

    // 데이터 변경 후 전체 스케줄을 다시 로드하여 UI에 반영
    await loadAllSchedules();
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

          String subjectName = '';
          if (key.startsWith('exams_')) {
            subjectName = key.substring('exams_'.length);
          } else if (key.startsWith('assignments_')) {
            subjectName = key.substring('assignments_'.length);
          }

          if (key.startsWith('exams_')) {
            loadedExams.addAll(decodedList.map((item) {
              final map = item as Map<String, dynamic>;
              map['subjectName'] = subjectName; // 과목명 추가 (수정/추가)
              return map;
            }));
          } else if (key.startsWith('assignments_')) {
            loadedAssignments.addAll(decodedList.map((item) {
              final map = item as Map<String, dynamic>;
              map['subjectName'] = subjectName; // 과목명 추가 (수정/추가)
              return map;
            }));
          }
        } catch (e) {
          // JSON 파싱 오류 무시
        }
      }
    }

    // 날짜별로 정렬 (미래 일정이 먼저 오도록 - 오름차순)
    loadedExams.sort((a, b) {
      final dateA = DateTime.tryParse(
              (a['examDate'] as String? ?? '').replaceAll(' ', 'T')) ??
          DateTime(9999);
      final dateB = DateTime.tryParse(
              (b['examDate'] as String? ?? '').replaceAll(' ', 'T')) ??
          DateTime(9999);
      return dateA.compareTo(dateB);
    });
    // 과제 정렬 로직
    loadedAssignments.sort((a, b) {
      final dateA = DateTime.tryParse(
              (a['dueDate'] as String? ?? '').replaceAll(' ', 'T')) ??
          DateTime(9999);
      final dateB = DateTime.tryParse(
              (b['dueDate'] as String? ?? '').replaceAll(' ', 'T')) ??
          DateTime(9999);
      return dateA.compareTo(dateB);
    });

    // 상태 업데이트
    _allExams = loadedExams;
    _allAssignments = loadedAssignments;
    _isLoading = false;

    notifyListeners();
  }
}
