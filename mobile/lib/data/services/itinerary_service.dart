import 'package:mobile/data/daos/itinerary_dao.dart';
import 'package:mobile/data/entities/itinerary.dart';

class ItineraryService {
  final ItineraryDao _itineraryDao;

  ItineraryService(this._itineraryDao);

  // 获取所有行程
  Future<List<Itinerary>> getAllItineraries() async {
    return await _itineraryDao.findAll();
  }

  // 根据ID获取行程
  Future<Itinerary?> getItineraryById(int id) async {
    return await _itineraryDao.findById(id);
  }

  // 根据计划ID获取所有行程
  Future<List<Itinerary>> getItinerariesByPlan(int planId) async {
    return await _itineraryDao.findByPlanId(planId);
  }

  // 根据计划ID和第几天获取行程
  Future<List<Itinerary>> getItinerariesByPlanAndDay(int planId, int dayNumber) async {
    return await _itineraryDao.findByPlanIdAndDay(planId, dayNumber);
  }

  // 根据日期获取行程
  Future<List<Itinerary>> getItinerariesByDate(String date) async {
    return await _itineraryDao.findByDate(DateTime.parse(date));
  }

  // 根据时间范围获取行程
  Future<List<Itinerary>> getItinerariesByDateRange(String startDate, String endDate) async {
    return await _itineraryDao.findByDateRange(
      DateTime.parse(startDate),
      DateTime.parse(endDate),
    );
  }

  // 搜索行程
  Future<List<Itinerary>> searchItineraries(String keyword) async {
    return await _itineraryDao.search('%$keyword%');
  }

  // 获取某个计划的最大天数
  Future<int?> getMaxDayNumberByPlan(int planId) async {
    return await _itineraryDao.getMaxDayNumberByPlan(planId);
  }

  // 获取某个计划的总行程数
  Future<int?> getCountByPlan(int planId) async {
    return await _itineraryDao.getCountByPlan(planId);
  }

  // 获取某个计划的某天行程数
  Future<int?> getCountByPlanAndDay(int planId, int dayNumber) async {
    return await _itineraryDao.getCountByPlanAndDay(planId, dayNumber);
  }

  // 获取计划的行程天数
  Future<int?> getDayCountByPlan(int planId) async {
    return await _itineraryDao.getDayCountByPlan(planId);
  }

  // 检查某天是否有行程
  Future<bool?> hasItineraryOnDay(int planId, int dayNumber) async {
    return await _itineraryDao.hasItineraryOnDay(planId, dayNumber);
  }

  // 新增行程
  Future<int> addItinerary({
    required int planId,
    required int dayNumber,
    required String date,
    required String title,
    String? description,
    String? startTime,
    String? endTime,
    String? notes,
    int? order,
  }) async {
    // 如果未指定排序，自动计算
    int calculatedOrder = order ?? await _calculateNextOrder(planId, dayNumber);

    final itinerary = Itinerary(
      planId: planId,
      dayNumber: dayNumber,
      date: DateTime.parse(date),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      order: calculatedOrder, 
      itineraryType: '',
    );
    return await _itineraryDao.insert(itinerary);
  }

  // 批量添加行程
  Future<void> addItineraries(List<Itinerary> itineraries) async {
    await _itineraryDao.insertAll(itineraries);
  }

  // 更新行程
  Future<int> updateItinerary({
    required int id,
    required int planId,
    required int dayNumber,
    required String date,
    required String title,
    String? description,
    String? startTime,
    String? endTime,
    String? notes,
    int? order,
  }) async {
    final existingItinerary = await _itineraryDao.findById(id);
    if (existingItinerary == null) {
      return 0;
    }

    final itinerary = Itinerary(
      id: id,
      planId: planId,
      dayNumber: dayNumber,
      date: DateTime.parse(date),
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
      itineraryType: '',
      order: order ?? existingItinerary.order, 
    );
    return await _itineraryDao.update(itinerary);
  }

  // 更新行程排序
  Future<void> updateItineraryOrder(int id, int order) async {
    return await _itineraryDao.updateOrder(id, order);
  }

  // 交换两个行程的排序
  Future<void> swapItineraryOrder(int firstId, int secondId) async {
    return await _itineraryDao.swapOrder(firstId, secondId);
  }

  // 重新排序某天的行程
  Future<void> reorderItinerariesByDay(int planId, int dayNumber) async {
    return await _itineraryDao.reorderByDay(planId, dayNumber);
  }

  // 移动行程到另一天
  Future<int> moveItineraryToDay(int id, int newDayNumber) async {
    final itinerary = await _itineraryDao.findById(id);
    if (itinerary == null) {
      return 0;
    }

    // 获取新天的最大排序值
    final newOrder = await _calculateNextOrder(itinerary.planId, newDayNumber);
    
    final updatedItinerary = Itinerary(
      id: id,
      planId: itinerary.planId,
      dayNumber: newDayNumber,
      date: _adjustDateForDay(itinerary.date, newDayNumber - itinerary.dayNumber),
      title: itinerary.title,
      itineraryType: '',
      description: itinerary.description,
      startTime: itinerary.startTime,
      endTime: itinerary.endTime,
      notes: itinerary.notes,
      order: newOrder, 
    );
    
    return await _itineraryDao.update(updatedItinerary);
  }

  // 根据ID删除行程
  Future<void> deleteItineraryById(int id) async {
    return await _itineraryDao.deleteById(id);
  }

  // 根据计划ID删除所有行程
  Future<void> deleteItinerariesByPlan(int planId) async {
    return await _itineraryDao.deleteByPlanId(planId);
  }

  // 删除某天的所有行程
  Future<void> deleteItinerariesByPlanAndDay(int planId, int dayNumber) async {
    return await _itineraryDao.deleteByPlanIdAndDay(planId, dayNumber);
  }

  // 删除所有行程
  Future<void> deleteAllItineraries() async {
    return await _itineraryDao.deleteAll();
  }

  // 获取行程总数
  Future<int?> getTotalCount() async {
    return await _itineraryDao.getCount();
  }

  // 验证行程信息是否完整
  bool isItineraryInfoComplete(Itinerary itinerary) {
    return itinerary.planId > 0 &&
           itinerary.dayNumber > 0 &&
           itinerary.title.isNotEmpty;
  }

  // 验证时间格式
  bool isValidTimeFormat(String? time) {
    if (time == null || time.isEmpty) return true;
    final timeRegex = RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  // 验证开始时间和结束时间的逻辑
  bool isValidTimeRange(String? startTime, String? endTime) {
    if (startTime == null || endTime == null) return true;
    if (!isValidTimeFormat(startTime) || !isValidTimeFormat(endTime)) return false;
    
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    return endMinutes >= startMinutes;
  }

  // 计算下一个排序值
  Future<int> _calculateNextOrder(int planId, int dayNumber) async {
    final itineraries = await _itineraryDao.findByPlanIdAndDay(planId, dayNumber);
    if (itineraries.isEmpty) {
      return 0;
    }
    final maxOrder = itineraries.map((it) => it.order ?? 0).reduce((a, b) => a > b ? a : b);
    return maxOrder + 1;
  }

  // 调整日期
  DateTime _adjustDateForDay(DateTime originalDate, int dayDifference) {
    return originalDate.add(Duration(days: dayDifference));
  }

  // 获取行程的持续时间（小时）
  double? calculateDuration(Itinerary itinerary) {
    if (itinerary.startTime == null || itinerary.endTime == null) {
      return null;
    }
    
    if (!isValidTimeRange(itinerary.startTime, itinerary.endTime)) {
      return null;
    }
    
    final startParts = itinerary.startTime!.split(':');
    final endParts = itinerary.endTime!.split(':');
    
    final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
    
    return (endMinutes - startMinutes) / 60.0;
  }

  // 生成行程摘要
  String generateSummary(Itinerary itinerary) {
    final timeInfo = itinerary.startTime != null && itinerary.endTime != null
        ? '${itinerary.startTime}-${itinerary.endTime}'
        : '全天';
    
    return '第${itinerary.dayNumber}天 $timeInfo: ${itinerary.title}';
  }

  // 复制行程
  Future<int> copyItinerary(int id, {int? newDayNumber}) async {
    final itinerary = await _itineraryDao.findById(id);
    if (itinerary == null) {
      return 0;
    }
    
    final targetDayNumber = newDayNumber ?? itinerary.dayNumber;
    final newOrder = await _calculateNextOrder(itinerary.planId, targetDayNumber);
    
    return await addItinerary(
      planId: itinerary.planId,
      dayNumber: targetDayNumber,
      date: itinerary.date.toIso8601String().split('T')[0],
      title: '${itinerary.title} (副本)',
      description: itinerary.description,
      startTime: itinerary.startTime,
      endTime: itinerary.endTime,
      notes: itinerary.notes,
      order: newOrder,
    );
  }
}