import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/menu_item.dart';
import '../../../../features/pos/data/providers.dart';

class MenuManageScreen extends ConsumerWidget {
  const MenuManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? [];
    final menuItems = ref.watch(menuItemsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLightGrey,
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: AppTheme.cardWhite,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _showCategoryDialog(context, ref);
            },
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final items = menuItems.where((i) => i.categoryId == category.id).toList();
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor, width: 0.5),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(category.emoji, style: const TextStyle(fontSize: 20))),
                ),
                title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textPrimary)),
                subtitle: Text('${items.length} items', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () => _showItemDialog(context, ref, category.id),
                        icon: Icon(Icons.add_rounded, color: AppTheme.primaryGreen.withOpacity(0.8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emojiController = TextEditingController(text: '🍽️');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Category Name')),
            const SizedBox(height: 12),
            TextField(controller: emojiController, decoration: const InputDecoration(labelText: 'Emoji')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final storage = await ref.read(storageProvider.future);
              final cats = storage.getCategories();
              cats.add(Category(id: 'cat_${DateTime.now().millisecondsSinceEpoch}', name: nameController.text.trim(), emoji: emojiController.text.trim()));
              await storage.saveCategories(cats);
              ref.invalidate(categoriesProvider);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showItemDialog(BuildContext context, WidgetRef ref, String categoryId) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Menu Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
            const SizedBox(height: 12),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹)', prefixText: '₹ ')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty) return;
              final storage = await ref.read(storageProvider.future);
              final items = storage.getMenuItems();
              items.add(MenuItem(
                id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text.trim(),
                categoryId: categoryId,
                price: double.tryParse(priceController.text.trim()) ?? 0,
              ));
              await storage.saveMenuItems(items);
              ref.invalidate(menuItemsProvider);
              ref.invalidate(menuProvider);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}