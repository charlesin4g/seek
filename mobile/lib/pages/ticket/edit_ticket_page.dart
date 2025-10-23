import 'package:flutter/material.dart';
import '../../widgets/section_card.dart';
import '../../widgets/form_field.dart';
import '../../widgets/selector_field.dart';
import '../../services/ticket_api.dart';
import '../../models/ticket.dart';
import '../../services/storage_service.dart';
import 'dart:convert';
import '../../services/station_api.dart';
import '../../services/http_client.dart';
import 'package:flutter/foundation.dart';

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
  String get _ticketKindCode => _ticketKindDisplay == '飞机票' ? 'flight' : 'train';

  // 行程信息
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _departStationController = TextEditingController();
  final TextEditingController _arriveStationController = TextEditingController();
  late DateTime _departDateTime;
  late DateTime _arriveDateTime;
  int get _durationMinutes => _arriveDateTime.difference(_departDateTime).inMinutes;

  // 车次/航班信息
  final TextEditingController _coachOrCabinController = TextEditingController();
  final TextEditingController _seatNoController = TextEditingController();
  String _seatTypeDisplay = '二等座';
  final TextEditingController _gateOrCheckinController = TextEditingController();
  final TextEditingController _waitingAreaController = TextEditingController();

  // 票务信息
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  String _ticketCategoryDisplay = '成人票';
  String _ticketStatusDisplay = '已支付';

  // 将后端/历史数据的码值映射为下拉显示文案，避免断言错误
  String _mapCategoryDisplay(String raw) {
    final r = raw.trim();
    switch (r.toLowerCase()) {
      case '1':
      case 'adult':
      case '成人票':
        return '成人票';
      case '2':
      case 'child':
      case '儿童票':
        return '儿童票';
      case '3':
      case 'student':
      case '学生票':
        return '学生票';
      case '4':
      case 'military':
      case '军人票':
        return '军人票';
      default:
        return ['成人票','儿童票','学生票','军人票'].contains(raw) ? raw : '成人票';
    }
  }

  String _mapStatusDisplay(String raw) {
    final r = raw.trim();
    switch (r.toLowerCase()) {
      case '1':
      case 'paid':
      case '已支付':
        return '已支付';
      case '2':
      case 'unpaid':
      case '未支付':
        return '未支付';
      case '3':
      case 'refunded':
      case '已退票':
        return '已退票';
      case '4':
      case 'changed':
      case '已改签':
        return '已改签';
      default:
        return ['已支付','未支付','已退票','已改签'].contains(raw) ? raw : '已支付';
    }
  }

  // 订单与乘客
  final TextEditingController _orderNoController = TextEditingController();
  final TextEditingController _passengerController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final TicketApi _ticketApi = TicketApi();
  // 输入框焦点与站点联想
  final FocusNode _departFocus = FocusNode();
  final FocusNode _arriveFocus = FocusNode();
  final StationApi _stationApi = StationApi(
  client: HttpClient(baseUrl: kIsWeb ? 'http://127.0.0.1:8081' : 'http://127.0.0.1:8080'),
  );
  final List<Map<String, dynamic>> _departStationSuggestions = [];
  final List<Map<String, dynamic>> _arriveStationSuggestions = [];
  String _lastDepartStationQuery = '';
  String _lastArriveStationQuery = '';

  @override
  void initState() {
    super.initState();
    final t = widget.ticket;
    _ticketKindDisplay = t.type == 'flight' ? '飞机票' : '火车票';
    _codeController.text = t.code;
    _departStationController.text = t.departStation;
    _arriveStationController.text = t.arriveStation;
    _departDateTime = t.departTime;
    _arriveDateTime = t.arriveTime;
    _coachOrCabinController.text = t.coachOrCabin ?? '';
    _seatNoController.text = t.seatNo ?? '';
    _seatTypeDisplay = t.seatType ?? (_ticketKindCode == 'train' ? '二等座' : '经济舱');
    _gateOrCheckinController.text = t.gateOrCheckin ?? '';
    _waitingAreaController.text = t.waitingArea ?? '';
    _priceController.text = t.price.toStringAsFixed(2);
    _discountController.text = t.discount ?? '';
    _ticketCategoryDisplay = _mapCategoryDisplay(t.ticketCategory);
    _ticketStatusDisplay = _mapStatusDisplay(t.status);
    _orderNoController.text = t.orderNo ?? '';
    _passengerController.text = t.passengerName ?? '';
    _remarkController.text = t.remark ?? '';
    _departFocus.addListener(() {
      if (_ticketKindCode == 'train' && _departFocus.hasFocus) {
        _loadTopStations(isDepart: true);
      }
    });
    _arriveFocus.addListener(() {
      if (_ticketKindCode == 'train' && _arriveFocus.hasFocus) {
        _loadTopStations(isDepart: false);
      }
    });
  }

  @override
  void dispose() {
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

  Future<void> _pickDate({required bool isDepart}) async {
    final DateTime initial = isDepart ? _departDateTime : _arriveDateTime;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isDepart) {
          _departDateTime = DateTime(picked.year, picked.month, picked.day, _departDateTime.hour, _departDateTime.minute);
          if (_arriveDateTime.isBefore(_departDateTime)) {
            _arriveDateTime = _departDateTime.add(const Duration(hours: 2));
          }
        } else {
          _arriveDateTime = DateTime(picked.year, picked.month, picked.day, _arriveDateTime.hour, _arriveDateTime.minute);
          if (_arriveDateTime.isBefore(_departDateTime)) {
            _arriveDateTime = _departDateTime.add(const Duration(hours: 2));
          }
        }
      });
    }
  }

  Future<void> _pickTime({required bool isDepart}) async {
    final TimeOfDay initial = TimeOfDay.fromDateTime(isDepart ? _departDateTime : _arriveDateTime);
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        if (isDepart) {
          _departDateTime = DateTime(_departDateTime.year, _departDateTime.month, _departDateTime.day, picked.hour, picked.minute);
        } else {
          _arriveDateTime = DateTime(_arriveDateTime.year, _arriveDateTime.month, _arriveDateTime.day, picked.hour, picked.minute);
        }
      });
    }
  }

  Future<void> _handleStationInput(String text, {required bool isDepart}) async {
    if (_ticketKindCode != 'train') return;
    final FocusNode focus = isDepart ? _departFocus : _arriveFocus;
    if (!focus.hasFocus) return;
    final String query = text.trim();
    if (query.length < 1) return;

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
    if (_ticketKindCode != 'train') return;
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


  String _fmtDateTime(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

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

    final DateTime picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
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

  void _showTicketKindPicker() {
    final options = ['火车票', '飞机票'];
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('票种', style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(height: 0),
            ...options.map((opt) => ListTile(
                  title: Text(opt),
                  onTap: () {
                    setState(() => _ticketKindDisplay = opt);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showSeatTypePicker() {
    final options = _ticketKindCode == 'train'
        ? ['二等座', '一等座', '商务座', '硬座', '软座', '硬卧', '软卧']
        : ['经济舱', '超经济舱', '商务舱', '头等舱'];
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(title: Text('座位类型', style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(height: 0),
            ...options.map((opt) => ListTile(
                  title: Text(opt),
                  onTap: () {
                    setState(() => _seatTypeDisplay = opt);
                    Navigator.pop(context);
                  },
                )),
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
        return parsed.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
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
              TextFormField(controller: codeCtrl, decoration: const InputDecoration(labelText: '站码*', hintText: '如 SHH、BJP'), textCapitalization: TextCapitalization.characters),
              const SizedBox(height: 8),
              TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: '站名*', hintText: '如 北京南')),
              const SizedBox(height: 8),
              TextFormField(controller: cityCtrl, decoration: const InputDecoration(labelText: '城市', hintText: '如 北京')),
              const SizedBox(height: 8),
              TextFormField(controller: latCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: '纬度', hintText: '如 39.872')),
              const SizedBox(height: 8),
              TextFormField(controller: lonCtrl, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: '经度', hintText: '如 116.407')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
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
              final ctrl = isDepart ? _departStationController : _arriveStationController;
              ctrl.text = city.isNotEmpty ? '$name（$city）' : name;
              ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
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

  Future<void> _showPickStation({required bool isDepart}) async {
    final stations = await _loadSavedStations();
    if (stations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('暂无已保存火车站')));
      return;
    }
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          children: [
            const ListTile(title: Text('选择火车站', style: TextStyle(fontWeight: FontWeight.bold))),
            const Divider(height: 0),
            ...stations.map((s) {
              final name = s['name']?.toString() ?? '';
              final city = s['city']?.toString() ?? '';
              final lat = s['latitude'];
              final lon = s['longitude'];
              final subtitle = [
                if (city.isNotEmpty) city,
                if (lat is num && lon is num) '(${lat.toStringAsFixed(3)}, ${lon.toStringAsFixed(3)})',
              ].join(' ');
              return ListTile(
                title: Text(name),
                subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                onTap: () {
                  final ctrl = isDepart ? _departStationController : _arriveStationController;
                  ctrl.text = city.isNotEmpty ? '$name（$city）' : name;
                  ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
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
      final payload = {
        'category': _ticketKindCode == 'flight' ? 'Flight' : 'Train',
        'travelNo': _codeController.text.trim(),
        'fromPlace': _departStationController.text.trim(),
        'toPlace': _arriveStationController.text.trim(),
        'departureTime': _departDateTime.toIso8601String(),
        'arrivalTime': _arriveDateTime.toIso8601String(),
        'seatClass': _seatTypeDisplay,
        'seatNo': _seatNoController.text.trim().isEmpty ? null : _seatNoController.text.trim(),
        'price': price,
        'currency': 'CNY',
        'passengerName': _passengerController.text.trim().isEmpty ? null : _passengerController.text.trim(),
      };

      await _ticketApi.editTicket(widget.ticket.id!, payload);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('票据更新成功！'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildDateTimeRow({required String label, required DateTime dateTime, required VoidCallback onPickDate, required VoidCallback onPickTime}) {
    String fmt(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Expanded(child: Text('$label: ${fmt(dateTime)}')),
        IconButton(icon: const Icon(Icons.date_range, color: Colors.blue), onPressed: onPickDate),
        IconButton(icon: const Icon(Icons.access_time, color: Colors.blue), onPressed: onPickTime),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('编辑票据', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _ticketKindDisplay,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: '火车票', child: Text('火车票')),
                              DropdownMenuItem(value: '飞机票', child: Text('飞机票')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _ticketKindDisplay = value);
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.blue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                      label: _ticketKindCode == 'train' ? '车次*' : '航班号*',
                      controller: _codeController,
                      hintText: _ticketKindCode == 'train' ? '如 G1234' : '如 MU5123',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      label: _ticketKindCode == 'train' ? '出发站*' : '出发机场*',
                      controller: _departStationController,
                      hintText: '请输入出发地',
                      focusNode: _departFocus,
                      onChanged: (v) => _handleStationInput(v, isDepart: true),
                    ),
                    if (_ticketKindCode == 'train')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_departFocus.hasFocus)
                              Card(
                                elevation: 0,
                                color: Colors.grey.shade100,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
                                child: Column(
                                  children: [
                                    if (_departStationSuggestions.isNotEmpty)
                                      ..._departStationSuggestions.take(6).map((s) {
                                        final name = s['name']?.toString() ?? '';
                                        final city = s['city']?.toString() ?? '';
                                        final code = s['stationCode']?.toString() ?? '';
                                        final subtitle = [
                                          if (code.isNotEmpty) code,
                                          if (city.isNotEmpty) city,
                                        ].join(' · ');
                                        return ListTile(
                                          dense: true,
                                          title: Text(name),
                                          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                                          onTap: () {
                                            final ctrl = _departStationController;
                                            ctrl.text = city.isNotEmpty ? '$name（$city）' : name;
                                            ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
                                            setState(() => _departStationSuggestions.clear());
                                          },
                                        );
                                      }),
                                    if (_departStationSuggestions.isEmpty)
                                      ListTile(
                                        dense: true,
                                        title: const Text('未找到车站，新增？'),
                                        trailing: const Icon(Icons.add, color: Colors.blue),
                                        onTap: () => _showAddStationDialog(isDepart: true),
                                      ),
                                  ],
                                ),
                              ),

                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      label: _ticketKindCode == 'train' ? '到达站*' : '到达机场*',
                      controller: _arriveStationController,
                      hintText: '请输入到达地',
                      focusNode: _arriveFocus,
                      onChanged: (v) => _handleStationInput(v, isDepart: false),
                    ),
                    if (_ticketKindCode == 'train')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_arriveFocus.hasFocus)
                              Card(
                                elevation: 0,
                                color: Colors.grey.shade100,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
                                child: Column(
                                  children: [
                                    if (_arriveStationSuggestions.isNotEmpty)
                                      ..._arriveStationSuggestions.take(6).map((s) {
                                        final name = s['name']?.toString() ?? '';
                                        final city = s['city']?.toString() ?? '';
                                        final code = s['stationCode']?.toString() ?? '';
                                        final subtitle = [
                                          if (code.isNotEmpty) code,
                                          if (city.isNotEmpty) city,
                                        ].join(' · ');
                                        return ListTile(
                                          dense: true,
                                          title: Text(name),
                                          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
                                          onTap: () {
                                            final ctrl = _arriveStationController;
                                            ctrl.text = city.isNotEmpty ? '$name（$city）' : name;
                                            ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
                                            setState(() => _arriveStationSuggestions.clear());
                                          },
                                        );
                                      }),
                                    if (_arriveStationSuggestions.isEmpty)
                                      ListTile(
                                        dense: true,
                                        title: const Text('未找到车站，新增？'),
                                        trailing: const Icon(Icons.add, color: Colors.blue),
                                        onTap: () => _showAddStationDialog(isDepart: false),
                                      ),
                                  ],
                                ),
                              ),

                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SelectorField(
                      label: _ticketKindCode == 'train' ? '出发时间' : '起飞时间',
                      value: _fmtDateTime(_departDateTime),
                      icon: Icons.schedule,
                      onTap: () => _pickDateTime(isDepart: true),
                    ),
                    const SizedBox(height: 8),
                    SelectorField(
                      label: _ticketKindCode == 'train' ? '到达时间' : '降落时间',
                      value: _fmtDateTime(_arriveDateTime),
                      icon: Icons.schedule,
                      onTap: () => _pickDateTime(isDepart: false),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(flex: 2, child: Text('行程时长', style: TextStyle(fontSize: 16, color: Colors.black87))),
                        Expanded(flex: 3, child: Text('$_durationMinutes分钟', style: const TextStyle(fontSize: 16, color: Colors.blue))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: _ticketKindCode == 'train' ? '车次信息' : '航班信息',
                  children: [
                    CustomFormField(label: _ticketKindCode == 'train' ? '车厢' : '舱位', controller: _coachOrCabinController, hintText: _ticketKindCode == 'train' ? '如 5车' : '如 经济舱'),
                    const SizedBox(height: 16),
                    CustomFormField(label: '座位号', controller: _seatNoController, hintText: '如 12A'),
                    const SizedBox(height: 16),
                    SelectorField(label: '座位类型', value: _seatTypeDisplay, onTap: _showSeatTypePicker),
                    const SizedBox(height: 16),
                    CustomFormField(label: _ticketKindCode == 'train' ? '检票口' : '登机口/值机柜台', controller: _gateOrCheckinController, hintText: _ticketKindCode == 'train' ? '如 A12' : '如 B12/岛2'),
                    const SizedBox(height: 16),
                    CustomFormField(label: _ticketKindCode == 'train' ? '候车区' : '航站楼', controller: _waitingAreaController, hintText: _ticketKindCode == 'train' ? '如 候车区A' : '如 T2'),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: '票务信息',
                  children: [
                    CustomFormField(label: '票价 CNY ¥', controller: _priceController, hintText: '请输入票价', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    CustomFormField(label: '折扣', controller: _discountController, hintText: '如 98折、对座98折'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            '票类型',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _ticketCategoryDisplay,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: '成人票', child: Text('成人票')),
                              DropdownMenuItem(value: '儿童票', child: Text('儿童票')),
                              DropdownMenuItem(value: '学生票', child: Text('学生票')),
                              DropdownMenuItem(value: '军人票', child: Text('军人票')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _ticketCategoryDisplay = value);
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.blue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: _ticketStatusDisplay,
                            isExpanded: true,
                            items: const [
                              DropdownMenuItem(value: '已支付', child: Text('已支付')),
                              DropdownMenuItem(value: '未支付', child: Text('未支付')),
                              DropdownMenuItem(value: '已退票', child: Text('已退票')),
                              DropdownMenuItem(value: '已改签', child: Text('已改签')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _ticketStatusDisplay = value);
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Colors.blue),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    CustomFormField(label: '取票号/订单号', controller: _orderNoController, hintText: '请输入订单号或取票号'),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: '乘客信息',
                  children: [
                    CustomFormField(label: '乘客姓名', controller: _passengerController, hintText: '请输入乘客姓名'),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: '备注',
                  children: [
                    CustomFormField(label: '备注', controller: _remarkController, hintText: '输入备注，如改签/退票说明'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 25,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 75,
                child: ElevatedButton(
                  onPressed: _updateTicket,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('保存修改'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}