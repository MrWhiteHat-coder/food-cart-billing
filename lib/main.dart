import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/currency_formatter.dart';
import 'core/utils/constants.dart';
import 'features/pos/presentation/screens/home_screen.dart';
import 'features/pos/presentation/widgets/cart_dock.dart';
import 'features/pos/data/providers.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/menu_management/presentation/screens/menu_manage_screen.dart';
import 'features/printer/presentation/screens/printer_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FoodCartApp()));
}

class FoodCartApp extends ConsumerWidget {
  const FoodCartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(storageProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: settingsAsync.when(
        data: (_) => const MainScreen(),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))),
        error: (e, st) => Scaffold(body: Center(child: Text('Error: $e', style: const TextStyle(color: AppTheme.errorRed)))),
      ),
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

  final List<Widget> _screens = const [
    HomeScreen(),
    ReportsScreen(),
    MenuManageScreen(),
    PrinterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLightGrey,
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex == 0 ? const CartDock() : null,
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        color: AppTheme.cardWhite,
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
                label: 'Reports',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              const SizedBox(width: 40),
              _NavItem(
                icon: Icons.inventory_2_rounded,
                label: 'Menu',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
              _NavItem(
                icon: Icons.print_rounded,
                label: 'Printer',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: IconTheme(
          data: IconThemeData(color: isSelected ? AppTheme.primaryGreen : AppTheme.textTertiary, size: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? AppTheme.primaryGreen : AppTheme.textTertiary)),
            ],
          ),
        ),
      ),
    );
  }
}