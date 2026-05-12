import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ipotapp/components/app_button.dart';
import 'package:ipotapp/models/api_error.model.dart';
import 'package:ipotapp/models/cart.model.dart';
import 'package:ipotapp/models/menu_response.model.dart';
import 'package:ipotapp/models/order.model.dart';
import 'package:ipotapp/screens/menu/providers/menu.provider.dart';
import 'package:ipotapp/state/providers.dart';
import 'package:ipotapp/utils/color_utils.dart';

/// Cart tab body (used inside [AppShellScreen] [IndexedStack]).
class CartTab extends ConsumerWidget {
  const CartTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final checkout = ref.watch(checkoutControllerProvider);
    final asyncMenu = ref.watch(menuResponseProvider);

    final itemsById = asyncMenu.maybeWhen(
      data: (menu) => {for (final it in menu.items) it.id: it},
      orElse: () => const <int, dynamic>{},
    );
    final optionById = asyncMenu.maybeWhen(
      data: (menu) {
        final out = <int, CustomizationOption>{};
        for (final it in menu.items) {
          for (final g in it.customizationGroups) {
            for (final o in g.options) {
              out[o.id] = o;
            }
          }
        }
        return out;
      },
      orElse: () => const <int, CustomizationOption>{},
    );

    final lines = cart.linesById.values.toList()
      ..sort((a, b) => a.lineId.compareTo(b.lineId));

    if (lines.isEmpty) {
      return const Center(
        child: Text(
          'Your cart is empty.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            itemCount: lines.length,
            separatorBuilder: (context, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final line = lines[index];
              final item = itemsById[line.menuItemId] as MenuItem?;
              final name = item?.name ?? 'Item #${line.menuItemId}';
              final baseCents = item?.priceCents ?? 0;
              var unitCents = baseCents;
              for (final sel in line.selectedOptions) {
                final opt = optionById[sel.optionId];
                if (opt == null) continue;
                unitCents += opt.priceModifierCents * sel.quantity;
              }
              final lineTotal = (unitCents * line.quantity) / 100;

              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral,
                              ),
                            ),
                            if (line.selectedOptions.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _CustomizationSummary(
                                selected: line.selectedOptions,
                                optionById: optionById,
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              '\$${lineTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(
                                  0xFF55423D,
                                ).withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () => ref
                                .read(cartControllerProvider.notifier)
                                .decrement(line.lineId),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            '${line.quantity}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral,
                            ),
                          ),
                          IconButton(
                            onPressed: () => ref
                                .read(cartControllerProvider.notifier)
                                .increment(line.lineId),
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () =>
                          ref.read(cartControllerProvider.notifier).clear(),
                      child: const Text('Clear cart'),
                    ),
                    Consumer(
                      builder: (context, ref, _) {
                        final totalCents = ref.watch(cartTotalCentsProvider);
                        final total = (totalCents / 100).toStringAsFixed(2);
                        return Text(
                          'Total: \$$total',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neutral,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppButton(
                  height: 56,
                  shape: const StadiumBorder(),
                  label: checkout.submitting ? 'Placing order…' : 'Checkout',
                  onPressed: checkout.submitting
                      ? null
                      : () => _submitOrder(context, ref),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _submitOrder(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final menu = ref.read(menuResponseProvider).valueOrNull;
  final cart = ref.read(cartControllerProvider);

  if (menu == null) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Connect to a table and wait for the menu to load.'),
      ),
    );
    return;
  }
  if (cart.linesById.isEmpty) return;

  final items = cart.linesById.values
      .map(
        (line) => OrderRequestItem(
          menuItemId: line.menuItemId,
          quantity: line.quantity,
          customizations: line.selectedOptions
              .map(
                (o) => OrderRequestCustomization(
                  optionId: o.optionId,
                  quantity: o.quantity,
                ),
              )
              .toList(),
        ),
      )
      .toList();

  final request = OrderRequest(
    tableId: menu.restaurant.tableId,
    items: items,
    customerNote: cart.customerNote,
  );

  try {
    final res = await ref
        .read(checkoutControllerProvider.notifier)
        .placeOrder(request: request, menuSnapshot: menu);
    if (!context.mounted) return;
    ref.read(cartControllerProvider.notifier).clear();
    final isQueued = res.order.id.startsWith('local_');
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isQueued
              ? 'Order saved on this device (${res.order.id}). It will send when you are back online.'
              : 'Order ${res.order.id} placed',
        ),
      ),
    );
  } on ApiError catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  } catch (e) {
    if (!context.mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
  }
}

class _CustomizationSummary extends StatelessWidget {
  const _CustomizationSummary({
    required this.selected,
    required this.optionById,
  });

  final List<SelectedOption> selected;
  final Map<int, CustomizationOption> optionById;

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    for (final sel in [
      ...selected,
    ]..sort((a, b) => a.optionId.compareTo(b.optionId))) {
      final opt = optionById[sel.optionId];
      final name = opt?.name ?? 'Option #${sel.optionId}';
      parts.add(sel.quantity == 1 ? name : '$name x${sel.quantity}');
    }

    return Text(
      parts.join(' • '),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF55423D).withValues(alpha: 0.75),
      ),
    );
  }
}
