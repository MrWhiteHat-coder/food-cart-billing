import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/category.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_provider.dart';
import '../../themes/app_theme.dart';
import '../../utils/currency_formatter.dart';

class MenuManageScreen extends ConsumerWidget {
  const MenuManageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final menuItems = ref.watch(menuItemsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(onPressed: () => _addCategory(context, ref), icon: const Icon(Icons.add_circle_outline_rounded)),
        ],
      ),
      body: categoriesAsync.when(
        data: (categories) {
          final activeCategories = categories.where((c) => c.isActive).toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeCategories.length,
            itemBuilder: (context, index) {
              final category = activeCategories[index];
              final items = menuItems.where((i) => i.categoryId == category.id).toList();
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border, width: 0.5),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(category.emoji, style: const TextStyle(fontSize: 20))),
                    ),
                    title: Text(category.name, style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary, fontSize: 16)),
                    subtitle: Text('${items.length} items', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(onPressed: () => _editCategory(context, ref, category), icon: const Icon(Icons.edit_rounded, size: 20)),
                        IconButton(onPressed: () => _deleteCategory(context, ref, category), icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppTheme.danger)),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.add, size: 20, color: AppTheme.primaryDark.withOpacity(0.8)),
                            label: Text('Add item', style: TextStyle(color: AppTheme.primaryDark.withOpacity(0.8), fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, ref),
        backgroundColor: AppTheme.primary,
        icon: Icon(Icons.add_rounded, color: AppTheme.textPrimary),
        label: Text('Add Item', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _addCategory(BuildContext context, WidgetRef ref) {
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
              final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
              final newCat = Category(id: id, name: nameController.text.trim(), emoji: emojiController.text.trim());
              final storage = await ref.read(storageProvider.future);
              final cats = storage.getCategories();
              cats.add(newCat);
              await storage.saveCategories(cats);
              ref.invalidate(categoriesProvider);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editCategory(BuildContext context, WidgetRef ref, Category category) {
    final nameController = TextEditingController(text: category.name);
    final emojiController = TextEditingController(text: category.emoji);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Category'),
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
              final updated = category.copyWith(name: nameController.text.trim(), emoji: emojiController.text.trim());
              final storage = await ref.read(storageProvider.future);
              final cats = storage.getCategories();
              final idx = cats.indexWhere((c) => c.id == updated.id);
              if (idx >= 0) {
                cats[idx] = updated;
                await storage.saveCategories(cats);
                ref.invalidate(categoriesProvider);
                ref.invalidate(menuProvider);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(BuildContext context, WidgetRef ref, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Category?'),
        content: Text('This will delete "${category.name}" and all its items. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final storage = await ref.read(storageProvider.future);
              final cats = storage.getCategories();
              final idx = cats.indexWhere((c) => c.id == category.id);
              if (idx >= 0) {
                cats[idx] = category.copyWith(isActive: false);
                await storage.saveCategories(cats);
                ref.invalidate(categoriesProvider);
                ref.invalidate(menuProvider);
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final categories = ref.read(categoriesProvider).value ?? [];
    if (categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a category first')));
      return;
    }

    final nameController = TextEditingController();
    final priceController = TextEditingController();
    String selectedCategoryId = categories.firstWhere((c) => c.isActive).id;
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Add Menu Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Item Name')),
            const SizedBox(height: 12),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (₹)', prefixText: '₹ ')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.where((c) => c.isActive)
                  .map((c) => DropdownMenuItem(value: c.id, child: Row(children: [Text(c.emoji, style: TextStyle(fontSize: 18)), const SizedBox(width: 8), Text(c.name)])))
                  .toList(),
              onChanged: (v) => selectedCategoryId = v ?? selectedCategoryId,
            ),
            const SizedBox(height: 12),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description (optional)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty || priceController.text.trim().isEmpty) return;
              final id = 'item_${DateTime.now().millisecondsSinceEpoch}';
              final newItem = MenuItem(
                id: id,
                name: nameController.text.trim(),
                categoryId: selectedCategoryId,
                price: double.tryParse(priceController.text.trim()) ?? 0,
                description: descController.text.trim().isEmpty ? null : descController.text.trim(),
              );
              final items = ref.read(menuItemsProvider).value ?? [];
              items.add(newItem);
              final storage = await ref.read(storageProvider.future);
              await storage.saveMenuItems(items);
              ref.invalidate(menuItemsProvider);
              ref.invalidate(menuProvider);
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${newItem.name} added'), behavior: SnackBarBehavior.floating));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}