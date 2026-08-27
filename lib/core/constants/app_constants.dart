class AppConstants {
  // App Info
  static const String appName = 'BullsApp';
  static const String appVersion = '1.0.0';
  static const String appPackageName = 'com.bullsapp.app';

  // BLE Constants
  static const String bleServiceUUID = '180A'; // Device Information Service
  static const String bleCharacteristicUUID = '2A29'; // Manufacturer Name String
  static const Duration bleScanTimeout = Duration(seconds: 30);
  static const Duration bleConnectionTimeout = Duration(seconds: 10);
  static const int bleMaxRetries = 3;

  // Discord Constants
  static const String discordClientId = 'YOUR_DISCORD_CLIENT_ID';
  static const String discordScopes = 'identify guilds';

  // Network & API
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration readTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // Spacing & Layout
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;

  // App Text Constants
  static const String appTitle = 'BullsApp';
  static const String appSubtitle = 'Conecte-se aos seus dispositivos BLE';

  // Error Messages
  static const String errorConnection = 'Erro de conexão. Tente novamente.';
  static const String errorTimeout = 'Tempo de conexão expirado.';
  static const String errorPermission = 'Permissão necessária para continuar.';
  static const String errorNotFound = 'Dispositivo não encontrado.';

  // Success Messages
  static const String successConnected = 'Conectado com sucesso!';
  static const String successDisconnected = 'Desconectado com sucesso!';

  // Loading Messages
  static const String loadingScanning = 'Procurando dispositivos...';
  static const String loadingConnecting = 'Conectando...';
  static const String loadingDisconnecting = 'Desconectando...';

  // Cache & Storage
  static const String cacheKeyUser = 'user_cache';
  static const String cacheKeyDevices = 'devices_cache';
  static const Duration cacheExpiration = Duration(hours: 24);

  // Animation Duration
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Sizes
  static const double buttonHeight = 48.0;
  static const double buttonHeightSmall = 36.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double cardElevation = 2.0;

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 32;

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxPages = 100;

  // Database
  static const String databaseName = 'bullsapp.db';
  static const int databaseVersion = 1;
}
