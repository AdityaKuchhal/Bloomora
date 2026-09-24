import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_shadows.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';

class AppBottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AppBottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// The single persistent bottom nav bar for the authenticated+onboarded
/// group (Home/Search/Progress/Profile) — rendered once by AppShell, not
/// duplicated per screen. See lib/core/router/app_shell.dart.
class AppBottomNav extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<AppBottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = ref.watch(activeColorSchemeProvider);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.border, width: 1)),
        boxShadow: AppShadows.elevation1(scheme.isDark),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < items.length; i++)
                _NavItem(
                  item: items[i],
                  selected: i == currentIndex,
                  scheme: scheme,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppBottomNavItem item;
  final bool selected;
  final AppColorScheme scheme;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.selected,
    required this.scheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? scheme.primary : scheme.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: AppTypography.caption.copyWith(
                      color: color,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
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
}
