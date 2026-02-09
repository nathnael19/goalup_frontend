import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GoalUpApp());
}

/// Main application widget for GoalUp - ASTU Football App
class GoalUpApp extends StatelessWidget {
  const GoalUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoalUp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2), // Football blue
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const HomeScreen(),
    );
  }
}
