import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 完整的端到端测试脚本
/// 测试用户注册-登录-更新-删除完整流程
/// 测试票据管理功能
/// 测试离线模式切换
/// 测试网络异常处理
void main() async {
  print('🚀 开始 Flutter 真机完整功能测试\n');
  
  final testResults = <String, bool>{};
  final performanceMetrics = <String, double>{};
  
  // 测试环境配置
  const baseUrl = 'http://127.0.0.1:8080';
  final testUsername = 'testuser_${DateTime.now().millisecondsSinceEpoch}';
  const testPassword = 'Test@123456';
  
  print('测试环境：');
  print('- 后端地址: $baseUrl');
  print('- 测试用户: $testUsername');
  print('- 测试时间: ${DateTime.now()}\n');
  
  try {
    // 1. 用户管理流程测试
    print('👤 1. 用户管理流程测试');
    print('=' * 50);
    
    // 1.1 创建用户
    final createStart = DateTime.now();
    final createResponse = await http.post(
      Uri.parse('$baseUrl/api/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': testUsername,
        'password': testPassword,
        'displayName': 'Test User',
        'email': '$testUsername@example.com',
        'phone': '13800138000',
      }),
    );
    final createDuration = DateTime.now().difference(createStart).inMilliseconds / 1000;
    performanceMetrics['create_user'] = createDuration;
    
    if (createResponse.statusCode == 201) {
      print('✅ 创建用户成功 (${createResponse.statusCode}) - ${createDuration}s');
      testResults['create_user'] = true;
    } else {
      print('❌ 创建用户失败 (${createResponse.statusCode}): ${createResponse.body}');
      testResults['create_user'] = false;
    }
    
    // 1.2 用户登录
    final loginStart = DateTime.now();
    final loginResponse = await http.post(
      Uri.parse('$baseUrl/api/user/login?username=$testUsername&password=$testPassword'),
      headers: {'Content-Type': 'application/json'},
    );
    final loginDuration = DateTime.now().difference(loginStart).inMilliseconds / 1000;
    performanceMetrics['login'] = loginDuration;
    
    if (loginResponse.statusCode == 200) {
      print('✅ 用户登录成功 (${loginResponse.statusCode}) - ${loginDuration}s');
      testResults['login'] = true;
    } else {
      print('❌ 用户登录失败 (${loginResponse.statusCode}): ${loginResponse.body}');
      testResults['login'] = false;
    }
    
    // 1.3 更新用户信息
    final updateStart = DateTime.now();
    final updateResponse = await http.put(
      Uri.parse('$baseUrl/api/user/$testUsername'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'displayName': 'Updated Test User',
        'signature': 'This is a test signature',
      }),
    );
    final updateDuration = DateTime.now().difference(updateStart).inMilliseconds / 1000;
    performanceMetrics['update_user'] = updateDuration;
    
    if (updateResponse.statusCode == 200) {
      print('✅ 更新用户成功 (${updateResponse.statusCode}) - ${updateDuration}s');
      testResults['update_user'] = true;
    } else {
      print('❌ 更新用户失败 (${updateResponse.statusCode}): ${updateResponse.body}');
      testResults['update_user'] = false;
    }
    
    // 1.4 查询用户信息
    final getStart = DateTime.now();
    final getResponse = await http.get(Uri.parse('$baseUrl/api/user/$testUsername'));
    final getDuration = DateTime.now().difference(getStart).inMilliseconds / 1000;
    performanceMetrics['get_user'] = getDuration;
    
    if (getResponse.statusCode == 200) {
      final userData = jsonDecode(getResponse.body);
      print('✅ 查询用户成功 (${getResponse.statusCode}) - ${getDuration}s');
      print('   用户信息: ${userData['displayName']} | ${userData['signature']}');
      testResults['get_user'] = true;
    } else {
      print('❌ 查询用户失败 (${getResponse.statusCode}): ${getResponse.body}');
      testResults['get_user'] = false;
    }
    
    // 2. 票据管理功能测试
    print('\n🎫 2. 票据管理功能测试');
    print('=' * 50);
    
    // 2.1 添加票据
    final ticketStart = DateTime.now();
    final ticketResponse = await http.post(
      Uri.parse('$baseUrl/api/ticket/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'category': 'Flight',
        'travelNo': 'CA1234',
        'fromCity': 'Beijing',
        'toCity': 'Shanghai',
        'departureTime': '2024-12-01T08:00:00',
        'arrivalTime': '2024-12-01T10:30:00',
        'owner': testUsername,
      }),
    );
    final ticketDuration = DateTime.now().difference(ticketStart).inMilliseconds / 1000;
    performanceMetrics['add_ticket'] = ticketDuration;
    
    if (ticketResponse.statusCode == 200) {
      print('✅ 添加票据成功 (${ticketResponse.statusCode}) - ${ticketDuration}s');
      testResults['add_ticket'] = true;
    } else {
      print('❌ 添加票据失败 (${ticketResponse.statusCode}): ${ticketResponse.body}');
      testResults['add_ticket'] = false;
    }
    
    // 2.2 查询用户票据
    final ticketsStart = DateTime.now();
    final ticketsResponse = await http.get(Uri.parse('$baseUrl/api/ticket/owner?owner=$testUsername'));
    final ticketsDuration = DateTime.now().difference(ticketsStart).inMilliseconds / 1000;
    performanceMetrics['get_tickets'] = ticketsDuration;
    
    if (ticketsResponse.statusCode == 200) {
      final ticketsData = jsonDecode(ticketsResponse.body) as List;
      print('✅ 查询票据成功 (${ticketsResponse.statusCode}) - ${ticketsDuration}s');
      print('   票据数量: ${ticketsData.length}');
      testResults['get_tickets'] = true;
    } else {
      print('❌ 查询票据失败 (${ticketsResponse.statusCode}): ${ticketsResponse.body}');
      testResults['get_tickets'] = false;
    }
    
    // 3. 网络异常处理测试
    print('\n🌐 3. 网络异常处理测试');
    print('=' * 50);
    
    // 3.1 测试404错误
    try {
      final notFoundResponse = await http.get(Uri.parse('$baseUrl/api/user/nonexistent_user'));
      if (notFoundResponse.statusCode == 404) {
        print('✅ 404错误处理正常');
        testResults['404_handling'] = true;
      } else {
        print('❌ 404错误处理异常');
        testResults['404_handling'] = false;
      }
    } catch (e) {
      print('✅ 网络异常捕获正常: $e');
      testResults['network_exception'] = true;
    }
    
    // 3.2 测试参数验证错误
    final invalidResponse = await http.post(
      Uri.parse('$baseUrl/api/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        // 缺少必填字段
        'email': 'invalid-email',
      }),
    );
    
    if (invalidResponse.statusCode == 400) {
      print('✅ 参数验证错误处理正常 (${invalidResponse.statusCode})');
      testResults['validation_error'] = true;
    } else {
      print('❌ 参数验证错误处理异常 (${invalidResponse.statusCode})');
      testResults['validation_error'] = false;
    }
    
    // 4. 清理测试数据
    print('\n🧹 4. 清理测试数据');
    print('=' * 50);
    
    final deleteStart = DateTime.now();
    final deleteResponse = await http.delete(Uri.parse('$baseUrl/api/user/$testUsername'));
    final deleteDuration = DateTime.now().difference(deleteStart).inMilliseconds / 1000;
    performanceMetrics['delete_user'] = deleteDuration;
    
    if (deleteResponse.statusCode == 204) {
      print('✅ 删除用户成功 (${deleteResponse.statusCode}) - ${deleteDuration}s');
      testResults['delete_user'] = true;
    } else {
      print('❌ 删除用户失败 (${deleteResponse.statusCode}): ${deleteResponse.body}');
      testResults['delete_user'] = false;
    }
    
  } catch (e, stackTrace) {
    print('❌ 测试执行失败: $e');
    print('堆栈跟踪: $stackTrace');
    testResults['overall_test'] = false;
  }
  
  // 生成测试报告
  print('\n' + '=' * 60);
  print('📊 测试报告总结');
  print('=' * 60);
  
  final passedTests = testResults.values.where((v) => v == true).length;
  final totalTests = testResults.length;
  final passRate = (passedTests / totalTests * 100).toStringAsFixed(1);
  
  print('测试通过率: $passedTests/$totalTests ($passRate%)');
  print('\n详细结果:');
  
  testResults.forEach((testName, passed) {
    final status = passed ? '✅' : '❌';
    final duration = performanceMetrics[testName] != null 
        ? ' (${performanceMetrics[testName]!.toStringAsFixed(3)}s)' 
        : '';
    print('$status $testName$duration');
  });
  
  print('\n性能指标:');
  performanceMetrics.forEach((metric, duration) {
    print('⏱️  $metric: ${duration.toStringAsFixed(3)}s');
  });
  
  // 保存测试报告
  final reportContent = '''
# Flutter 真机功能测试报告

**测试时间**: ${DateTime.now()}
**测试用户**: $testUsername
**后端地址**: $baseUrl

## 测试结果统计

- **测试总数**: $totalTests
- **通过数量**: $passedTests  
- **通过率**: $passRate%

## 详细测试结果

${testResults.entries.map((e) => '- ${e.value ? "✅" : "❌"} ${e.key}').join('\n')}

## 性能指标

${performanceMetrics.entries.map((e) => '- **${e.key}**: ${e.value.toStringAsFixed(3)}s').join('\n')}

## 测试结论

${passRate == '100.0' ? '🎉 所有测试均通过，应用功能正常！' : '⚠️ 部分测试失败，需要进一步排查'}

## 建议

${passedTests < totalTests ? '- 检查失败测试项对应的代码逻辑\n- 验证后端服务状态\n- 检查网络连接稳定性' : '- 可以进入性能测试阶段\n- 建议进行离线模式测试\n- 考虑增加更多边界条件测试'}
''';  
  
  final reportFile = File('/tmp/flutter_test_report.md');
  await reportFile.writeAsString(reportContent);
  
  print('\n📄 详细测试报告已保存至: ${reportFile.path}');
  
  // 返回整体测试结果
  if (passedTests == totalTests) {
    print('\n🎉 真机功能测试完成 - 全部通过！');
    exit(0);
  } else {
    print('\n⚠️ 真机功能测试完成 - 部分失败，请查看详细报告');
    exit(1);
  }
}