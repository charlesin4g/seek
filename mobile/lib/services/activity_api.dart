class ActivityApi {
  ActivityApi();

  /// 离线模式：不再从服务端加载活动数据，返回空列表
  Future<List<Map<String, dynamic>>> getMyActivities() async {
    return <Map<String, dynamic>>[];
  }
}
