import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qirshity/views/goals/goals_view.dart';
import 'package:qirshity/views/home/home_view.dart';
import 'package:qirshity/views/reports/reports_view.dart';
import 'package:qirshity/views/settings/settings_view.dart';
import 'package:qirshity/views/transactions/add_transaction_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimController;
  late Animation<double> _fabScaleAnim;

  final List<Widget> _pages = const [
    HomeView(),
    ReportsScreen(),
    GoalPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fabScaleAnim = CurvedAnimation(parent: _fabAnimController, curve: Curves.elasticOut);
    _fabAnimController.forward();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color primaryColor = theme.colorScheme.primary;

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnim,
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor.withOpacity(0.85), primaryColor],
            ),
            boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 22),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.06), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 75,
          color: theme.colorScheme.surface,
          shape: const AutomaticNotchedShape(
            RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))),
            StadiumBorder(),
          ),
          notchMargin: 10.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, FontAwesomeIcons.house, "الرئيسية", theme),
                    _buildNavItem(1, FontAwesomeIcons.chartPie, "التقارير", theme),
                  ],
                ),
              ),
              const SizedBox(width: 80),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(2, FontAwesomeIcons.bullseye, "الأهداف", theme),
                    _buildNavItem(3, FontAwesomeIcons.gear, "الإعدادات", theme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, FaIconData icon, String label, ThemeData theme) {
    bool isSelected = _selectedIndex == index;
    bool isDark = theme.brightness == Brightness.dark;
    Color activeColor = theme.colorScheme.primary;
    Color inactiveColor = isDark ? Colors.white38 : Colors.grey.shade500;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: isSelected ? activeColor : inactiveColor, size: 18),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? activeColor : inactiveColor, fontFamily: "Alexandria")),
          ],
        ),
      ),
    );
  }
}
