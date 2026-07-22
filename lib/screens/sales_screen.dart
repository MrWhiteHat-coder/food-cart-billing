import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/bill_provider.dart';
import '../../themes/app_theme.dart';
import '../../models/bill.dart';
import '../../models/cart_item.dart';
import '../../utils/currency_formatter.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.watch(billsProvider);
    final totalSalesAsync = ref.watch(totalSalesProvider);
    final billCountAsync = ref.watch(billCountProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Sales History'),
        actions: [
          IconButton(onPressed: () => _showDailyReport(context, ref), icon: const Icon(Icons.bar_chart_rounded)),
        ],
      ),
      body: billsAsync.when(
        data: (bills) {
          if (bills.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: AppTheme.textTertiary),
                  const SizedBox(height: 16),
                  Text('No sales yet', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              final date = DateFormat('dd MMM, yyyy').format(bill.createdAt);
              final time = DateFormat('hh:mm a').format(bill.createdAt);
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 300),
                child: SlideAnimation(
                  verticalOffset: 20,
                  child: FadeInAnimation(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border, width: 0.5),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.accent.withOpacity(0.15),
                          child: Icon(Icons.receipt_rounded, color: AppTheme.accent),
                        ),
                        title: Text(CurrencyFormatter.format(bill.total), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        subtitle: Text('$date • $time • ${bill.paymentMethod}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textTertiary),
                        onTap: () => _showBillDetail(context, bill),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      bottomNavigationBar: billCountAsync.when(
        data: (count) {
          final total = totalSalesAsync.value ?? 0;
          if (count == 0) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [BoxShadow(color: AppTheme.textTertiary, blurRadius: 12, offset: Offset(0, -4))],
            ),
            child: Row(
              children: [
                Expanded(child: _StatTile(label: 'Total Sales', value: CurrencyFormatter.format(total))),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(label: 'Bills', value: count.toString())),
              ],
            ),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  void _showBillDetail(BuildContext context, Bill bill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Bill Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            ...bill.items.map((item) {
              final cartItem = item as CartItem;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text('${cartItem.name} x${cartItem.quantity}', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
                  Text(CurrencyFormatter.format(cartItem.lineTotal), style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                ],
              );
            }),
            const SizedBox(height: 12),
            Divider(color: AppTheme.border),
            _SummaryRow(label: 'Total', value: CurrencyFormatter.format(bill.total)),
            if (bill.customerName != null && bill.customerName!.isNotEmpty)
              _SummaryRow(label: 'Customer', value: bill.customerName!),
            _SummaryRow(label: 'Payment', value: bill.paymentMethod),
            _SummaryRow(label: 'Date', value: DateFormat('dd MMM, yyyy hh:mm a').format(bill.createdAt)),
            const SizedBox(height: 16),
            if (bill.receiptPath != null && bill.receiptPath!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Share.shareFiles([bill.receiptPath!], text: 'Receipt', subject: 'Bill Receipt'),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share Receipt'),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
            ),
          ],
        ),
      ),
    );
  }

  void _showDailyReport(BuildContext context, WidgetRef ref) {
    final billsAsync = ref.read(billsProvider);
    final bills = billsAsync.value;
    if (bills == null) return;

    final Map<String, List<Bill>> byDay = {};
    for (final bill in bills) {
      final key = DateFormat('dd MMM yyyy').format(bill.createdAt);
      byDay.putIfAbsent(key, () => []).add(bill);
    }

    final report = byDay.entries.map((entry) {
      final total = entry.value.fold(0.0, (sum, b) => sum + b.total);
      final count = entry.value.length;
      return MapEntry(entry.key, {'total': total, 'count': count});
    }).toList()
      ..sort((a, b) => DateFormat('dd MMM yyyy').parse(a.key).compareTo(DateFormat('dd MMM yyyy').parse(b.key)));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Daily Report'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: report.length,
            itemBuilder: (context, index) {
              final entry = report[index];
              final value = entry.value;
              return ListTile(
                title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                trailing: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyFormatter.format(value['total'] as double), style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    Text('${value['count']} bills', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;

  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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