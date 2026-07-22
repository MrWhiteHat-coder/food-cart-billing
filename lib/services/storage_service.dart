import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../models/bill.dart';

class StorageService {
  static const String _categoriesKey = 'categories';
  static const String _menuItemsKey = 'menu_items';
  static const String _billsKey = 'bills';
  static const String _settingsKey = 'settings';

  late Box<String> _vault;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    await Hive.openBox<String>(_vaultBoxKey);
    _vault = Hive.box<String>(_vaultBoxKey);
    await _seedDefaults();
  }

  static const String _vaultBoxKey = 'food_cart_vault';

  Future<void> _seedDefaults() async {
    if (_vault.isEmpty) {
      final defaultCategories = [
        Category(id: 'cat_1', name: 'Main Course', emoji: '🍛', sortOrder: 0),
        Category(id: 'cat_2', name: 'Snacks', emoji: '🍿', sortOrder: 1),
        Category(id: 'cat_3', name: 'Drinks', emoji: '🥤', sortOrder: 2),
        Category(id: 'cat_4', name: 'Desserts', emoji: '🍰', sortOrder: 3),
      ];
      final defaultItems = [
        MenuItem(id: 'item_1', name: 'Paneer Butter Masala', categoryId: 'cat_1', price: 180),
        MenuItem(id: 'item_2', name: 'Chicken Curry', categoryId: 'cat_1', price: 220),
        MenuItem(id: 'item_3', name: 'Veg Biryani', categoryId: 'cat_1', price: 150),
        MenuItem(id: 'item_4', name: 'Samosa', categoryId: 'cat_2', price: 20),
        MenuItem(id: 'item_5', name: 'Vada Pav', categoryId: 'cat_2', price: 25),
        MenuItem(id: 'item_6', name: 'Pav Bhaji', categoryId: 'cat_2', price: 120),
        MenuItem(id: 'item_7', name: 'Masala Chai', categoryId: 'cat_3', price: 20),
        MenuItem(id: 'item_8', name: 'Cold Coffee', categoryId: 'cat_3', price: 60),
        MenuItem(id: 'item_9', name: 'Gulab Jamun', categoryId: 'cat_4', price: 40),
      ];

      await _vault.put(_categoriesKey, jsonEncode(defaultCategories.map((c) => c.toJson()).toList()));
      await _vault.put(_menuItemsKey, jsonEncode(defaultItems.map((i) => i.toJson()).toList()));
      await _vault.put(_billsKey, jsonEncode([]));
      await _vault.put(_settingsKey, jsonEncode({'gstRate': 5.0, 'shopName': 'My Food Cart'}));
    }
  }

  List<Category> getCategories() {
    final raw = _vault.get(_categoriesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Category.fromJson(e)).toList();
  }

  Future<void> saveCategories(List<Category> categories) async {
    await _vault.put(_categoriesKey, jsonEncode(categories.map((c) => c.toJson()).toList()));
  }

  List<MenuItem> getMenuItems() {
    final raw = _vault.get(_menuItemsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => MenuItem.fromJson(e)).toList();
  }

  Future<void> saveMenuItems(List<MenuItem> items) async {
    await _vault.put(_menuItemsKey, jsonEncode(items.map((i) => i.toJson()).toList()));
  }

  List<Bill> getBills() {
    final raw = _vault.get(_billsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    final bills = list.map((e) => Bill.fromJson(e)).toList();
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }

  Future<void> saveBill(Bill bill) async {
    final bills = getBills();
    bills.insert(0, bill);
    await _vault.put(_billsKey, jsonEncode(bills.map((b) => b.toJson()).toList()));
  }

  Future<void> updateBill(Bill bill) async {
    final bills = getBills();
    final index = bills.indexWhere((b) => b.id == bill.id);
    if (index >= 0) {
      bills[index] = bill;
    } else {
      bills.insert(0, bill);
    }
    await _vault.put(_billsKey, jsonEncode(bills.map((b) => b.toJson()).toList()));
  }

  Map<String, dynamic> getSettings() {
    final raw = _vault.get(_settingsKey);
    if (raw == null) return {'gstRate': 5.0, 'shopName': 'My Food Cart'};
    return Map<String, dynamic>.from(jsonDecode(raw));
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _vault.put(_settingsKey, jsonEncode(settings));
  }
}