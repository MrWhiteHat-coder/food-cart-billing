import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'menu_provider.dart';

final settingsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final storage = await ref.watch(storageProvider.future);
  return storage.getSettings();
});

class SettingsNotifier extends StateNotifier<AsyncValue<void>> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(const AsyncValue.data(null));

  Future<void> updateGstRate(double rate) async {
    final settings = _storage.getSettings();
    settings['gstRate'] = rate;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _storage.saveSettings(settings));
  }

  Future<void> updateShopName(String name) async {
    final settings = _storage.getSettings();
    settings['shopName'] = name;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _storage.saveSettings(settings));
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, AsyncValue<void>>((ref) {
  final storageAsync = ref.watch(storageProvider);
  return SettingsNotifier(storageAsync.value!);
});