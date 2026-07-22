import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/providers.dart';
import '../../../../core/models/category.dart';
import '../../../../core/models/menu_item.dart';

class CategoryChips extends ConsumerWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final Function(String?) onSelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCategories = categories.where((c) => c.isActive).toList();
    return SizedBox(
      height: 48,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: activeCategories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAll = selectedCategoryId == null;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: 'All',
                isSelected: isAll,
                onTap: () => onSelected(null),
              ),
            );
          }
          final cat = activeCategories[index - 1];
          final isSelected = selectedCategoryId == cat.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _Chip(
              label: '${cat.emoji} ${cat.name}',
              isSelected: isSelected,
              onTap: () => onSelected(isSelected ? null : cat.id),
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGreen : AppTheme.cardWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.borderColor,
            width: 0.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppTheme.primaryGreen.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppTheme.cardWhite : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}