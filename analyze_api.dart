import 'dart:convert';
import 'dart:io';

void main() async {
  // 读取API文档
  final apiDocsFile = File('/tmp/api-docs.json');
  final apiDocsContent = await apiDocsFile.readAsString();
  final apiDocs = jsonDecode(apiDocsContent);
  
  // 提取后端API端点
  final backendEndpoints = <Map<String, dynamic>>[];
  final paths = apiDocs['paths'] as Map<String, dynamic>;
  
  paths.forEach((path, pathItem) {
    (pathItem as Map<String, dynamic>).forEach((method, operation) {
      if (operation is Map<String, dynamic>) {
        backendEndpoints.add({
          'path': path,
          'method': method.toUpperCase(),
          'operationId': operation['operationId'] ?? '',
          'tags': operation['tags'] ?? [],
          'parameters': operation['parameters'] ?? [],
          'requestBody': operation['requestBody'],
          'responses': operation['responses'] ?? {},
        });
      }
    });
  });
  
  print('=== 后端API端点 (${backendEndpoints.length}个) ===');
  for (final endpoint in backendEndpoints) {
    print('${endpoint['method']} ${endpoint['path']} - ${endpoint['operationId']}');
  }
  
  // 前端API调用清单
  final frontendCalls = [
    // 用户相关
    {'method': 'POST', 'path': '/api/user/login', 'source': 'user_api.dart'},
    {'method': 'GET', 'path': '/api/user/{username}', 'source': 'user_api.dart'},
    {'method': 'POST', 'path': '/api/user', 'source': 'user_api.dart'},
    {'method': 'PUT', 'path': '/api/user/{username}', 'source': 'user_api.dart'},
    {'method': 'DELETE', 'path': '/api/user/{username}', 'source': 'user_api.dart'},
    
    // 活动相关
    {'method': 'GET', 'path': '/api/activity/owner/{owner}', 'source': 'activity_api.dart'},
    
    // 票据相关
    {'method': 'POST', 'path': '/api/ticket/add', 'source': 'ticket_api.dart'},
    {'method': 'GET', 'path': '/api/ticket/owner', 'source': 'ticket_api.dart'},
    {'method': 'PUT', 'path': '/api/ticket/edit', 'source': 'ticket_api.dart'},
    {'method': 'GET', 'path': '/api/ticket/airport', 'source': 'ticket_api.dart'},
    
    // 装备相关
    {'method': 'PUT', 'path': '/api/gear/add', 'source': 'gear_api.dart'},
    {'method': 'GET', 'path': '/api/gear/brands', 'source': 'gear_api.dart'},
    {'method': 'GET', 'path': '/api/gear/category', 'source': 'gear_api.dart'},
    {'method': 'GET', 'path': '/api/gear/my', 'source': 'gear_api.dart'},
    {'method': 'POST', 'path': '/api/gear/edit', 'source': 'gear_api.dart'},
    
    // 照片相关
    {'method': 'GET', 'path': '/api/photo/owner/{owner}', 'source': 'photo_api.dart'},
    {'method': 'GET', 'path': '/api/oss/sign-put', 'source': 'photo_api.dart'},
    {'method': 'POST', 'path': '/api/photo/add', 'source': 'photo_api.dart'},
    
    // 站点相关
    {'method': 'POST', 'path': '/api/ticket/station/add', 'source': 'station_api.dart'},
    {'method': 'GET', 'path': '/api/ticket/station', 'source': 'station_api.dart'},
    {'method': 'GET', 'path': '/api/ticket/station/search', 'source': 'station_api.dart'},
  ];
  
  print('\n=== 前端API调用 (${frontendCalls.length}个) ===');
  for (final call in frontendCalls) {
    print('${call['method']} ${call['path']} - ${call['source']}');
  }
  
  // 对比分析
  print('\n=== 接口差异分析 ===');
  
  final mismatches = <Map<String, dynamic>>[];
  
  for (final frontendCall in frontendCalls) {
    final frontendMethod = frontendCall['method'];
    final frontendPath = frontendCall['path'];
    
    // 尝试匹配后端端点
    bool found = false;
    
    for (final backendEndpoint in backendEndpoints) {
      final backendMethod = backendEndpoint['method'];
      final backendPath = backendEndpoint['path'];
      
      // 简单的路径匹配逻辑
      if (frontendMethod == backendMethod && pathsMatch(frontendPath, backendPath)) {
        found = true;
        break;
      }
    }
    
    if (!found) {
      mismatches.add({
        'frontend': frontendCall,
        'issue': '未找到匹配的后端端点',
        'suggestion': '请检查后端是否实现了该接口'
      });
    }
  }
  
  // 输出不匹配结果
  if (mismatches.isEmpty) {
    print('✅ 所有前端调用都能找到对应的后端端点');
  } else {
    print('❌ 发现 ${mismatches.length} 个不匹配项：');
    for (final mismatch in mismatches) {
      final frontend = mismatch['frontend'];
      print('\n问题：${mismatch['issue']}');
      print('前端调用：${frontend['method']} ${frontend['path']} (${frontend['source']})');
      print('建议：${mismatch['suggestion']}');
    }
  }
  
  // 生成详细报告文件
  final reportFile = File('/tmp/api_comparison_report.md');
  final reportBuffer = StringBuffer();
  
  reportBuffer.writeln('# API接口匹配检查报告');
  reportBuffer.writeln('生成时间：${DateTime.now()}');
  reportBuffer.writeln();
  
  reportBuffer.writeln('## 统计信息');
  reportBuffer.writeln('- 后端API端点总数：${backendEndpoints.length}');
  reportBuffer.writeln('- 前端API调用总数：${frontendCalls.length}');
  reportBuffer.writeln('- 不匹配数量：${mismatches.length}');
  reportBuffer.writeln();
  
  if (mismatches.isNotEmpty) {
    reportBuffer.writeln('## ❌ 不匹配接口清单');
    reportBuffer.writeln();
    
    for (final mismatch in mismatches) {
      final frontend = mismatch['frontend'];
      reportBuffer.writeln('### ${frontend['method']} ${frontend['path']}');
      reportBuffer.writeln('- **来源文件**：${frontend['source']}');
      reportBuffer.writeln('- **问题描述**：${mismatch['issue']}');
      reportBuffer.writeln('- **修改建议**：${mismatch['suggestion']}');
      reportBuffer.writeln();
    }
  } else {
    reportBuffer.writeln('## ✅ 检查结果');
    reportBuffer.writeln('所有前端API调用都能找到对应的后端端点，接口匹配良好。');
  }
  
  reportBuffer.writeln('## 📋 后端API端点清单');
  reportBuffer.writeln();
  for (final endpoint in backendEndpoints) {
    reportBuffer.writeln('- **${endpoint['method']}** `${endpoint['path']}` - ${endpoint['operationId']}');
  }
  
  reportBuffer.writeln();
  reportBuffer.writeln('## 📋 前端API调用清单');
  reportBuffer.writeln();
  for (final call in frontendCalls) {
    reportBuffer.writeln('- **${call['method']}** `${call['path']}` - ${call['source']}');
  }
  
  await reportFile.writeAsString(reportBuffer.toString());
  print('\n📄 详细报告已保存至：${reportFile.path}');
}

bool pathsMatch(String? frontendPath, String? backendPath) {
  if (frontendPath == null || backendPath == null) return false;
  // 简单的路径匹配逻辑
  // 将路径参数 {param} 替换为通配符进行匹配
  final normalizedFrontend = frontendPath.replaceAll(RegExp(r'\{[^}]+\}'), '[^/]+');
  final normalizedBackend = backendPath.replaceAll(RegExp(r'\{[^}]+\}'), '[^/]+');
  
  return RegExp('^$normalizedFrontend\$').hasMatch(backendPath) ||
         RegExp('^$normalizedBackend\$').hasMatch(frontendPath) ||
         frontendPath == backendPath;
}