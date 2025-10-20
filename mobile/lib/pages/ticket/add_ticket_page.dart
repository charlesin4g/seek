import 'package:flutter/material.dart';
import '../../widgets/section_card.dart';
import '../../widgets/form_field.dart';
import '../../widgets/selector_field.dart';
import '../../services/ticket_api.dart';
import '../../models/ticket.dart';

class AddTicketPage extends StatefulWidget {
  const AddTicketPage({super.key});

  @override
  State<AddTicketPage> createState() => _AddTicketPageState();
}

class _AddTicketPageState extends State<AddTicketPage> {
  final _formKey = GlobalKey<FormState>();

  // 基本类型选择
  String _ticketKindDisplay = '火车票'; // 显示文字
  String get _ticketKindCode => _ticketKindDisplay == '飞机票' ? 'flight' : 'train';

  // 行程信息
  final TextEditingController _codeController = TextEditingController(); // 车次/航班号
  final TextEditingController _departStationController = TextEditingController();
  final TextEditingController _arriveStationController = TextEditingController();
  DateTime _departDateTime = DateTime.now();
  DateTime _arriveDateTime = DateTime.now().add(const Duration(hours: 2));

  // 车次/航班信息
  final TextEditingController _coachOrCabinController = TextEditingController();
  final TextEditingController _seatNoController = TextEditingController();
  String _seatTypeDisplay = '二等座';
  final TextEditingController _gateOrCheckinController = TextEditingController(); // 检票口/登机口/值机柜台
  final TextEditingController _waitingAreaController = TextEditingController(); // 候车区/航站楼

  // 票务信息
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  String _ticketCategoryDisplay = '成人票';
  String _ticketStatusDisplay = '已支付';

  // 订单与乘客
  final TextEditingController _orderNoController = TextEditingController();
  final TextEditingController _passengerController = TextEditingController();
  final TextEditingController _remarkController = TextEditingController();

  final TicketApi _ticketApi = TicketApi();
  final FocusNode _departFocus = FocusNode();
  final FocusNode _arriveFocus = FocusNode();
  String _lastDepartIataQuery = '';
  String _lastArriveIataQuery = '';

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

  Future<void> _handleAirportInput(String text, {required bool isDepart}) async {
    if (_ticketKindCode != 'flight') return;
    final FocusNode focus = isDepart ? _departFocus : _arriveFocus;
    if (!focus.hasFocus) return;
    final String query = text.trim().toUpperCase();
    if (query.length < 3) return;

    if (isDepart && _lastDepartIataQuery == query) return;
    if (!isDepart && _lastArriveIataQuery == query) return;

    if (isDepart) {
      _lastDepartIataQuery = query;
    } else {
      _lastArriveIataQuery = query;
    }

    try {
      final result = await _ticketApi.getAirportByIata(query);
      final name = result['name']?.toString();
      if (name != null && name.isNotEmpty) {
        final ctrl = isDepart ? _departStationController : _arriveStationController;
        ctrl.text = name;
        ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
      }
    } catch (_) {
      // ignore network errors or not found
    }
  }

  // 计算行程时长
  int get _durationMinutes {
    final diff = _arriveDateTime.difference(_departDateTime);
    return diff.inMinutes.abs();
  }

  Future<void> _pickDate({required bool isDepart}) async {
    final DateTime initial = isDepart ? _departDateTime : _arriveDateTime;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isDepart) {
          _departDateTime = DateTime(
            picked.year, picked.month, picked.day,
            _departDateTime.hour, _departDateTime.minute,
          );
        } else {
          _arriveDateTime = DateTime(
            picked.year, picked.month, picked.day,
            _arriveDateTime.hour, _arriveDateTime.minute,
          );
        }
      });
    }
  }

  Future<void> _pickTime({required bool isDepart}) async {
    final TimeOfDay initial = TimeOfDay.fromDateTime(
      isDepart ? _departDateTime : _arriveDateTime,
    );
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isDepart) {
          _departDateTime = DateTime(
            _departDateTime.year, _departDateTime.month, _departDateTime.day,
            picked.hour, picked.minute,
          );
        } else {
          _arriveDateTime = DateTime(
            _arriveDateTime.year, _arriveDateTime.month, _arriveDateTime.day,
            picked.hour, picked.minute,
          );
        }
      });
    }
  }

  void _showTicketKindPicker() {
    final options = ['火车票', '飞机票'];
    _showBottomList(
      title: '票种',
      options: options,
      onSelect: (value) {
        setState(() => _ticketKindDisplay = value);
      },
    );
  }

  void _showSeatTypePicker() {
    final options = _ticketKindCode == 'train'
        ? ['二等座', '一等座', '商务座', '硬座', '软座', '硬卧', '软卧']
        : ['经济舱', '超经济舱', '商务舱', '头等舱'];
    _showBottomList(
      title: '座位类型',
      options: options,
      onSelect: (value) {
        setState(() => _seatTypeDisplay = value);
      },
    );
  }

  void _showTicketCategoryPicker() {
    final options = ['成人票', '儿童票', '学生票', '军人票'];
    _showBottomList(
      title: '票类型',
      options: options,
      onSelect: (value) {
        setState(() => _ticketCategoryDisplay = value);
      },
    );
  }

  void _showTicketStatusPicker() {
    final options = ['已支付', '未支付', '已退票', '已改签'];
    _showBottomList(
      title: '票状态',
      options: options,
      onSelect: (value) {
        setState(() => _ticketStatusDisplay = value);
      },
    );
  }

  void _showBottomList({
    required String title,
    required List<String> options,
    required void Function(String value) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            const Divider(height: 0),
            ...options.map((opt) => ListTile(
              title: Text(opt),
              onTap: () {
                Navigator.pop(context);
                onSelect(opt);
              },
            )),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime dt) => '${dt.year}年${dt.month.toString().padLeft(2, '0')}月${dt.day.toString().padLeft(2, '0')}日';
  String _fmtTime(DateTime dt) => '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Widget _buildDateTimeRow({required String label, required DateTime value, required VoidCallback onPickDate, required VoidCallback onPickTime}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onPickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtDate(value), style: const TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onPickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_fmtTime(value), style: const TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveTicket() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;

      final ticket = Ticket(
        type: _ticketKindCode,
        code: _codeController.text.trim(),
        departStation: _departStationController.text.trim(),
        arriveStation: _arriveStationController.text.trim(),
        departTime: _departDateTime,
        arriveTime: _arriveDateTime,
        durationMinutes: _durationMinutes,
        coachOrCabin: _coachOrCabinController.text.trim().isEmpty ? null : _coachOrCabinController.text.trim(),
        seatNo: _seatNoController.text.trim().isEmpty ? null : _seatNoController.text.trim(),
        seatType: _seatTypeDisplay,
        gateOrCheckin: _gateOrCheckinController.text.trim().isEmpty ? null : _gateOrCheckinController.text.trim(),
        waitingArea: _waitingAreaController.text.trim().isEmpty ? null : _waitingAreaController.text.trim(),
        price: price,
        discount: _discountController.text.trim().isEmpty ? null : _discountController.text.trim(),
        ticketCategory: _ticketCategoryDisplay,
        status: _ticketStatusDisplay,
        orderNo: _orderNoController.text.trim().isEmpty ? null : _orderNoController.text.trim(),
        passengerName: _passengerController.text.trim().isEmpty ? null : _passengerController.text.trim(),
        remark: _remarkController.text.trim().isEmpty ? null : _remarkController.text.trim(),
      );

      await _ticketApi.addTicket(ticket.toJson());

      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('票据保存成功！'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消', style: TextStyle(color: Colors.blue, fontSize: 16)),
        ),
        title: const Text('新建票据', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveTicket,
            child: const Text('保存', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
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
                    SelectorField(
                      label: '票种类型',
                      value: _ticketKindDisplay,
                      onTap: _showTicketKindPicker,
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
                      label: _ticketKindCode == 'train' ? '出发站(火车站)*' : '出发站(机场)*',
                      controller: _departStationController,
                      hintText: '请输入出发站',
                      focusNode: _departFocus,
                      onChanged: (v) => _handleAirportInput(v, isDepart: true),
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      label: _ticketKindCode == 'train' ? '到达站(火车站)*' : '到达站(机场)*',
                      controller: _arriveStationController,
                      hintText: '请输入到达站',
                      focusNode: _arriveFocus,
                      onChanged: (v) => _handleAirportInput(v, isDepart: false),
                    ),
                    const SizedBox(height: 16),
                    _buildDateTimeRow(
                      label: '出发时间*',
                      value: _departDateTime,
                      onPickDate: () => _pickDate(isDepart: true),
                      onPickTime: () => _pickTime(isDepart: true),
                    ),
                    const SizedBox(height: 16),
                    _buildDateTimeRow(
                      label: '到达时间*',
                      value: _arriveDateTime,
                      onPickDate: () => _pickDate(isDepart: false),
                      onPickTime: () => _pickTime(isDepart: false),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text('行程时长', style: TextStyle(fontSize: 16, color: Colors.black87)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('$_durationMinutes分钟', style: const TextStyle(fontSize: 16, color: Colors.blue)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: _ticketKindCode == 'train' ? '车次信息' : '航班信息',
                  children: [
                    CustomFormField(
                      label: _ticketKindCode == 'train' ? '车厢' : '舱位',
                      controller: _coachOrCabinController,
                      hintText: _ticketKindCode == 'train' ? '如 5车' : '如 经济舱',
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      label: '座位号',
                      controller: _seatNoController,
                      hintText: _ticketKindCode == 'train' ? '如 12A' : '如 12A',
                    ),
                    const SizedBox(height: 16),
                    SelectorField(
                      label: '座位类型',
                      value: _seatTypeDisplay,
                      onTap: _showSeatTypePicker,
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      label: _ticketKindCode == 'train' ? '检票口' : '登机口/值机柜台',
                      controller: _gateOrCheckinController,
                      hintText: _ticketKindCode == 'train' ? '如 A12' : '如 B12/岛2',
                    ),
                    const SizedBox(height: 16),
                    CustomFormField(
                      label: _ticketKindCode == 'train' ? '候车区' : '航站楼',
                      controller: _waitingAreaController,
                      hintText: _ticketKindCode == 'train' ? '如 候车区A' : '如 T2',
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
                    SelectorField(
                      label: '票类型',
                      value: _ticketCategoryDisplay,
                      onTap: _showTicketCategoryPicker,
                    ),
                    const SizedBox(height: 16),
                    SelectorField(
                      label: '票状态',
                      value: _ticketStatusDisplay,
                      onTap: _showTicketStatusPicker,
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
                      hintText: '请输入备注',
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}