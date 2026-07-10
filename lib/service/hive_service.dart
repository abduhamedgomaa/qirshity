import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String boxName = "qirshityBox";

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(boxName);
  }

  static Future<void> saveUser({
    required String username,
    required double income,
    required double expense,
    required String gender,
    required bool isLogin,
    required double balance,
  }) async {
    var box = Hive.box(boxName);
    await box.put("username", username);
    await box.put("income", income);
    await box.put("expense", expense);
    await box.put("gender", gender);
    await box.put("isLogin", isLogin);
    await box.put("balance", balance);
  }

  static Future<bool> saveTransaction({
    required double amount,
    required String type,
    required List<String> tags,
    required String date,
  }) async {
    var box = Hive.box(boxName);
    double currentBalance = (box.get("balance", defaultValue: 0.0) as num).toDouble();
    double currentIncome = (box.get("income", defaultValue: 0.0) as num).toDouble();
    double currentExpense = (box.get("expense", defaultValue: 0.0) as num).toDouble();
    List transactions = box.get("transactions", defaultValue: []);

    if (type == 'مصروف' && currentBalance < amount) return false;

    if (type == 'مصروف') {
      currentBalance -= amount;
      currentExpense += amount;
    } else {
      currentBalance += amount;
      currentIncome += amount;
    }

    transactions.add({'amount': amount, 'type': type, 'tags': tags, 'date': date});

    await box.put("balance", currentBalance);
    await box.put("income", currentIncome);
    await box.put("expense", currentExpense);
    await box.put("transactions", transactions);

    return true;
  }

  static Future<void> addCustomTag({
    required String name,
    required int iconCodePoint,
    required int colorValue,
    required String type,
  }) async {
    var box = Hive.box(boxName);
    List customTags = List.from(box.get('custom_tags', defaultValue: []));
    customTags.add({'name': name, 'icon': iconCodePoint, 'color': colorValue, 'type': type});
    await box.put('custom_tags', customTags);
  }

  static Future<void> deleteCustomTag(String tagName) async {
    var box = Hive.box(boxName);
    List customTags = List.from(box.get('custom_tags', defaultValue: []));
    customTags.removeWhere((tag) => tag['name'] == tagName);
    await box.put('custom_tags', customTags);
  }

  static Future<void> deleteGoal(int index) async {
    var box = Hive.box(boxName);
    List goals = List.from(box.get("goals", defaultValue: []));
    if (index >= 0 && index < goals.length) {
      goals.removeAt(index);
      await box.put("goals", goals);
    }
  }

  static Future<void> clearAllData() async {
    await Hive.box(boxName).clear();
  }
}
