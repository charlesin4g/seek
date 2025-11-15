import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mobile/services/http_client.dart';
import 'package:mobile/services/user_api.dart';

class FakeClient extends http.BaseClient {
  final http.Response? Function(String method, Uri url, {Map<String, String>? headers, Object? body}) handler;
  FakeClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = request is http.Request ? request.body : null;
    final res = handler(request.method, request.url, headers: request.headers, body: body);
    if (res == null) throw Exception('SocketException');
    final stream = Stream<List<int>>.fromIterable([utf8.encode(res.body)]);
    return http.StreamedResponse(stream, res.statusCode, headers: res.headers, reasonPhrase: res.reasonPhrase);
  }
}
void main() {
  group('UserApi 错误处理与重试', () {
    late FakeClient mockHttp;
    late HttpClient httpClient;
    late UserApi userApi;

    setUp(() {
      mockHttp = FakeClient((method, url, {headers, body}) => http.Response('{}', 200));
      httpClient = HttpClient(client: mockHttp);
      userApi = UserApi(client: httpClient);
    });

    test('404 抛出 UserNotFoundException', () async {
      mockHttp = FakeClient((method, url, {headers, body}) => http.Response.bytes(utf8.encode('{"message":"用户不存在"}'), 404, headers: {'content-type': 'application/json; charset=utf-8'}));
      httpClient = HttpClient(client: mockHttp);
      userApi = UserApi(client: httpClient);

      expect(
        () => userApi.getUserByUsername('notfound'),
        throwsA(isA<UserNotFoundException>()),
      );
    });

    test('409 抛出 ConflictException', () async {
      mockHttp = FakeClient((method, url, {headers, body}) => http.Response.bytes(utf8.encode('{"message":"用户名已存在"}'), 409, headers: {'content-type': 'application/json; charset=utf-8'}));
      httpClient = HttpClient(client: mockHttp);
      userApi = UserApi(client: httpClient);

      expect(
        () => userApi.createUser({'username': 'dup'}),
        throwsA(isA<ConflictException>()),
      );
    });

    test('500 抛出 ServerException', () async {
      mockHttp = FakeClient((method, url, {headers, body}) => http.Response.bytes(utf8.encode('{"message":"服务器内部错误"}'), 500, headers: {'content-type': 'application/json; charset=utf-8'}));
      httpClient = HttpClient(client: mockHttp);
      userApi = UserApi(client: httpClient);

      expect(
        () => userApi.updateUser('user', {'displayName': 'New'}),
        throwsA(isA<ServerException>()),
      );
    });

    test('网络异常触发重试，最终成功', () async {
      int call = 0;
      mockHttp = FakeClient((method, url, {headers, body}) {
        if (method == 'POST') {
          call++;
          if (call == 1) return null;
          return http.Response('{"username":"alice"}', 201);
        }
        return http.Response('{}', 200);
      });
      httpClient = HttpClient(client: mockHttp);
      userApi = UserApi(client: httpClient);

      final res = await userApi.createUser({'username': 'alice'});
      expect(res['username'], 'alice');
    });

    test('重试 3 次仍失败则抛出原始异常', () async {
      mockHttp = FakeClient((method, url, {headers, body}) => null);
      httpClient = HttpClient(client: mockHttp);
      userApi = UserApi(client: httpClient);

      expect(
        () => userApi.createUser({'username': 'alice'}),
        throwsA(isA<Exception>()),
      );
    });
  });
}
