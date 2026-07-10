import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qirshity/service/hive_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _balanceAnim;
  late Animation<double> _fadeAnim;
  double _lastBalance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _balanceAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerBalanceAnim(double newBalance) {
    if (newBalance != _lastBalance) {
      _lastBalance = newBalance;
      _controller.forward(from: 0);
    }
  }

  Map<String, dynamic> _getTagDetails(String tagName, Box box) {
    final defaultTags = [
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

    List customTagsFromHive = box.get('custom_tags', defaultValue: []);
    List<Map<String, dynamic>> customTags = customTagsFromHive.map((t) {
      return {
        'name': t['name'],
        'icon': FaIconData(IconData(t['icon'], fontFamily: 'FontAwesomeSolid', fontPackage: 'font_awesome_flutter')),
        'color': Color(t['color']),
      };
    }).toList();

    final allTags = [...defaultTags, ...customTags];
    return allTags.firstWhere(
      (e) => e['name'].toString().trim() == tagName.trim(),
      orElse: () => {'name': tagName, 'icon': FontAwesomeIcons.tag, 'color': Colors.blueGrey},
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final size = MediaQuery.of(context).size;
    final double sp = size.width / 375;

    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box(HiveService.boxName).listenable(),
        builder: (context, Box box, _) {
          final userName = box.get("username", defaultValue: "مستخدم");
          final double userBalance = (box.get("balance", defaultValue: 0.0) as num).toDouble();
          final double userIncome = (box.get("income", defaultValue: 0.0) as num).toDouble();
          final double userExpense = (box.get("expense", defaultValue: 0.0) as num).toDouble();
          final String currency = box.get('currency', defaultValue: 'ج.م');
          final List transactions = box.get("transactions", defaultValue: []).reversed.toList();

          _triggerBalanceAnim(userBalance);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(context, size, sp, primaryColor, isDark, userName, userBalance, currency, userIncome, userExpense, box),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Row(
                      children: [
                        Expanded(child: _buildMoneyCard(context, FontAwesomeIcons.arrowDown, Colors.green, 'الدخل', userIncome, currency, isDark, sp)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildMoneyCard(context, FontAwesomeIcons.arrowUp, Colors.red, 'المصروفات', userExpense, currency, isDark, sp)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المعاملات الأخيرة',
                            style: TextStyle(fontSize: (14 * sp).clamp(13.0, 17.0), fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87, fontFamily: "Alexandria")),
                        Text('هذا الشهر',
                            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold,
                                fontSize: (11 * sp).clamp(10.0, 13.0), fontFamily: "Alexandria")),
                      ],
                    ),
                  ),
                ),
              ),
              transactions.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(FontAwesomeIcons.clipboardList, size: (48 * sp).clamp(36.0, 56.0), color: Colors.grey),
                            const SizedBox(height: 10),
                            Text('لا توجد عمليات مسجلة بعد',
                                style: TextStyle(color: Colors.grey, fontFamily: "Alexandria",
                                    fontSize: (12 * sp).clamp(11.0, 14.0))),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final transaction = transactions[index];
                            final firstTag = transaction['tags']?.isNotEmpty == true ? transaction['tags'][0] : '';
                            final tagInfo = _getTagDetails(firstTag, box);
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 300 + (index * 60)),
                              tween: Tween(begin: 0, end: 1),
                              builder: (context, value, child) => Opacity(
                                opacity: value,
                                child: Transform.translate(offset: Offset(0, 16 * (1 - value)), child: child),
                              ),
                              child: _buildTransactionItem(context, transaction, tagInfo, box, currency, isDark, sp),
                            );
                          },
                          childCount: transactions.length > 10 ? 10 : transactions.length,
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size size, double sp, Color primaryColor, bool isDark,
      String userName, double userBalance, String currency, double income, double expense, Box box) {
    final Color c1 = primaryColor;
    final Color c2 = Color.lerp(primaryColor, const Color(0xFF6C3FC5), 0.55)!;
    final Color c3 = Color.lerp(primaryColor, const Color(0xFF2D1B69), 0.75)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18, size.height * 0.062, 18, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c3, c2, c1],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
        boxShadow: [
          BoxShadow(color: c2.withOpacity(0.4), blurRadius: 28, spreadRadius: -4, offset: const Offset(0, 14)),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -35,
            right: -45,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Colors.white.withOpacity(0.09), Colors.transparent]),
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            left: 8,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.white.withOpacity(0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF4ADE80)),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'أهلاً، $userName',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: (12 * sp).clamp(11.0, 14.0),
                                fontWeight: FontWeight.w600,
                                fontFamily: "Alexandria",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        FaIcon(FontAwesomeIcons.bell, color: Colors.white, size: (14 * sp).clamp(13.0, 17.0)),
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF97316),
                              shape: BoxShape.circle,
                              border: Border.all(color: c2, width: 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.025),

              Text(
                'رصيدك الحالي',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: (11 * sp).clamp(10.0, 13.0),
                  letterSpacing: 0.4,
                  fontFamily: "Alexandria",
                ),
              ),
              const SizedBox(height: 6),

              AnimatedBuilder(
                animation: _balanceAnim,
                builder: (context, _) {
                  final displayVal = userBalance * _balanceAnim.value;
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 6),
                            child: Text(
                              currency,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: (15 * sp).clamp(13.0, 18.0),
                                fontWeight: FontWeight.bold,
                                fontFamily: "Alexandria",
                              ),
                            ),
                          ),
                          Text(
                            displayVal.toStringAsFixed(0),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (38 * sp).clamp(28.0, 46.0),
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              fontFamily: "Alexandria",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5, left: 3),
                            child: Text(
                              '.${(displayVal % 1 * 100).toInt().toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: (18 * sp).clamp(14.0, 22.0),
                                fontWeight: FontWeight.w700,
                                height: 1.0,
                                fontFamily: "Alexandria",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildHeaderStatChip(box, currency, sp),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStatChip(Box box, String currency, double sp) {
    final double income = (box.get("income", defaultValue: 0.0) as num).toDouble();
    final double expense = (box.get("expense", defaultValue: 0.0) as num).toDouble();

    if (income == 0 && expense == 0) return const SizedBox.shrink();

    final bool incomeHigher = income >= expense;
    final Color color = incomeHigher ? const Color(0xFF4ADE80) : const Color(0xFFF87171);
    final FaIconData icon = incomeHigher ? FontAwesomeIcons.arrowTrendUp : FontAwesomeIcons.arrowTrendDown;
    final String label = incomeHigher ? 'الدخل أعلى هذا الشهر' : 'المصاريف أعلى هذا الشهر';
    final double amount = incomeHigher ? income : expense;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
            child: FaIcon(icon, color: color, size: (10 * sp).clamp(9.0, 12.0)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: (10 * sp).clamp(9.0, 12.0),
                      fontFamily: "Alexandria")),
              Text('${amount.toStringAsFixed(0)} $currency',
                  style: TextStyle(
                      color: color,
                      fontSize: (12 * sp).clamp(11.0, 14.0),
                      fontWeight: FontWeight.w700,
                      fontFamily: "Alexandria")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyCard(BuildContext context, FaIconData icon, Color color, String title,
      double amount, String currency, bool isDark, double sp) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: (15 * sp).clamp(13.0, 18.0),
            backgroundColor: color.withOpacity(0.12),
            child: FaIcon(icon, color: color, size: (12 * sp).clamp(10.0, 14.0)),
          ),
          const SizedBox(height: 8),
          Text(title,
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: (10 * sp).clamp(9.5, 12.0),
                  fontFamily: "Alexandria")),
          const SizedBox(height: 3),
          FittedBox(
            child: Text('${amount.toStringAsFixed(0)} $currency',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (13 * sp).clamp(11.0, 15.0),
                    fontFamily: "Alexandria")),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, dynamic transaction,
      Map<String, dynamic> tagInfo, Box box, String currency, bool isDark, double sp) {
    final isExpense = transaction['type'] == 'مصروف';
    final Color tagColor = tagInfo['color'] as Color;
    final List tags = transaction['tags'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: tagColor.withOpacity(0.12), shape: BoxShape.circle),
            child: FaIcon(tagInfo['icon'] as FaIconData, color: tagColor, size: (14 * sp).clamp(12.0, 17.0)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tagInfo['name'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: (12 * sp).clamp(11.0, 14.0),
                        fontFamily: "Alexandria")),
                const SizedBox(height: 3),
                Text(transaction['date'],
                    style: TextStyle(color: Colors.grey, fontSize: (9 * sp).clamp(8.5, 11.0), fontFamily: "Alexandria")),
                if (tags.length > 1) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 4,
                    runSpacing: 3,
                    children: tags.skip(1).map<Widget>((t) {
                      final tInfo = _getTagDetails(t.toString(), box);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: (tInfo['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FaIcon(tInfo['icon'] as FaIconData, size: 8, color: tInfo['color'] as Color),
                            const SizedBox(width: 3),
                            Text(tInfo['name'].toString(),
                                style: TextStyle(
                                    fontSize: (9 * sp).clamp(8.0, 10.5),
                                    color: tInfo['color'] as Color,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Alexandria")),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isExpense ? '-' : '+'}${transaction['amount']} $currency',
                style: TextStyle(
                    color: isExpense ? Colors.redAccent : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: (12 * sp).clamp(11.0, 14.0),
                    fontFamily: "Alexandria"),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(isExpense ? 'مصروف' : 'دخل',
                    style: TextStyle(
                        color: isExpense ? Colors.redAccent : Colors.green,
                        fontSize: (8 * sp).clamp(7.5, 10.0),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Alexandria")),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
