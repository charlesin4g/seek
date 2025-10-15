import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  HttpClient({this.baseUrl = 'http://172.16.115.42:8080', http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Map<String, String> get defaultHeaders => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final res = await _client
        .get(_uri(path), headers: {...defaultHeaders, ...?headers})
        .timeout(timeout);
    return _decodeJsonOrThrow(res, 'GET', path);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    print("path2 --> : ${_uri(path)}");
    try {
      final res = await _client
          .post(
            _uri(path),
            headers: {...defaultHeaders, ...?headers},
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout);

      print('🟢 Response Status: ${res.statusCode}');
      print('📥 Response Body: ${res.body}');
      print('📌 Response Headers: ${res.headers}');

      return _decodeJsonOrThrow(res, 'POST', path);
    } catch (e) {
      print('🔴 Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final res = await _client
        .put(
          _uri(path),
          headers: {...defaultHeaders, ...?headers},
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);
    return _decodeJsonOrThrow(res, 'PUT', path);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final res = await _client
        .delete(
          _uri(path),
          headers: {...defaultHeaders, ...?headers},
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);
    return _decodeJsonOrThrow(res, 'DELETE', path);
  }

  Map<String, dynamic> _decodeJsonOrThrow(
    http.Response res,
    String method,
    String path,
  ) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return <String, dynamic>{};
      final decoded = jsonDecode(res.body);
      return decoded is Map<String, dynamic> ? decoded : {'data': decoded};
    }
    throw Exception(
      'HTTP ${res.statusCode} when $method $path: ${res.reasonPhrase}',
    );
  }

  void close() => _client.close();
}
