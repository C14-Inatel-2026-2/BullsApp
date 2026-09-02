import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/device_model.dart';
import '../controllers/ble_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/device_list_item.dart';
import 'home_page.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BleController()..init(),
      child: const _ScanPageView(),
    );
  }
}

class _ScanPageView extends StatelessWidget {
  const _ScanPageView();

  void _connect(BuildContext context, BleDeviceModel device) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(deviceName: device.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BleController>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Image.asset('assets/images/robotbull.png', height: 110),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(' ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),

                // ── Lista de dispositivos ─────────────────────────────────
                Column(
                  children: [
                    for (int i = 0; i < controller.devices.length; i++) ...[
                      DeviceListItem(
                        device: controller.devices[i],
                        onConnect: () =>
                            _connect(context, controller.devices[i]),
                      ),
                      if (i != controller.devices.length - 1)
                        const SizedBox(height: 12),
                    ],
                  ],
                ),

                const SizedBox(height: 20),

                // ── Botão SCAN / PARAR ────────────────────────────────────
                CustomButton(
                  label: controller.isScanning ? 'PARAR' : 'SCAN',
                  icon: controller.isScanning
                      ? Icons.stop
                      : Icons.bluetooth_searching,
                  color: AppColors.secondary,
                  height: 52,
                  onTap: controller.isScanning
                      ? () => controller.stopScan()
                      : () => controller.startScan(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}