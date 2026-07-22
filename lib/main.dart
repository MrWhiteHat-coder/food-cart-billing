import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/menu_provider.dart';
import 'providers/bill_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/sales_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/menu_management_screen.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FoodCartApp()));
}

class FoodCartApp extends ConsumerWidget {
  const FoodCartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'FoodCart Billing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      routes: {
        '/home': (ctx) => const MainScreen(),
        '/cart': (ctx) => const CartScreen(),
        '/checkout': (ctx) => const CheckoutScreen(),
        '/sales': (ctx) => const SalesScreen(),
        '/settings': (ctx) => const SettingsScreen(),
        '/menu': (ctx) => const MenuManageScreen(),
      },
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SalesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex == 0
          ? Consumer(
              builder: (context, ref, _) {
                final cart = ref.watch(cartProvider);
                final cartCount = cart.fold(0, (sum, item) => sum + item.quantity);
                if (cartCount == 0) return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                  backgroundColor: AppTheme.primary,
                  elevation: 4,
                  icon: const Icon(Icons.shopping_bag_rounded, color: AppTheme.textPrimary),
                  label: Text('$cartCount items', style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w700)),
                );
              },
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        color: AppTheme.card,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.restaurant_menu_rounded,
                label: 'Menu',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Sales',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 40),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavItem(
                icon: Icons.inventory_2_rounded,
                label: 'Manage',
                isSelected: false,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuManageScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: IconTheme(
          data: IconThemeData(color: isSelected ? AppTheme.textPrimary : AppTheme.textTertiary, size: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppTheme.textPrimary : AppTheme.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}