import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/device_model.dart';
import 'home_page.dart';
import '../widgets/custom_button.dart';
import '../widgets/device_list_item.dart';
import '../widgets/selector.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // false = mostra "disponíveis", true = mostra "pareados"
  bool _showPaired = false;

  void _connect(BuildContext context, BleDeviceModel device) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => HomePage(deviceName: device.name),
      ),
    );
  }

  // Depois substituir por uma lista vinda do BleController
  final List<BleDeviceModel> devices = const [
    BleDeviceModel(name: 'ELECTABULLZZ', macAddress: 'A1:B2:C3:D4:E5:F6', rssi: -42),
    BleDeviceModel(name: 'BULLBASAUR', macAddress: '00:1A:2B:3C:4D:5E', rssi: -68, isPaired: true),
    BleDeviceModel(name: 'EXCALIBULL', macAddress: 'F1:E2:D3:C4:B5:A6', rssi: -89, isPaired: true),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDevices =
        devices.where((d) => d.isPaired == _showPaired).toList();

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
                const SizedBox(height: 32),

                TabSelector(
                  options: const ['DISPONÍVEIS', 'PAREADOS'],
                  selectedIndex: _showPaired ? 0 : 1,
                  onChanged: (index) => setState(() => _showPaired = index == 0),
                ),
                const SizedBox(height: 16),

                if (filteredDevices.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      _showPaired
                          ? 'Nenhum dispositivo pareado ainda'
                          : 'Nenhum dispositivo disponível',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < filteredDevices.length; i++) ...[
                        DeviceListItem(
                          device: filteredDevices[i],
                          onConnect: () => _connect(context, filteredDevices[i]),
                        ),
                        if (i != filteredDevices.length - 1) const SizedBox(height: 12),
                      ],
                    ],
                  ),

                const SizedBox(height: 20),
                CustomButton(
                  label: 'SCAN',
                  icon: Icons.bluetooth_searching,
                  color: AppColors.secondary,
                  height: 52,
                  onTap: () {},
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