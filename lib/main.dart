// 📄 main.dart (수정됨: 시작 페이지를 LoginPage로 변경)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 💡 오류 해결을 위해 추가: 지역화(Localization) 패키지 임포트
import 'package:flutter_localizations/flutter_localizations.dart';

// ✅ LoginPage 임포트 추가
import 'FrontEnd/LoginPage.dart';
import 'FrontEnd/HomePage.dart'; // ✅ 네 홈 화면
// 💡 수정: 파일 시스템의 대소문자를 고려하여 정확한 경로 하나만 임포트합니다.
import 'Providers/TimetableProvider.dart';

void main() {
  // 💡 추가: SharedPreferences 사용 전 초기화 (TimeTableButton.dart 때문)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimetableProvider()),
        // 💡 ScheduleProvider 등록 (TimetableProvider.dart 파일에 정의되어 있음)
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study App',
      // -------------------------------------------------------------------
      // 💡 DatePicker 오류 해결: 지역화(Localization) 설정 추가
      // -------------------------------------------------------------------
      localizationsDelegates: const [
        // 필수: Material 위젯 (DatePicker 포함)의 지역화 제공
        GlobalMaterialLocalizations.delegate,
        // 위젯의 기본 텍스트 방향 및 기타 설정
        GlobalWidgetsLocalizations.delegate,
        // iOS 스타일 위젯의 지역화
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'), // 한국어 지원 추가
        Locale('en', 'US'), // 영어 지원 (기본값)
      ],
      // -------------------------------------------------------------------
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      // 🚨 핵심 수정: 시작 페이지를 HomePage()에서 LoginPage()로 변경
      home: const LoginPage(), // ✅ 로그인 페이지 진입점
    );
  }
}
