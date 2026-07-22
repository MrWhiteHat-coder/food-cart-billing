import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/settings_provider.dart';
import '../../providers/menu_provider.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppTheme.card,
      ),
      body: settingsAsync.when(
        data: (settings) {
          final shopNameController = TextEditingController(text: settings['shopName']?.toString() ?? 'My Food Cart');
          final gstController = TextEditingController(text: (settings['gstRate']?.toDouble() ?? 5.0).toString());

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shop Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: shopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Shop Name',
                        prefixIcon: Icon(Icons.store_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: gstController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'GST Rate (%)',
                        prefixIcon: Icon(Icons.percent_rounded),
                        suffixText: '%',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final newRate = double.tryParse(gstController.text.trim());
                          if (newRate == null || newRate < 0 || newRate > 100) return;
                          final storage = await ref.read(storageProvider.future);
                          final settings = storage.getSettings();
                          settings['gstRate'] = newRate;
                          storage.saveSettings(settings);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved'), behavior: SnackBarBehavior.floating));
                          ref.invalidate(settingsProvider);
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('Save Settings'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('App Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    _InfoRow(label: 'Version', value: '1.0.0'),
                    _InfoRow(label: 'Currency', value: 'Indian Rupee (₹)'),
                    _InfoRow(label: 'Storage', value: 'Local Device'),
                    _InfoRow(label: 'Internet', value: 'Not Required'),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}