import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/state/providers.dart';
import 'package:ipotapp/utils/color_utils.dart';

import '../screens/menu/providers/qr_scan.provider.dart';

/// Shared glass app bar (used by [AppShellScreen] and [AppScaffold]).
class GlobalGlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalGlassAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final resolvedLeading =
        leading ??
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.restaurant, color: AppColors.primary),
        );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AppBar(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.80),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          leadingWidth: 56,
          leading: resolvedLeading,
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: actions,
        ),
      ),
    );
  }
}

/// Bottom nav for the root shell only — updates index, no [Navigator] transition.
class AppBottomNavigationBar extends ConsumerWidget {
  const AppBottomNavigationBar({super.key});

  /// Base content height (icon + label + padding). Must be a **tight** height: the
  /// scaffold bottom slot often passes a very large `maxHeight`; unconstrained
  /// children like [Center] would otherwise expand and steal the whole screen.
  static double _barHeight(BuildContext context) {
    final scaled = MediaQuery.textScalerOf(context).scale(92);
    return scaled.clamp(80, 128);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = ref.watch(bottomNavIndexProvider);
    final h = _barHeight(context);

    return SafeArea(
      top: false,
      child: SizedBox(
        height: h,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.80),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _NavItem(
                      selected: idx == 0,
                      icon: Icons.menu_book_outlined,
                      label: 'Menu',
                      onTap: () =>
                          ref.read(bottomNavIndexProvider.notifier).state = 0,
                    ),
                    _NavItem(
                      selected: idx == 1,
                      icon: Icons.shopping_cart_outlined,
                      label: 'Cart',
                      onTap: () =>
                          ref.read(bottomNavIndexProvider.notifier).state = 1,
                    ),
                    _NavItem(
                      selected: idx == 2,
                      icon: Icons.receipt_long_outlined,
                      label: 'Orders',
                      onTap: () =>
                          ref.read(bottomNavIndexProvider.notifier).state = 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-screen chrome for pushed routes (e.g. QR camera). Tabs use [AppShellScreen] instead.
class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.extendBodyBehindAppBar = false,
    this.backgroundColor,
    this.floatingActionButton,
    this.showBottomNavigationBar = false,
    this.title,
    this.leading,
    this.actions,
  });

  final Widget body;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final bool showBottomNavigationBar;

  /// When set, overrides the title derived from QR scan state.
  final String? title;

  final Widget? leading;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrState = ref.watch(qrScanControllerProvider);
    final resolvedTitle =
        title ??
        (qrState.qrCode != null
            ? 'Table ${qrState.qrCode?.split('/').last}'
            : 'Welcome to Ipot');

    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final resolvedLeading =
        leading ??
        (canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.neutral),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null);

    final resolvedActions =
        actions ??
        [
          IconButton(
            tooltip: 'Info',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Info coming soon')));
            },
            icon: const Icon(Icons.info_outline, color: AppColors.neutral),
          ),
        ];

    return Scaffold(
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: backgroundColor,
      appBar: GlobalGlassAppBar(
        title: resolvedTitle,
        leading: resolvedLeading,
        actions: resolvedActions,
      ),
      body: SafeArea(top: !extendBodyBehindAppBar, bottom: false, child: body),
      bottomNavigationBar: showBottomNavigationBar
          ? const AppBottomNavigationBar()
          : null,
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.primary : const Color(0xFF55423D);
    final bg = selected
        ? AppColors.primary.withValues(alpha: 0.10)
        : Colors.transparent;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Align(
            alignment: Alignment.center,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: fg, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      fontSize: 12,
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
