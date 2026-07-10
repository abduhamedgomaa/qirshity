import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qirshity/service/hive_service.dart';
import 'package:qirshity/views/main_wrapper/main_wrapper.dart';

class SetupView extends StatefulWidget {
  const SetupView({super.key});

  @override
  State<SetupView> createState() => _SetupViewState();
}

class _SetupViewState extends State<SetupView> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  String _selectedGender = 'ذكر';
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _saveAndStart() async {
    final name = _nameController.text.trim();
    final double initialBalance = double.tryParse(_balanceController.text) ?? 0.0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white, size: 14),
              SizedBox(width: 8),
              Text('برجاء كتابة الاسم بالكامل', style: TextStyle(fontFamily: "Alexandria")),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    await HiveService.saveUser(
      username: name,
      income: 0.0,
      expense: 0.0,
      gender: _selectedGender,
      isLogin: true,
      balance: initialBalance,
    );

    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F7FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: FaIcon(FontAwesomeIcons.userPen, size: 40, color: primaryColor),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'خلّينا نتعرّف عليك',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, fontFamily: "Alexandria", color: isDark ? Colors.white : const Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'بياناتك بتساعدنا ننظم حساباتك بشكل أدق',
                            style: TextStyle(fontSize: 14, fontFamily: "Alexandria", color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                          const SizedBox(height: 36),
                          _buildLabel('الاسم بالكامل', isDark),
                          _buildTextField(controller: _nameController, hint: 'اكتب اسمك هنا...', keyboardType: TextInputType.name, isDark: isDark, icon: FontAwesomeIcons.user),
                          const SizedBox(height: 20),
                          _buildLabel('الرصيد الابتدائي (اختياري)', isDark),
                          _buildTextField(controller: _balanceController, hint: '0.00', keyboardType: TextInputType.number, isDark: isDark, icon: FontAwesomeIcons.coins),
                          const SizedBox(height: 20),
                          _buildLabel('النوع', isDark),
                          Row(
                            children: [
                              Expanded(child: _buildGenderCard(title: 'ذكر', icon: FontAwesomeIcons.mars, value: 'ذكر', color: Colors.blue, isDark: isDark)),
                              const SizedBox(width: 14),
                              Expanded(child: _buildGenderCard(title: 'أنثى', icon: FontAwesomeIcons.venus, value: 'أنثى', color: Colors.pinkAccent, isDark: isDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveAndStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        FaIcon(FontAwesomeIcons.rocket, size: 16),
                        SizedBox(width: 10),
                        Text('ابدأ الآن', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "Alexandria", color: isDark ? Colors.white70 : const Color(0xFF334155))),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required bool isDark,
    required FaIconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.right,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontFamily: "Alexandria"),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          prefixIcon: Padding(padding: const EdgeInsets.all(14), child: FaIcon(icon, size: 16, color: Colors.grey.shade400)),
        ),
      ),
    );
  }

  Widget _buildGenderCard({required String title, required FaIconData icon, required String value, required Color color, required bool isDark}) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            FaIcon(icon, size: 28, color: isSelected ? color : Colors.grey),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "Alexandria", color: isSelected ? color : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
