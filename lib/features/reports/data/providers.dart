import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/storage_service.dart';
import '../../../../core/models/bill.dart';

final billsProvider = FutureProvider<List<Bill>>((ref) async {
  final storage = await ref.watch(storageProvider.future);
  return storage.getBills();
});