import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(), // ✅ 홈 페이지 진입점
    );
  }
}
