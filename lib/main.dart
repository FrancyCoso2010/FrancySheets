import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'models/theme.dart';

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
      theme: appTheme,
      home: const HomePage(),
    );
  }
}
