import 'package:flutter/material.dart';
import 'shared/theme/app_theme.dart';
import 'home/home_screen.dart';

void main() {
  runApp(const GamePoolApp());
}

class GamePoolApp extends StatelessWidget {
  const GamePoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Pool',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}
