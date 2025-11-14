import 'dart:io';

class ApiConfig {
  // Base URLs
  // Nota: En Android emulador usa 10.0.2.2 para acceder a localhost de la máquina host
  // En iOS simulator, localhost funciona directamente
  static String get baseUrlDev {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }

  static const String baseUrlProd = 'https://api.mindflow.com/api/v1';

  // Current environment
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  static String get baseUrl => isProduction ? baseUrlProd : baseUrlDev;

  // Endpoints
  static const String auth = '/auth';
  static const String users = '/users';
  static const String meditations = '/meditations';
  static const String journal = '/journal';
  static const String mood = '/mood';
  static const String subscriptions = '/subscriptions';

  // Timeout
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
