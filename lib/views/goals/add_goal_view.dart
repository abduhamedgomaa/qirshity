import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qirshity/service/hive_service.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  Color _selectedColor = const Color(0xFFB99BFF);
  FaIconData _selectedIcon = FontAwesomeIcons.bullseye;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Color> _colors = [
    const Color(0xFFB99BFF), const Color(0xFF7B61FF), const Color(0xFFEF4444),
    const Color(0xFF0EA5E9), const Color(0xFFF59E0B), const Color(0xFF10B981),
    const Color(0xFFEC4899), const Color(0xFF64748B), const Color(0xFF14B8A6),
  ];

  final List<FaIconData> _icons = [
    FontAwesomeIcons.bullseye, FontAwesomeIcons.car, FontAwesomeIcons.house,
    FontAwesomeIcons.laptop, FontAwesomeIcons.mobileScreen, FontAwesomeIcons.planeDeparture,
    FontAwesomeIcons.fish, FontAwesomeIcons.gamepad, FontAwesomeIcons.bagShopping,
    FontAwesomeIcons.building, FontAwesomeIcons.umbrellaBeach, FontAwesomeIcons.gem,
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _saveGoal() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (name.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(children: [
            FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white, size: 14),
            SizedBox(width: 8),
            Text('برجاء إدخال اسم الهدف والمبلغ المستهدف', style: TextStyle(fontFamily: "Alexandria")),
          ]),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    final box = Hive.box(HiveService.boxName);
    List goals = List.from(box.get('goals', defaultValue: []));
    goals.add({'name': name, 'target': amount, 'color': _selectedColor.value, 'icon': _selectedIcon.codePoint, 'current': 0.0});
    await box.put('goals', goals);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('إضافة هدف جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "Alexandria")),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Center(child: FaIcon(FontAwesomeIcons.arrowRight, color: primaryColor, size: 16)),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _selectedColor.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: _selectedColor.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: _selectedColor.withOpacity(0.15), shape: BoxShape.circle),
                        child: FaIcon(_selectedIcon, color: _selectedColor, size: 26),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _nameController.text.isEmpty ? "اسم الهدف..." : _nameController.text,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Alexandria", color: isDark ? Colors.white : Colors.black),
                            ),
                            Text(
                              _amountController.text.isEmpty ? "0.0" : "${_amountController.text} مبلغ مستهدف",
                              style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: "Alexandria"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputCard(
                  title: 'ماذا تريد أن تشتري؟',
                  icon: FontAwesomeIcons.penToSquare,
                  isDark: isDark,
                  child: TextField(
                    controller: _nameController,
                    onChanged: (v) => setState(() {}),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontFamily: "Alexandria"),
                    decoration: const InputDecoration(hintText: 'مثلاً: آيفون جديد، رحلة سياحية...', hintStyle: TextStyle(color: Colors.grey, fontSize: 14), border: InputBorder.none),
                  ),
                ),
                _buildInputCard(
                  title: 'المبلغ المستهدف',
                  icon: FontAwesomeIcons.coins,
                  isDark: isDark,
                  child: TextField(
                    controller: _amountController,
                    onChanged: (v) => setState(() {}),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black, fontFamily: "Alexandria"),
                    decoration: const InputDecoration(hintText: '0.0', hintStyle: TextStyle(color: Colors.grey, fontSize: 14), border: InputBorder.none),
                  ),
                ),
                _buildInputCard(
                  title: 'لون الهدف',
                  icon: FontAwesomeIcons.palette,
                  isDark: isDark,
                  child: SizedBox(
                    height: 48,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _colors.length,
                      itemBuilder: (_, index) {
                        final isSelected = _selectedColor.value == _colors[index].value;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = _colors[index]),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(left: 12),
                            width: isSelected ? 46 : 36,
                            height: isSelected ? 46 : 36,
                            decoration: BoxDecoration(
                              color: _colors[index],
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? (isDark ? Colors.white : Colors.black) : Colors.transparent, width: 3),
                              boxShadow: isSelected ? [BoxShadow(color: _colors[index].withOpacity(0.4), blurRadius: 8)] : [],
                            ),
                            child: isSelected ? const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 14) : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildInputCard(
                  title: 'أيقونة تميز الهدف',
                  icon: FontAwesomeIcons.icons,
                  isDark: isDark,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _icons.map((icon) {
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected ? _selectedColor : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSelected ? [BoxShadow(color: _selectedColor.withOpacity(0.3), blurRadius: 8)] : [],
                          ),
                          child: FaIcon(icon, color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600), size: 20),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        FaIcon(FontAwesomeIcons.rocket, size: 15),
                        SizedBox(width: 10),
                        Text('بدء رحلة الادخار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard({required String title, required FaIconData icon, required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            FaIcon(icon, size: 13, color: _selectedColor),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
          ]),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
