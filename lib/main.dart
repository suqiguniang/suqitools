import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const QiXiaoHeApp());
}

class QiXiaoHeApp extends StatelessWidget {
  const QiXiaoHeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '柒小盒',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
