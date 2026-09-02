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

  // ── FUNÇÃO DE CONEXÃO ATUALIZADA ────────────────────────────────────────
  Future<void> _connect(BuildContext context, BleController controller, BleDeviceModel device) async {
    // 1. Mostra um aviso de que está tentando conectar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conectando a ${device.name}...'),
        duration: const Duration(seconds: 3),
      ),
    );

    // 2. Aguarda a resposta do hardware BLE
    final success = await controller.connect(device);

    // 3. Verifica se o widget ainda está ativo na tela
    if (!context.mounted) return;

    // Remove o aviso de "conectando"
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 4. Navega apenas se a conexão foi estabelecida com sucesso
    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(deviceName: device.name),
        ),
      );
    } else {
      // 5. Mostra erro se falhar
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

    // Lista ordenada puxando os conhecidos pro topo
    final listaOrdenada = controller.sortDevicesForUI(controller.devices);

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
                    // Tratamento visual para listas vazias
                    if (listaOrdenada.isEmpty && controller.isScanning)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else if (listaOrdenada.isEmpty && !controller.isScanning)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Nenhum robô encontrado. Verifique o Bluetooth e o GPS do celular.',
                          style: TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      for (int i = 0; i < listaOrdenada.length; i++) ...[
                        DeviceListItem(
                          device: listaOrdenada[i],
                          // Chama a nova função passando o controller
                          onConnect: () => _connect(context, controller, listaOrdenada[i]),
                        ),
                        if (i != listaOrdenada.length - 1)
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