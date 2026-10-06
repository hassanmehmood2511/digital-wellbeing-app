import 'package:flutter/material.dart';

import 'features/habits/presentation/screens/habit_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Wellbeing',
      debugShowCheckedModeBanner: false,
      home: const HabitListScreen(),
    );
  }
}
