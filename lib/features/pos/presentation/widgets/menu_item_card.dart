import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/models/menu_item.dart';
import '../../../../core/models/cart_item.dart';
import '../../data/providers.dart';
import '../widgets/quantity_stepper.dart';

class MenuItemCard extends ConsumerWidget {
  final MenuItem item;
  final List<CartItem> cartItems;

  MenuItemCard({
    Key? key,
    required this.item,
    required this.cartItems,
  }) : super(key: key);

  int get cartQty {
    final ci = cartItems.firstWhere((c) => c.menuItemId == item.id, orElse: () => CartItem(id: '', menuItemId: '', name: '', price: 0, quantity: 0, gstRate: 0));
    return ci.quantity;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qty = cartQty;
    final isInCart = qty > 0;

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showAddOnsSheet(context, ref);
      },
      child: AnimationConfiguration.staggeredList(
        position: 0,
        duration: const Duration(milliseconds: 300),
        child: SlideAnimation(
          verticalOffset: 20,
          child: FadeInAnimation(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLightGrey,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Center(
                        child: Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${CurrencyFormatter.format(item.price)} each',
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (isInCart)
                          QuantityStepper(
                            quantity: qty,
                            onChanged: (newQty) {
                              HapticFeedback.lightImpact();
                              ref.read(cartProvider.notifier).updateQuantityDirect(item.id, newQty);
                            },
                          )
                        else
                          InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              final gst = ref.read(storageProvider).value?.getSettings()['gstRate']?.toDouble() ?? 5.0;
                              ref.read(cartProvider.notifier).addItem(
                                CartItem(
                                  id: '${item.id}_${DateTime.now().millisecondsSinceEpoch}',
                                  menuItemId: item.id,
                                  name: item.name,
                                  price: item.price,
                                  quantity: 1,
                                  gstRate: gst,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Text(
                                'ADD',
                                style: TextStyle(
                                  color: AppTheme.cardWhite,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddOnsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.cardWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.borderColor, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Customize ${item.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Extra Cheese'),
              subtitle: const Text('+ ₹20'),
              value: false,
              onChanged: (v) {},
            ),
            SwitchListTile(
              title: const Text('Extra Spicy'),
              subtitle: const Text('+ ₹10'),
              value: false,
              onChanged: (v) {},
            ),
            ListTile(
              title: const Text('Spice Level'),
              trailing: DropdownButton<String>(
                value: 'Medium',
                items: const ['Mild', 'Medium', 'Spicy']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {},
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  HapticFeedback.lightImpact();
                  final gst = ref.read(storageProvider).value?.getSettings()['gstRate']?.toDouble() ?? 5.0;
                  ref.read(cartProvider.notifier).addItem(
                    CartItem(
                      id: '${item.id}_${DateTime.now().millisecondsSinceEpoch}',
                      menuItemId: item.id,
                      name: '${item.name} (Customized)',
                      price: item.price + 20,
                      quantity: 1,
                      gstRate: gst,
                      addOns: 'Extra Cheese',
                    ),
                  );
                },
                child: const Text('Add to Cart'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}