import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qirshity/service/hive_service.dart';

class AddTagScreen extends StatefulWidget {
  const AddTagScreen({super.key});

  @override
  State<AddTagScreen> createState() => _AddTagScreenState();
}

class _AddTagScreenState extends State<AddTagScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  String _tagType = 'مصروف';
  Color _selectedColor = const Color(0xFFB99BFF);
  FaIconData _selectedIcon = FontAwesomeIcons.tag;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<Color> _colors = [
    const Color(0xFFB99BFF),
    const Color(0xFFEF4444),
    const Color(0xFF0EA5E9),
    const Color(0xFFF59E0B),
    const Color(0xFF10B981),
    const Color(0xFFEC4899),
    const Color(0xFF64748B),
    const Color(0xFF14B8A6),
    const Color(0xFF8B5CF6),
    const Color(0xFFF97316),
  ];

  final List<Map<String, dynamic>> _faIcons = [
    {'icon': FontAwesomeIcons.utensils, 'label': 'طعام'},
    {'icon': FontAwesomeIcons.cartShopping, 'label': 'تسوق'},
    {'icon': FontAwesomeIcons.car, 'label': 'سيارة'},
    {'icon': FontAwesomeIcons.house, 'label': 'منزل'},
    {'icon': FontAwesomeIcons.moneyBillWave, 'label': 'مال'},
    {'icon': FontAwesomeIcons.briefcase, 'label': 'عمل'},
    {'icon': FontAwesomeIcons.graduationCap, 'label': 'تعليم'},
    {'icon': FontAwesomeIcons.heartPulse, 'label': 'صحة'},
    {'icon': FontAwesomeIcons.gamepad, 'label': 'ترفيه'},
    {'icon': FontAwesomeIcons.planeDeparture, 'label': 'سفر'},
    {'icon': FontAwesomeIcons.dumbbell, 'label': 'رياضة'},
    {'icon': FontAwesomeIcons.pallet, 'label': 'فن'},
    {'icon': FontAwesomeIcons.wrench, 'label': 'صيانة'},
    {'icon': FontAwesomeIcons.paw, 'label': 'حيوانات'},
    {'icon': FontAwesomeIcons.gift, 'label': 'هدية'},
    {'icon': FontAwesomeIcons.mobileScreen, 'label': 'موبايل'},
    {'icon': FontAwesomeIcons.wifi, 'label': 'إنترنت'},
    {'icon': FontAwesomeIcons.paintbrush, 'label': 'تصميم'},
    {'icon': FontAwesomeIcons.coffee, 'label': 'قهوة'},
    {'icon': FontAwesomeIcons.bolt, 'label': 'كهرباء'},
    {'icon': FontAwesomeIcons.chartLine, 'label': 'استثمار'},
    {'icon': FontAwesomeIcons.trophy, 'label': 'مكافأة'},
    {'icon': FontAwesomeIcons.spa, 'label': 'عناية'},
    {'icon': FontAwesomeIcons.tag, 'label': 'تصنيف'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _saveTag() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.white, size: 14),
              SizedBox(width: 8),
              Text('برجاء كتابة اسم التصنيف', style: TextStyle(fontFamily: "Alexandria")),
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
    await HiveService.addCustomTag(
      name: _nameController.text.trim(),
      colorValue: _selectedColor.value,
      iconCodePoint: _selectedIcon.codePoint,
      type: _tagType,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F7FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                pinned: true,
                backgroundColor: isDark ? const Color(0xFF1A1A2E) : primaryColor,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: const FaIcon(FontAwesomeIcons.arrowRight, color: Colors.white, size: 14)),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(right: 20, bottom: 16),
                  title: const Text('تصنيف جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: "Alexandria")),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryColor, Color.lerp(primaryColor, Colors.deepPurple, 0.5)!],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverToBoxAdapter(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Column(
                      children: [
                        _buildPreviewCard(isDark),
                        const SizedBox(height: 20),
                        _buildNameCard(isDark),
                        const SizedBox(height: 16),
                        _buildTypeCard(isDark),
                        const SizedBox(height: 16),
                        _buildColorsCard(isDark),
                        const SizedBox(height: 16),
                        _buildIconsCard(isDark),
                        const SizedBox(height: 28),
                        _buildSaveButton(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(color: _selectedColor.withOpacity(0.25), blurRadius: 24, offset: const Offset(0, 10))],
        border: Border.all(color: _selectedColor.withOpacity(isDark ? 0.4 : 0.2), width: 1.5),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: _selectedColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: FaIcon(_selectedIcon, color: _selectedColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nameController.text.isEmpty ? "اسم التصنيف..." : _nameController.text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _nameController.text.isEmpty ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                    fontFamily: "Alexandria",
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _tagType,
                    style: TextStyle(color: _selectedColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "Alexandria"),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _selectedColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FaIcon(FontAwesomeIcons.eye, color: _selectedColor, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required FaIconData icon, required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _selectedColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: FaIcon(icon, color: _selectedColor, size: 13),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildNameCard(bool isDark) {
    return _buildCard(
      title: 'اسم التصنيف',
      icon: FontAwesomeIcons.penToSquare,
      isDark: isDark,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _selectedColor.withOpacity(0.2)),
        ),
        child: TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontFamily: "Alexandria", fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'مثلاً: هدايا، بنزين، فواتير...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTypeCard(bool isDark) {
    return _buildCard(
      title: 'نوع التصنيف',
      icon: FontAwesomeIcons.arrowsUpDown,
      isDark: isDark,
      child: Row(
        children: ['مصروف', 'دخل'].map((type) {
          final selected = _tagType == type;
          final color = type == 'مصروف' ? Colors.red : Colors.green;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tagType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: EdgeInsets.only(left: type == 'مصروف' ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: selected ? color.withOpacity(0.12) : (isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.07)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(type == 'مصروف' ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                        size: 12, color: selected ? color : Colors.grey),
                    const SizedBox(width: 6),
                    Text(type, style: TextStyle(color: selected ? color : Colors.grey, fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColorsCard(bool isDark) {
    return _buildCard(
      title: 'لون التصنيف',
      icon: FontAwesomeIcons.palette,
      isDark: isDark,
      child: SizedBox(
        height: 50,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _colors.length,
          itemBuilder: (_, i) {
            final color = _colors[i];
            final selected = _selectedColor.value == color.value;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(left: 12),
                width: selected ? 48 : 38,
                height: selected ? 48 : 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? (isDark ? Colors.white : Colors.black) : Colors.transparent, width: 2.5),
                  boxShadow: selected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))] : [],
                ),
                child: selected ? const FaIcon(FontAwesomeIcons.check, color: Colors.white, size: 14) : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIconsCard(bool isDark) {
    return _buildCard(
      title: 'أيقونة التصنيف',
      icon: FontAwesomeIcons.icons,
      isDark: isDark,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _faIcons.map((item) {
          final icon = item['icon'] as FaIconData;
          final selected = _selectedIcon == icon;
          return GestureDetector(
            onTap: () => setState(() => _selectedIcon = icon),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(selected ? 12 : 10),
              decoration: BoxDecoration(
                color: selected ? _selectedColor : (isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.09)),
                borderRadius: BorderRadius.circular(14),
                boxShadow: selected ? [BoxShadow(color: _selectedColor.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))] : [],
              ),
              child: FaIcon(
                icon,
                color: selected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                size: selected ? 22 : 20,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveTag,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
          shadowColor: _selectedColor.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            FaIcon(FontAwesomeIcons.floppyDisk, size: 15),
            SizedBox(width: 10),
            Text('حفظ التصنيف', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
          ],
        ),
      ),
    );
  }
}
