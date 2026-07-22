import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';

class StorageService {
  static const String boxName = 'food_cart_vault';
  static Box<dynamic>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(boxName);

    if (_box!.isEmpty) {
      await _seedDefaults();
    }
  }

  static Box<dynamic> get box {
    if (_box == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _box!;
  }

  static Future<void> _seedDefaults() async {
    final defaultCategories = [
      {'id': 'cat_1', 'name': 'Main Course', 'emoji': '🍛', 'sortOrder': 1, 'isActive': true},
      {'id': 'cat_2', 'name': 'Snacks', 'emoji': '🍿', 'sortOrder': 2, 'isActive': true},
      {'id': 'cat_3', 'name': 'Drinks', 'emoji': '🥤', 'sortOrder': 3, 'isActive': true},
      {'id': 'cat_4', 'name': 'Desserts', 'emoji': '🍰', 'sortOrder': 4, 'isActive': true},
    ];

    final defaultMenuItems = [
      {'id': 'menu_1', 'name': 'Paneer Butter Masala', 'categoryId': 'cat_1', 'price': 180.0, 'description': 'Creamy paneer curry', 'isAvailable': true, 'sortOrder': 1},
      {'id': 'menu_2', 'name': 'Chicken Curry', 'categoryId': 'cat_1', 'price': 220.0, 'description': 'Spicy chicken curry', 'isAvailable': true, 'sortOrder': 2},
      {'id': 'menu_3', 'name': 'Veg Biryani', 'categoryId': 'cat_1', 'price': 150.0, 'description': 'Fragrant veg biryani', 'isAvailable': true, 'sortOrder': 3},
      {'id': 'menu_4', 'name': 'Samosa', 'categoryId': 'cat_2', 'price': 20.0, 'description': 'Crispy samosa', 'isAvailable': true, 'sortOrder': 1},
      {'id': 'menu_5', 'name': 'Vada Pav', 'categoryId': 'cat_2', 'price': 25.0, 'description': 'Mumbai street vada pav', 'isAvailable': true, 'sortOrder': 2},
      {'id': 'menu_6', 'name': 'Pav Bhaji', 'categoryId': 'cat_2', 'price': 120.0, 'description': 'Buttery pav bhaji', 'isAvailable': true, 'sortOrder': 3},
      {'id': 'menu_7', 'name': 'Masala Chai', 'categoryId': 'cat_3', 'price': 20.0, 'description': 'Hot masala chai', 'isAvailable': true, 'sortOrder': 1},
      {'id': 'menu_8', 'name': 'Cold Coffee', 'categoryId': 'cat_3', 'price': 60.0, 'description': 'Chilled cold coffee', 'isAvailable': true, 'sortOrder': 2},
      {'id': 'menu_9', 'name': 'Gulab Jamun', 'categoryId': 'cat_4', 'price': 40.0, 'description': 'Sweet gulab jamun', 'isAvailable': true, 'sortOrder': 1},
    ];

    final defaultSettings = {
      'gstRate': AppConstants.defaultGstRate,
      'shopName': 'My Food Cart',
      'currency': '₹',
    };

    await box.put('categories', jsonEncode(defaultCategories));
    await box.put('menu_items', jsonEncode(defaultMenuItems));
    await box.put('bills', jsonEncode(<Map<String, dynamic>>[]));
    await box.put('settings', jsonEncode(defaultSettings));
  }

  static List<Map<String, dynamic>> getCategories() {
    final raw = box.get('categories');
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw.toString());
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> saveCategories(List<Map<String, dynamic>> categories) async {
    await box.put('categories', jsonEncode(categories));
  }

  static List<Map<String, dynamic>> getMenuItems() {
    final raw = box.get('menu_items');
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw.toString());
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> saveMenuItems(List<Map<String, dynamic>> menuItems) async {
    await box.put('menu_items', jsonEncode(menuItems));
  }

  static List<Map<String, dynamic>> getBills() {
    final raw = box.get('bills');
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw.toString());
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> saveBill(Map<String, dynamic> bill) async {
    final bills = getBills();
    bills.add(bill);
    await box.put('bills', jsonEncode(bills));
  }

  static Future<void> updateBill(int index, Map<String, dynamic> updatedBill) async {
    final bills = getBills();
    if (index >= 0 && index < bills.length) {
      bills[index] = updatedBill;
      await box.put('bills', jsonEncode(bills));
    }
  }

  static Map<String, dynamic> getSettings() {
    final raw = box.get('settings');
    if (raw == null) {
      return {
        'gstRate': AppConstants.defaultGstRate,
        'shopName': 'My Food Cart',
        'currency': '₹',
      };
    }
    final decoded = jsonDecode(raw.toString());
    return Map<String, dynamic>.from(decoded);
  }

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await box.put('settings', jsonEncode(settings));
  }
}
