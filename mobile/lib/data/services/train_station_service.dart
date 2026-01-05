import 'package:mobile/data/daos/train_station_dao.dart';
import 'package:mobile/data/entities/train_station.dart';

class TrainStationService {
  final TrainStationDao _trainStationDao;

  TrainStationService(this._trainStationDao);

  // 获取所有火车站
  Future<List<TrainStation>> getAllStations() async {
    return await _trainStationDao.findAll();
  }

  // 根据ID获取火车站
  Future<TrainStation?> getStationById(int id) async {
    return await _trainStationDao.findById(id);
  }

  // 根据代码获取火车站
  Future<TrainStation?> getStationByCode(String code) async {
    return await _trainStationDao.findByCode(code);
  }

  // 搜索火车站
  Future<List<TrainStation>> searchStations(String keyword) async {
    return await _trainStationDao.search('%$keyword%');
  }

  // 根据城市获取火车站
  Future<List<TrainStation>> getStationsByCity(String city) async {
    return await _trainStationDao.findByCity(city);
  }

  // 根据省份获取火车站
  Future<List<TrainStation>> getStationsByProvince(String province) async {
    return await _trainStationDao.findByProvince(province);
  }

  // 根据铁路局获取火车站
  Future<List<TrainStation>> getStationsByRailwayAdministration(String administration) async {
    return await _trainStationDao.findByRailwayAdministration(administration);
  }

  // 获取所有省份
  Future<List<String>> getAllProvinces() async {
    return await _trainStationDao.getAllProvinces();
  }

  // 根据省份获取城市列表
  Future<List<String>> getCitiesByProvince(String province) async {
    return await _trainStationDao.getCitiesByProvince(province);
  }

  // 获取所有铁路局列表
  Future<List<String>> getAllRailwayAdministrations() async {
    return await _trainStationDao.getAllRailwayAdministrations();
  }

  // 增加访问次数
  Future<void> incrementVisitCount(int id) async {
    return await _trainStationDao.incrementVisitCount(id);
  }

  // 获取最常访问的车站
  Future<List<TrainStation>> getMostVisitedStations({int limit = 10}) async {
    return await _trainStationDao.getMostVisited(limit);
  }

  // 新增火车站
  Future<int> addStation({
    required String code,
    required String name,
    String? englishName,
    String? alias,
    required String city,
    required String province,
    String? district,
    String? railwayAdministration,
    double? longitude,
    double? latitude,
    String? notes,
  }) async {
    final station = TrainStation(
      code: code,
      name: name,
      englishName: englishName,
      alias: alias,
      city: city,
      province: province,
      district: district,
      railwayAdministration: railwayAdministration,
      longitude: longitude,
      latitude: latitude,
      notes: notes,
      visitCount: 0,
    );
    return await _trainStationDao.insert(station);
  }

  // 批量导入火车站
  Future<void> importStations(List<TrainStation> stations) async {
    await _trainStationDao.insertAll(stations);
  }

  // 更新火车站信息
  Future<int> updateStation({
    required int id,
    required String code,
    required String name,
    String? englishName,
    String? alias,
    required String city,
    required String province,
    String? district,
    String? railwayAdministration,
    double? longitude,
    double? latitude,
    String? notes,
  }) async {
    // 首先获取现有车站以保留visitCount
    final existingStation = await _trainStationDao.findById(id);
    if (existingStation == null) {
      return 0;
    }

    final station = TrainStation(
      id: id,
      code: code,
      name: name,
      englishName: englishName,
      alias: alias,
      city: city,
      province: province,
      district: district,
      railwayAdministration: railwayAdministration,
      longitude: longitude,
      latitude: latitude,
      notes: notes,
      visitCount: existingStation.visitCount,
    );
    return await _trainStationDao.update(station);
  }

  // 删除火车站
  Future<void> deleteStation(int id) async {
    return await _trainStationDao.deleteById(id);
  }

  // 删除所有火车站
  Future<void> deleteAllStations() async {
    return await _trainStationDao.deleteAll();
  }

  // 获取车站总数
  Future<int?> getTotalCount() async {
    return await _trainStationDao.getCount();
  }

  // 获取省份车站数量
  Future<int?> getCountByProvince(String province) async {
    return await _trainStationDao.getCountByProvince(province);
  }

  // 获取城市车站数量
  Future<int?> getCountByCity(String city) async {
    return await _trainStationDao.getCountByCity(city);
  }

  // 批量操作：根据城市更新铁路局
  Future<void> updateRailwayAdministrationByCity(String city, String administration) async {
    final stations = await getStationsByCity(city);
    for (var station in stations) {
      final updatedStation = TrainStation(
        id: station.id,
        code: station.code,
        name: station.name,
        englishName: station.englishName,
        alias: station.alias,
        city: station.city,
        province: station.province,
        district: station.district,
        railwayAdministration: administration,
        longitude: station.longitude,
        latitude: station.latitude,
        notes: station.notes,
        visitCount: station.visitCount,
      );
      await _trainStationDao.update(updatedStation);
    }
  }

  // 验证车站信息是否完整
  bool isStationInfoComplete(TrainStation station) {
    return station.code.isNotEmpty &&
           station.name.isNotEmpty &&
           station.city.isNotEmpty &&
           station.province.isNotEmpty;
  }

  // 根据经纬度获取附近的车站
  Future<List<TrainStation>> getNearbyStations(double latitude, double longitude, double radiusInKm) async {
    final allStations = await getAllStations();
    final nearbyStations = <TrainStation>[];
    
    for (var station in allStations) {
      if (station.latitude != null && station.longitude != null) {
        final distance = _calculateDistance(
          latitude, longitude, 
          station.latitude!, station.longitude!
        );
        if (distance <= radiusInKm) {
          nearbyStations.add(station);
        }
      }
    }
    
    return nearbyStations;
  }

  // 计算两个坐标之间的距离
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // TODO 实现距离算法
    return 0.90;
  }
}