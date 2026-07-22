import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../../features/pos/data/providers.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);
    final subtotal = ref.read(cartProvider.notifier).subtotal;
    final gstAmount = ref.read(cartProvider.notifier).gstAmount;
    final total = ref.read(cartProvider.notifier).total;
    final gstRate = cart.isNotEmpty ? cart.first.gstRate : AppConstants.defaultGstRate;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLightGrey,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.cardWhite,
      ),
      body: ListView(
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
                const Text('Order Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                ...cart.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.name} x${item.quantity}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
                      Text(CurrencyFormatter.format(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    ],
                  ),
                )),
                const SizedBox(height: 8),
                Divider(color: AppTheme.borderColor),
                const SizedBox(height: 8),
                _Row(label: 'Subtotal', value: CurrencyFormatter.format(subtotal)),
                const SizedBox(height: 4),
                _Row(label: 'GST (${gstRate.toStringAsFixed(1)}%)', value: CurrencyFormatter.format(gstAmount)),
                const SizedBox(height: 4),
                _Row(label: 'Total', value: CurrencyFormatter.format(total), isBold: true),
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
                const Text('Customer Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                  onChanged: ref.read(checkoutProvider.notifier).updateName,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'WhatsApp Number (10 digits)', prefixIcon: Icon(Icons.phone_rounded)),
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  onChanged: ref.read(checkoutProvider.notifier).updatePhone,
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
                const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Cash', label: Text('Cash'), icon: Icon(Icons.money_rounded)),
                    ButtonSegment(value: 'UPI', label: Text('UPI'), icon: Icon(Icons.qr_code_2_rounded)),
                  ],
                  selected: {ref.read(checkoutProvider).paymentMethod},
                  onSelectionChanged: (Set<String> newSelection) {
                    ref.read(checkoutProvider.notifier).updatePaymentMethod(newSelection.first);
                  },
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
                const Text('Quick Cash', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 12),
                Row(
                  children: [100, 200, 500, 1000].map((amt) {
                    final change = amt - total;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('Change to return'),
                                content: Text(CurrencyFormatter.format(change > 0 ? change : 0)),
                                actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                              ),
                            );
                          },
                          style: ElevatedButton(
                            backgroundColor: AppTheme.primaryGreen,
                            foregroundColor: AppTheme.cardWhite,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ).copyWith(elevation: const WidgetStatePropertyAll(0)),
                          child: Text('₹$amt', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () async {
                final storage = await ref.read(storageProvider.future);
                await ref.read(checkoutProvider.notifier).completeOrder(
                  cart,
                  subtotal,
                  0,
                  0,
                  gstRate,
                  gstAmount,
                  total,
                  storage,
                );
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bill saved successfully!'), backgroundColor: AppTheme.primaryGreen, behavior: SnackBarBehavior.floating),
                );
              },
              icon: const Icon(Icons.receipt_long_rounded),
              label: Text('Pay ${CurrencyFormatter.format(total)}', style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
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