import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/ble_repository.dart';
import 'data/repositories/fake_robot_command_port.dart';
import 'data/repositories/robot_command_port.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/scan_page.dart';

/// `flutter run --dart-define=FAKE_ROBOT=true` roda o app sem robô:
/// pula o scan e responde os comandos com o [FakeRobotCommandPort].
const bool useFakeRobot = bool.fromEnvironment('FAKE_ROBOT');

void main() {
  // Instância ÚNICA: guarda a conexão com o robô para o app inteiro.
  final repository = BleRepository();
  final RobotCommandPort port =
      useFakeRobot ? FakeRobotCommandPort() : repository;

  runApp(MyApp(repository: repository, port: port));
}

class MyApp extends StatelessWidget {
  final BleRepository repository;
  final RobotCommandPort port;

  const MyApp({super.key, required this.repository, required this.port});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BleRepository>.value(value: repository),
        Provider<RobotCommandPort>.value(value: port),
      ],
      child: MaterialApp(
        title: 'BullsApp',
        theme: AppTheme.theme(),
        home: useFakeRobot
            ? const HomePage(deviceName: 'Robô simulado', isConnected: true)
            : const ScanPage(),
      ),
    );
  }
}
