import 'http_client.dart';

class UserApi {
  UserApi({HttpClient? client}) : _client = client ?? HttpClient();

  final HttpClient _client;

  // Login with username/password via GET query parameters
  Future<Map<String, dynamic>> login(String username, String password) {
    final path = '/api/user/login?'
                    'username=${Uri.encodeQueryComponent(username)}&'
                    'password=${Uri.encodeQueryComponent(password)}';
    print("path --> : ${path}");
    return _client.postJson(path);
  }

  Future<Map<String, dynamic>> getUserByUsername(String username) {
    return _client.getJson('/api/user/$username');
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> payload) {
    return _client.postJson('/api/user', body: payload);
  }

  Future<Map<String, dynamic>> updateUser(String username, Map<String, dynamic> payload) {
    return _client.putJson('/api/user/$username', body: payload);
  }

  Future<Map<String, dynamic>> deleteUser(String username) {
    return _client.deleteJson('/api/user/$username');
  }
}
