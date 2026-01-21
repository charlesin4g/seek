import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile/data/entities/ticket.dart';
import 'package:mobile/data/services/ticket_service.dart';

import '../../config/app_colors.dart';
import '../../services/snapshot_service.dart';
import '../../services/station_api.dart';
import '../../services/storage_service.dart';
import '../../utils/responsive.dart';
import '../../widgets/form_field.dart';
import '../../widgets/section_card.dart';
import '../../widgets/selector_field.dart';
import 'widgets/ticket_summary_card.dart';

class EditTicketPage extends StatefulWidget {
  final Ticket ticket;
  const EditTicketPage({super.key, required this.ticket});

  @override
  State<EditTicketPage> createState() => _EditTicketPageState();
}

class _EditTicketPageState extends State<EditTicketPage> {
  final _formKey = GlobalKey<FormState>();

  // 基本类型
  late String _ticketKindDisplay; // 火车票/飞机票
  String get _ticketKindCode => _ticketKindDisplay == '飞机票' ? '飞机' : '火车';

  // 行程信息
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _departStationController =
      TextEditingController();
  final TextEditingController _arriveStationController =
      TextEditingController();
  late DateTime _departDateTime;
  late DateTime _arriveDateTime;
  int get _durationMinutes =>
      _arriveDateTime.difference(_departDateTime).inMinutes;

  // 车次/航班信息
  final TextEditingController _coachOrCabinController = TextEditingController();
  final TextEditingController _seatNoController = TextEditingController();
  String _seatTypeDisplay = '二等座';
  final TextEditingController _gateOrCheckinController =
      TextEditingController();
  final TextEditingController _waitingAreaController = TextEditingController();

  // 票务信息
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  String _ticketCategoryDisplay = '成人票';
  String _ticketStatusDisplay = '已支付';

  // 订单与乘客
  final TextEditingController _orderNoController = TextEditingController();
  final TextEditingController _passengerController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  late final TicketService _ticketService;
  // 输入框焦点与站点联想
  final FocusNode _departFocus = FocusNode();
  final FocusNode _arriveFocus = FocusNode();
  // 站点联想：使用共享 HttpClient，统一管理 baseUrl
  final StationApi _stationApi = StationApi();
  final List<Map<String, dynamic>> _departStationSuggestions = [];
  final List<Map<String, dynamic>> _arriveStationSuggestions = [];
  String _lastDepartStationQuery = '';
  String _lastArriveStationQuery = '';

  @override
  void initState() {
    super.initState();
    final t = widget.ticket;
    _ticketKindDisplay = t.type == '飞机' ? '飞机票' : '火车票';
    _codeController.text = t.transportNo;
    _departStationController.text = t.from;
    _arriveStationController.text = t.to;
    _departDateTime = t.departureTime;
    _arriveDateTime = t.arrivalTime;
    _coachOrCabinController.text = t.seatClass ?? '';
    _seatNoController.text = t.seatNo ?? '';
    _seatTypeDisplay = _ticketKindCode == '火车' ? '二等座' : '经济舱';
    _gateOrCheckinController.text = t.checkInPosition ?? '';
    _waitingAreaController.text = t.terminalArea ?? '';
    _priceController.text = t.price.toString();
    _departFocus.addListener(() {
      if (_ticketKindCode == '火车' && _departFocus.hasFocus) {
        _loadTopStations(isDepart: true);
      }
    });
    _arriveFocus.addListener(() {
      if (_ticketKindCode == '火车' && _arriveFocus.hasFocus) {
        _loadTopStations(isDepart: false);
      }
    });

    // 注册编辑票据表单快照提供者：离线切换前保存当前编辑状态
    final key = 'ticket:edit:${widget.ticket.id ?? widget.ticket.transportNo}';
    SnapshotService.instance.registerFormProvider(key, () async {
      return {
        'id': widget.ticket.id,
        'category': _ticketKindCode,
        'travelNo': _codeController.text.trim(),
        'fromPlace': _departStationController.text.trim(),
        'toPlace': _arriveStationController.text.trim(),
        'departureTime': _departDateTime.toIso8601String(),
        'arrivalTime': _arriveDateTime.toIso8601String(),
        'durationMinutes': _durationMinutes,
        'coachOrCabin': _coachOrCabinController.text.trim(),
        'seatNo': _seatNoController.text.trim(),
        'seatClass': _seatTypeDisplay,
        'gateOrCheckin': _gateOrCheckinController.text.trim(),
        'waitingArea': _waitingAreaController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'discount': _discountController.text.trim(),
        'ticketCategory': _ticketCategoryDisplay,
        'status': _ticketStatusDisplay,
        'orderNo': _orderNoController.text.trim(),
        'passengerName': _passengerController.text.trim(),
        'remark': _remarkController.text.trim(),
      };
    });
  }

  @override
  void dispose() {
    // 取消注册：页面销毁时移除提供者
    final key = 'ticket:edit:${widget.ticket.id ?? widget.ticket.transportNo}';
    SnapshotService.instance.unregisterFormProvider(key);
    _codeController.dispose();
    _departStationController.dispose();
    _arriveStationController.dispose();
    _coachOrCabinController.dispose();
    _seatNoController.dispose();
    _gateOrCheckinController.dispose();
    _waitingAreaController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _orderNoController.dispose();
    _passengerController.dispose();
    _remarkController.dispose();
    _departFocus.dispose();
    _arriveFocus.dispose();
    super.dispose();
  }

  Future<void> _handleStationInput(
    String text, {
    required bool isDepart,
  }) async {
    if (_ticketKindCode != '火车') return;
    final FocusNode focus = isDepart ? _departFocus : _arriveFocus;
    if (!focus.hasFocus) return;
    final String query = text.trim();
    if (query.isEmpty) return;

    if (isDepart && _lastDepartStationQuery == query) return;
    if (!isDepart && _lastArriveStationQuery == query) return;

    if (isDepart) {
      _lastDepartStationQuery = query;
    } else {
      _lastArriveStationQuery = query;
    }

    try {
      final results = await _stationApi.search(query);
      setState(() {
        if (isDepart) {
          _departStationSuggestions
            ..clear()
            ..addAll(results);
        } else {
          _arriveStationSuggestions
            ..clear()
            ..addAll(results);
        }
      });
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadTopStations({required bool isDepart}) async {
    if (_ticketKindCode != '火车') return;
    try {
      final results = await _stationApi.search('');
      final top = results.take(5).toList();
      setState(() {
        if (isDepart) {
          _departStationSuggestions
            ..clear()
            ..addAll(top);
        } else {
          _arriveStationSuggestions
            ..clear()
            ..addAll(top);
        }
      });
    } catch (_) {
      // ignore network errors
    }
  }

  Widget _buildStationSuggestionList({required bool isDepart}) {
    if (_ticketKindCode != '火车') {
      return const SizedBox.shrink();
    }

    final focus = isDepart ? _departFocus : _arriveFocus;
    if (!focus.hasFocus) {
      return const SizedBox.shrink();
    }

    final suggestions = isDepart
        ? _departStationSuggestions
        : _arriveStationSuggestions;
    final controller = isDepart
        ? _departStationController
        : _arriveStationController;

    Widget buildContent() {
      if (suggestions.isEmpty) {
        return ListTile(
          dense: true,
          title: const Text('未找到车站，新增？'),
          trailing: const Icon(Icons.add, color: AppColors.primaryDarkBlue),
          onTap: () => _showAddStationDialog(isDepart: isDepart),
        );
      }

      final tiles = <Widget>[];
      final maxItems = suggestions.length < 6 ? suggestions.length : 6;
      for (int i = 0; i < maxItems; i++) {
        final station = suggestions[i];
        final name = station['name']?.toString() ?? '';
        final city = station['city']?.toString() ?? '';
        final code = station['stationCode']?.toString() ?? '';
        final subtitleParts = <String>[];
        if (code.isNotEmpty) subtitleParts.add(code);
        if (city.isNotEmpty) subtitleParts.add(city);
        tiles.add(
          ListTile(
            dense: true,
            title: Text(name),
            subtitle: subtitleParts.isNotEmpty
                ? Text(subtitleParts.join(' · '))
                : null,
            onTap: () {
              final display = city.isNotEmpty ? '$name（$city）' : name;
              controller.text = display;
              controller.selection = TextSelection.collapsed(
                offset: controller.text.length,
              );
              setState(() => suggestions.clear());
            },
          ),
        );
        if (i != maxItems - 1) {
          tiles.add(const Divider(height: 0));
        }
      }
      return Column(children: tiles);
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite.withValues(alpha: 0.95),
        borderRadius: AppBorderRadius.large,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: const [AppShadows.light],
      ),
      child: Material(color: Colors.transparent, child: buildContent()),
    );
  }

  String _fmtDateTime(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDateTime({required bool isDepart}) async {
    final DateTime initial = isDepart ? _departDateTime : _arriveDateTime;
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    final DateTime picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() {
      if (isDepart) {
        _departDateTime = picked;
        if (_arriveDateTime.isBefore(_departDateTime)) {
          _arriveDateTime = _departDateTime.add(const Duration(hours: 2));
        }
      } else {
        _arriveDateTime = picked;
        if (_arriveDateTime.isBefore(_departDateTime)) {
          _arriveDateTime = _departDateTime.add(const Duration(hours: 2));
        }
      }
    });
  }

  void _showSeatTypePicker() {
    final options = _ticketKindCode == '火车'
        ? ['二等座', '一等座', '商务座', '硬座', '软座', '硬卧', '软卧']
        : ['经济舱', '超经济舱', '商务舱', '头等舱'];
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                '座位类型',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 0),
            ...options.map(
              (opt) => ListTile(
                title: Text(opt),
                onTap: () {
                  setState(() => _seatTypeDisplay = opt);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 保存与选择火车站（本地）
  Future<List<Map<String, dynamic>>> _loadSavedStations() async {
    final raw = await StorageService().getString('train_stations');
    if (raw == null || raw.isEmpty) return [];
    try {
      final parsed = jsonDecode(raw);
      if (parsed is List) {
        return parsed
            .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveTrainStation(Map<String, dynamic> station) async {
    try {
      final saved = await _stationApi.addStation(station);
      final list = await _loadSavedStations();
      list.add(saved.isEmpty ? station : saved);
      await StorageService().setString('train_stations', jsonEncode(list));
    } catch (_) {
      final list = await _loadSavedStations();
      list.add(station);
      await StorageService().setString('train_stations', jsonEncode(list));
    }
  }

  Future<void> _showAddStationDialog({required bool isDepart}) async {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final cityCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lonCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('新增火车站'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codeCtrl,
                decoration: const InputDecoration(
                  labelText: '站码*',
                  hintText: '如 SHH、BJP',
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: '站名*',
                  hintText: '如 北京南',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: cityCtrl,
                decoration: const InputDecoration(
                  labelText: '城市',
                  hintText: '如 北京',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: latCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '纬度',
                  hintText: '如 39.872',
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: lonCtrl,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '经度',
                  hintText: '如 116.407',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeCtrl.text.trim();
              final name = nameCtrl.text.trim();
              if (code.isEmpty || name.isEmpty) return;
              final city = cityCtrl.text.trim();
              final lat = double.tryParse(latCtrl.text.trim());
              final lon = double.tryParse(lonCtrl.text.trim());
              final station = {
                'stationCode': code.toUpperCase(),
                'name': name,
                if (city.isNotEmpty) 'city': city,
                if (lat != null) 'latitude': lat,
                if (lon != null) 'longitude': lon,
              };
              await _saveTrainStation(station);
              final ctrl = isDepart
                  ? _departStationController
                  : _arriveStationController;
              ctrl.text = city.isNotEmpty ? '$name（$city）' : name;
              ctrl.selection = TextSelection.collapsed(
                offset: ctrl.text.length,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    codeCtrl.dispose();
    nameCtrl.dispose();
    cityCtrl.dispose();
    latCtrl.dispose();
    lonCtrl.dispose();
  }

  Future<void> _updateTicket() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      await _ticketService.update(
        widget.ticket.id!,
        _ticketKindCode,
        _codeController.text.trim(),
        _departStationController.text.trim(),
        _arriveStationController.text.trim(),
        _departDateTime.toIso8601String(),
        _arriveDateTime.toIso8601String(),
        _coachOrCabinController.text.trim(),
        _seatNoController.text.trim(),
        price,
        '',
        '',
        '',
        '',
        '',
        '',
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('票据更新成功！'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      // TODO: handle error (更新失败)
    }
  }

  Widget _buildBottomActions({
    required BuildContext context,
    required String primaryLabel,
    required VoidCallback onPrimary,
  }) {
    final double buttonHeight = Responsive.responsiveButtonHeight(context);
    return SafeArea(
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.borderLight),
                  minimumSize: Size(double.infinity, buttonHeight),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppBorderRadius.large,
                  ),
                ),
                child: const Text('取消'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppBorderRadius.large,
                ),
                child: ElevatedButton(
                  onPressed: onPrimary,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: Size(double.infinity, buttonHeight),
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.large,
                    ),
                  ),
                  child: Text(
                    primaryLabel,
                    style: const TextStyle(
                      fontSize: AppFontSizes.bodyLarge,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            '编辑票据',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: ResponsiveContainer(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TicketSummaryCard(
                      ticketKindDisplay: _ticketKindDisplay,
                      codeController: _codeController,
                      departController: _departStationController,
                      arriveController: _arriveStationController,
                      priceController: _priceController,
                      departTime: _departDateTime,
                      arriveTime: _arriveDateTime,
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: '票种',
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                '票种类型',
                                style: TextStyle(
                                  fontSize: AppFontSizes.bodyLarge,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: _ticketKindDisplay,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: '火车票',
                                    child: Text('火车票'),
                                  ),
                                  DropdownMenuItem(
                                    value: '飞机票',
                                    child: Text('飞机票'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _ticketKindDisplay = value);
                                  }
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: AppBorderRadius.large,
                                    borderSide: BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppBorderRadius.large,
                                    borderSide: BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: AppBorderRadius.large,
                                    borderSide: BorderSide(
                                      color: AppColors.primaryBlue,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: '行程信息 (*为必填项)',
                      children: [
                        CustomFormField(
                          label: _ticketKindCode == '火车' ? '车次*' : '航班号*',
                          controller: _codeController,
                          hintText: _ticketKindCode == '火车'
                              ? '如 G1234'
                              : '如 MU5123',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          label: _ticketKindCode == '火车' ? '出发站*' : '出发机场*',
                          controller: _departStationController,
                          hintText: '请输入出发地',
                          focusNode: _departFocus,
                          onChanged: (v) =>
                              _handleStationInput(v, isDepart: true),
                        ),
                        _buildStationSuggestionList(isDepart: true),
                        const SizedBox(height: 16),
                        CustomFormField(
                          label: _ticketKindCode == '火车' ? '到达站*' : '到达机场*',
                          controller: _arriveStationController,
                          hintText: '请输入到达地',
                          focusNode: _arriveFocus,
                          onChanged: (v) =>
                              _handleStationInput(v, isDepart: false),
                        ),
                        _buildStationSuggestionList(isDepart: false),
                        const SizedBox(height: 16),
                        SelectorField(
                          label: _ticketKindCode == '火车' ? '出发时间' : '起飞时间',
                          value: _fmtDateTime(_departDateTime),
                          icon: Icons.schedule,
                          onTap: () => _pickDateTime(isDepart: true),
                        ),
                        const SizedBox(height: 16),
                        SelectorField(
                          label: _ticketKindCode == '火车' ? '到达时间' : '降落时间',
                          value: _fmtDateTime(_arriveDateTime),
                          icon: Icons.schedule,
                          onTap: () => _pickDateTime(isDepart: false),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                '行程时长',
                                style: TextStyle(
                                  fontSize: AppFontSizes.bodyLarge,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '$_durationMinutes分钟',
                                style: const TextStyle(
                                  fontSize: AppFontSizes.bodyLarge,
                                  color: AppColors.primaryDarkBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: _ticketKindCode == '火车' ? '车次信息' : '航班信息',
                      children: [
                        CustomFormField(
                          label: _ticketKindCode == '火车' ? '车厢' : '舱位',
                          controller: _coachOrCabinController,
                          hintText: _ticketKindCode == '火车' ? '如 5车' : '如 经济舱',
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          label: '座位号',
                          controller: _seatNoController,
                          hintText: '如 12A',
                        ),
                        const SizedBox(height: 16),
                        SelectorField(
                          label: '座位类型',
                          value: _seatTypeDisplay,
                          onTap: _showSeatTypePicker,
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          label: _ticketKindCode == '火车' ? '检票口' : '登机口/值机柜台',
                          controller: _gateOrCheckinController,
                          hintText: _ticketKindCode == '火车'
                              ? '如 A12'
                              : '如 B12/岛2',
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          label: _ticketKindCode == '火车' ? '候车区' : '航站楼',
                          controller: _waitingAreaController,
                          hintText: _ticketKindCode == '火车' ? '如 候车区A' : '如 T2',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: '票务信息',
                      children: [
                        CustomFormField(
                          label: '票价 CNY ¥',
                          controller: _priceController,
                          hintText: '请输入票价',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          label: '折扣',
                          controller: _discountController,
                          hintText: '如 98折、对座98折',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                '票类型',
                                style: TextStyle(
                                  fontSize: AppFontSizes.bodyLarge,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: _ticketCategoryDisplay,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: '成人票',
                                    child: Text('成人票'),
                                  ),
                                  DropdownMenuItem(
                                    value: '儿童票',
                                    child: Text('儿童票'),
                                  ),
                                  DropdownMenuItem(
                                    value: '学生票',
                                    child: Text('学生票'),
                                  ),
                                  DropdownMenuItem(
                                    value: '军人票',
                                    child: Text('军人票'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(
                                      () => _ticketCategoryDisplay = value,
                                    );
                                  }
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: AppBorderRadius.large,
                                    borderSide: BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppBorderRadius.large,
                                    borderSide: BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: AppBorderRadius.large,
                                    borderSide: BorderSide(
                                      color: AppColors.primaryBlue,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              flex: 2,
                              child: Text(
                                '票状态',
                                style: TextStyle(
                                  fontSize: AppFontSizes.bodyLarge,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<String>(
                                initialValue: _ticketStatusDisplay,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: '已支付',
                                    child: Text('已支付'),
                                  ),
                                  DropdownMenuItem(
                                    value: '未支付',
                                    child: Text('未支付'),
                                  ),
                                  DropdownMenuItem(
                                    value: '已退票',
                                    child: Text('已退票'),
                                  ),
                                  DropdownMenuItem(
                                    value: '已改签',
                                    child: Text('已改签'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(
                                      () => _ticketStatusDisplay = value,
                                    );
                                  }
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: AppBorderRadius.large,
                                    borderSide: BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppBorderRadius.large,
                                    borderSide: BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: AppBorderRadius.large,
                                    borderSide: BorderSide(
                                      color: AppColors.primaryBlue,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: '订单信息',
                      children: [
                        CustomFormField(
                          label: '取票号/订单号',
                          controller: _orderNoController,
                          hintText: '请输入订单号或取票号',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: '乘客信息',
                      children: [
                        CustomFormField(
                          label: '乘客姓名',
                          controller: _passengerController,
                          hintText: '请输入乘客姓名',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SectionCard(
                      title: '备注',
                      children: [
                        CustomFormField(
                          label: '备注',
                          controller: _remarkController,
                          hintText: '输入备注，如改签/退票说明',
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomActions(
          context: context,
          primaryLabel: '保存修改',
          onPrimary: _updateTicket,
        ),
      ),
    );
  }
}
