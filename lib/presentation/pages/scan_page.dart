import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/device_model.dart';
import '../controllers/ble_controller.dart';
import '../widgets/custom_button.dart';
import '../widgets/device_list_item.dart';
import '../widgets/selector.dart';
import 'home_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // false = mostra "disponíveis", true = mostra "pareados"
  bool _showPaired = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BleController()..init(),
      child: _ScanPageView(
        showPaired: _showPaired,
        onToggle: (value) => setState(() => _showPaired = value),
      ),
    );
  }
}

class _ScanPageView extends StatelessWidget {
  const _ScanPageView({
    required this.showPaired,
    required this.onToggle,
  });

  final bool showPaired;
  final ValueChanged<bool> onToggle;

  Future<void> _connect(
    BuildContext context,
    BleController controller,
    BleDeviceModel device,
  ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conectando a ${device.name}...'),
        duration: const Duration(seconds: 3),
      ),
    );

    final success = await controller.connect(device);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(deviceName: device.name),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.errorMessage ?? 'Falha ao conectar no robô.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BleController>();
    final displayedDevices = controller
        .sortDevicesForUI(controller.devices)
        .where((device) => device.isPaired == showPaired)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Image.asset('lib/assets/images/robotbull.png', height: 110),
                const SizedBox(height: 32),
                TabSelector(
                  options: const ['DISPONÍVEIS', 'PAREADOS'],
                  selectedIndex: showPaired ? 1 : 0,
                  onChanged: (index) => onToggle(index == 1),
                ),
                const SizedBox(height: 26),

                if (displayedDevices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      showPaired
                          ? 'Nenhum dispositivo pareado ainda'
                          : 'Nenhum dispositivo disponível',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < displayedDevices.length; i++) ...[
                        DeviceListItem(
                          device: displayedDevices[i],
                          onConnect: () =>
                              _connect(context, controller, displayedDevices[i]),
                        ),
                        if (i != displayedDevices.length - 1)
                          const SizedBox(height: 12),
                      ],
                    ],
                  ),

                const SizedBox(height: 20),

                if (controller.devices.isEmpty && controller.isScanning)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                else if (controller.devices.isEmpty && !controller.isScanning)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Nenhum robô encontrado. Verifique o Bluetooth e o GPS do celular.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 20),

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