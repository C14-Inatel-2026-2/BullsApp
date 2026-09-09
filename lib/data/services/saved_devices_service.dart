import 'package:shared_preferences/shared_preferences.dart';

class SavedDevicesService {
  static const String _prefsKey = 'saved_ble_macs';

  /// Retorna a lista de endereços MAC salvos localmente
  static Future<List<String>> getSavedMacs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey) ?? [];
  }

  /// Salva um novo endereço MAC localmente (sem duplicar)
  static Future<void> saveDeviceMac(String mac) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> macs = prefs.getStringList(_prefsKey) ?? [];

    if (!macs.contains(mac)) {
      macs.add(mac);
      await prefs.setStringList(_prefsKey, macs);
    }
  }

  /// Método para limpar o histórico
  static Future<void> clearSavedMacs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}