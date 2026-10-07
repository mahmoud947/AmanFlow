import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Session material is never written to ordinary preferences or displayed in UI.
abstract class SessionStore {
  Future<String?> read();
  Future<void> write(String session);
  Future<void> clear();
}

class PlatformSessionStore implements SessionStore {
  static const _key = 'authenticated_session';
  final FlutterSecureStorage _storage;

  PlatformSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String session) => _storage.write(key: _key, value: session);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}
