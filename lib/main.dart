import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const FrancySheetsApp());
}

class FrancySheetsApp extends StatelessWidget {
  const FrancySheetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FrancySheets',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1C1B2F),
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.redAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E2C45),
        ),
      ),
      home: const HomePage(),
    );
  }
}
