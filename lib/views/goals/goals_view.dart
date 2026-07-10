import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qirshity/service/hive_service.dart';
import 'package:qirshity/views/goals/add_goal_view.dart';

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> with TickerProviderStateMixin {
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext scaffoldCtx, String goalName) {
    final bool isDark = Theme.of(scaffoldCtx).brightness == Brightness.dark;
    showDialog(
      context: scaffoldCtx,
      barrierDismissible: false,
      builder: (_) => _CongratsDialog(goalName: goalName, isDark: isDark, primaryColor: Theme.of(scaffoldCtx).colorScheme.primary),
    );
  }

  void _showConfirmDialog({required BuildContext context, required String title, required String content, required VoidCallback onConfirm}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, textAlign: TextAlign.right, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontFamily: 'Alexandria')),
        content: Text(content, textAlign: TextAlign.right, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontFamily: 'Alexandria')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Alexandria'))),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              onConfirm();
            },
            child: const Text('تأكيد', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Alexandria')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final BuildContext stableCtx = context;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('أهدافي المالية', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Alexandria')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(context, _slideRoute(const AddGoalPage())),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                child: FaIcon(FontAwesomeIcons.plus, color: primaryColor, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(HiveService.boxName).listenable(),
        builder: (context, Box box, _) {
          final double currentBalance = (box.get("balance", defaultValue: 0.0) as num).toDouble();
          final List goals = box.get("goals", defaultValue: []);
          final String currency = box.get("currency", defaultValue: "ج.م");

          if (goals.isEmpty) return _EmptyState(isDark: isDark, primaryColor: primaryColor);

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final Animation<double> fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: _listController, curve: Interval((index * 0.15).clamp(0.0, 0.7), 1.0, curve: Curves.easeOutCubic)),
              );
              final Animation<Offset> slideAnim = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
                CurvedAnimation(parent: _listController, curve: Interval((index * 0.15).clamp(0.0, 0.7), 1.0, curve: Curves.easeOutCubic)),
              );

              return FadeTransition(
                opacity: fadeAnim,
                child: SlideTransition(
                  position: slideAnim,
                  child: _GoalCard(
                    index: index,
                    name: goal['name'],
                    target: (goal['target'] as num).toDouble(),
                    current: currentBalance,
                    color: Color(goal['color']),
                    icon: FontAwesomeIcons.bullseye,
                    currency: currency,
                    isDark: isDark,
                    onDelete: () => _showConfirmDialog(
                      context: stableCtx,
                      title: 'حذف الهدف',
                      content: 'هل أنت متأكد من رغبتك في حذف هدف "${goal['name']}"؟',
                      onConfirm: () => HiveService.deleteGoal(index),
                    ),
                    onComplete: () => _showConfirmDialog(
                      context: stableCtx,
                      title: 'إتمام الهدف',
                      content: 'سيتم خصم ${(goal['target'] as num).toStringAsFixed(0)} $currency من رصيدك. هل أنت جاهز؟',
                      onConfirm: () async {
                        final double t = (goal['target'] as num).toDouble();
                        final String n = goal['name'] as String;
                        await HiveService.saveTransaction(
                          amount: t,
                          type: 'مصروف',
                          tags: ['أهداف', n],
                          date: DateTime.now().toString().split(' ')[0],
                        );
                        await HiveService.deleteGoal(index);
                        if (stableCtx.mounted) _showSuccessDialog(stableCtx, n);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Route _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
}

class _GoalCard extends StatefulWidget {
  final int index;
  final String name;
  final double target;
  final double current;
  final Color color;
  final FaIconData icon;
  final String currency;
  final bool isDark;
  final VoidCallback onDelete;
  final VoidCallback onComplete;

  const _GoalCard({
    required this.index,
    required this.name,
    required this.target,
    required this.current,
    required this.color,
    required this.icon,
    required this.currency,
    required this.isDark,
    required this.onDelete,
    required this.onComplete,
  });

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard> with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    final double progress = (widget.current / widget.target).clamp(0.0, 1.0);
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _progressAnim = Tween<double>(begin: 0, end: progress).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressCtrl.forward();
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (widget.current / widget.target).clamp(0.0, 1.0);
    final int percentage = (progress * 100).toInt();
    final double leftAmount = widget.target - widget.current;
    final bool canComplete = widget.current >= widget.target;
    final Color c = widget.color;
    final bool isDark = widget.isDark;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: c.withOpacity(isDark ? 0.12 : 0.15), blurRadius: isDark ? 20 : 24, offset: const Offset(0, 10)),
          if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
            child: Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.7, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [c, c.withOpacity(0.7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: c.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: FaIcon(widget.icon, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Alexandria', color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: canComplete ? Colors.green.withOpacity(0.12) : c.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          canComplete ? 'جاهز للإتمام ✓' : '$percentage%',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Alexandria', color: canComplete ? Colors.green : c),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: FaIcon(FontAwesomeIcons.ellipsisVertical, color: isDark ? Colors.white38 : Colors.black38, size: 16),
                  color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  onSelected: (v) {
                    if (v == 'delete') widget.onDelete();
                    if (v == 'complete') widget.onComplete();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        const FaIcon(FontAwesomeIcons.trash, color: Colors.red, size: 16),
                        const SizedBox(width: 10),
                        Text('حذف الهدف', style: TextStyle(fontFamily: 'Alexandria', color: isDark ? Colors.white : Colors.black)),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'complete',
                      enabled: canComplete,
                      child: Row(children: [
                        FaIcon(FontAwesomeIcons.trophy, color: canComplete ? Colors.amber : Colors.grey, size: 16),
                        const SizedBox(width: 10),
                        Text('إتمام الهدف', style: TextStyle(fontFamily: 'Alexandria', color: canComplete ? (isDark ? Colors.white : Colors.black) : Colors.grey)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الهدف', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12, fontFamily: 'Alexandria')),
                    const SizedBox(height: 2),
                    Text('${widget.target.toStringAsFixed(0)} ${widget.currency}',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, fontFamily: 'Alexandria', color: isDark ? Colors.white : Colors.black)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('رصيدك الحالي', style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 12, fontFamily: 'Alexandria')),
                    const SizedBox(height: 2),
                    Text('${widget.current.toStringAsFixed(0)} ${widget.currency}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Alexandria', color: canComplete ? Colors.green : c)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => Stack(
                    children: [
                      Container(height: 10, width: double.infinity, decoration: BoxDecoration(color: isDark ? Colors.white10 : c.withOpacity(0.10), borderRadius: BorderRadius.circular(10))),
                      LayoutBuilder(
                        builder: (_, constraints) => Container(
                          height: 10,
                          width: constraints.maxWidth * _progressAnim.value,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [c, c.withOpacity(0.55)]),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(progress * 100).toInt()}%',
                        style: TextStyle(color: c, fontWeight: FontWeight.bold, fontFamily: 'Alexandria', fontSize: 13)),
                    Text(
                      leftAmount > 0 ? 'متبقي ${leftAmount.toStringAsFixed(0)} ${widget.currency}' : 'وصلت للهدف! 🎉',
                      style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Alexandria', fontSize: 12, color: leftAmount <= 0 ? Colors.green : (isDark ? Colors.white54 : Colors.black54)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c, c.withOpacity(0.75)], begin: Alignment.centerRight, end: Alignment.centerLeft),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              children: [
                FaIcon(canComplete ? FontAwesomeIcons.trophy : FontAwesomeIcons.arrowTrendUp, color: Colors.white, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    canComplete ? 'مبروك! رصيدك كافٍ لإتمام هذا الهدف الآن 🏆' : 'أنت حققت $percentage% من هذا الهدف — استمر!',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Alexandria'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CongratsDialog extends StatefulWidget {
  final String goalName;
  final bool isDark;
  final Color primaryColor;

  const _CongratsDialog({required this.goalName, required this.isDark, required this.primaryColor});

  @override
  State<_CongratsDialog> createState() => _CongratsDialogState();
}

class _CongratsDialogState extends State<_CongratsDialog> with TickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _scaleCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeIn)));
    _scaleCtrl.forward();
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [BoxShadow(color: widget.primaryColor.withOpacity(0.25), blurRadius: 40, spreadRadius: 2)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 130,
                  height: 130,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _particleCtrl,
                        builder: (_, __) => Transform.rotate(
                          angle: _particleCtrl.value * 2 * pi,
                          child: CustomPaint(size: const Size(120, 120), painter: _OrbitPainter(color: widget.primaryColor)),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _particleCtrl,
                        builder: (_, __) {
                          final pulse = sin(_particleCtrl.value * 2 * pi) * 0.15 + 0.85;
                          return Container(
                            width: 80 * pulse,
                            height: 80 * pulse,
                            decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.amber.withOpacity(0.3), Colors.transparent])),
                          );
                        },
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.elasticOut,
                        builder: (_, v, child) => Transform.scale(scale: v, child: child),
                        child: const FaIcon(FontAwesomeIcons.trophy, color: Colors.amber, size: 52),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('ألف مبروك! 🎉', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Alexandria')),
                const SizedBox(height: 10),
                Text('لقد نجحت في تحقيق هدفك', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontFamily: 'Alexandria', color: widget.isDark ? Colors.white70 : Colors.black54)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.primaryColor.withOpacity(0.3)),
                  ),
                  child: Text('"${widget.goalName}"',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Alexandria', color: widget.primaryColor)),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('رائع! شكراً 🙌', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Alexandria')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final Color color;
  _OrbitPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 6;
    const dotCount = 8;
    final paint = Paint();
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * pi;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      final radius = i % 2 == 0 ? 4.0 : 2.5;
      paint.color = color.withOpacity(i % 2 == 0 ? 0.8 : 0.4);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => old.color != color;
}

class _EmptyState extends StatefulWidget {
  final bool isDark;
  final Color primaryColor;
  const _EmptyState({required this.isDark, required this.primaryColor});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _bounce = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _bounce,
            builder: (_, child) => Transform.translate(offset: Offset(0, _bounce.value), child: child),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(color: widget.primaryColor.withOpacity(0.08), shape: BoxShape.circle),
              child: FaIcon(FontAwesomeIcons.bullseye, size: 56, color: widget.primaryColor),
            ),
          ),
          const SizedBox(height: 24),
          Text('لا يوجد أهداف بعد',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Alexandria', color: widget.isDark ? Colors.white : Colors.black)),
          const SizedBox(height: 8),
          Text('ابدأ بإضافة أول هدف مالي لك 🚀',
              style: TextStyle(fontFamily: 'Alexandria', color: widget.isDark ? Colors.white54 : Colors.black45)),
        ],
      ),
    );
  }
}
