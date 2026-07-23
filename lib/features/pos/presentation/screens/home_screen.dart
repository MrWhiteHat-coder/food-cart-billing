import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/providers.dart';
import '../../../../core/models/menu_item.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/category_chip.dart';

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
    final categories = ref.watch(categoriesProvider).value ?? [];
    final menuMap = ref.watch(menuProvider).value ?? {};
    final cart = ref.watch(cartProvider);

    var items = <MenuItem>[];
    if (selectedCategoryId == null) {
      for (final list in menuMap.values) {
        items.addAll(list);
      }
    } else {
      items = menuMap[selectedCategoryId] ?? [];
    }
    items = items.where((i) => i.isAvailable).toList();
    if (_searchQuery.isNotEmpty) {
      items = items.where((i) => i.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Scaffold(
      backgroundColor: AppTheme.backgroundLightGrey,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    HapticFeedback.lightImpact();
                    setState(() => _searchQuery = v);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search for items...',
                    hintStyle: TextStyle(color: AppTheme.textTertiary, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textTertiary, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: Icon(Icons.clear_rounded, size: 18, color: AppTheme.textTertiary),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            CategoryChips(
              categories: categories,
              selectedCategoryId: selectedCategoryId,
              onSelected: (id) {
                HapticFeedback.lightImpact();
                setState(() => selectedCategoryId = id);
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return MenuItemCard(item: item, cartItems: cart);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}