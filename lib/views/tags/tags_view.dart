import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qirshity/service/hive_service.dart';
import 'package:qirshity/views/tags/add_tag_view.dart';

class TagsScreen extends StatefulWidget {
  const TagsScreen({super.key});

  @override
  State<TagsScreen> createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final box = Hive.box(HiveService.boxName);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F7FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
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
              title: const Text('تصنيفاتي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "Alexandria")),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, Color.lerp(primaryColor, Colors.purple, 0.5)!],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 30,
                      left: 30,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 100,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: box.listenable(),
            builder: (context, Box box, _) {
              List customTags = box.get('custom_tags', defaultValue: []);

              if (customTags.isEmpty) {
                return SliverFillRemaining(
                  child: FadeTransition(
                    opacity: CurvedAnimation(parent: _animController, curve: Curves.easeOut),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: FaIcon(FontAwesomeIcons.tags, size: 50, color: primaryColor.withOpacity(0.4)),
                          ),
                          const SizedBox(height: 20),
                          Text('لا يوجد تصنيفات مخصصة بعد',
                              style: TextStyle(color: isDark ? Colors.white54 : Colors.black45, fontSize: 13, fontFamily: "Alexandria")),
                          const SizedBox(height: 10),
                          Text('اضغط + لإضافة تصنيف جديد',
                              style: TextStyle(color: primaryColor.withOpacity(0.7), fontSize: 13, fontFamily: "Alexandria")),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tag = customTags[index];
                      final Color tagColor = Color(tag['color']);
                      final bool isExpense = tag['type'] == 'مصروف';

                      return TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 300 + (index * 80)),
                        tween: Tween(begin: 0, end: 1),
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Transform.translate(offset: Offset(30 * (1 - value), 0), child: child),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(color: tagColor.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 6)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Container(width: 5, color: tagColor),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: tagColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: FaIcon(FaIconData(IconData(tag['icon'], fontFamily: 'FontAwesomeSolid', fontPackage: 'font_awesome_flutter')), color: tagColor, size: 20),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(tag['name'],
                                                    style: TextStyle(
                                                        color: isDark ? Colors.white : Colors.black87,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                        fontFamily: "Alexandria")),
                                                const SizedBox(height: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: (isExpense ? Colors.red : Colors.green).withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      FaIcon(
                                                        isExpense ? FontAwesomeIcons.arrowUp : FontAwesomeIcons.arrowDown,
                                                        size: 9,
                                                        color: isExpense ? Colors.red : Colors.green,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        tag['type'],
                                                        style: TextStyle(
                                                          color: isExpense ? Colors.red : Colors.green,
                                                          fontSize: 11,
                                                          fontWeight: FontWeight.bold,
                                                          fontFamily: "Alexandria",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () => _showDeleteDialog(context, index, tag['name'], isDark, primaryColor),
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const FaIcon(FontAwesomeIcons.trash, color: Colors.red, size: 14),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: customTags.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTagScreen())),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        label: const Text('تصنيف جديد', style: TextStyle(fontFamily: "Alexandria", fontWeight: FontWeight.bold)),
        icon: const FaIcon(FontAwesomeIcons.plus, size: 14),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index, String tagName, bool isDark, Color primaryColor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(child: const FaIcon(FontAwesomeIcons.triangleExclamation, color: Colors.red, size: 24)),
        ),
        title: Text('حذف التصنيف',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Alexandria", fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        content: Text('هل تريد حذف "$tagName"؟\nسيتم إزالته نهائياً من القائمة.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: "Alexandria", fontSize: 13, color: isDark ? Colors.white60 : Colors.black54)),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('إلغاء', style: TextStyle(color: Colors.grey, fontFamily: "Alexandria")),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final box = Hive.box(HiveService.boxName);
                    List customTags = List.from(box.get('custom_tags', defaultValue: []));
                    customTags.removeAt(index);
                    box.put('custom_tags', customTags);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('حذف', style: TextStyle(fontFamily: "Alexandria", fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
