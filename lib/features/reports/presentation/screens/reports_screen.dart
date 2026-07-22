import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/storage_service.dart';
import '../../../../core/models/bill.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../data/providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLightGrey,
      appBar: AppBar(
        title: const Text('Sales Reports'),
        backgroundColor: AppTheme.cardWhite,
        actions: [
          IconButton(
            onPressed: () async {
              final storage = await ref.read(storageProvider.future);
              final bills = storage.getBills();
              final json = bills.map((b) => b.toJson()).toList();
              final bytes = json.toString().codeUnits;
              final tempDir = '/sdcard/Download';
              final file = File('$tempDir/backup_${DateTime.now().millisecondsSinceEpoch}.json');
              await file.writeAsBytes(bytes);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved: ${file.path}'), backgroundColor: AppTheme.primaryGreen));
            },
            icon: const Icon(Icons.download_rounded),
          ),
        ],
      ),
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded, size: 64, color: AppTheme.textTertiary),
                  const SizedBox(height: 16),
                  Text('No sales yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                ],
              ),
            );
          }

          final today = DateTime.now();
          final dailyMap = <DateTime, double>{};
          for (final bill in bills) {
            final key = DateTime(today.year, today.month, today.day).subtract(Duration(days: today.difference(bill.createdAt).inDays));
            dailyMap[key] = (dailyMap[key] ?? 0) + bill.total;
          }
          final sortedDays = dailyMap.keys.toList()..sort();
          final last7 = sortedDays.take(7).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Revenue (Last 7 Days)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: SalesChart(days: last7, data: dailyMap),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Recent Bills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 12),
                    ...bills.take(10).map((bill) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(DateFormat('dd MMM, hh:mm a').format(bill.createdAt), style: const TextStyle(color: AppTheme.textPrimary))),
                          Text(CurrencyFormatter.format(bill.total), style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
        error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.errorRed))),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final storage = await ref.read(storageProvider.future);
          final bills = storage.getBills();
          final json = bills.map((b) => b.toJson()).toList();
          final bytes = json.toString().codeUnits;
          final tempDir = '/sdcard/Download';
          final file = File('$tempDir/backup_${DateTime.now().millisecondsSinceEpoch}.json');
          await file.writeAsBytes(bytes);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Backup saved: ${file.path}'), backgroundColor: AppTheme.primaryGreen));
          }
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.download_rounded, color: AppTheme.cardWhite),
        label: const Text('Backup', style: TextStyle(color: AppTheme.cardWhite, fontWeight: FontWeight.w700)),
      ),
    );
  }
}