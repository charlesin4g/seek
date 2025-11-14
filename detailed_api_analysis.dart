import 'dart:convert';
import 'dart:io';

void main() async {
  // 读取API文档
  final apiDocsFile = File('/tmp/api-docs.json');
  final apiDocsContent = await apiDocsFile.readAsString();
  final apiDocs = jsonDecode(apiDocsContent);
  
  print('# 🔍 API接口全面匹配检查报告');
  print('生成时间：${DateTime.now()}');
  print('');
  
  // 1. 基础统计
  final paths = apiDocs['paths'] as Map<String, dynamic>;
  int totalBackendEndpoints = 0;
  paths.forEach((path, pathItem) {
    totalBackendEndpoints += (pathItem as Map<String, dynamic>).length;
  });
  
  print('## 📊 基础统计');
  print('- 后端API端点总数：$totalBackendEndpoints');
  print('- 前端服务类数量：7个 (user_api, activity_api, ticket_api, gear_api, photo_api, station_api, sync_service)');
  print('');
  
  // 2. 详细对比分析
  print('## 🔍 详细对比分析');
  print('');
  
  // 分析每个前端服务
  analyzeUserApi(apiDocs);
  analyzeActivityApi(apiDocs);
  analyzeTicketApi(apiDocs);
  analyzeGearApi(apiDocs);
  analyzePhotoApi(apiDocs);
  analyzeStationApi(apiDocs);
  analyzeSyncService(apiDocs);
  
  // 3. 总结和建议
  print('## 📋 总结和建议');
  print('');
  print('### ✅ 匹配良好的接口');
  print('- 用户登录：POST /api/user/login');
  print('- 获取用户信息：GET /api/user/{username}');
  print('- 活动查询：GET /api/activity/owner/{owner}');
  print('- 票据管理：大部分接口匹配');
  print('- 装备管理：大部分接口匹配');
  print('- 照片管理：大部分接口匹配');
  print('- 站点管理：大部分接口匹配');
  print('');
  
  print('### ❌ 发现的问题');
  print('1. **用户管理接口缺失**');
  print('   - 前端调用了 POST /api/user (创建用户)');
  print('   - 前端调用了 PUT /api/user/{username} (更新用户)');
  print('   - 前端调用了 DELETE /api/user/{username} (删除用户)');
  print('   - **后端缺失这些接口**');
  print('');
  print('2. **HTTP方法不一致**');
  print('   - 装备添加：前端使用 PUT /api/gear/add，后端使用 POST /api/gear/add');
  print('   - 装备编辑：前端使用 POST /api/gear/edit?gearId=，后端使用 POST /api/gear/edit');
  print('   - 票据编辑：前端使用 PUT /api/ticket/edit?ticketId=，后端使用 PUT /api/ticket/edit');
  print('');
  print('3. **参数传递方式差异**');
  print('   - 部分接口前端使用查询参数，后端可能使用路径参数');
  print('   - 需要统一参数传递方式');
  print('');
  
  print('### 🔧 修改建议');
  print('1. **后端需要补充的接口**');
  print('   - POST /api/user - 创建用户');
  print('   - PUT /api/user/{username} - 更新用户信息');
  print('   - DELETE /api/user/{username} - 删除用户');
  print('');
  print('2. **前端需要调整的接口**');
  print('   - 装备添加：改为 POST /api/gear/add');
  print('   - 统一参数传递方式，保持一致性');
  print('');
  print('3. **建议的优先级**');
  print('   - **高优先级**：补充用户管理接口（影响核心功能）');
  print('   - **中优先级**：统一HTTP方法和参数传递方式');
  print('   - **低优先级**：完善错误处理和响应格式');
}

void analyzeUserApi(Map<String, dynamic> apiDocs) {
  print('### 👤 用户API (user_api.dart)');
  print('');
  
  final endpoints = [
    {'method': 'POST', 'path': '/api/user/login', 'description': '用户登录'},
    {'method': 'GET', 'path': '/api/user/{username}', 'description': '获取用户信息'},
    {'method': 'POST', 'path': '/api/user', 'description': '创建用户'},
    {'method': 'PUT', 'path': '/api/user/{username}', 'description': '更新用户'},
    {'method': 'DELETE', 'path': '/api/user/{username}', 'description': '删除用户'},
  ];
  
  for (final endpoint in endpoints) {
    final result = checkEndpoint(apiDocs, endpoint['method']!, endpoint['path']!);
    print('- **${endpoint['description']}**: ${endpoint['method']} ${endpoint['path']}');
    print('  - 状态: ${result['status']}');
    if (result['details'] != null) {
      print('  - 详情: ${result['details']}');
    }
    print('');
  }
}

void analyzeActivityApi(Map<String, dynamic> apiDocs) {
  print('### 🏃 活动API (activity_api.dart)');
  print('');
  
  final result = checkEndpoint(apiDocs, 'GET', '/api/activity/owner/{owner}');
  print('- **获取用户活动列表**: GET /api/activity/owner/{owner}');
  print('  - 状态: ${result['status']}');
  if (result['details'] != null) {
    print('  - 详情: ${result['details']}');
  }
  print('');
}

void analyzeTicketApi(Map<String, dynamic> apiDocs) {
  print('### 🎫 票据API (ticket_api.dart)');
  print('');
  
  final endpoints = [
    {'method': 'POST', 'path': '/api/ticket/add', 'description': '添加票据'},
    {'method': 'GET', 'path': '/api/ticket/owner', 'description': '获取用户票据'},
    {'method': 'PUT', 'path': '/api/ticket/edit', 'description': '编辑票据'},
    {'method': 'GET', 'path': '/api/ticket/airport', 'description': '获取机场信息'},
  ];
  
  for (final endpoint in endpoints) {
    final result = checkEndpoint(apiDocs, endpoint['method']!, endpoint['path']!);
    print('- **${endpoint['description']}**: ${endpoint['method']} ${endpoint['path']}');
    print('  - 状态: ${result['status']}');
    if (result['details'] != null) {
      print('  - 详情: ${result['details']}');
    }
    print('');
  }
}

void analyzeGearApi(Map<String, dynamic> apiDocs) {
  print('### 🎒 装备API (gear_api.dart)');
  print('');
  
  final endpoints = [
    {'method': 'PUT', 'path': '/api/gear/add', 'description': '添加装备'},
    {'method': 'GET', 'path': '/api/gear/brands', 'description': '获取品牌列表'},
    {'method': 'GET', 'path': '/api/gear/category', 'description': '获取分类列表'},
    {'method': 'GET', 'path': '/api/gear/my', 'description': '获取我的装备'},
    {'method': 'POST', 'path': '/api/gear/edit', 'description': '编辑装备'},
  ];
  
  for (final endpoint in endpoints) {
    final result = checkEndpoint(apiDocs, endpoint['method']!, endpoint['path']!);
    print('- **${endpoint['description']}**: ${endpoint['method']} ${endpoint['path']}');
    print('  - 状态: ${result['status']}');
    if (result['details'] != null) {
      print('  - 详情: ${result['details']}');
    }
    print('');
  }
}

void analyzePhotoApi(Map<String, dynamic> apiDocs) {
  print('### 📸 照片API (photo_api.dart)');
  print('');
  
  final endpoints = [
    {'method': 'GET', 'path': '/api/photo/owner/{owner}', 'description': '获取用户照片'},
    {'method': 'GET', 'path': '/api/oss/sign-put', 'description': '获取上传签名'},
    {'method': 'POST', 'path': '/api/photo/add', 'description': '添加照片记录'},
  ];
  
  for (final endpoint in endpoints) {
    final result = checkEndpoint(apiDocs, endpoint['method']!, endpoint['path']!);
    print('- **${endpoint['description']}**: ${endpoint['method']} ${endpoint['path']}');
    print('  - 状态: ${result['status']}');
    if (result['details'] != null) {
      print('  - 详情: ${result['details']}');
    }
    print('');
  }
}

void analyzeStationApi(Map<String, dynamic> apiDocs) {
  print('### 🚉 站点API (station_api.dart)');
  print('');
  
  final endpoints = [
    {'method': 'POST', 'path': '/api/ticket/station/add', 'description': '添加站点'},
    {'method': 'GET', 'path': '/api/ticket/station', 'description': '获取站点信息'},
    {'method': 'GET', 'path': '/api/ticket/station/search', 'description': '搜索站点'},
  ];
  
  for (final endpoint in endpoints) {
    final result = checkEndpoint(apiDocs, endpoint['method']!, endpoint['path']!);
    print('- **${endpoint['description']}**: ${endpoint['method']} ${endpoint['path']}');
    print('  - 状态: ${result['status']}');
    if (result['details'] != null) {
      print('  - 详情: ${result['details']}');
    }
    print('');
  }
}

void analyzeSyncService(Map<String, dynamic> apiDocs) {
  print('### 🔄 同步服务 (sync_service.dart)');
  print('');
  
  final endpoints = [
    {'method': 'POST', 'path': '/api/ticket/add', 'description': '同步添加票据'},
    {'method': 'PUT', 'path': '/api/ticket/edit', 'description': '同步编辑票据'},
  ];
  
  for (final endpoint in endpoints) {
    final result = checkEndpoint(apiDocs, endpoint['method']!, endpoint['path']!);
    print('- **${endpoint['description']}**: ${endpoint['method']} ${endpoint['path']}');
    print('  - 状态: ${result['status']}');
    if (result['details'] != null) {
      print('  - 详情: ${result['details']}');
    }
    print('');
  }
}

Map<String, dynamic> checkEndpoint(Map<String, dynamic> apiDocs, String method, String path) {
  final paths = apiDocs['paths'] as Map<String, dynamic>;
  
  // 尝试精确匹配
  if (paths.containsKey(path)) {
    final pathItem = paths[path] as Map<String, dynamic>;
    if (pathItem.containsKey(method.toLowerCase())) {
      return {
        'status': '✅ 完全匹配',
        'details': '找到对应的后端端点'
      };
    }
  }
  
  // 尝试模糊匹配（考虑路径参数）
  for (final backendPath in paths.keys) {
    if (pathsMatch(path, backendPath)) {
      final pathItem = paths[backendPath] as Map<String, dynamic>;
      if (pathItem.containsKey(method.toLowerCase())) {
        return {
          'status': '✅ 路径匹配',
          'details': '路径参数匹配，找到对应端点: $backendPath'
        };
      }
    }
  }
  
  // 检查方法是否匹配但路径不匹配
  for (final backendPath in paths.keys) {
    final pathItem = paths[backendPath] as Map<String, dynamic>;
    if (pathItem.containsKey(method.toLowerCase())) {
      return {
        'status': '❌ 方法匹配但路径不匹配',
        'details': '找到相同方法的端点但路径不同: $backendPath'
      };
    }
  }
  
  return {
    'status': '❌ 未找到匹配',
    'details': '后端未实现该接口'
  };
}

bool pathsMatch(String frontendPath, String backendPath) {
  // 将路径参数 {param} 替换为正则表达式进行匹配
  final frontendPattern = frontendPath.replaceAllMapped(
    RegExp(r'\{([^}]+)\}'),
    (match) => '([^/]+)'
  );
  
  final backendPattern = backendPath.replaceAllMapped(
    RegExp(r'\{([^}]+)\}'),
    (match) => '([^/]+)'
  );
  
  return RegExp('^$frontendPattern\$').hasMatch(backendPath) ||
         RegExp('^$backendPattern\$').hasMatch(frontendPath);
}