import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/scan_page.dart';
import 'presentation/pages/sensor_page.dart';//temporario para testar sensor page

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
      //home: const ScanPage(),
      home: const SensorPage(), // TEMPORÁRIO - testando sensores
    );
  }
}
