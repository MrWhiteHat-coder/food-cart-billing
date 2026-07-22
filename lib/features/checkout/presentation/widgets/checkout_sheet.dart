import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/models/bill.dart';
import '../../../../features/pos/data/providers.dart';
import '../../data/providers.dart';

class CheckoutSheet extends ConsumerStatefulWidget {
  const CheckoutSheet({super.key});

  @override
  ConsumerState<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<CheckoutSheet> {
  final _formKey = GlobalKey<FormState>();
  String _customerName = '';
  String _phone = '';
  String _payment = 'Cash';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final gstAmount = ref.read(cartProvider.notifier).gstAmount;
    final total = ref.read(cartProvider.notifier).total;
    final gstRate = cart.isNotEmpty ? cart.first.gstRate : 5.0;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 20, left: 20, right: 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            const Text('Checkout', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Customer Name (optional)', prefixIcon: Icon(Icons.person_outline_rounded)),
              onSaved: (v) => _customerName = v?.trim() ?? '',
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'WhatsApp Number (optional)', prefixIcon: Icon(Icons.phone_rounded)),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                if (v.length != 10) return 'Enter 10 digit number';
                return null;
              },
              onSaved: (v) => _phone = v?.trim() ?? '',
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Cash', label: Text('Cash'), icon: Icon(Icons.money_rounded)),
                ButtonSegment(value: 'UPI', label: Text('UPI'), icon: Icon(Icons.qr_code_2_rounded)),
              ],
              selected: {_payment},
              onSelectionChanged: (Set<String> newSelection) {
                HapticFeedback.lightImpact();
                setState(() => _payment = newSelection.first);
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.backgroundLightGrey, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _Row(label: 'Subtotal', value: CurrencyFormatter.format(subtotal)),
                  _Row(label: 'GST (${gstRate.toStringAsFixed(1)}%)', value: CurrencyFormatter.format(gstAmount)),
                  Divider(color: AppTheme.borderColor),
                  _Row(label: 'Total', value: CurrencyFormatter.format(total), isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                child: _isLoading ? const CircularProgressIndicator(color: AppTheme.cardWhite) : Text('Pay ${CurrencyFormatter.format(total)}', style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    try {
      final storage = await ref.read(storageProvider.future);
      final billId = await ref.read(checkoutProvider.notifier).completeOrder(
        ref.read(cartProvider),
        ref.read(cartProvider.notifier).subtotal,
        0,
        0,
        ref.read(cartProvider).first.gstRate,
        ref.read(cartProvider.notifier).gstAmount,
        ref.read(cartProvider.notifier).total,
        storage,
      );

      if (!mounted) return;

      await _sendWhatsApp(billId);

      ref.read(cartProvider.notifier).clear();
      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful! Bill: $billId'), backgroundColor: AppTheme.primaryGreen, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendWhatsApp(String? billId) async {
    final phone = ref.read(checkoutProvider).customerPhone;
    if (phone == null || phone.isEmpty) return;

    final shopName = (await ref.read(storageProvider.future)).getSettings()['shopName']?.toString() ?? 'My Food Cart';
    final cart = ref.read(cartProvider);
    final total = ref.read(cartProvider.notifier).total;

    final buffer = StringBuffer();
    buffer.writeln('🧾 *Receipt from $shopName*');
    buffer.writeln('Bill: ${billId?.substring(0, 8)}');
    buffer.writeln('Date: ${DateTime.now().toString().substring(0, 16)}');
    buffer.writeln('---');
    for (final item in cart) {
      buffer.writeln('• ${item.name} x${item.quantity} = ${CurrencyFormatter.format(item.lineTotal)}');
    }
    buffer.writeln('---');
    buffer.writeln('Total: ${CurrencyFormatter.format(total)}');
    buffer.writeln('Payment: ${ref.read(checkoutProvider).paymentMethod}');

    final uri = Uri.parse('whatsapp://send?phone=91$phone&text=${Uri.encodeComponent(buffer.toString())}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      final alt = Uri.parse('https://wa.me/91$phone?text=${Uri.encodeComponent(buffer.toString())}');
      await launchUrl(alt, mode: LaunchMode.externalApplication);
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _Row({required this.label, required this.value, this.isBold = false});

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