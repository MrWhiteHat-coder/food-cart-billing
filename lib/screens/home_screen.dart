import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/menu_item_card.dart';
import '../../themes/app_theme.dart';
import '../../models/menu_item.dart';
import '../../models/category.dart';
import '../../models/cart_item.dart';
import '../../utils/currency_formatter.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final menuMapAsync = ref.watch(menuProvider);
    final cart = ref.watch(cartProvider);
    final cartCount = cart.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Search menu items...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.tune_rounded),
                      onPressed: () => _showFilterBottomSheet(context, categoriesAsync.value),
                    ),
                  ),
                ],
              ),
            ),
            categoriesAsync.when(
              data: (categories) {
                final activeCategories = categories.where((c) => c.isActive).toList();
                return SizedBox(
                  height: 56,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: activeCategories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = selectedCategoryId == null;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _CategoryChip(
                            label: 'All',
                            isSelected: isSelected,
                            onTap: () => setState(() => selectedCategoryId = null),
                          ),
                        );
                      }
                      final category = activeCategories[index - 1];
                      final isSelected = selectedCategoryId == category.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _CategoryChip(
                          label: '${category.emoji} ${category.name}',
                          isSelected: isSelected,
                          onTap: () => setState(() {
                            selectedCategoryId = isSelected ? null : category.id;
                          }),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: menuMapAsync.when(
                data: (menuMap) {
                  var items = <MenuItem>[];
                  if (selectedCategoryId == null) {
                    for (final list in menuMap.values) {
                      items.addAll(list.where((i) => i.isAvailable));
                    }
                  } else {
                    items = menuMap[selectedCategoryId] ?? [];
                    items = items.where((i) => i.isAvailable).toList();
                  }
                  if (_searchQuery.isNotEmpty) {
                    items = items.where((i) => i.name.toLowerCase().contains(_searchQuery)).toList();
                  }
                  items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: AppTheme.textTertiary),
                          const SizedBox(height: 16),
                          Text('No items found', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isInCart = cart.any((c) => c.menuItemId == item.id);
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 300),
                        child: SlideAnimation(
                          verticalOffset: 20,
                          child: FadeInAnimation(
                            child: MenuItemCard(
                              item: item,
                              onAdd: () => _addToCart(item),
                              isInCart: isInCart,
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
            ),
          ],
        ),
      ),
      floatingActionButton: cartCount > 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              backgroundColor: AppTheme.primary,
              elevation: 4,
              icon: const Icon(Icons.shopping_bag_rounded, color: AppTheme.textPrimary),
              label: Text('$cartCount • ${ref.read(cartProvider.notifier).total > 0 ? CurrencyFormatter.format(ref.read(cartProvider.notifier).total) : '₹0'}', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
            )
          : null,
    );
  }

  void _addToCart(MenuItem item) {
    final cartItem = CartItem(
      id: '${item.id}_${DateTime.now().millisecondsSinceEpoch}',
      menuItemId: item.id,
      name: item.name,
      price: item.price,
      quantity: 1,
      gstRate: ref.read(settingsProvider).value?['gstRate']?.toDouble() ?? 5.0,
      imageAsset: item.imageAsset,
    );
    ref.read(cartProvider.notifier).addItem(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, List<Category>? categories) {
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
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text('Filter by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: selectedCategoryId == null,
                  onSelected: (v) {
                    setState(() => selectedCategoryId = null);
                    Navigator.pop(ctx);
                  },
                  selectedColor: AppTheme.primary.withOpacity(0.3),
                ),
                ...?categories?.map((c) => FilterChip(
                  label: Text('${c.emoji} ${c.name}'),
                  selected: selectedCategoryId == c.id,
                  onSelected: (v) {
                    setState(() => selectedCategoryId = v ? c.id : null);
                    Navigator.pop(ctx);
                  },
                  selectedColor: AppTheme.primary.withOpacity(0.3),
                )),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppTheme.primary : AppTheme.border, width: 0.5),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}