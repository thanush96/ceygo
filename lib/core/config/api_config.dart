import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // For web (Chrome): use localhost directly
  // For Android emulator: use 10.0.2.2 (alias for host machine localhost)
  static String get baseUrl => kIsWeb
      ? 'http://localhost:3000/api/v1'
      : 'http://10.0.2.2:3000/api/v1';

  static String get wsUrl => kIsWeb
      ? 'ws://localhost:3000'
      : 'ws://10.0.2.2:3000';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
