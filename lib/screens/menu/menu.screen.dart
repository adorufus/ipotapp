import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ipotapp/components/app_button.dart';
import 'package:ipotapp/components/menu_item_card.dart';
import 'package:ipotapp/models/cart.model.dart';
import 'package:ipotapp/models/menu_response.model.dart';
import 'package:ipotapp/screens/menu/providers/menu.provider.dart';
import 'package:ipotapp/state/providers.dart';
import 'package:ipotapp/utils/color_utils.dart';

import 'menu_qr_scan.screen.dart';
import 'providers/qr_scan.provider.dart';

/// Tab 0 content:
/// - if QR not scanned, show scan prompt
/// - else show Menu UI (HTML-matched layout)
class MenuOrQrTab extends ConsumerWidget {
  const MenuOrQrTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrState = ref.watch(qrScanControllerProvider);
    if (qrState.qrCode == null) return const QrScanTab();
    return const MenuTab();
  }
}

class MenuTab extends ConsumerStatefulWidget {
  const MenuTab({super.key});

  @override
  ConsumerState<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends ConsumerState<MenuTab> {
  late final TextEditingController _searchController;
  String _query = '';
  int? _selectedCategoryId;

  Future<void> _refreshMenu() async {
    final refreshed = ref.refresh(menuResponseProvider.future);
    await refreshed;
  }

  Future<void> _handleAddToCart(MenuItem item) async {
    if (item.customizationGroups.isEmpty) {
      ref.read(cartControllerProvider.notifier).addMenuItem(item);
      return;
    }

    final selectedOptions = await showModalBottomSheet<List<SelectedOption>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CustomizeSheet(item: item),
    );

    if (!mounted || selectedOptions == null) return;
    ref
        .read(cartControllerProvider.notifier)
        .addMenuItem(item, selectedOptions: selectedOptions);
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      final v = _searchController.text;
      if (v == _query) return;
      setState(() => _query = v);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// View Cart sits in a [Stack] over the menu so it never fights [Expanded] for
  /// height (avoids overflows) and stays above the scroll edge.
  Widget _withViewCartOverlay(
    BuildContext context, {
    required int navIndex,
    required Widget body,
  }) {
    if (navIndex != 0) return body;

    final bottomGap = 12.0 + MediaQuery.viewPaddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: body),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: bottomGap,
          child: AppButton(
            label: 'View Cart',
            leading: const Icon(Icons.shopping_basket_outlined),
            trailing: Consumer(
              builder: (context, ref, _) {
                final count = ref.watch(cartItemCountProvider);
                final totalCents = ref.watch(cartTotalCentsProvider);
                final total = (totalCents / 100).toStringAsFixed(2);
                return Text('$count items • \$$total');
              },
            ),
            height: 56,
            shape: const StadiumBorder(),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
            onPressed: () {
              ref.read(bottomNavIndexProvider.notifier).state = 1;
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncMenu = ref.watch(menuResponseProvider);
    final idx = ref.watch(bottomNavIndexProvider);

    final viewPad = MediaQuery.viewPaddingOf(context).bottom;
    const kViewCartSlot = 56.0 + 16.0 + 20.0;
    final listBottomPadding =
        24.0 + viewPad + (idx == 0 ? kViewCartSlot : 16.0);

    return Padding(
      padding: EdgeInsets.only(top: 30.h),
      child: Column(
        children: [
          Expanded(
            child: _withViewCartOverlay(
              context,
              navIndex: idx,
              body: asyncMenu.when(
                data: (menu) {
                  final categories = [...menu.categories]
                    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                  final selectedCategoryId = _selectedCategoryId ??
                      (categories.isNotEmpty ? categories.first.id : null);

                  final items = menu.items.where((it) {
                    final matchesCategory = selectedCategoryId == null
                        ? true
                        : it.categoryId == selectedCategoryId;
                    final q = _query.trim().toLowerCase();
                    final matchesQuery = q.isEmpty
                        ? true
                        : it.name.toLowerCase().contains(q) ||
                            it.description.toLowerCase().contains(q);
                    return matchesCategory && matchesQuery;
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: _refreshMenu,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.fromLTRB(20, 80, 20, listBottomPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SearchBar(controller: _searchController),
                          const SizedBox(height: 20),
                          _CategoryTabs(
                            categories: categories,
                            selectedId: selectedCategoryId,
                            onSelected: (id) =>
                                setState(() => _selectedCategoryId = id),
                          ),
                          const SizedBox(height: 20),
                          ...items.map(
                            (it) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: MenuItemCard(
                                item: it,
                                onAdd: () => _handleAddToCart(it),
                              ),
                            ),
                          ),
                          if (items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Text(
                                'No items found.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: AppColors.mutedOnLight.withValues(
                                        alpha: 0.75,
                                      ),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const _MenuLoadingBody(),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to load menu.\n$e',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.neutral),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuLoadingBody extends StatelessWidget {
  const _MenuLoadingBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: 'Loading menu',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 20),
            Text(
              'Loading menu…',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.mutedOnLight,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Search menu',
      hint: 'Search for your favorite flavors',
      textField: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFF89726C)),
          hintText: 'Search for your favorite flavors...',
          hintStyle: const TextStyle(color: AppColors.hintOnLight),
          filled: true,
          fillColor: const Color(0xFFFBF2EE),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.10),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.40),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<MenuCategory> categories;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = categories[i];
          final selected = c.id == selectedId;
          return Semantics(
            button: true,
            selected: selected,
            label: c.name,
            excludeSemantics: true,
            child: InkWell(
              onTap: () => onSelected(c.id),
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color:
                        selected ? Colors.transparent : const Color(0xFFDCC1B9),
                  ),
                ),
                child: Center(
                  child: Text(
                    c.name,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              selected ? Colors.white : AppColors.mutedOnLight,
                        ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CustomizeSheet extends StatefulWidget {
  const _CustomizeSheet({required this.item});

  final MenuItem item;

  @override
  State<_CustomizeSheet> createState() => _CustomizeSheetState();
}

class _CustomizeSheetState extends State<_CustomizeSheet> {
  final Map<int, Map<int, int>> _qtyByGroupOption = {};

  @override
  void initState() {
    super.initState();
    for (final g in widget.item.customizationGroups) {
      _qtyByGroupOption[g.id] = <int, int>{};
      if (g.required && g.maxSelections == 1 && g.options.isNotEmpty) {
        // Preselect the first option for required single-select groups.
        _qtyByGroupOption[g.id]![g.options.first.id] = 1;
      }
    }
  }

  int _selectedCount(CustomizationGroup g) {
    return (_qtyByGroupOption[g.id]?.values.where((q) => q > 0).length) ?? 0;
  }

  bool get _isValid {
    for (final g in widget.item.customizationGroups) {
      final count = _selectedCount(g);
      if (g.required && count == 0) return false;
      if (g.maxSelections > 0 && count > g.maxSelections) return false;
    }
    return true;
  }

  List<SelectedOption> _buildSelectedOptions() {
    final out = <SelectedOption>[];
    for (final g in widget.item.customizationGroups) {
      final m = _qtyByGroupOption[g.id];
      if (m == null) continue;
      for (final e in m.entries) {
        if (e.value <= 0) continue;
        out.add(SelectedOption(optionId: e.key, quantity: e.value));
      }
    }
    out.sort((a, b) => a.optionId.compareTo(b.optionId));
    return out;
  }

  void _toggleOption(CustomizationGroup g, CustomizationOption o) {
    final groupMap = _qtyByGroupOption[g.id]!;
    final current = groupMap[o.id] ?? 0;
    final selected = current > 0;

    if (selected) {
      groupMap.remove(o.id);
      setState(() {});
      return;
    }

    if (g.maxSelections == 1) {
      groupMap
        ..clear()
        ..[o.id] = 1;
      setState(() {});
      return;
    }

    final count = _selectedCount(g);
    if (g.maxSelections > 0 && count >= g.maxSelections) return;
    groupMap[o.id] = 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Customize',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                item.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mutedOnLight.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: item.customizationGroups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, i) {
                    final g = item.customizationGroups[i];
                    final groupMap = _qtyByGroupOption[g.id]!;

                    final subtitleParts = <String>[];
                    if (g.required) subtitleParts.add('Required');
                    if (g.maxSelections > 0) {
                      subtitleParts.add('Choose up to ${g.maxSelections}');
                    }
                    final subtitle = subtitleParts.join(' • ');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                g.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.neutral,
                                ),
                              ),
                            ),
                            Text(
                              '${_selectedCount(g)}/${g.maxSelections == 0 ? '∞' : g.maxSelections}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.mutedOnLight.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        ...g.options.map((o) {
                          final selected = (groupMap[o.id] ?? 0) > 0;
                          final delta = o.priceModifierCents == 0
                              ? null
                              : (o.priceModifierCents / 100).toStringAsFixed(2);

                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            onTap: () => _toggleOption(g, o),
                            leading: g.maxSelections == 1
                                ? Radio<bool>(
                                    value: true,
                                    groupValue: selected ? true : null,
                                    onChanged: (_) => _toggleOption(g, o),
                                  )
                                : Checkbox(
                                    value: selected,
                                    onChanged: (_) => _toggleOption(g, o),
                                  ),
                            title: Text(
                              o.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral,
                              ),
                            ),
                            trailing: delta == null
                                ? null
                                : Text(
                                    '+\$$delta',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Add to cart',
                height: 56,
                shape: const StadiumBorder(),
                onPressed: _isValid
                    ? () => Navigator.of(context).pop(_buildSelectedOptions())
                    : null,
              ),
              const SizedBox(height: 8),
              AppButton(
                label: 'Cancel',
                height: 52,
                shape: const StadiumBorder(),
                variant: AppButtonVariant.outlined,
                onPressed: () => Navigator.of(context).pop(null),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
