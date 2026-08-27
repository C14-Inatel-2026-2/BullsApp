import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/device_model.dart';
import 'package:iconsax/iconsax.dart';

class DeviceListItem extends StatelessWidget {
  final BleDeviceModel device;
  final VoidCallback onConnect;

  const DeviceListItem({
    super.key,
    required this.device,
    required this.onConnect,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14)),
      width: 500,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Iconsax.bluetooth, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                Text(device.macAddress, style: const TextStyle(color: AppColors.white, fontSize: 12)),
                const SizedBox(height: 4),
                Text('${device.rssi} dBm', style: const TextStyle(color: AppColors.white, fontSize: 11)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onConnect,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(device.isPaired ? 'PAREAR' : 'CONECTAR',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}