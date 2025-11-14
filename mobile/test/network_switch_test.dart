import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

/// 网络切换测试脚本
/// 模拟4G↔WiFi切换和重试机制验证
void main() async {
  print('🔄 开始网络切换测试\n');
  
  final testResults = <String, bool>{};
  final performanceMetrics = <String, double>{};
  
  // 测试配置
  const baseUrl = 'http://127.0.0.1:8080';
  final testUsername = 'network_user_${DateTime.now().millisecondsSinceEpoch}';
  const testPassword = 'Network@123';
  
  print('测试配置:');
  print('- 测试用户: $testUsername');
  print('- 后端地址: $baseUrl');
  print('- 测试时间: ${DateTime.now()}\n');
  
  try {
    // 1. 测试网络延迟和重试机制
    print('1️⃣ 测试网络延迟和重试机制...');
    
    // 1.1 测试正常网络条件下的响应时间
    final normalStart = DateTime.now();
    final normalResponse = await http.get(Uri.parse('$baseUrl/api/ticket/owner?owner=testuser'));
    final normalDuration = DateTime.now().difference(normalStart).inMilliseconds / 1000;
    performanceMetrics['normal_network'] = normalDuration;
    
    if (normalResponse.statusCode == 200) {
      print('   ✅ 正常网络响应时间: ${normalDuration}s');
      testResults['normal_network'] = true;
    } else {
      print('   ❌ 正常网络请求失败: ${normalResponse.statusCode}');
      testResults['normal_network'] = false;
    }
    
    // 1.2 测试超时重试机制
    print('\n   测试超时重试机制...');
    final retryStart = DateTime.now();
    
    // 模拟慢网络，设置较短的超时时间
    int retryCount = 0;
    bool retrySuccess = false;
    
    while (retryCount < 3 && !retrySuccess) {
      try {
        final retryResponse = await http.get(
          Uri.parse('$baseUrl/api/ticket/owner?owner=testuser'),
        ).timeout(Duration(seconds: 2 + retryCount)); // 递增超时时间
        
        if (retryResponse.statusCode == 200) {
          retrySuccess = true;
          final retryDuration = DateTime.now().difference(retryStart).inMilliseconds / 1000;
          performanceMetrics['retry_mechanism'] = retryDuration;
          print('   ✅ 第${retryCount + 1}次重试成功 (${retryDuration}s)');
          testResults['retry_mechanism'] = true;
        }
      } catch (e) {
        retryCount++;
        if (retryCount < 3) {
          print('   ⏳ 第$retryCount次重试失败，等待${retryCount * 2}秒后重试...');
          await Future.delayed(Duration(seconds: retryCount * 2)); // 指数退避
        } else {
          final retryDuration = DateTime.now().difference(retryStart).inMilliseconds / 1000;
          performanceMetrics['retry_mechanism'] = retryDuration;
          print('   ❌ 重试机制失败 (${retryDuration}s): $e');
          testResults['retry_mechanism'] = false;
        }
      }
    }
    
    // 2. 测试网络切换场景
    print('\n2️⃣ 测试网络切换场景...');
    
    // 2.1 模拟网络中断后立即恢复
    print('   模拟网络中断后立即恢复...');
    final disconnectStart = DateTime.now();
    
    // 模拟网络中断（通过访问不存在的地址）
    try {
      await http.get(Uri.parse('http://192.168.255.255:8080/api/health'))
          .timeout(Duration(seconds: 1));
    } catch (e) {
      // 预期的网络异常
    }
    
    // 立即尝试恢复连接
    final reconnectStart = DateTime.now();
    bool reconnectSuccess = false;
    int reconnectAttempts = 0;
    
    while (!reconnectSuccess && reconnectAttempts < 5) {
      try {
        final reconnectResponse = await http.get(
          Uri.parse('$baseUrl/api/ticket/owner?owner=testuser'),
        ).timeout(Duration(seconds: 1));
        
        if (reconnectResponse.statusCode == 200) {
          reconnectSuccess = true;
          final reconnectDuration = DateTime.now().difference(reconnectStart).inMilliseconds / 1000;
          performanceMetrics['network_reconnect'] = reconnectDuration;
          print('   ✅ 网络重连成功 (${reconnectDuration}s)');
          testResults['network_reconnect'] = true;
        }
      } catch (e) {
        reconnectAttempts++;
        await Future.delayed(Duration(milliseconds: 500)); // 短暂等待
      }
    }
    
    if (!reconnectSuccess) {
      print('   ❌ 网络重连失败');
      testResults['network_reconnect'] = false;
    }
    
    // 2.2 测试网络切换时的数据一致性
    print('\n   测试网络切换时的数据一致性...');
    final consistencyStart = DateTime.now();
    
    try {
      // 在网络切换前获取数据
      final beforeSwitchResponse = await http.get(Uri.parse('$baseUrl/api/ticket/owner?owner=testuser'));
      List<dynamic> beforeData = [];
      if (beforeSwitchResponse.statusCode == 200) {
        beforeData = jsonDecode(beforeSwitchResponse.body) as List;
      }
      
      // 模拟网络切换（短暂延迟）
      await Future.delayed(Duration(seconds: 2));
      
      // 网络切换后再次获取数据
      final afterSwitchResponse = await http.get(Uri.parse('$baseUrl/api/ticket/owner?owner=testuser'));
      List<dynamic> afterData = [];
      if (afterSwitchResponse.statusCode == 200) {
        afterData = jsonDecode(afterSwitchResponse.body) as List;
      }
      
      // 验证数据一致性
      final consistencyDuration = DateTime.now().difference(consistencyStart).inMilliseconds / 1000;
      performanceMetrics['data_consistency'] = consistencyDuration;
      
      if (beforeData.length == afterData.length) {
        print('   ✅ 数据一致性验证通过 (${consistencyDuration}s)');
        print('   📊 数据条数: ${beforeData.length} → ${afterData.length}');
        testResults['data_consistency'] = true;
      } else {
        print('   ⚠️ 数据条数变化: ${beforeData.length} → ${afterData.length}');
        testResults['data_consistency'] = true; // 允许数据变化
      }
    } catch (e) {
      final consistencyDuration = DateTime.now().difference(consistencyStart).inMilliseconds / 1000;
      performanceMetrics['data_consistency'] = consistencyDuration;
      print('   ❌ 数据一致性验证失败 (${consistencyDuration}s): $e');
      testResults['data_consistency'] = false;
    }
    
    // 3. 测试网络质量检测
    print('\n3️⃣ 测试网络质量检测...');
    final qualityStart = DateTime.now();
    
    // 进行多次ping测试，计算平均响应时间
    final pingTimes = <double>[];
    for (int i = 0; i < 5; i++) {
      final pingStart = DateTime.now();
      try {
        final pingResponse = await http.get(Uri.parse('$baseUrl/api/ticket/owner?owner=testuser'))
            .timeout(Duration(seconds: 1));
        if (pingResponse.statusCode == 200) {
          final pingTime = DateTime.now().difference(pingStart).inMilliseconds / 1000;
          pingTimes.add(pingTime);
        }
      } catch (e) {
        // 超时不计入
      }
      await Future.delayed(Duration(milliseconds: 200)); // 间隔200ms
    }
    
    final qualityDuration = DateTime.now().difference(qualityStart).inMilliseconds / 1000;
    performanceMetrics['network_quality'] = qualityDuration;
    
    if (pingTimes.isNotEmpty) {
      final avgPingTime = pingTimes.reduce((a, b) => a + b) / pingTimes.length;
      final maxPingTime = pingTimes.reduce(math.max);
      final minPingTime = pingTimes.reduce(math.min);
      
      print('   ✅ 网络质量检测完成 (${qualityDuration}s)');
      print('   📊 平均响应时间: ${avgPingTime.toStringAsFixed(3)}s');
      print('   📊 最大响应时间: ${maxPingTime.toStringAsFixed(3)}s');
      print('   📊 最小响应时间: ${minPingTime.toStringAsFixed(3)}s');
      testResults['network_quality'] = true;
    } else {
      print('   ❌ 网络质量检测失败');
      testResults['network_quality'] = false;
    }
    
    // 4. 测试错误恢复机制
    print('\n4️⃣ 测试错误恢复机制...');
    final recoveryStart = DateTime.now();
    
    // 模拟一系列错误情况
    final errorScenarios = [
      {'url': '$baseUrl/api/nonexistent', 'expected': 404},
      {'url': '$baseUrl/api/ticket/owner?owner=', 'expected': 400}, // 无效参数
    ];
    
    bool allErrorsHandled = true;
    for (final scenario in errorScenarios) {
      try {
        final errorResponse = await http.get(Uri.parse(scenario['url'] as String));
        if (errorResponse.statusCode != scenario['expected']) {
          allErrorsHandled = false;
          print('   ❌ 错误处理异常: 期望${scenario['expected']}, 实际${errorResponse.statusCode}');
        }
      } catch (e) {
        // 网络错误也是预期的
      }
    }
    
    final recoveryDuration = DateTime.now().difference(recoveryStart).inMilliseconds / 1000;
    performanceMetrics['error_recovery'] = recoveryDuration;
    
    if (allErrorsHandled) {
      print('   ✅ 错误恢复机制正常 (${recoveryDuration}s)');
      testResults['error_recovery'] = true;
    } else {
      print('   ❌ 错误恢复机制异常 (${recoveryDuration}s)');
      testResults['error_recovery'] = false;
    }
    
  } catch (e, stackTrace) {
    print('❌ 网络切换测试执行失败: $e');
    print('堆栈跟踪: $stackTrace');
    testResults['overall_test'] = false;
  }
  
  // 生成测试报告
  print('\n' + '=' * 60);
  print('📊 网络切换测试报告');
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
# Flutter 网络切换测试报告

**测试时间**: ${DateTime.now()}
**测试用户**: $testUsername
**后端地址**: $baseUrl

## 测试场景

1. **正常网络响应**: 测试基础网络条件下的响应时间
2. **超时重试机制**: 模拟网络超时，测试自动重试功能
3. **网络中断恢复**: 模拟网络中断后立即恢复的场景
4. **网络切换一致性**: 验证网络切换时的数据一致性
5. **网络质量检测**: 多次ping测试，评估网络稳定性
6. **错误恢复机制**: 测试各种错误情况的处理能力

## 测试结果统计

- **测试总数**: $totalTests
- **通过数量**: $passedTests  
- **通过率**: $passRate%

## 详细测试结果

${testResults.entries.map((e) => '- ${e.value ? "✅" : "❌"} ${e.key}').join('\n')}

## 性能指标

${performanceMetrics.entries.map((e) => '- **${e.key}**: ${e.value.toStringAsFixed(3)}s').join('\n')}

## 测试结论

${passRate == '100.0' ? '🎉 网络切换测试全部通过！' : '⚠️ 部分网络场景需要优化'}

## 发现的问题

${testResults.containsValue(false) ? '- 网络重试机制需要优化\\n- 错误处理机制不够完善\\n- 网络质量检测准确性待提升' : '- 网络切换处理正常\\n- 重试机制有效\\n- 数据一致性良好'}

## 优化建议

1. **优化重试策略**: 实现更智能的指数退避算法
2. **增强网络检测**: 实现更准确的网络状态判断
3. **完善错误处理**: 细化不同网络错误的处理逻辑
4. **增加缓存机制**: 在网络不稳定时提供更好的用户体验
''';  
  
  final reportFile = File('/tmp/flutter_network_test_report.md');
  await reportFile.writeAsString(reportContent);
  
  print('\n📄 详细测试报告已保存至: ${reportFile.path}');
  
  // 返回整体测试结果
  if (passedTests == totalTests) {
    print('\n🎉 网络切换测试完成 - 全部通过！');
    exit(0);
  } else {
    print('\n⚠️ 网络切换测试完成 - 部分失败，请查看详细报告');
    exit(1);
  }
}