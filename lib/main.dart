import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// 💡 오류 해결을 위해 추가: 지역화(Localization) 패키지 임포트
import 'package:flutter_localizations/flutter_localizations.dart';

import 'FrontEnd/HomePage.dart'; // ✅ 네 홈 화면
import 'Providers/TimetableProvider.dart'; // ✅ Provider 추가

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimetableProvider()), // ✅ 추가
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
      home: const HomePage(), // ✅ 홈 페이지 진입점
    );
  }
}