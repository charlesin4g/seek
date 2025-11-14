import 'dart:convert';
import 'dart:io';
import 'package:your_app/services/user_api.dart';

/// 手动验证脚本：注册-登录-更新-删除完整流程
void main() async {
  final api = UserApi();

  try {
    // 1. 注册
    print('1. 创建用户...');
    final createRes = await api.createUser({
      'username': 'testalice',
      'password': '123456',
      'displayName': 'Alice Test',
      'email': 'alice@example.com',
      'phone': '13800138000',
    });
    print('注册成功: ${createRes['username']}');

    // 2. 登录
    print('2. 登录...');
    final loginRes = await api.login('testalice', '123456');
    print('登录成功: ${loginRes['displayName']}');

    // 3. 更新
    print('3. 更新用户...');
    final updateRes = await api.updateUser('testalice', {
      'displayName': 'Alice Updated',
      'signature': 'Stay hungry, stay foolish.',
    });
    print('更新成功: ${updateRes['displayName']}');

    // 4. 查询
    print('4. 查询用户...');
    final getRes = await api.getUserByUsername('testalice');
    print('查询成功: ${getRes['displayName']} / ${getRes['signature']}');

    // 5. 删除
    print('5. 删除用户...');
    await api.deleteUser('testalice');
    print('删除成功');

    print('✅ 全流程验证通过');
  } catch (e) {
    print('❌ 验证失败: $e');
    exit(1);
  }
}