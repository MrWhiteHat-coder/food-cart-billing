import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'menu_provider.dart';
import '../services/storage_service.dart';
import '../models/bill.dart';
import '../models/cart_item.dart';

final billsProvider = FutureProvider<List<Bill>>((ref) async {
  final storage = await ref.watch(storageProvider.future);
  return storage.getBills();
});

final totalSalesProvider = Provider<AsyncValue<double>>((ref) {
  final billsAsync = ref.watch(billsProvider);
  return billsAsync.when(
    data: (bills) => AsyncValue.data(bills.fold(0, (sum, b) => sum + b.total)),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

final billCountProvider = Provider<AsyncValue<int>>((ref) {
  final billsAsync = ref.watch(billsProvider);
  return billsAsync.when(
    data: (bills) => AsyncValue.data(bills.length),
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

class BillNotifier extends StateNotifier<AsyncValue<void>> {
  final StorageService _storage;

  BillNotifier(this._storage) : super(const AsyncValue.data(null));

  Future<void> addBill(Bill bill) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _storage.saveBill(bill));
  }

  Future<void> saveReceipt(Bill bill, String? path) async {
    if (path == null) return;
    final updated = bill.copyWith(receiptPath: path);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _storage.updateBill(updated));
  }
}

final billNotifierProvider = StateNotifierProvider<BillNotifier, AsyncValue<void>>((ref) {
  final storageAsync = ref.watch(storageProvider);
  return BillNotifier(storageAsync.value!);
});