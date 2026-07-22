import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';

class QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: Icons.remove_rounded,
            onTap: () => onChanged(quantity - 1),
          ),
          Container(
            width: 36,
            alignment: Alignment.center,
            child: Text(
              '$quantity',
              style: const TextStyle(
                color: AppTheme.cardWhite,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          _Btn(
            icon: Icons.add_rounded,
            onTap: () => onChanged(quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _Btn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppTheme.vibrantYellow,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppTheme.primaryGreen),
      ),
    );
  }
}