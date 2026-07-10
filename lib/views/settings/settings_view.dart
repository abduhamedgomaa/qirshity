import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qirshity/service/hive_service.dart';
import 'package:qirshity/views/settings/about_view.dart';
import 'package:qirshity/views/splash/splash_view.dart';
import 'package:qirshity/views/tags/tags_view.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedCurrency = 'ج.م';
  bool _isDarkMode = false;
  Color _primaryColor = const Color(0xFFB99BFF);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final box = Hive.box(HiveService.boxName);
    setState(() {
      _selectedCurrency = box.get("currency", defaultValue: "ج.م");
      _isDarkMode = box.get("isDarkMode", defaultValue: false);
      _primaryColor = Color(box.get("primaryColor", defaultValue: 0xFFB99BFF));
    });
  }

  void _updateCurrency(String newCurrency) {
    setState(() => _selectedCurrency = newCurrency);
    Hive.box(HiveService.boxName).put("currency", newCurrency);
    Navigator.pop(context);
  }

  void _updateTheme(bool isDark) {
    setState(() => _isDarkMode = isDark);
    Hive.box(HiveService.boxName).put("isDarkMode", isDark);
  }

  void _updateColor(Color newColor) {
    setState(() => _primaryColor = newColor);
    Hive.box(HiveService.boxName).put("primaryColor", newColor.value);
    Navigator.pop(context);
  }

  void _showEditNameSheet() {
    final isDark = _isDarkMode;
    final box = Hive.box(HiveService.boxName);
    final controller = TextEditingController(text: box.get("username", defaultValue: ""));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text('تعديل الاسم',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Alexandria",
                      color: isDark ? Colors.white : Colors.black87)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF8F7FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _primaryColor.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontFamily: "Alexandria",
                      fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'اكتب اسمك هنا...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontFamily: "Alexandria"),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12),
                      child: FaIcon(FontAwesomeIcons.user, size: 15, color: _primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final newName = controller.text.trim();
                    if (newName.isEmpty) return;
                    box.put("username", newName);
                    setState(() {});
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(children: [
                          FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 14),
                          SizedBox(width: 8),
                          Text('تم تحديث الاسم بنجاح', style: TextStyle(fontFamily: "Alexandria")),
                        ]),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('حفظ',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "Alexandria")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyBottomSheet() {
    final currencies = ['ج.م', 'دولار', 'يورو', 'ريال', 'درهم', 'دينار'];
    final isDark = _isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('اختر العملة الأساسية',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Alexandria",
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 16),
            ...currencies.map((currency) => ListTile(
                  title: Text(currency,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Alexandria",
                          color: isDark ? Colors.white : Colors.black87)),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: FaIcon(FontAwesomeIcons.coins, color: _primaryColor, size: 14),
                  ),
                  trailing: _selectedCurrency == currency
                      ? FaIcon(FontAwesomeIcons.circleCheck, color: _primaryColor, size: 18)
                      : null,
                  onTap: () => _updateCurrency(currency),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showColorBottomSheet() {
    final isDark = _isDarkMode;
    final List<Map<String, dynamic>> appColors = [
      {'color': const Color(0xFFB99BFF), 'name': 'بنفسجي فاتح'},
      {'color': const Color(0xFF7C3AED), 'name': 'بنفسجي غامق'},
      {'color': const Color(0xFF0EA5E9), 'name': 'أزرق سماوي'},
      {'color': const Color(0xFF10B981), 'name': 'أخضر زمردي'},
      {'color': const Color(0xFFF97316), 'name': 'برتقالي'},
      {'color': const Color(0xFFEC4899), 'name': 'وردي'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text('تخصيص لون التطبيق',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Alexandria",
                    color: isDark ? Colors.white : Colors.black87)),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.7),
              itemCount: appColors.length,
              itemBuilder: (_, i) {
                final item = appColors[i];
                final color = item['color'] as Color;
                final selected = _primaryColor.value == color.value;
                return GestureDetector(
                  onTap: () => _updateColor(color),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(selected ? 0.18 : 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? color : Colors.transparent, width: 2),
                      boxShadow: selected
                          ? [BoxShadow(color: color.withOpacity(0.28), blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                          if (selected) ...[
                            const SizedBox(width: 5),
                            FaIcon(FontAwesomeIcons.circleCheck, color: color, size: 13),
                          ],
                        ]),
                        const SizedBox(height: 5),
                        Text(item['name'],
                            style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Alexandria"),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                    child: const FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.red, size: 26),
                  ),
                ),
        title: Text('حذف كافة البيانات',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Alexandria",
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _isDarkMode ? Colors.white : Colors.black87)),
        content: Text('هل أنت متأكد؟ سيتم حذف جميع بياناتك نهائياً ولا يمكن التراجع عن هذا.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "Alexandria",
                fontSize: 13,
                color: _isDarkMode ? Colors.white60 : Colors.black54)),
        actions: [
          Row(children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء',
                    style: TextStyle(color: Colors.grey, fontFamily: "Alexandria")),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  await HiveService.clearAllData();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const SplashView()),
                      (_) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حذف',
                    style: TextStyle(fontFamily: "Alexandria", fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final box = Hive.box(HiveService.boxName);
    final String userName = box.get("username", defaultValue: "مستخدم");

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F7FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? const Color(0xFF1A1A2E) : _primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.lerp(_primaryColor, const Color(0xFF2D1B69), 0.7)!,
                      _primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  shape: BoxShape.circle),
                              child: const FaIcon(FontAwesomeIcons.userGear,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('الإعدادات',
                                      style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 11,
                                          fontFamily: "Alexandria")),
                                  Text(userName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Alexandria")),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _showEditNameSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    FaIcon(FontAwesomeIcons.penToSquare,
                                        color: Colors.white, size: 11),
                                    SizedBox(width: 5),
                                    Text('تعديل',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Alexandria")),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _sectionTitle('الحساب والعملة'),
                  _settingItem(
                    icon: FontAwesomeIcons.userPen,
                    iconColor: _primaryColor,
                    title: 'تعديل الاسم',
                    subtitle: userName,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: _showEditNameSheet,
                  ),
                  _settingItem(
                    icon: FontAwesomeIcons.coins,
                    iconColor: Colors.amber,
                    title: 'العملة الأساسية',
                    subtitle: _selectedCurrency,
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: _showCurrencyBottomSheet,
                  ),
                  _settingItem(
                    icon: FontAwesomeIcons.tags,
                    iconColor: _primaryColor,
                    title: 'التصنيفات المخصصة',
                    subtitle: 'إضافة وإدارة التصنيفات',
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () =>
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const TagsScreen())),
                  ),
                  const SizedBox(height: 14),
                  _sectionTitle('المظهر'),
                  _settingItem(
                    icon: FontAwesomeIcons.palette,
                    iconColor: _primaryColor,
                    title: 'لون التطبيق',
                    subtitle: 'تخصيص اللون الرئيسي',
                    cardColor: cardColor,
                    textColor: textColor,
                    trailing: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                          color: _primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: _primaryColor.withOpacity(0.4), blurRadius: 6)
                          ]),
                    ),
                    onTap: _showColorBottomSheet,
                  ),
                  _settingItem(
                    icon: FontAwesomeIcons.moon,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'الوضع الليلي',
                    subtitle: _isDarkMode ? 'مفعّل' : 'معطّل',
                    cardColor: cardColor,
                    textColor: textColor,
                    trailing: Switch(
                        value: _isDarkMode, activeColor: _primaryColor, onChanged: _updateTheme),
                    onTap: () => _updateTheme(!_isDarkMode),
                  ),
                  const SizedBox(height: 14),
                  _sectionTitle('منطقة الخطر'),
                  GestureDetector(
                    onTap: _confirmDelete,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.red.withOpacity(0.08) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                                color: isDark ? Colors.red.withOpacity(0.15) : Colors.white,
                                shape: BoxShape.circle),
                            child: const FaIcon(FontAwesomeIcons.trash, color: Colors.red, size: 14),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('حذف كافة البيانات',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily: "Alexandria")),
                              Text('لا يمكن التراجع عن هذا',
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 10, fontFamily: "Alexandria")),
                            ],
                          ),
                          const Spacer(),
                          const FaIcon(FontAwesomeIcons.triangleExclamation,
                              color: Colors.red, size: 14),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _sectionTitle('عن التطبيق'),
                  _settingItem(
                    icon: FontAwesomeIcons.circleInfo,
                    iconColor: Colors.grey.shade600,
                    title: 'عن تطبيق قِرشَتي',
                    subtitle: 'النسخة 1.1.0',
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (_) => const AboutScreen())),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text('قِرشَتي • النسخة 1.1.0',
                        style:
                            TextStyle(color: Colors.grey.shade400, fontSize: 11, fontFamily: "Alexandria")),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8, top: 2),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, fontFamily: "Alexandria")),
    );
  }

  Widget _settingItem({
    required FaIconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color cardColor,
    required Color textColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(11)),
              child: FaIcon(icon, color: iconColor, size: 14),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: textColor,
                          fontFamily: "Alexandria")),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 10, fontFamily: "Alexandria")),
                ],
              ),
            ),
            trailing ??
                FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.grey.shade400, size: 11),
          ],
        ),
      ),
    );
  }
}
