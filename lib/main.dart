import 'package:flutter/material.dart';
import 'package:study_app/FrontEnd/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study App',
      home: HomePage(), // ✅ 바로 여기서 시작
    );
  }
}
