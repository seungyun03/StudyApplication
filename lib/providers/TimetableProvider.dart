// 📄 TimetableProvider.dart (수정된 전체 코드)
// ===================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // 🚨 [필요] 고유 ID 생성을 위한 uuid 패키지 import

// ---------------------------
// 📘 TimeTable 모델 클래스 추가
// ---------------------------
/// 시간표 자체의 메타 정보를 저장하는 모델 (이름, 색상, ID 등)
class TimeTable {
  final String id; // 시간표를 구분하는 고유 ID
  final String name;
  final Color color;
  final DateTime createdAt; // 생성일시

  TimeTable({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  // ✨ JSON 변환 (저장 시 사용)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.value, // Color를 int 값으로 저장
    'createdAt': createdAt.toIso8601String(),
  };

  // ✨ JSON으로부터 객체 생성 (로드 시 사용)
  factory TimeTable.fromJson(Map<String, dynamic> json) => TimeTable(
    id: json['id'] as String,
    name: json['name'] as String,
    color: Color(json['color'] as int),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  // 💡 [추가] 새로운 이름과 색상으로 복사된 TimeTable 객체를 반환하는 함수
  TimeTable copyWith({String? name, Color? color}) {
    return TimeTable(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
    );
  }

  // ID 기반 동등성 비교
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TimeTable && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// ---------------------------
// 📘 과목 정보 모델 (기존 코드 유지)
// ---------------------------
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
/// 📘 시간표 Provider (영구 저장/로드 기능 추가 및 다중 시간표 지원)
/// ---------------------------
class TimetableProvider extends ChangeNotifier {
  // 🚨 [추가] 다중 시간표 관리를 위한 키
  static const String _timeTableListKey = 'all_timetable_list'; // 전체 시간표 목록 저장 키
  static const String _currentTimetableIdKey = 'current_timetable_id'; // 현재 활성화된 시간표 ID 저장 키

  // 기존 키를 suffix로 사용
  static const String _timetableDataSuffix = 'timetable_data';
  static const String _subjectListSuffix = 'all_subjects_data';

  // 🚨 [추가] 전체 시간표 목록 및 현재 시간표 ID
  List<TimeTable> _allTimeTables = [];
  String? _currentTimetableId;

  Map<String, SubjectInfo?> _timetable = {};
  List<SubjectInfo> _subjectList = [];
  bool _isTimetableLoading = true;

  Future<void> Function()? onTimetableUpdate; // EditingPageParents에서 설정할 예정

  // 💡 Getter 정의
  Map<String, SubjectInfo?> get timetable => _timetable;
  bool get isTimetableLoading => _isTimetableLoading;
  List<SubjectInfo> get subjectList => _subjectList;
  // 🚨 [추가] 전체 시간표 목록 Getter
  List<TimeTable> get allTimeTables => _allTimeTables;
  // 🚨 [추가] 현재 활성화된 시간표 ID Getter
  String? get currentTimetableId => _currentTimetableId;
  // 🚨 [추가] 현재 활성화된 TimeTable 객체 Getter
  TimeTable? get currentTimetable =>
      _allTimeTables.firstWhereOrNull((t) => t.id == _currentTimetableId);

  // 💡 Provider 생성 시 모든 데이터 로드 시작
  TimetableProvider() {
    loadAllData();
  }

  // ---------------------------
  // 🚨 [추가] 시간표 목록 관리 로직
  // ---------------------------

  /// 🚨 [추가] 전체 시간표 목록 로드
  Future<void> loadAllTimeTables() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_timeTableListKey);
    // 현재 활성화된 시간표 ID 로드
    _currentTimetableId = prefs.getString(_currentTimetableIdKey);

    if (jsonString != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        _allTimeTables = decodedList
            .map((item) => TimeTable.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _allTimeTables = [];
      }
    } else {
      _allTimeTables = [];
    }

    // 🚨 목록이 비어 있으면 현재 ID도 초기화
    if (_allTimeTables.isEmpty) {
      _currentTimetableId = null;
      await prefs.remove(_currentTimetableIdKey);
    } else if (_currentTimetableId == null || _allTimeTables.firstWhereOrNull((t) => t.id == _currentTimetableId) == null) {
      // 목록이 있는데 ID가 없거나 유효하지 않으면 가장 최근 시간표(첫 번째)를 선택
      await selectTimeTable(_allTimeTables.first.id, shouldNotify: false);
    }
  }

  /// 🚨 [추가] 전체 시간표 목록 저장
  Future<void> saveAllTimeTables() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonToEncode =
    _allTimeTables.map((info) => info.toJson()).toList();
    final String jsonString = jsonEncode(jsonToEncode);
    await prefs.setString(_timeTableListKey, jsonString);

    if (_currentTimetableId != null) {
      await prefs.setString(_currentTimetableIdKey, _currentTimetableId!);
    } else {
      await prefs.remove(_currentTimetableIdKey);
    }
  }

  /// 🚨 [추가] 특정 시간표의 이름/색상 수정
  Future<void> updateTimeTableInfo({
    required String timeTableId,
    required String newName,
    required Color newColor,
  }) async {
    // 1. 목록에서 해당 시간표 찾기
    final int index = _allTimeTables.indexWhere((t) => t.id == timeTableId);

    if (index != -1) {
      final TimeTable originalTable = _allTimeTables[index];
      // 2. 새로운 이름과 색상으로 TimeTable 객체 생성 (copyWith 사용)
      final TimeTable updatedTable = originalTable.copyWith(
        name: newName,
        color: newColor,
      );

      // 3. 목록 업데이트
      _allTimeTables[index] = updatedTable;

      // 4. 목록 저장
      await saveAllTimeTables();

      // 5. 리스너 알림
      notifyListeners();
    }
  }

  /// 🚨 [추가] 새로운 시간표 추가 및 선택
  Future<void> addNewTimeTable(TimeTable newTable) async {
    // 1. 목록에 추가
    _allTimeTables.add(newTable);
    // 2. 새로운 시간표로 즉시 선택 (데이터 로드를 위해)
    await selectTimeTable(newTable.id);
    // 3. 목록 저장 (selectTimeTable에서 currentId 저장까지 처리됨)
    await saveAllTimeTables();
    notifyListeners();
  }

  /// 🚨 [추가] 시간표 선택 (활성화)
  Future<void> selectTimeTable(String timeTableId, {bool shouldNotify = true}) async {
    if (_currentTimetableId == timeTableId && _timetable.isNotEmpty && _subjectList.isNotEmpty) {
      // 이미 로드된 상태이고 변경사항이 없으면 리턴
      return;
    }

    _currentTimetableId = timeTableId;
    _isTimetableLoading = true;
    if(shouldNotify) notifyListeners();

    // 1. 현재 ID 저장
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentTimetableIdKey, timeTableId);

    // 2. 새 시간표의 데이터 로드
    await Future.wait([
      loadSubjectList(), // 현재 ID 기반으로 과목 목록 로드
      loadTimetable(), // 현재 ID 기반으로 시간표 데이터 로드
    ]);

    _isTimetableLoading = false;
    if(shouldNotify) notifyListeners();
  }

  /// 🚨 [추가] 특정 시간표 삭제
  Future<void> deleteTimeTable(String timeTableId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. 목록에서 해당 시간표 찾기
    final TimeTable? tableToDelete =
    _allTimeTables.firstWhereOrNull((t) => t.id == timeTableId);

    if (tableToDelete == null) return; // 이미 삭제되었거나 존재하지 않음

    // 2. 시간표 목록에서 제거
    _allTimeTables.removeWhere((t) => t.id == timeTableId);

    // 3. SharedPreferences에서 해당 시간표 관련 데이터 (시간표 데이터, 과목 목록) 삭제
    //    ⚠️ [주의] ScheduleProvider가 사용하는 키와 중복되지 않도록 접미사를 사용하여 삭제해야 함
    await prefs.remove('${timeTableId}_$_timetableDataSuffix');
    await prefs.remove('${timeTableId}_$_subjectListSuffix');

    // 4. 목록 저장
    await saveAllTimeTables();

    // 5. 현재 활성화된 시간표가 삭제된 경우 처리
    if (_currentTimetableId == timeTableId) {
      if (_allTimeTables.isNotEmpty) {
        // 남은 시간표가 있으면 가장 첫 번째 시간표를 선택
        await selectTimeTable(_allTimeTables.first.id);
      } else {
        // 남은 시간표가 없으면 현재 시간표 ID 및 데이터 초기화
        _currentTimetableId = null;
        _timetable = {};
        _subjectList = [];
        await prefs.remove(_currentTimetableIdKey);
        await prefs.remove(_getTimetableKey(_timetableDataSuffix)); // default_timetable_data 삭제
        await prefs.remove(_getTimetableKey(_subjectListSuffix)); // default_all_subjects_data 삭제
      }
    }

    notifyListeners();
  }

  /// 🚨 [추가] 현재 시간표 ID 기반의 키 생성 함수
  String _getTimetableKey(String suffix) {
    if (_currentTimetableId == null) {
      // ID가 없을 경우 임시 키 사용 또는 기본 키 사용
      return 'default_$suffix';
    }
    return '${_currentTimetableId!}_$suffix';
  }

  // ---------------------------
  // 💡 기존 로직 수정 (ID 기반으로 키 변경)
  // ---------------------------

  /// ✅ [수정] 모든 데이터 로드 (TimeTable List, SubjectList, Timetable)
  Future<void> loadAllData() async {
    _isTimetableLoading = true;
    notifyListeners();

    // 1. 시간표 목록 및 현재 ID 로드
    await loadAllTimeTables();

    // 2. 현재 활성화된 시간표의 데이터 로드 (ID가 설정된 후 호출)
    await Future.wait([
      loadSubjectList(),
      loadTimetable(),
    ]);

    _isTimetableLoading = false;
    notifyListeners();
  }

  /// ✅ [수정] 과목 목록 로드 (현재 ID 기반)
  Future<void> loadSubjectList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 🚨 [수정] 키를 현재 ID 기반으로 변경
    final String? jsonString = prefs.getString(_getTimetableKey(_subjectListSuffix));

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

  /// ✅ [수정] 과목 목록 저장 (현재 ID 기반)
  Future<void> saveSubjectList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonToEncode =
    _subjectList.map((info) => info.toJson()).toList();
    final String jsonString = jsonEncode(jsonToEncode);
    // 🚨 [수정] 키를 현재 ID 기반으로 변경
    await prefs.setString(_getTimetableKey(_subjectListSuffix), jsonString);
  }

  /// ✅ [수정] 시간표 로드 (현재 ID 기반)
  Future<void> loadTimetable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 🚨 [수정] 키를 현재 ID 기반으로 변경
    final String? jsonString = prefs.getString(_getTimetableKey(_timetableDataSuffix));

    if (jsonString != null) {
      try {
        final Map<String, dynamic> decodedMap = jsonDecode(jsonString);
        final Map<String, SubjectInfo?> loadedTimetable = {};

        decodedMap.forEach((key, value) {
          if (value != null) {
            loadedTimetable[key] =
                SubjectInfo.fromJson(value as Map<String, dynamic>);
          } else {
            loadedTimetable[key] = null;
          }
        });
        _timetable = loadedTimetable;
      } catch (e) {
        _timetable = {};
      }
    } else {
      _timetable = {};
    }
  }

  /// ✅ [수정] 시간표 저장 (현재 ID 기반)
  Future<void> saveTimetable() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, dynamic> jsonToEncode = {};
    _timetable.forEach((key, info) {
      jsonToEncode[key] = info?.toJson();
    });

    final String jsonString = jsonEncode(jsonToEncode);
    // 🚨 [수정] 키를 현재 ID 기반으로 변경
    await prefs.setString(_getTimetableKey(_timetableDataSuffix), jsonString);
  }

  // ---------------------------
  // 💡 기타 함수
  // ---------------------------

  /// ✅ 과목 영구 추가 (subjectList에서 사용)
  void addSubject(SubjectInfo newSubject) async {
    if (!_subjectList.contains(newSubject)) {
      _subjectList.add(newSubject);
      await saveSubjectList();
      notifyListeners();
    }
  }

  // 💡 [추가] 과목 정보 수정 (이름 변경 시 데이터 마이그레이션 포함)
  Future<void> updateSubjectDetails({
    required String originalSubjectName,
    required SubjectInfo newSubjectInfo,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. 과목 목록(subjectList)에서 원본을 찾아 새 정보로 교체
    int subjectIndex = _subjectList.indexWhere((s) => s.subject == originalSubjectName);
    if (subjectIndex != -1) {
      _subjectList[subjectIndex] = newSubjectInfo;
      await saveSubjectList(); // 과목 목록 저장
    }

    // 2. 시간표(timetable)에서 원본 과목을 사용하는 모든 슬롯을 새 정보로 교체
    final Map<String, SubjectInfo?> updatedTimetable = {};
    _timetable.forEach((key, info) {
      if (info != null && info.subject == originalSubjectName) {
        updatedTimetable[key] = newSubjectInfo; // 새 정보로 교체
      } else {
        updatedTimetable[key] = info; // 기존 정보 유지
      }
    });
    _timetable = updatedTimetable;
    await saveTimetable(); // 시간표 저장

    // 3. [중요] 과목 이름이 변경된 경우, SharedPreferences 키 마이그레이션
    if (originalSubjectName != newSubjectInfo.subject) {
      final String newName = newSubjectInfo.subject;

      // 마이그레이션할 키 접두사 (TimeTableButton.dart 참조)
      const List<String> prefixes = ['lectures_', 'assignments_', 'exams_'];

      for (final prefix in prefixes) {
        final String oldKey = '${prefix}${originalSubjectName}';
        final String newKey = '${prefix}${newName}';

        final String? data = prefs.getString(oldKey);
        if (data != null) {
          await prefs.setString(newKey, data); // 새 키로 데이터 복사
          await prefs.remove(oldKey);        // 이전 키 삭제
        }
      }
    }

    // 4. 리스너 알림
    notifyListeners();

    // 5. HomePage의 EditingPageParents에도 알림 (시간표 UI 갱신)
    if (onTimetableUpdate != null) {
      await onTimetableUpdate!();
    }
    // (참고: 이 함수를 호출한 TimeTableButton에서 ScheduleProvider.loadAllSchedules()를 호출하여
    // 과제/시험 목록 UI도 갱신해야 합니다.)
  }


  /// ✅ [수정] 과목 영구 삭제 (관련 SharedPreferences 데이터 포함)
  Future<void> deleteSubject(SubjectInfo subjectToDelete) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String subjectName = subjectToDelete.subject;

    // 1. 과목 목록에서 제거
    _subjectList.remove(subjectToDelete);

    // 2. 시간표 슬롯에서 해당 과목을 null로 설정
    final keysToClear = _timetable.keys
        .where((key) =>
    _timetable[key] != null &&
        _timetable[key]!.subject == subjectName)
        .toList();

    for (final key in keysToClear) {
      _timetable[key] = null;
    }

    // 3. [추가] 관련된 SharedPreferences 데이터 (강의, 과제, 시험) 삭제
    // (TimeTableButton.dart에서 사용하는 키 형식과 일치해야 함)
    const List<String> prefixes = ['lectures_', 'assignments_', 'exams_'];
    for (final prefix in prefixes) {
      final String keyToDelete = '${prefix}${subjectName}';
      await prefs.remove(keyToDelete);
    }

    // 4. 두 데이터 모두 저장
    await saveSubjectList();
    await saveTimetable();

    // 5. 리스너 알림 (HomePage 등)
    notifyListeners();

    // 6. 시간표 UI 갱신 콜백
    if (onTimetableUpdate != null) {
      await onTimetableUpdate!();
    }
    // (참고: 이 함수를 호출한 TimeTableButton에서 ScheduleProvider.loadAllSchedules()를
    // 호출하여 과제/시험 목록 UI도 갱신해야 합니다.)
  }

  /// ✅ 개별 업데이트 (저장 로직 추가)
  void update(String key, SubjectInfo? info) {
    _timetable = {..._timetable, key: info};
    saveTimetable();
    notifyListeners();
  }

  /// ✅ 전체 덮어쓰기 (저장 로직 추가)
  void setAll(Map<String, SubjectInfo?> newTable) async {
    _timetable = {...newTable};
    await saveTimetable();
    notifyListeners();
    if (onTimetableUpdate != null) {
      await onTimetableUpdate!();
    }
  }

  /// ✅ 초기화 (현재 시간표 데이터만 초기화)
  // 🚨 [수정] async가 붙었으므로 Future<void>를 반환하도록 수정
  Future<void> clearCurrentTimetableData() async {
    _timetable.clear();
    _subjectList.clear();

    await saveTimetable();
    await saveSubjectList();

    notifyListeners();
    if (onTimetableUpdate != null) {
      await onTimetableUpdate!();
    }
  }

  /// ✅ 모든 데이터 초기화 (시간표 목록 포함)
  // 🚨 [수정] async가 붙었으므로 Future<void>를 반환하도록 수정
  Future<void> clearAllData() async {
    // 현재 시간표 데이터 초기화
    await clearCurrentTimetableData();

    // 💡 시간표 목록도 모두 삭제 (다른 시간표의 데이터는 삭제되지 않음)
    _allTimeTables.clear();
    _currentTimetableId = null;
    await saveAllTimeTables();

    // 다른 모든 시간표 데이터를 삭제하려면 SharedPreferences.clear()를 사용해야 하지만,
    // 현재 구현에서는 current ID가 설정되지 않은 상태로 load/save를 호출하면
    // default_ 접두사를 사용하므로, 모든 시간표 데이터를 순회하며 삭제하는 로직이 필요.
    // 여기서는 목록만 초기화하고 현재 활성화된 데이터만 삭제하는 것으로 구현합니다.
  }
}

// ---------------------------
// 📘 시험/과제 스케줄 Provider (로직 유지)
// ---------------------------
class ScheduleProvider extends ChangeNotifier {
  // ... (기존 코드는 변경 없이 유지)

  List<Map<String, dynamic>> _allExams = [];
  List<Map<String, dynamic>> _allAssignments = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get allExams => _allExams;
  List<Map<String, dynamic>> get allAssignments => _allAssignments;
  List<Map<String, dynamic>> get allSchedules =>
      [..._allExams, ..._allAssignments];
  bool get isLoading => _isLoading;

  ScheduleProvider() {
    loadAllSchedules();
  }

  // ✅ 과목 이름 목록을 기반으로 해당 과목과 관련 없는 스케줄만 유지하고 새로 로드하는 함수
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

// 💡 확장 함수: 리스트에서 특정 조건에 맞는 첫 번째 요소를 찾는 편의 기능
extension IterableExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}