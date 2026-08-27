import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/scan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BullsApp',
      theme: AppTheme.theme(),
      home: const ScanPage(),
    );
  }
}
