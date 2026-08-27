import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/device_model.dart';
import 'home_page.dart';
import '../widgets/custom_button.dart';
import '../widgets/device_list_item.dart';



class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

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
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),

                
                Column(
                  children: [
                    for (int i = 0; i < devices.length; i++) ...[
                      DeviceListItem(
                        device: devices[i],
                        onConnect: () => _connect(context, devices[i]),
                      ),
                      if (i != devices.length - 1) const SizedBox(height: 12),
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