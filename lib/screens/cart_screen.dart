import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/menu_provider.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Your Cart'),
        actions: cart.isNotEmpty
            ? [
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear cart?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          TextButton(onPressed: () { notifier.clear(); Navigator.pop(ctx); }, child: const Text('Clear')),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ]
            : null,
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: AppTheme.textTertiary),
                  const SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.menu_rounded),
                    label: const Text('Browse Menu'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
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
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primary.withOpacity(0.15),
                                  child: Text(
                                    item.name[0].toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                                  ),
                                ),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                subtitle: Text(CurrencyFormatter.formatWithDecimals(item.price) + ' each', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _QuantityButton(
                                      icon: Icons.remove_rounded,
                                      onTap: () => notifier.updateQuantity(item.id, item.quantity - 1),
                                    ),
                                    Container(
                                      width: 36,
                                      alignment: Alignment.center,
                                      child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                    ),
                                    _QuantityButton(
                                      icon: Icons.add_rounded,
                                      onTap: () => notifier.updateQuantity(item.id, item.quantity + 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [BoxShadow(color: AppTheme.textTertiary, blurRadius: 12, offset: Offset(0, -4))],
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Subtotal', value: CurrencyFormatter.format(notifier.subtotal)),
                      const SizedBox(height: 8),
                      _SummaryRow(label: 'GST (${cart.first.gstRate.toStringAsFixed(1)}%)', value: CurrencyFormatter.format(notifier.gstAmount)),
                      const SizedBox(height: 8),
                      Divider(color: AppTheme.border),
                      _SummaryRow(
                        label: 'Total',
                        value: CurrencyFormatter.format(notifier.total),
                        isBold: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/checkout'),
                          child: const Text('Proceed to Billing'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 18, color: AppTheme.textPrimary),
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