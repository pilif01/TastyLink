import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class MainNavigation extends ConsumerWidget {
  final Widget child;

  const MainNavigation({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentIndex = _getCurrentIndex(context);
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: AppTheme.tabSwitchDuration,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.saved,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart),
            label: l10n.shopping,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: l10n.planner,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
  
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/home':
        return 0;
      case '/saved':
        return 1;
      case '/shopping':
        return 2;
      case '/planner':
        return 3;
      case '/settings':
        return 4;
      default:
        return 0;
    }
  }
  
  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/saved');
        break;
      case 2:
        context.go('/shopping');
        break;
      case 3:
        context.go('/planner');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }
}
