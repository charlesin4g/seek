import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpClient {
  final String localBaseUrl = 'http://127.0.0.1:8080';
  final String localAreaBaseUrl = 'http://172.16.115.42:8081';
  
  HttpClient({this.baseUrl = 'http://127.0.0.1:8080', http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Map<String, String> get defaultHeaders => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<String> getJson(
    String path, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final res = await _client
        .get(_uri(path), headers: {...defaultHeaders, ...?headers})
        .timeout(timeout);
    return _decodeJsonOrThrow(res, 'GET', path);
  }

  Future<String> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final res = await _client
        .post(
          _uri(path),
          headers: {...defaultHeaders, ...?headers},
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(timeout);
    return _decodeJsonOrThrow(res, 'POST', path);
  }

  Future<String> putJson(
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

  Future<String> deleteJson(
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

  String _decodeJsonOrThrow(
    http.Response res,
    String method,
    String path,
  ) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return '';
      return res.body;
    }
    throw Exception(
      'HTTP ${res.statusCode} when $method $path: ${res.reasonPhrase}',
    );
  }

  void close() => _client.close();
}
