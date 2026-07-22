import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';
import '../models/bill.dart';
import '../services/storage_service.dart';

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
  final menuItemAsync = ref.watch(menuItemsProvider);
  final categoriesAsync = ref.watch(categoriesProvider);

  return menuItemAsync.when(
    data: (items) {
      final categoryMap = <String, List<MenuItem>>{};
      for (final item in items) {
        if (!categoryMap.containsKey(item.categoryId)) {
          categoryMap[item.categoryId] = [];
        }
        categoryMap[item.categoryId]!.add(item);
      }
      for (final entry in categoryMap.entries) {
        entry.value.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }
      return AsyncValue.data(categoryMap);
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
    final existing = state.indexWhere((c) => c.menuItemId == item.menuItemId);
    if (existing >= 0) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existing)
            state[i].copyWith(quantity: state[i].quantity + item.quantity)
          else
            state[i]
      ];
    } else {
      state = [...state, item];
    }
  }

  void removeItem(String id) {
    state = state.where((c) => c.id != id).toList();
  }

  void updateQuantity(String id, int quantity) {
    if (quantity <= 0) {
      removeItem(id);
      return;
    }
    state = state.map((c) => c.id == id ? c.copyWith(quantity: quantity) : c).toList();
  }

  void clear() {
    state = [];
  }

  double get subtotal {
    return state.fold(0, (sum, item) => sum + item.lineTotal);
  }

  double get gstAmount {
    final rate = state.isNotEmpty ? state.first.gstRate : 0;
    return subtotal * rate / 100;
  }

  double get total => subtotal + gstAmount;

  int get itemCount => state.fold(0, (sum, item) => sum + item.quantity);
}