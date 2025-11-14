import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:your_app/services/http_client.dart';
import 'package:your_app/services/user_api.dart';

import 'user_api_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('UserApi 错误处理与重试', () {
    late MockClient mockHttp;
    late HttpClient httpClient;
    late UserApi userApi;

    setUp(() {
      mockHttp = MockClient();
      httpClient = HttpClient(client: mockHttp);
      userApi = UserApi(client: httpClient);
    });

    test('404 抛出 UserNotFoundException', () async {
      when(mockHttp.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"message":"用户不存在"}', 404));

      expect(
        () => userApi.getUserByUsername('notfound'),
        throwsA(isA<UserNotFoundException>()),
      );
    });

    test('409 抛出 ConflictException', () async {
      when(mockHttp.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"message":"用户名已存在"}', 409));

      expect(
        () => userApi.createUser({'username': 'dup'}),
        throwsA(isA<ConflictException>()),
      );
    });

    test('500 抛出 ServerException', () async {
      when(mockHttp.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"message":"服务器内部错误"}', 500));

      expect(
        () => userApi.updateUser('user', {'displayName': 'New'}),
        throwsA(isA<ServerException>()),
      );
    });

    test('网络异常触发重试，最终成功', () async {
      // 第一次失败，第二次成功
      when(mockHttp.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => throw Exception('SocketException'))
          .thenAnswer((_) async => http.Response('{"username":"alice"}', 201));

      final res = await userApi.createUser({'username': 'alice'});
      expect(res['username'], 'alice');
    });

    test('重试 3 次仍失败则抛出原始异常', () async {
      when(mockHttp.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenThrow(Exception('SocketException'));

      expect(
        () => userApi.createUser({'username': 'alice'}),
        throwsA(isA<Exception>()),
      );
    });
  });
}