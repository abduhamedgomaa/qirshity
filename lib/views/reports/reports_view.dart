import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:qirshity/service/hive_service.dart';

class CategoryStat {
  final String name;
  final double amount;
  final double percentage;
  final Color color;
  final FaIconData icon;

  CategoryStat({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  String _selectedType = 'مصروف';
  late DateTime _selectedDate;
  int _touchedIndex = -1;
  bool _showBarChart = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<String> _arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

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
    _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openDatePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        int selectedYear = _selectedDate.year;
        int selectedMonth = _selectedDate.month;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 5, decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  Text('اختر الشهر والسنة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontFamily: "Alexandria")),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('السنة:', style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600, fontFamily: "Alexandria")),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => setSheetState(() => selectedYear--),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: FaIcon(FontAwesomeIcons.chevronRight, color: primaryColor, size: 14),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text('$selectedYear', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontFamily: "Alexandria")),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              if (selectedYear < DateTime.now().year) setSheetState(() => selectedYear++);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                              child: FaIcon(FontAwesomeIcons.chevronLeft, color: primaryColor, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: 12,
                    itemBuilder: (_, i) {
                      final selected = selectedMonth == i + 1;
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedMonth = i + 1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: selected ? primaryColor : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.08)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _arabicMonths[i],
                            style: TextStyle(
                              color: selected ? Colors.white : (isDark ? Colors.white60 : Colors.grey.shade700),
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                              fontFamily: "Alexandria",
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = DateTime(selectedYear, selectedMonth, 1);
                          _touchedIndex = -1;
                          _animController.forward(from: 0);
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('تأكيد', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _generateColorFromName(String name) {
    final int hash = name.hashCode;
    return Color((hash & 0xFFFFFF) | 0xFF000000).withOpacity(0.85);
  }

  Map<String, dynamic> _processData() {
    final box = Hive.box(HiveService.boxName);
    List transactions = box.get("transactions", defaultValue: []);
    List customTagsFromHive = box.get('custom_tags', defaultValue: []);
    List goalsFromHive = box.get('goals', defaultValue: []);

    double totalAmount = 0.0;
    Map<String, double> groupedData = {};

    for (var t in transactions) {
      DateTime tDate = DateTime.parse(t['date']);
      if (tDate.month == _selectedDate.month && tDate.year == _selectedDate.year && t['type'] == _selectedType) {
        List tags = t['tags'] ?? [];
        String tagName = tags.isNotEmpty ? tags[0] : 'أخرى';
        double amount = (t['amount'] is int) ? (t['amount'] as int).toDouble() : (t['amount'] ?? 0.0);
        groupedData[tagName] = (groupedData[tagName] ?? 0) + amount;
        totalAmount += amount;
      }
    }

    List<CategoryStat> stats = [];
    groupedData.forEach((tagName, amount) {
      Color? finalColor;
      FaIconData finalIcon = FontAwesomeIcons.tag;

      for (var item in (_selectedType == 'مصروف' ? _expenseTagsList : _incomeTagsList)) {
        if (item['name'].toString().trim() == tagName.trim()) {
          finalColor = item['color'];
          finalIcon = item['icon'];
          break;
        }
      }
      if (finalColor == null) {
        for (var g in goalsFromHive) {
          if (g['name'].toString().trim() == tagName.trim()) {
            finalColor = Color(g['color']);
            break;
          }
        }
      }
      if (finalColor == null) {
        for (var t in customTagsFromHive) {
          if (t['name'].toString().trim() == tagName.trim()) {
            finalColor = Color(t['color']);
            finalIcon = FaIconData(IconData(t['icon'], fontFamily: 'FontAwesomeSolid', fontPackage: 'font_awesome_flutter'));
            break;
          }
        }
      }
      finalColor ??= _generateColorFromName(tagName);

      double pct = totalAmount > 0 ? (amount / totalAmount) * 100 : 0.0;
      stats.add(CategoryStat(name: tagName, amount: amount, percentage: pct, color: finalColor, icon: finalIcon));
    });

    stats.sort((a, b) => b.amount.compareTo(a.amount));
    return {'total': totalAmount, 'stats': stats};
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F7FF),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(HiveService.boxName).listenable(),
        builder: (context, Box box, _) {
          final data = _processData();
          final List<CategoryStat> stats = data['stats'];
          final double total = data['total'];
          final String currency = box.get('currency', defaultValue: 'ج.م');

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 110,
                pinned: true,
                backgroundColor: isDark ? const Color(0xFF1A1A2E) : primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(right: 20, bottom: 16),
                  title: Row(
                    children: [
                      const Spacer(),
                      const Text('تحليل الميزانية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "Alexandria")),
                      const Spacer(),
                    ],
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, Color.lerp(primaryColor, Colors.purple, 0.4)!],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => _openDatePicker(context),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FaIcon(FontAwesomeIcons.calendarDays, color: Colors.white, size: 12),
                          const SizedBox(width: 6),
                          Text('${_arabicMonths[_selectedDate.month - 1]} ${_selectedDate.year}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: "Alexandria")),
                          const SizedBox(width: 4),
                          const FaIcon(FontAwesomeIcons.chevronDown, color: Colors.white, size: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildTypeToggle(isDark, cardColor, primaryColor),
                        const SizedBox(height: 20),
                        _buildChartToggle(isDark, primaryColor),
                        const SizedBox(height: 24),
                        if (stats.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: Column(
                              children: [
                                FaIcon(FontAwesomeIcons.chartPie, size: 52, color: Colors.grey.withOpacity(0.3)),
                                const SizedBox(height: 14),
                                const Text('لا توجد بيانات لهذا الشهر', style: TextStyle(color: Colors.grey, fontFamily: "Alexandria")),
                              ],
                            ),
                          )
                        else ...[
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: _showBarChart
                                ? _buildBarChart(stats, total, currency, isDark, primaryColor)
                                : _buildPieChart(stats, total, currency, isDark),
                          ),
                          const SizedBox(height: 24),
                          ...stats.asMap().entries.map((e) {
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 300 + (e.key * 80)),
                              tween: Tween(begin: 0, end: 1),
                              builder: (ctx, val, child) => Opacity(
                                opacity: val,
                                child: Transform.translate(offset: Offset(0, 20 * (1 - val)), child: child),
                              ),
                              child: _buildStatCard(e.value, isDark, cardColor, currency),
                            );
                          }),
                        ],
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTypeToggle(bool isDark, Color cardColor, Color primaryColor) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: ['مصروف', 'دخل'].map((type) {
          final selected = _selectedType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedType = type;
                  _touchedIndex = -1;
                  _animController.forward(from: 0);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? cardColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: selected ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)] : [],
                ),
                child: Text(
                  type == 'مصروف' ? 'المصروفات' : 'الدخل',
                  style: TextStyle(
                    color: selected ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontFamily: "Alexandria",
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartToggle(bool isDark, Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => setState(() => _showBarChart = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: !_showBarChart ? primaryColor : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.09)),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
            ),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.chartPie, color: !_showBarChart ? Colors.white : Colors.grey, size: 14),
                const SizedBox(width: 7),
                Text('دائري', style: TextStyle(color: !_showBarChart ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontFamily: "Alexandria", fontSize: 13)),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() => _showBarChart = true),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: _showBarChart ? primaryColor : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.09)),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.chartBar, color: _showBarChart ? Colors.white : Colors.grey, size: 14),
                const SizedBox(width: 7),
                Text('أعمدة', style: TextStyle(color: _showBarChart ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontFamily: "Alexandria", fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart(List<CategoryStat> stats, double total, String currency, bool isDark) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 70,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() => _touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1);
                },
              ),
              sections: stats.asMap().entries.map((e) {
                final touched = e.key == _touchedIndex;
                return PieChartSectionData(
                  color: e.value.color,
                  value: e.value.amount,
                  radius: touched ? 35 : 25,
                  showTitle: false,
                );
              }).toList(),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('الإجمالي', style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: "Alexandria")),
              Text('${total.toStringAsFixed(0)} $currency',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<CategoryStat> stats, double total, String currency, bool isDark, Color primaryColor) {
    final maxY = stats.isNotEmpty ? stats.first.amount * 1.2 : 100.0;

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int i = value.toInt();
                  if (i >= 0 && i < stats.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        stats[i].name.length > 6 ? '${stats[i].name.substring(0, 5)}..' : stats[i].name,
                        style: const TextStyle(fontSize: 9, color: Colors.grey, fontFamily: "Alexandria"),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barGroups: stats.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.amount,
                  color: e.value.color,
                  width: 18,
                  borderRadius: BorderRadius.circular(8),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY, color: e.value.color.withOpacity(0.07)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatCard(CategoryStat stat, bool isDark, Color cardColor, String currency) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: stat.color.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: stat.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: FaIcon(stat.icon, color: stat.color, size: 16),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
                    Text('${stat.percentage.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text('${stat.amount.toStringAsFixed(0)} $currency',
                  style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Alexandria", color: stat.color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (stat.percentage / 100).clamp(0.0, 1.0),
              backgroundColor: stat.color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(stat.color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
