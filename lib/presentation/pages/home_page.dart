import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/device_model.dart';
import '../../data/repositories/ble_repository.dart';
import '../widgets/custom_button.dart';
import 'scan_page.dart';
import 'mod_page.dart';
import 'test_page.dart';

// presentation/pages/home_page.dart
class HomePage extends StatefulWidget {
  final String deviceName;
  final bool isConnected;

  /// Dispositivo conectado — usado pra monitorar a conexão.
  /// Se for null, a página não monitora nada (comportamento antigo).
  final BleDeviceModel? device;

  /// Injetável pra facilitar testes (mock/fake). Por padrão usa o real.
  final BleRepository? repository;

  const HomePage({
    super.key,
    required this.deviceName,
    required this.isConnected,
    this.device,
    this.repository,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final BleRepository _repo;
  StreamSubscription<BleConnectionState>? _connectionSub;
  late bool _isConnected;

  @override
  void initState() {
    super.initState();
    _isConnected = widget.isConnected;
    _repo = widget.repository ?? BleRepository();
    _listenToConnection();
  }

  void _listenToConnection() {
    final device = widget.device;
    if (device == null) return;

    _connectionSub = _repo.connectionStateOf(device).listen(
      (state) {
        if (state == BleConnectionState.disconnected) _onConnectionLost();
      },
      onError: (e) => debugPrint('Erro ao monitorar conexão: $e'),
    );
  }

  void _onConnectionLost() {
    if (!mounted || !_isConnected) return;

    // Troca "CONECTADO" por "DESCONECTADO"
    setState(() => _isConnected = false);

    // Fecha ModPage/TestPage (se estiverem abertas) e volta pro menu (esta página)
    final homeRoute = ModalRoute.of(context);
    if (homeRoute != null) {
      Navigator.of(context).popUntil((route) => route == homeRoute);
    }
  }

  void _disconnect() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScanPage()),
    );
  }

  @override
  void dispose() {
    _connectionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset('lib/assets/images/robotbull.png', height: 130),
              const SizedBox(height: 20),
              Text(
                widget.deviceName.toUpperCase(),
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isConnected ? AppColors.success : Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isConnected ? 'CONECTADO' : 'DESCONECTADO',
                    style: const TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Center(
                child: Column(
                  children: [
                    CustomButton(
                      label: 'COMBATE',
                      iconAsset: 'lib/assets/icons/rapier.png',
                      color: AppColors.secondary,
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (_) => ModPage()));}, // navegar para tela de combate
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'TESTAR',
                      icon: Icons.build,
                      color: AppColors.secondary,
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (_) => TestPage()));}, // navegar para tela de teste
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'HISTÓRICO DE LUTAS',
                      icon: Icons.history,
                      color: AppColors.secondary,
                      onTap: () {}, // navegar para histórico
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'DISCORD',
                      iconAsset: 'lib/assets/icons/discord.png',
                      color: AppColors.discord,
                      textColor: Colors.white,
                      onTap: () {}, // abrir link do discord
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      label: 'DESCONECTAR',
                      icon: Icons.logout,
                      color: AppColors.secondary,
                      height: 42,
                      width: CustomButton.defaultWidth * 0.65,
                      onTap: _disconnect,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}