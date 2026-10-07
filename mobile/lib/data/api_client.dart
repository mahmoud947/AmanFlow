import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

/// Thin JSON-over-HTTP client. The only place that knows about the base URL.
class ApiClient {
  final String baseUrl;
  final http.Client _http;
  String? _token;
  ApiClient(this.baseUrl, {http.Client? client})
    : _http = client ?? http.Client();

  Future<void> signIn(String identifier, String password) async {
    _token = null;
    final result = await post('/auth/login', {
      'identifier': identifier,
      'password': password,
    });
    _token = (result as Map<String, dynamic>)['token'] as String;
  }

  Future<dynamic> get(String path) async {
    final res = await _send(() => _http.get(
      Uri.parse('$baseUrl$path'), headers: _headers,
    ));
    return _decode(res);
  }

  Map<String, String> get _headers => {
    if (_token != null) 'authorization': 'Bearer $_token',
  };

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final res = await _send(
      () => _http.post(
        Uri.parse('$baseUrl$path'),
        headers: {..._headers, 'content-type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    return _decode(res);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 10));
    } catch (_) {
      throw ApiException('Cannot reach the server. Please try again.');
    }
  }

  dynamic _decode(http.Response res) {
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final msg = body is Map && body['error'] != null
        ? body['error'].toString()
        : 'Request failed';
    throw ApiException(msg, statusCode: res.statusCode);
  }
}
