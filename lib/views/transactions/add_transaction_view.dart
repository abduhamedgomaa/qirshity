import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qirshity/service/hive_service.dart';
import 'package:qirshity/views/tags/tags_view.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> with SingleTickerProviderStateMixin {
  String _transactionType = 'مصروف';
  final TextEditingController _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _selectedTags = [];
  bool _amountError = false;
  bool _tagError = false;
  late AnimationController _animController;
  late Animation<double> _slideAnim;

  final String boxName = HiveService.boxName;

  final List<Map<String, dynamic>> _expenseTagsList = [
    {'name': 'الطعام والمشروبات', 'icon': FontAwesomeIcons.utensils, 'color': Colors.orange},
    {'name': 'السكن والإيجار', 'icon': FontAwesomeIcons.house, 'color': Colors.brown},
    {'name': 'المواصلات', 'icon': FontAwesomeIcons.car, 'color': Colors.blue},
    {'name': 'الملابس والأحذية', 'icon': FontAwesomeIcons.shirt, 'color': Colors.pink},
    {'name': 'الإنترنت والاشتراكات', 'icon': FontAwesomeIcons.wifi, 'color': Colors.cyan},
    {'name': 'الترفيه والألعاب', 'icon': FontAwesomeIcons.gamepad, 'color': Colors.purple},
    {'name': 'الصحة والعلاج', 'icon': FontAwesomeIcons.heartPulse, 'color': Colors.red},
    {'name': 'الأجهزة الإلكترونية', 'icon': FontAwesomeIcons.mobileScreen, 'color': Colors.grey},
    {'name': 'التعليم والدراسة', 'icon': FontAwesomeIcons.graduationCap, 'color': Colors.teal},
    {'name': 'السفر والسياحة', 'icon': FontAwesomeIcons.planeDeparture, 'color': Colors.indigo},
    {'name': 'العناية الشخصية', 'icon': FontAwesomeIcons.spa, 'color': Colors.pinkAccent},
  ];

  final List<Map<String, dynamic>> _incomeTagsList = [
    {'name': 'مرتب', 'icon': FontAwesomeIcons.moneyBillWave, 'color': Colors.green},
    {'name': 'بونص', 'icon': FontAwesomeIcons.gift, 'color': Colors.orangeAccent},
    {'name': 'هدية', 'icon': FontAwesomeIcons.handHoldingHeart, 'color': Colors.redAccent},
    {'name': 'بيع', 'icon': FontAwesomeIcons.tag, 'color': Colors.blue},
    {'name': 'استرجاع', 'icon': FontAwesomeIcons.rotateLeft, 'color': Colors.teal},
    {'name': 'استثمار', 'icon': FontAwesomeIcons.chartLine, 'color': Colors.indigo},
    {'name': 'تحويل', 'icon': FontAwesomeIcons.rightLeft, 'color': Colors.purple},
    {'name': 'مكافأة', 'icon': FontAwesomeIcons.trophy, 'color': Colors.amber},
    {'name': 'إيجار', 'icon': FontAwesomeIcons.buildingUser, 'color': Colors.brown},
    {'name': 'دخل إضافي', 'icon': FontAwesomeIcons.circlePlus, 'color': Colors.lightGreen},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    _animController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showTagsBottomSheet() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    List<Map<String, dynamic>> defaultList = _transactionType == 'مصروف' ? _expenseTagsList : _incomeTagsList;

    final box = Hive.box(boxName);
    List customTagsFromHive = box.get('custom_tags', defaultValue: []);

    List<Map<String, dynamic>> customTags = customTagsFromHive
        .where((t) => t['type'] == _transactionType)
        .map<Map<String, dynamic>>((t) => {
              'name': t['name'],
              'icon': FaIconData(IconData(t['icon'], fontFamily: 'FontAwesomeSolid', fontPackage: 'font_awesome_flutter')),
              'color': Color(t['color']),
            })
        .toList();

    List<Map<String, dynamic>> allTags = [...defaultList, ...customTags];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 16),
              height: MediaQuery.of(ctx).size.height * 0.7,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const TagsScreen()))
                              .then((_) => setState(() {}));
                        },
                        icon: FaIcon(FontAwesomeIcons.plus, color: primaryColor, size: 13),
                        label: Text('تصنيف جديد', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      Text('اختر التصنيفات', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(width: 80),
                    ],
                  ),
                  if (_selectedTags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _selectedTags.map((tag) {
                            return Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: (tag['color'] as Color).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: (tag['color'] as Color).withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FaIcon(tag['icon'], size: 11, color: tag['color'] as Color),
                                  const SizedBox(width: 5),
                                  Text(tag['name'], style: TextStyle(fontSize: 11, color: tag['color'] as Color, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedTags.removeWhere((t) => t['name'] == tag['name']));
                                      setSheetState(() {});
                                    },
                                    child: FaIcon(FontAwesomeIcons.xmark, size: 10, color: tag['color'] as Color),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  Divider(color: isDark ? Colors.white12 : Colors.black12, height: 1),
                  const SizedBox(height: 4),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: allTags.length,
                      itemBuilder: (_, index) {
                        final tag = allTags[index];
                        final bool isSelected = _selectedTags.any((e) => e['name'] == tag['name']);
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (tag['color'] as Color).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: FaIcon(tag['icon'], color: tag['color'] as Color, size: 16),
                          ),
                          title: Text(
                            tag['name'],
                            style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black),
                          ),
                          trailing: isSelected
                              ? FaIcon(FontAwesomeIcons.circleCheck, color: primaryColor, size: 20)
                              : FaIcon(FontAwesomeIcons.circle, color: Colors.grey.shade300, size: 20),
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedTags.removeWhere((e) => e['name'] == tag['name']);
                              } else {
                                _selectedTags.add(tag);
                              }
                              _tagError = false;
                            });
                            setSheetState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('تأكيد (${_selectedTags.length} تصنيف)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final box = Hive.box(boxName);
    final String currency = box.get('currency', defaultValue: 'ج.م');
    final bool isExpense = _transactionType == 'مصروف';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF0EEFF),
      body: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(_slideAnim),
        child: FadeTransition(
          opacity: _slideAnim,
          child: Column(
            children: [
              _buildCustomAppBar(context, isDark, primaryColor, isExpense),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildAmountSection(context, isDark, primaryColor, currency, isExpense),
                      const SizedBox(height: 16),
                      _buildTagsSection(context, isDark, primaryColor),
                      const SizedBox(height: 16),
                      _buildDateSection(context, isDark, primaryColor),
                    ],
                  ),
                ),
              ),
              _buildSaveButton(context, primaryColor, currency, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, bool isDark, Color primaryColor, bool isExpense) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                ),
                child: FaIcon(FontAwesomeIcons.arrowRight, size: 16, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
            const Spacer(),
            Text('إضافة عملية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: ['مصروف', 'دخل'].map((type) {
                  final selected = _transactionType == type;
                  final color = type == 'مصروف' ? Colors.red : Colors.green;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _transactionType = type;
                      _selectedTags.clear();
                      _tagError = false;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? color.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: selected ? color : Colors.grey,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection(BuildContext context, bool isDark, Color primaryColor, String currency, bool isExpense) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExpense
              ? [const Color(0xFFFF6B6B).withOpacity(0.08), Colors.red.withOpacity(0.03)]
              : [Colors.green.withOpacity(0.08), Colors.green.withOpacity(0.03)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _amountError ? Colors.red.withOpacity(0.5) : (isExpense ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(isExpense ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                    color: isExpense ? Colors.red : Colors.green, size: 14),
              ),
              const SizedBox(width: 10),
              Text('المبلغ', style: TextStyle(color: _amountError ? Colors.red : Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
              if (_amountError) ...[
                const SizedBox(width: 8),
                const Text('- برجاء إدخال مبلغ صحيح', style: TextStyle(color: Colors.red, fontSize: 11)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
            onChanged: (_) {
              if (_amountError) setState(() => _amountError = false);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixText: '$currency  ',
              prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor.withOpacity(0.7)),
              hintText: '0.00',
              hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, bool isDark, Color primaryColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _tagError ? Colors.red.withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _tagError ? Colors.red.withOpacity(0.08) : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: FaIcon(FontAwesomeIcons.tags, color: primaryColor, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'التصنيف',
                    style: TextStyle(color: _tagError ? Colors.red : Colors.grey, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Text(' *', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: _showTagsBottomSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.plus, color: primaryColor, size: 12),
                      const SizedBox(width: 6),
                      Text('إضافة', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_selectedTags.isEmpty)
            GestureDetector(
              onTap: _showTagsBottomSheet,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: _tagError ? Colors.red.withOpacity(0.05) : (isDark ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.05)),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _tagError ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.15),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    FaIcon(FontAwesomeIcons.tags, color: _tagError ? Colors.red : Colors.grey.shade400, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      _tagError ? 'يجب اختيار تصنيف واحد على الأقل' : 'اضغط لاختيار تصنيف أو أكثر',
                      style: TextStyle(color: _tagError ? Colors.red : Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: (tag['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: (tag['color'] as Color).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(tag['icon'], size: 12, color: tag['color'] as Color),
                      const SizedBox(width: 6),
                      Text(tag['name'], style: TextStyle(color: tag['color'] as Color, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _selectedTags.removeWhere((t) => t['name'] == tag['name'])),
                        child: FaIcon(FontAwesomeIcons.xmark, size: 12, color: tag['color'] as Color),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: FaIcon(FontAwesomeIcons.calendarDays, color: primaryColor, size: 14),
              ),
              const SizedBox(width: 10),
              const Text('التاريخ', style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primaryColor.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FaIcon(FontAwesomeIcons.calendar, size: 16, color: primaryColor),
                  Text(
                    DateFormat('EEEE، dd MMMM yyyy', 'ar').format(_selectedDate),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, Color primaryColor, String currency, bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 17),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            onPressed: () async {
              bool hasError = false;
              if (_amountController.text.trim().isEmpty || (double.tryParse(_amountController.text) ?? 0) <= 0) {
                setState(() => _amountError = true);
                hasError = true;
              }
              if (_selectedTags.isEmpty) {
                setState(() => _tagError = true);
                hasError = true;
              }
              if (hasError) return;

              double amount = double.tryParse(_amountController.text) ?? 0.0;
              List<String> tagsStringList = _selectedTags.map((t) => t['name'].toString()).toList();
              String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

              bool isSuccess = await HiveService.saveTransaction(
                amount: amount,
                type: _transactionType,
                tags: tagsStringList,
                date: formattedDate,
              );

              if (context.mounted) {
                if (isSuccess) {
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white, size: 16),
                          SizedBox(width: 10),
                          Text('عذراً، رصيدك الحالي لا يكفي!', style: TextStyle(fontFamily: 'Alexandria')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                }
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                FaIcon(FontAwesomeIcons.floppyDisk, size: 16),
                SizedBox(width: 10),
                Text('حفظ العملية', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
