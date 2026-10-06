import 'dart:io' show Platform;

/// Backend base URL. Override with:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.20:4000
/// Defaults: Android emulator -> 10.0.2.2 (host loopback), others -> localhost.
class AppConfig {
  static const _override = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    return Platform.isAndroid
        ? 'http://10.0.2.2:4000'
        : 'http://localhost:4000';
  }
}
