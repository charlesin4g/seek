import 'package:mobile/data/daos/plan_dao.dart';
import 'package:mobile/data/entities/plan.dart';

class PlanService {
  final PlanDao _planDao;

  PlanService(this._planDao);

  // 获取所有计划
  Future<List<Plan>> getAllPlans() async {
    return await _planDao.findAll();
  }

  // 根据ID获取计划
  Future<Plan?> getPlanById(int id) async {
    return await _planDao.findById(id);
  }

  // 搜索计划
  Future<List<Plan>> searchPlans(String keyword) async {
    return await _planDao.search('%$keyword%');
  }

  // 根据状态获取计划
  Future<List<Plan>> getPlansByStatus(String status) async {
    return await _planDao.findByStatus(status);
  }

  // 根据目的地获取计划
  Future<List<Plan>> getPlansByDestination(String destination) async {
    return await _planDao.findByDestination('%$destination%');
  }

  // 根据日期范围获取计划
  Future<List<Plan>> getPlansByDateRange(String startDate, String endDate) async {
    return await _planDao.findByDateRange(
      DateTime.parse(startDate),
      DateTime.parse(endDate),
    );
  }

  // 获取即将开始的计划
  Future<List<Plan>> getUpcomingPlans() async {
    return await _planDao.findUpcoming(DateTime.now());
  }

  // 获取已完成的计划
  Future<List<Plan>> getPastPlans() async {
    return await _planDao.findPast(DateTime.now());
  }

  // 获取当前进行中的计划
  Future<List<Plan>> getCurrentPlans() async {
    return await _planDao.findCurrent(DateTime.now());
  }

  // 新增计划
  Future<int> addPlan({
    required String name,
    String? description,
    required String startDate,
    required String endDate,
    double? budget,
    required String destination,
    double? destinationLat,
    double? destinationLng,
    String? participants,
    String? images,
    String? starImage,
    required String status,
    String? notes,
  }) async {
    final plan = Plan(
      name: name,
      description: description,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      budget: budget,
      destination: destination,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      participants: participants,
      images: images,
      starImage: starImage,
      status: status,
      notes: notes,
    );
    return await _planDao.insert(plan);
  }

  // 更新计划
  Future<int> updatePlan({
    required int id,
    required String name,
    String? description,
    required String startDate,
    required String endDate,
    double? budget,
    double? actualCost,
    required String destination,
    double? destinationLat,
    double? destinationLng,
    String? participants,
    String? images,
    String? starImage,
    required String status,
    String? notes,
  }) async {
    final existingPlan = await _planDao.findById(id);
    if (existingPlan == null) {
      return 0;
    }

    final plan = Plan(
      id: id,
      name: name,
      description: description,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      budget: budget,
      actualCost: actualCost ?? existingPlan.actualCost,
      destination: destination,
      destinationLat: destinationLat,
      destinationLng: destinationLng,
      participants: participants,
      images: images,
      starImage: starImage,
      status: status,
      notes: notes,
    );
    return await _planDao.update(plan);
  }

  // 更新计划状态
  Future<void> updatePlanStatus(int id, String status) async {
    return await _planDao.updateStatus(id, status);
  }

  // 更新实际花费
  Future<void> updateActualCost(int id, double actualCost) async {
    if (actualCost < 0) {
      throw ArgumentError('Actual cost cannot be negative');
    }
    return await _planDao.updateActualCost(id, actualCost);
  }

  // 更新封面图片
  Future<void> updateStarImage(int id, String starImage) async {
    return await _planDao.updateStarImage(id, starImage);
  }

  // 更新图片集合
  Future<void> updateImages(int id, String images) async {
    return await _planDao.updateImages(id, images);
  }

  // 根据ID删除计划
  Future<void> deletePlanById(int id) async {
    return await _planDao.deleteById(id);
  }

  // 删除所有计划
  Future<void> deleteAllPlans() async {
    return await _planDao.deleteAll();
  }

  // 获取计划总数
  Future<int?> getTotalCount() async {
    return await _planDao.getCount();
  }

  // 根据状态获取计划数量
  Future<int?> getCountByStatus(String status) async {
    return await _planDao.getCountByStatus(status);
  }

  // 获取下一个即将开始的计划
  Future<Plan?> getNextUpcomingPlan() async {
    return await _planDao.getNextUpcomingPlan(DateTime.now());
  }

  // 获取当前进行中的计划
  Future<Plan?> getCurrentPlan() async {
    return await _planDao.getCurrentPlan(DateTime.now());
  }

  // 计算计划总天数
  int calculateTotalDays(Plan plan) {
    return plan.endDate.difference(plan.startDate).inDays + 1;
  }

  // 计算计划已进行天数
  int calculateDaysElapsed(Plan plan) {
    final now = DateTime.now();
    if (now.isBefore(plan.startDate)) {
      return 0;
    }
    final endDate = now.isBefore(plan.endDate) ? now : plan.endDate;
    return endDate.difference(plan.startDate).inDays + 1;
  }

  // 计算计划剩余天数
  int calculateDaysRemaining(Plan plan) {
    final now = DateTime.now();
    if (now.isAfter(plan.endDate)) {
      return 0;
    }
    return plan.endDate.difference(now).inDays;
  }

  // 验证计划信息是否完整
  bool isPlanInfoComplete(Plan plan) {
    return plan.name.isNotEmpty &&
           plan.destination.isNotEmpty &&
           plan.status.isNotEmpty;
  }

  // 获取预算使用率
  double? calculateBudgetUsage(Plan plan) {
    if (plan.budget == null || plan.budget == 0 || plan.actualCost == null) {
      return null;
    }
    return (plan.actualCost! / plan.budget! * 100);
  }

  // 解析参与人员JSON
  List<String>? parseParticipants(Plan plan) {
    if (plan.participants == null || plan.participants!.isEmpty) {
      return null;
    }
    try {
      // 这里需要实际的JSON解析
      // 例如: return jsonDecode(plan.participants!);
      return null;
    } catch (e) {
      return null;
    }
  }

  // 解析图片JSON
  List<String>? parseImages(Plan plan) {
    if (plan.images == null || plan.images!.isEmpty) {
      return null;
    }
    try {
      // 这里需要实际的JSON解析
      // 例如: return jsonDecode(plan.images!);
      return null;
    } catch (e) {
      return null;
    }
  }
}