import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/database/storage_service.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/menu_item.dart';
import '../../../../core/models/cart_item.dart';

final storageProvider = FutureProvider<StorageService>((ref) async {
  final service = StorageService();
  await service.init();
  return service;
});

final categoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  final storage = ref.watch(storageProvider).value;
  if (storage == null) return const AsyncValue.data([]);
  return AsyncValue.data(storage.getCategories());
});

final menuItemsProvider = Provider<AsyncValue<List<MenuItem>>>((ref) {
  final storage = ref.watch(storageProvider).value;
  if (storage == null) return const AsyncValue.data([]);
  return AsyncValue.data(storage.getMenuItems());
});

final menuProvider = Provider<AsyncValue<Map<String, List<MenuItem>>>>((ref) {
  final menuItems = ref.watch(menuItemsProvider);
  final categories = ref.watch(categoriesProvider);
  return menuItems.when(
    data: (items) {
      final map = <String, List<MenuItem>>{};
      for (final item in items) {
        map.putIfAbsent(item.categoryId, () => []).add(item);
      }
      for (final entry in map.entries) {
        entry.value.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
      return AsyncValue.data(map);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem item) {
    final idx = state.indexWhere((c) => c.menuItemId == item.menuItemId);
    if (idx >= 0) {
      final existing = state[idx];
      state = state.map((c) {
        if (c.menuItemId == item.menuItemId) {
          return c.copyWith(quantity: c.quantity + item.quantity);
        }
        return c;
      }).toList();
    } else {
      state = [...state, item];
    }
    HapticFeedback.lightImpact();
  }

  void updateQuantity(String menuItemId, int delta) {
    final idx = state.indexWhere((c) => c.menuItemId == menuItemId);
    if (idx < 0) return;
    final current = state[idx];
    final newQty = current.quantity + delta;
    if (newQty <= 0) {
      state = state.where((c) => c.menuItemId != menuItemId).toList();
    } else {
      state = state.map((c) {
        if (c.menuItemId == menuItemId) return c.copyWith(quantity: newQty);
        return c;
      }).toList();
    }
    HapticFeedback.lightImpact();
  }

  void updateQuantityDirect(String menuItemId, int quantity) {
    if (quantity <= 0) {
      state = state.where((c) => c.menuItemId != menuItemId).toList();
      return;
    }
    final idx = state.indexWhere((c) => c.menuItemId == menuItemId);
    if (idx >= 0) {
      state = state.map((c) {
        if (c.menuItemId == menuItemId) return c.copyWith(quantity: quantity);
        return c;
      }).toList();
    }
    HapticFeedback.lightImpact();
  }

  void clear() {
    state = [];
    HapticFeedback.lightImpact();
  }

  double get subtotal => state.fold(0, (sum, c) => sum + c.lineTotal);
  double get gstAmount => subtotal * (state.isNotEmpty ? state.first.gstRate : 0) / 100;
  double get total => subtotal + gstAmount;
  int get itemCount => state.fold(0, (sum, c) => sum + c.quantity);
}