import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const RhapsodyTVApp());
}

class RhapsodyTVApp extends StatelessWidget {
  const RhapsodyTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RhapsodyTV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0033FF),
      ),
      home: const SplashScreen(),
    );
  }
}
