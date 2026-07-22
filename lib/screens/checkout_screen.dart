import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/menu_provider.dart';
import '../../providers/bill_provider.dart';
import '../../providers/settings_provider.dart';
import '../../themes/app_theme.dart';
import '../../models/bill.dart';
import '../../utils/currency_formatter.dart';
import '../../services/pdf_service.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _customerName = '';
  String _paymentMethod = 'Cash';

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final settings = ref.watch(settingsProvider).value ?? {};

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: Text('Cart is empty', style: TextStyle(color: AppTheme.textSecondary))),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Checkout'), backgroundColor: AppTheme.card),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 16),
                  ...cart.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${item.name} x${item.quantity}', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
                        Text(CurrencyFormatter.format(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  Divider(color: AppTheme.border),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Subtotal', value: CurrencyFormatter.format(notifier.subtotal)),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'GST (${cart.first.gstRate}%)', value: CurrencyFormatter.format(notifier.gstAmount)),
                  const SizedBox(height: 8),
                  Divider(color: AppTheme.border),
                  const SizedBox(height: 8),
                  _SummaryRow(label: 'Total Payable', value: CurrencyFormatter.format(notifier.total), isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Customer Name (optional)', prefixIcon: Icon(Icons.person_outline_rounded)),
                    onSaved: (v) => _customerName = v?.trim() ?? '',
                  ),
                  const SizedBox(height: 16),
                  Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'Cash', label: Text('Cash'), icon: Icon(Icons.money_rounded)),
                      ButtonSegment(value: 'UPI', label: Text('UPI'), icon: Icon(Icons.qr_code_2_rounded)),
                      ButtonSegment(value: 'Card', label: Text('Card'), icon: Icon(Icons.credit_card_rounded)),
                    ],
                    selected: {_paymentMethod},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() => _paymentMethod = newSelection.first);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _processPayment,
                icon: const Icon(Icons.receipt_long_rounded),
                label: Text('Pay ${CurrencyFormatter.format(notifier.total)}', style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    final notifier = ref.read(cartProvider.notifier);
    final storage = await ref.read(storageProvider.future);
    final settings = storage.getSettings();
    final shopName = settings['shopName']?.toString() ?? 'My Food Cart';

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final bill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      items: List.from(ref.read(cartProvider)),
      subtotal: notifier.subtotal,
      gstRate: ref.read(cartProvider).first.gstRate,
      gstAmount: notifier.gstAmount,
      total: notifier.total,
      customerName: _customerName.isEmpty ? null : _customerName,
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now(),
    );

    if (!mounted) return;
    final receiptPath = await PdfService.generateReceiptPdf(bill, shopName);
    await storage.saveBill(bill);
    if (receiptPath != null) {
      await storage.updateBill(bill.copyWith(receiptPath: receiptPath));
    }

    notifier.clear();
    if (!mounted) return;

    // Refresh bills if visible
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      ref.invalidate(billsProvider);
      ref.invalidate(totalSalesProvider);
      ref.invalidate(billCountProvider);
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(color: AppTheme.accent.withOpacity(0.15), shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, size: 40, color: AppTheme.accent),
            ),
            const SizedBox(height: 16),
            Text('Payment Successful', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text('${CurrencyFormatter.format(bill.total)} collected', style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
          ],
        ),
        actions: [
          if (receiptPath != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                Share.shareFiles([receiptPath], text: 'Receipt from $shopName', subject: 'Receipt');
              },
              icon: const Icon(Icons.share_rounded),
              label: const Text('Share Receipt'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _SummaryRow({required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, color: AppTheme.textPrimary)),
        Text(value, style: TextStyle(fontSize: isBold ? 18 : 14, fontWeight: isBold ? FontWeight.w700 : FontWeight.w600, color: AppTheme.textPrimary)),
      ],
    );
  }
}