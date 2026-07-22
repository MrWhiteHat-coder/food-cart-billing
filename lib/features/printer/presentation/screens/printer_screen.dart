import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/providers.dart';

class PrinterScreen extends ConsumerWidget {
  const PrinterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerState = ref.watch(printerProvider);
    final scanResults = ref.read(printerProvider.notifier).scanResults;
    final connectedDevice = ref.read(printerProvider.notifier).connectedDevice;
    final isScanning = ref.read(printerProvider.notifier).isScanning;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLightGrey,
      appBar: AppBar(
        title: const Text('Bluetooth Printer'),
        backgroundColor: AppTheme.cardWhite,
        actions: [
          if (connectedDevice != null)
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(printerProvider.notifier).disconnect();
              },
              icon: const Icon(Icons.bluetooth_disabled_rounded, color: AppTheme.errorRed),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (connectedDevice != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryGreen),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bluetooth_connected_rounded, color: AppTheme.primaryGreen),
                    const SizedBox(width: 12),
                    Expanded(child: Text('${connectedDevice.platformName} (Connected)', style: const TextStyle(fontWeight: FontWeight.w600))),
                    Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.vibrantYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.vibrantYellow),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bluetooth_searching_rounded, color: AppTheme.vibrantYellow),
                    SizedBox(width: 12),
                    Expanded(child: Text('No printer connected', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isScanning
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            ref.read(printerProvider.notifier).startScan();
                          },
                    icon: const Icon(Icons.search_rounded),
                    label: Text(isScanning ? 'Scanning...' : 'Scan Printers'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isScanning
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            ref.read(printerProvider.notifier).stopScan();
                          },
                    style: ElevatedButton(backgroundColor: AppTheme.vibrantYellow, foregroundColor: AppTheme.textPrimary).copyWith(elevation: const WidgetStatePropertyAll(0)),
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('Stop'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: scanResults.isEmpty
                  ? Center(child: Text(isScanning ? 'Scanning for printers...' : 'No printers found. Tap Scan to search.', style: TextStyle(color: AppTheme.textSecondary)))
                  : ListView.builder(
                      itemCount: scanResults.length,
                      itemBuilder: (context, index) {
                        final result = scanResults[index];
                        return PrinterItemTile(result: result, onConnect: () async {
                          HapticFeedback.lightImpact();
                          await ref.read(printerProvider.notifier).connect(result.device);
                        });
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrinterItemTile extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onConnect;

  const PrinterItemTile({super.key, required this.result, required this.onConnect});

  @override
  Widget build(BuildContext context) {
    final device = result.device;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.print_rounded, color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(device.platformName.isNotEmpty ? device.platformName : 'Unknown Printer', style: const TextStyle(fontWeight: FontWeight.w600))),
          TextButton.icon(
            onPressed: onConnect,
            icon: const Icon(Icons.bluetooth_rounded, size: 18),
            label: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}