class PhotoApi {
  PhotoApi();

  /// 离线模式：不再从服务端加载照片墙数据，返回空列表
  Future<List<String>> getMyPhotos({Duration timeout = const Duration(seconds: 3)}) async {
    return <String>[];
  }

  /// 离线模式：不支持直传上传，返回 null
  Future<String?> signPutUrl(String key) async {
    return null;
  }

  /// 离线模式：不再向服务端写入照片记录，直接返回
  Future<void> addPhotoRecord({
    required String owner,
    required String objectKey,
    String? title,
    String? description,
  }) async {}
}
